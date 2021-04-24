//
//  EditImageVC.swift
//  Document Scanner
//
//  Created by Sandesh on 08/03/21.
//

import UIKit
import WeScan
import SnapKit

protocol EditImageVCDelegate: class {
    func cancelImageEditing(_controller: EditImageVC)
    func finishedImageEditing(_ finalImage: UIImage, controller: EditImageVC)
}

protocol EditImageVCDataSource: class {
    var originalImage: UIImage? { get }
    var isNewDocument: Bool { get }
}

class EditImageVC: DocumentScannerViewController {
    
    // MARK: - ViewController specific enums
    enum ImageAdjustmentOption {
        case contrast, brightness, saturation
    }
    
    // MARK: - ImageEditorControls
    private lazy var imageEditControls: ImageEditorControls = {
        let imageEditControls = ImageEditorControls()
        imageEditControls.onTransformTap = didTapTransformImage
        imageEditControls.onAdjustTap = didTapAdjustImage
        imageEditControls.onColorTap = didTapColorImage
        imageEditControls.onOriginalTap = didTapOriginalImage
        imageEditControls.translatesAutoresizingMaskIntoConstraints = false
        return imageEditControls
    }()
    
    // MARK: - TransformImageControls
    private lazy var transformImageControls: TransformImageControls = {
        let imageTransformView = TransformImageControls()
        imageTransformView.onRotationTap = didTapRotateImage
        imageTransformView.onCropTap = didTapCropImageOption
        imageTransformView.onMirrorTap = didTapMirrorImage
        return imageTransformView
    }()
    
    // MARK: - ImageAdjustControls
    private lazy var imageAdjustControls: ImageAdjustControls = {
        let imageAdjustControls = ImageAdjustControls()
        imageAdjustControls.onBrightnessSliderValueChanged = didChangeBrightness
        imageAdjustControls.onContrastSliderValueChanged = didChangeContrast
        imageAdjustControls.onSaturationSliderValueChanged = didChangeSaturation
        return imageAdjustControls
    }()
    
    // MARK: - ImageColorControls
    lazy var imageColorControls: ImageColorControls = {
        let imageColorControls = ImageColorControls()
        imageColorControls.onOriginalTap = didTapOriginalImage
        imageColorControls.onGrayScaleTap = didTapGrayScaleImage
        imageColorControls.onBlackAndWhiteTap = didTapBlackAndWhitImage
        return imageColorControls
    }()
    
    // MARK: - Views
    private var _editVC: EditImageViewController!
    private var imageView: UIImageView?
    private var currentEditingControlView: UIView?
    
    
    // MARK: - Variables
    
    //set externally
    var imageToEdit: UIImage!
    weak var delegate: EditImageVCDelegate?
    weak var dateSource: EditImageVCDataSource?
    
    //temporary images
    private var editedImagesBufferStack = [UIImage]()
    private var temporaryImageForColorAdjustment: UIImage?
    //last slide values for filters defaults 0
    
    // MARK:- IBoutlets
    @IBOutlet private weak var imageEditorContainerView: UIView!
    @IBOutlet private weak var editControllerContainer: UIView!
    @IBOutlet private weak var footerView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        _setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func _setupViews() {
        _setupImageEditorView()
        footerView.addSubview(imageEditControls)
        imageEditControls.snp.makeConstraints { make in make.left.right.top.bottom.equalToSuperview() }
        footerView.hero.id = Constants.HeroIdentifiers.footerIdentifier
    }
    
    //initial setup
    private func _setupImageEditorView() {
        imageEditorContainerView.subviews.forEach { $0.removeFromSuperview() }
        guard let dataSource = dateSource, let imageToEdit = imageToEdit else {
            fatalError("ERROR: Datasource or imageToEdit is not set is not set is not set")
        }
        
        imageEditControls.editOriginalImageOptionIsHidden = dataSource.isNewDocument
        _presentImageViewInImageEditorView(for: imageToEdit)
    }
    
    private func _presentWeScanImageControllerInImageEditorView(for image: UIImage) {
        if _editVC == nil {
            _editVC = WeScan.EditImageViewController(image: image, quad: nil,rotateImage: false, strokeColor: UIColor.primary.cgColor)
            _editVC.view.backgroundColor = .backgroundColor
        }
        _editVC.view.frame = imageEditorContainerView.bounds
        _editVC.willMove(toParent: self)
        imageEditorContainerView.addSubview(_editVC.view)
        self.addChild(_editVC)
        _editVC.didMove(toParent: self)
        _editVC.delegate = self
    }
    
    private func _presentImageViewInImageEditorView(for image: UIImage) {
        if imageView == nil {
            imageView = UIImageView()
        }
        imageView!.image = image
        imageView!.backgroundColor = .backgroundColor
        imageView!.frame = imageEditorContainerView.bounds
        imageEditorContainerView.addSubview(imageView!)
        imageView!.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView!.leftAnchor.constraint(equalTo: imageEditorContainerView.leftAnchor),
            imageView!.topAnchor.constraint(equalTo: imageEditorContainerView.topAnchor),
            imageView!.rightAnchor.constraint(equalTo: imageEditorContainerView.rightAnchor),
            imageView!.bottomAnchor.constraint(equalTo: imageEditorContainerView.bottomAnchor)
        ])
        
        imageView!.contentMode = .scaleAspectFit
        imageEditorContainerView.bringSubviewToFront(imageView!)
        _editVC?.view.removeFromSuperview()
    }
    
    private func _adjustImage(_ option: ImageAdjustmentOption, intensity: Float) {
        guard let imageToFilter =  temporaryImageForColorAdjustment else {
            fatalError("ERROR: temporary image for color adjust is not set")
        }
        
        var editedImage: UIImage?
        switch option {
        case .brightness:
            //editedImage = FilterHelper.shared.adjustColor(.brightness, of: imageToFilter, intensity: intensity)
            editedImage = GPUImageHelper.shared.adjustBrightness(imageToFilter, intensity: intensity)
        case .contrast:
            //editedImage = FilterHelper.shared.adjustColor(.contrast, of: imageToFilter, intensity: intensity)
            editedImage = GPUImageHelper.shared.adjustContrast(imageToFilter, intensity: intensity)
            
        case .saturation:
            //editedImage = FilterHelper.shared.adjustColor(.saturation, of: imageToFilter, intensity: intensity)
            editedImage = GPUImageHelper.shared.adjustSaturation(imageToFilter, intensity: intensity)
        }
        guard let newImage = editedImage else { return }
        imageView?.image = newImage
        
    }
    
    
    @IBAction private func didTapDone(_ sender: UIButton) {
        delegate?.finishedImageEditing(editedImagesBufferStack.last ?? imageToEdit, controller: self)
    }
    
    @IBAction private func didTapUndo(_ sender: UIButton) {
        
    }
    
}

// MARK: - Image Edit Options
extension EditImageVC {
    
    private func presentImageEditing(control: UIView) {
        UIView.animate(withDuration: 0.2) {
            if self.currentEditingControlView is ImageAdjustControls {
                if self.imageView?.image != nil { self.editedImagesBufferStack.append((self.imageView?.image)!) }
                self.editControllerContainer.isHidden = false
                self.currentEditingControlView?.frame.origin.y = self.editControllerContainer.frame.maxY
            } else {
                self.currentEditingControlView?.frame.origin.x = -self.editControllerContainer.frame.width
            }
            if control is ImageAdjustControls {
                self.editControllerContainer.isHidden = true
                control.frame.origin.y = self.footerView.frame.minY - 135
            } else {
                control.frame.origin.x = 0
            }
        } completion: { completed in
            self.currentEditingControlView?.removeFromSuperview()
            self.currentEditingControlView = control
        }
    }
    
    private func didTapTransformImage(_ sender: FooterButton) {
        if currentEditingControlView === transformImageControls { return }
        editControllerContainer.addSubview(transformImageControls)
        transformImageControls.frame = editControllerContainer.bounds
        transformImageControls.frame.origin.x = editControllerContainer.frame.maxX
        presentImageEditing(control: transformImageControls)
    }
    
    private func didTapAdjustImage(_ sender: FooterButton) {
        if currentEditingControlView === imageAdjustControls { return }
        temporaryImageForColorAdjustment = imageView?.image
        view.insertSubview(imageAdjustControls, belowSubview: footerView)
        let imageAdjustControlsFrame = CGRect(x: 0,
                                              y: footerView.frame.minY,
                                              width: view.frame.width,
                                              height: 135)
        imageAdjustControls.frame = imageAdjustControlsFrame
        presentImageEditing(control: imageAdjustControls)
    }
    
    private func didTapColorImage(_ sender: FooterButton) {
        if currentEditingControlView === imageColorControls { return }
        editControllerContainer.addSubview(imageColorControls)
        imageColorControls.frame = editControllerContainer.bounds
        imageColorControls.frame.origin.x = editControllerContainer.frame.maxX
        presentImageEditing(control: imageColorControls)
    }
    
    private func didTapEditOriginalImage(_ sender: FooterButton) {
        imageView?.image = dateSource?.originalImage
    }
}

// MARK: - Image Transform Option
extension EditImageVC {
    private func didTapRotateImage(_ sender: FooterButton) {
        print("Rotate Image")
    }
    
    private func didTapCropImageOption(_ sender: FooterButton) {
        guard let imageToCrop = imageView?.image else {
            fatalError("ERROR: no image available for cropping")
        }
       _presentWeScanImageControllerInImageEditorView(for: imageToCrop)
    }
    
    private func didTapMirrorImage(_ sender: FooterButton) {
        print("Mirror Image")
    }
}

// MARK: - Image Color Option
extension EditImageVC {
    private func didTapOriginalImage(_ sender: FooterButton) {
        print("Original Image")
    }
    
    private func didTapGrayScaleImage(_ sender: FooterButton) {
        let imageToFilter = editedImagesBufferStack.last
        if imageToFilter == nil {
            guard let imageToFilter =  imageToEdit else {
                fatalError("ERROR: There is no image to edit")
            }
            if let grayScaledImage = FilterHelper.shared.convertToGrayScale(imageToFilter) {
                imageView?.image = grayScaledImage
                editedImagesBufferStack.append(grayScaledImage)
            }
        }
    }
    
    private func didTapBlackAndWhitImage(_ sender: FooterButton) {
        let imageToFilter = editedImagesBufferStack.last
        if imageToFilter == nil {
            guard let imageToFilter = imageToEdit else {
                fatalError("ERROR: There is no image to edit")
            }
            if let grayScaledImage = FilterHelper.shared.convertToBlackAndWhit(imageToFilter) {
                imageView?.image = grayScaledImage
                editedImagesBufferStack.append(grayScaledImage)
            }
        }
    }
}

// MARK: - Image Adjust Controls
extension EditImageVC {
    private func didChangeBrightness(_ value: Float, sender: UISlider) {
        _adjustImage(.brightness, intensity: value)
    }
    
    private func didChangeContrast(_ value: Float, sender: UISlider) {
        _adjustImage(.contrast, intensity: value)
    }
    
    private func didChangeSaturation(_ value: Float, sender: UISlider) {
        _adjustImage(.saturation, intensity: value)
    }
}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
       
    }
}
