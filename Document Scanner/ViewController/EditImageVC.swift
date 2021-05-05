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
    func finishedImageEditing(_ finalImage: UIImage, controller: EditImageVC, isRotated: Bool)
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
    
    // MARK: - Crop Footer Controls
    private lazy var cropFooterControls: CropFooterControls = {
        let cropFooterControls = CropFooterControls()
        cropFooterControls.onCropTap = didTapCrop
        cropFooterControls.onCancelTap = didTapCancel
        return cropFooterControls
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
    private var isRotated = false
    private var setFooterControlsHidden = false {
        didSet {
            imageEditControls.isHidden = setFooterControlsHidden
        }
    }
    
    
    // MARK: - Variables
    
    //set externally
    var imageToEdit: UIImage!
    weak var delegate: EditImageVCDelegate?
    weak var dataSource: EditImageVCDataSource?
    
    //temporary images
    private var editedImagesBufferStack = [UIImage]()
    private var temporaryImageForColorAdjustment: UIImage?
    //last slide values for filters defaults 0
    
    // MARK:- IBoutlets
    
    
    @IBOutlet private weak var undoButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var imageEditorContainerView: UIView!
    @IBOutlet private weak var editControllerContainer: UIView!
    @IBOutlet private weak var footerContainerView: UIView!
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
        guard let dataSource = dataSource, let imageToEdit = imageToEdit else {
            fatalError("ERROR: Datasource or imageToEditis not set")
        }
        
        imageEditControls.editOriginalImageOptionIsHidden = dataSource.isNewDocument
        _presentImageViewInImageEditorView(for: imageToEdit)
    }
    
    private func _presentWeScanImageControllerInImageEditorView(for image: UIImage) {
        if _editVC == nil {
            _editVC = WeScan.EditImageViewController(image: image, quad: nil,rotateImage: false, strokeColor: UIColor.primary.cgColor)
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
            editedImage = GPUImageHelper.shared.adjustBrightness(imageToFilter, intensity: intensity)
        case .contrast:
            editedImage = GPUImageHelper.shared.adjustContrast(imageToFilter, intensity: intensity)
            
        case .saturation:
            editedImage = GPUImageHelper.shared.adjustSaturation(imageToFilter, intensity: intensity)
        }
        guard let newImage = editedImage else { return }
        imageView?.image = newImage
        
    }
    
    
    @IBAction private func didTapDone(_ sender: UIButton) {
        editedImagesBufferStack.append(imageView?.image ?? imageToEdit)
        delegate?.finishedImageEditing(editedImagesBufferStack.last!, controller: self, isRotated: isRotated)
    }
    
    @IBAction private func didTapUndo(_ sender: UIButton) {
        editedImagesBufferStack.popLast()
        imageView?.image = editedImagesBufferStack.last ?? imageToEdit
    }
    
    @IBAction private func didTapBack(_ sender: UIButton) {
        delegate?.cancelImageEditing(_controller: self)
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
                control.frame.origin.y = self.footerContainerView.frame.minY - 135
            } else {
                control.frame.origin.x = 0
            }
        } completion: { completed in
            self.currentEditingControlView?.removeFromSuperview()
            self.currentEditingControlView = control
        }
    }
    
    private func didTapTransformImage(_ sender: FooterButton) {
        guard let dataSource = dataSource else {
            fatalError("ERROR: Datasource is not set")
        }
        if currentEditingControlView === transformImageControls { return }
        transformImageControls.cropImageOptionIsHidden = dataSource.isNewDocument
        editControllerContainer.addSubview(transformImageControls)
        transformImageControls.frame = editControllerContainer.bounds
        transformImageControls.frame.origin.x = editControllerContainer.frame.maxX
        presentImageEditing(control: transformImageControls)
    }
    
    private func didTapAdjustImage(_ sender: FooterButton) {
        if currentEditingControlView === imageAdjustControls { return }
        temporaryImageForColorAdjustment = imageView?.image
        view.insertSubview(imageAdjustControls, belowSubview: footerContainerView)
        let imageAdjustControlsFrame = CGRect(x: 0,
                                              y: footerContainerView.frame.minY,
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
        imageView?.image = dataSource?.originalImage
    }
}

// MARK: - Image Transform Option
extension EditImageVC {
    private func didTapRotateImage(_ sender: FooterButton) {
        guard let imageToRotate = imageView?.image else {
            fatalError("ERROR: no image available for cropping")
        }
        isRotated = true
        imageView?.image = imageToRotate.rotateRight()
    }
    
    private func didTapCropImageOption(_ sender: FooterButton) {
        guard let imageToCrop = imageView?.image else {
            fatalError("ERROR: no image available for cropping")
        }
       _presentWeScanImageControllerInImageEditorView(for: imageToCrop)
        footerView.addSubview(cropFooterControls)
        cropFooterControls.frame = footerView.bounds
        setFooterControlsHidden = true
        editControllerContainer.isHidden = true
        undoButton.isHidden = true
        doneButton.isHidden = true
    }
    
    private func didTapMirrorImage(_ sender: FooterButton) {
        guard let imageToMirror = imageView?.image else {
            fatalError("ERROR: no image available for cropping")
        }
        if let mirroredImage = imageToMirror.mirror() {
            imageView?.image = mirroredImage
            editedImagesBufferStack.append(mirroredImage)
        }
    }
    
    private func didTapCrop(_ sender: UIButton) {
        _editVC.cropImage()
        editControllerContainer.isHidden = false
        undoButton.isHidden = false
        doneButton.isHidden = false
    }
    
    private func didTapCancel(_ sender: UIButton) {
        let lastAvailableImage = editedImagesBufferStack.last ?? imageToEdit
        guard let image = lastAvailableImage else {
            fatalError("ERROR: No image to present")
        }
        _presentImageViewInImageEditorView(for: image)
        cropFooterControls.removeFromSuperview()
        setFooterControlsHidden = false
        editControllerContainer.isHidden = false
        undoButton.isHidden = false
        doneButton.isHidden = false
    }
}

// MARK: - Image Color Option
extension EditImageVC {
    private func didTapOriginalImage(_ sender: FooterButton) {
        guard let imageToFilter =  imageToEdit else {
            fatalError("ERROR: There is no image to edit")
        }
        imageView?.image = imageToFilter
        editedImagesBufferStack.append(imageToFilter)
    }
    
    private func didTapGrayScaleImage(_ sender: FooterButton) {
        guard let imageToFilter =  imageToEdit else {
            fatalError("ERROR: There is no image to edit")
        }
        if let grayScaledImage = GPUImageHelper.shared.convertToGrayScale(imageToFilter) {
            imageView?.image = grayScaledImage
            editedImagesBufferStack.append(grayScaledImage)
        }
    }
    
    private func didTapBlackAndWhitImage(_ sender: FooterButton) {
        guard let imageToFilter = imageToEdit else {
            fatalError("ERROR: There is no image to edit")
        }
        
        if let grayScaledImage =  GPUImageHelper.shared.convertToBlackAndWhite(imageToFilter) {
            imageView?.image = grayScaledImage
            editedImagesBufferStack.append(grayScaledImage)
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
        editedImagesBufferStack.append(image)
        _presentImageViewInImageEditorView(for: image)
    }
}
