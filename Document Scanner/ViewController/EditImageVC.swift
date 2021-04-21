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
    func rescanImage(_ controller: EditImageVC)
    func finishedImageEditing(_ finalImage: [UIImage], originalImage: [UIImage],documentName: String, controller: EditImageVC)
    func finishedEditing(_ pages: [Page], controller: EditImageVC)
}

protocol EditImageVCDataSource: class {
    var imageSource: EditDocumentCoordinator.ImageSource? { get }
    var isNewDocument: Bool { get }
}

class EditImageVC: DocumentScannerViewController {
    
    // MARK: - ViewController specific enums
    enum ImageEditingMode {
        case basic
        case correction
        case filtering
    }

    enum ImageFilters {
        case black_and_white
        case brightness
        case contrast
    }
    
    // MARK: - ImageEditorControls
    private lazy var imageEditControls: ImageEditorControls = {
        let imageEditControls = ImageEditorControls()
        imageEditControls.onTransformTap = didTapTransformImage
        imageEditControls.onAdjustTap = didTapAdjustImage
        imageEditControls.onColorTap = didTapColorImage
        imageEditControls.onOriginalTap = didTapOriginalImage
        imageEditControls.onUndoTap = didTapUndoImage
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
    var imageEditingMode: ImageEditingMode? {
        didSet {
            if _editVC != nil || imageView != nil {
            }
        }
    }
    
    //set externally
    var quad: Quadrilateral?
    var imagesToEdit: [UIImage]?
    var pages: [Page]?
    weak var delegate: EditImageVCDelegate?
    weak var dateSource: EditImageVCDataSource?
    
    //temporary images
    private var _croppedImages = [UIImage]() //cropped image for filtering
    private var _editedImagesBuffer = [[UIImage]]()
    private var _currentFilter: ImageFilters?
    private var _currentIndexOfImage = 0
    //last slide values for filters defaults 0
    
    // MARK:- IBoutlets
    @IBOutlet private weak var imageEditorView: UIView!
    @IBOutlet private weak var editControllerContainer: UIView!
    @IBOutlet private weak var footerView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        _croppedImages = []
        _editedImagesBuffer = []
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
        imageEditorView.backgroundColor = .backgroundColor
        imageEditorView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let dataSource = dateSource else {
            fatalError("ERROR: Datasource is not set is not set")
        }
    
        switch dataSource.isNewDocument {
        case true:
            guard let imageToEdit = imagesToEdit?.first else {
                fatalError("ERROR: Images are not set for editing")
            }
            _presentWeScanImageControllerInImageEditorView(for: imageToEdit)
        case false:
            guard  let firstPage = pages?.first,
                   let imageToEdit = firstPage.editedImage else {
                fatalError("ERROR: documents pages is not set, or page does't have edited image for editing")
            }
            imagesToEdit = [imageToEdit]
            _presentImageViewInImageEditorView(for: imageToEdit)
        }
    }
    
    private func _presentWeScanImageControllerInImageEditorView(for image: UIImage) {
        if _editVC == nil {
            _editVC = WeScan.EditImageViewController(image: image, quad: quad,rotateImage: false, strokeColor: UIColor.primary.cgColor)
            _editVC.view.backgroundColor = .backgroundColor
        }
        _editVC.view.frame = imageEditorView.bounds
        _editVC.willMove(toParent: self)
        imageEditorView.addSubview(_editVC.view)
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
        _croppedImages = [image]
        imageView!.frame = imageEditorView.bounds
        imageEditorView.addSubview(imageView!)
        imageView!.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView!.leftAnchor.constraint(equalTo: imageEditorView.leftAnchor),
            imageView!.topAnchor.constraint(equalTo: imageEditorView.topAnchor),
            imageView!.rightAnchor.constraint(equalTo: imageEditorView.rightAnchor),
            imageView!.bottomAnchor.constraint(equalTo: imageEditorView.bottomAnchor)
        ])
        
        imageView!.contentMode = .scaleAspectFit
        imageEditorView.bringSubviewToFront(imageView!)
        _editVC?.view.removeFromSuperview()
    }
   
    private func _initiateImageFiltering() {
        
         //1 set cropped image as initial image of edited images buffer
        
        guard _croppedImages.count > 0 else {
            fatalError("ERROR: No cropped image available to edit")
        }
        _editedImagesBuffer = [[_croppedImages[_currentIndexOfImage]]]
        imageEditingMode = .filtering
    }
    
    private func _saveDocument(withName name: String) {
        guard let editingMode = imageEditingMode,
              let originalImages = imagesToEdit else {
            fatalError("ERROR: Image editing mode or Original Images not set")
        }
        
        switch editingMode {
        case .basic:
            delegate?.finishedImageEditing(originalImages,
                                           originalImage: originalImages,
                                           documentName: name,
                                           controller: self)
        case .correction:
            guard _croppedImages.count == originalImages.count else {
                fatalError("ERROR: Cropped Images count does not original images count")
            }
            delegate?.finishedImageEditing(_croppedImages,
                                           originalImage: originalImages,
                                           documentName: name,
                                           controller: self)
            
        case .filtering:
            guard  _editedImagesBuffer.count == originalImages.count, let finalImage = imageView?.image else {
                fatalError("ERROR: Edited Images count does not original images count")
            }
            delegate?.finishedImageEditing([finalImage],
                                           originalImage: originalImages,
                                           documentName: name,
                                           controller: self)
        }
    }
    
    private func _updateDocument() {
        guard let pages = pages else {
            fatalError("ERROR: Pages are not set for editing")
        }
        if let editedImage = imageView?.image {
            if pages[_currentIndexOfImage].saveEditedImage(editedImage) {
                delegate?.finishedEditing(pages, controller: self)
            }
        } else if _croppedImages.count > 0 {
            if pages[_currentIndexOfImage].saveEditedImage(_croppedImages[_currentIndexOfImage]) {
                delegate?.finishedEditing(pages, controller: self)
            }
        } else {
            delegate?.cancelImageEditing(_controller: self)
        }
    }
    
    
    
//    private func _applyFilter(_ intensity: Float) {
//        guard let imageToFilter = _editedImagesBuffer[_currentIndexOfImage].last else {
//            fatalError("ERROR: No image is found for filtering")
//        }
//        print(imageToFilter)
//        var editedImage: UIImage?
//
//        switch _currentFilter {
//        case .black_and_white:
//            editedImage = GPUImageHelper.shared.convertToBlackAndWhite(imageToFilter, intensity: intensity)
//            lastSliderValueForBlackAndWhite = intensity
//        case .brightness:
//            editedImage = GPUImageHelper.shared.adjustBrightness(imageToFilter, intensity: intensity)
//            lastSliderValueForBrightness = intensity
//        case .contrast:
//            editedImage = GPUImageHelper.shared.adjustContrast(imageToFilter, intensity: intensity)
//            lastSliderValueForContrast = intensity
//        case .none:
//            break
//        }
//
//        guard let newImage = editedImage else { return }
//        imageView?.image = newImage
//    }
    
    @IBAction func didTapEditButtonFive(_ sender: Any) {
        guard let dataSource = dateSource else {
            fatalError("ERROR: Datasource is not set")
        }
        
        
        
//        func saveDocument() {
//            let alterView = UIAlertController(title: "Saving Image",
//                                              message: "Enter document name",
//                                              preferredStyle: .alert)
//
//            alterView.addTextField { textField in
//                textField.placeholder = "Documents Name!"
//            }
//
//            alterView.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alterView] _ in
//                guard let textField = alterView?.textFields![0],
//                      let documentName = textField.text,
//                      !documentName.isEmpty else {
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.error)
//                    return
//                }
//                // Force unwrapping because we know it exists.
//                self._saveDocument(withName: documentName)
//            }))
//
//            alterView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
//            present(alterView, animated: true)
//        }
//        dataSource.isNewDocument ? saveDocument() : _updateDocument()
    }
    
   
    func presentAlerte(_ mes: String) {
        let alert = UIAlertController(title: mes, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func didChange(_ sender: UISlider) {
        guard  _currentFilter != nil else {
            fatalError("ERROR: Slide shown without filter selection")
        }
        print("Slider Value:" + " \(sender.value)")
    }
    
}

// MARK: - Image Edit Options
extension EditImageVC {
    
    private func didTapTransformImage(_ sender: FooterButton) {
        if currentEditingControlView === transformImageControls { return }
        editControllerContainer.addSubview(transformImageControls)
        transformImageControls.frame = editControllerContainer.bounds
        transformImageControls.frame.origin.x = editControllerContainer.frame.maxX
        
        UIView.animate(withDuration: 0.2) {
            if self.currentEditingControlView is ImageAdjustControls {
                
            } else {
                self.currentEditingControlView?.frame.origin.x = -self.editControllerContainer.frame.width
            }
            self.transformImageControls.frame.origin.x = 0
        } completion: { completed in
            self.currentEditingControlView?.removeFromSuperview()
            self.currentEditingControlView = self.transformImageControls
        }
    }
    
    private func didTapAdjustImage(_ sender: FooterButton) {
        if currentEditingControlView === imageAdjustControls { return }
        view.addSubview(imageAdjustControls)
        
        let yPosition = footerView.frame.minY - 100
        let imageAdjustControlsFrame = CGRect(x: 0,
                                              y: yPosition,
                                              width: view.frame.width,
                                              height: 100)
        
        imageColorControls.frame = imageAdjustControlsFrame
        imageColorControls.frame.origin.y = footerView.frame.minY
        
        UIView.animate(withDuration: 0.2) {
            self.currentEditingControlView?.frame.origin.y = self.footerView.frame.maxY
            self.imageColorControls.frame.origin.y = yPosition
        } completion: { completed in
            self.currentEditingControlView?.removeFromSuperview()
            self.currentEditingControlView = self.imageAdjustControls
        }
    }
    
    private func didTapColorImage(_ sender: FooterButton) {
        if currentEditingControlView === imageColorControls { return }
        editControllerContainer.addSubview(imageColorControls)
        imageColorControls.frame = editControllerContainer.bounds
        imageColorControls.frame.origin.x = editControllerContainer.frame.maxX
        
        UIView.animate(withDuration: 0.2) {
            self.currentEditingControlView?.frame.origin.x = -self.editControllerContainer.frame.width
            self.imageColorControls.frame.origin.x = 0
        } completion: { completed in
            self.currentEditingControlView?.removeFromSuperview()
            self.currentEditingControlView = self.imageColorControls
        }
    }
    
    private func didTapEditOriginalImage(_ sender: FooterButton) {
        
    }
    
    private func didTapUndoImage(_ sender: FooterButton) {
        
    }
}

// MARK: - Image Transform Option
extension EditImageVC {
    private func didTapRotateImage(_ sender: FooterButton) {
        print("Rotate Image")
    }
    
    private func didTapCropImageOption(_ sender: FooterButton) {
        print("Crop Image")
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
        print("Gray Scale Image")
    }
    
    private func didTapBlackAndWhitImage(_ sender: FooterButton) {
        print("Black And White Image")
    }
}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        imageEditingMode = .correction
        _presentImageViewInImageEditorView(for: image)
    }
}
