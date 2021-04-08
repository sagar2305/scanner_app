//
//  EditImageVC.swift
//  Document Scanner
//
//  Created by Sandesh on 08/03/21.
//

import UIKit
import WeScan

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
    
    enum ImageRotationDirection: CGFloat {
        case left = -1.5708
        case right = 1.5708
    }
    
    enum ImageFilters {
        case black_and_white
        case brightness
        case sharpen
    }
    
    // MARK: - Views
    private var _editVC: EditImageViewController!
    private var imageView: UIImageView?
    
    // MARK: - Constants
    private var _footerViewHightWithoutSlider: CGFloat = 55
    private var _footerViewHightWithSlider: CGFloat = 110
    
    // MARK: - Variables
    var imageEditingMode: ImageEditingMode? {
        didSet {
            if _editVC != nil || imageView != nil {
                _updateViewForEditing()
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
    private var lastSliderValueForBlackAndWhite: Float = 0.0
    private var lastSliderValueForBrightness: Float = 0.0
    private var lastSliderValueForSharpen: Float = 0.0
    
    // MARK:- IBoutlets
    @IBOutlet private weak var imageEditorView: UIView!
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sliderViewContainer: UIView!
    @IBOutlet private weak var slider: UISlider!
    
    //button  left to right in xib
    @IBOutlet private weak var editButtonOne: FooterButton!
    @IBOutlet private weak var editButtonTwo: FooterButton!
    @IBOutlet private weak var editButtonThree: FooterButton!
    @IBOutlet private weak var editButtonFour: FooterButton!
    @IBOutlet private weak var editButtonFive: FooterButton!
    
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
        _updateViewForEditing()
        footerView.hero.id = Constant.HeroIdentifiers.footerIdentifier
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
    
    private func _updateViewForEditing() {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        switch  editingMode {
        case .basic: _setupEditorViewForBasicEditingMode()
        case .correction : _setupEditorViewForCorrectionMode()
        case .filtering : _setupEditorViewForFilteringMode()
        }
    }
    
    private func _setupEditorViewForBasicEditingMode() {
        
        editButtonOne.isHidden = false
        editButtonTwo.isHidden = false
        editButtonThree.isHidden = true
        editButtonFour.isHidden = false
        editButtonFive.isHidden = true
        editButtonOne.setImage(Icons.cancel, for: .normal)
        editButtonOne.setTitle("Cancel", for: .normal)
        if dateSource?.imageSource == .camera {
            editButtonTwo.setImage(Icons.camera, for: .normal)
            editButtonTwo.setTitle("Rescan", for: .normal)
        } else {
            editButtonTwo.setImage(Icons.photoLibrary, for: .normal)
            editButtonTwo.setTitle("Pick Again", for: .normal)
        }
        editButtonFour.setImage(Icons.crop, for: .normal)
        editButtonFour.setTitle("Crop", for: .normal)
        self.sliderViewContainer.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func _setupEditorViewForCorrectionMode() {
        editButtonOne.isHidden = false
        editButtonTwo.isHidden = false
        editButtonThree.isHidden = false
        editButtonFour.isHidden = false
        editButtonFive.isHidden = false
        
        editButtonOne.setImage(Icons.cancel, for: .normal)
        editButtonOne.setTitle("Cancel", for: .normal)
        editButtonTwo.setImage(Icons.reset, for: .normal)
        editButtonTwo.setTitle("Reset", for: .normal)
        editButtonThree.setImage(Icons.filter, for: .normal)
        editButtonThree.setTitle("Filter", for: .normal)
        editButtonFour.setImage(Icons.rotateRight, for: .normal)
        editButtonFour.setTitle("Rotate", for: .normal)
        editButtonFive.setImage(Icons.done, for: .normal)
        editButtonFive.setTitle("Done", for: .normal)
                
        sliderViewContainer.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func _setupEditorViewForFilteringMode() {
    
        editButtonOne.isHidden = false
        editButtonTwo.isHidden = false
        editButtonThree.isHidden = false
        editButtonFour.isHidden = false
        editButtonFive.isHidden = false

        editButtonTwo.setImage(Icons.blackAndWhite, for: .normal)
        editButtonTwo.setTitle("B&W", for: .normal)
        editButtonThree.setImage(Icons.brightness, for: .normal)
        editButtonThree.setTitle("Brightness", for: .normal)
        editButtonFour.setImage(Icons.sharpen, for: .normal)
        editButtonFour.setTitle("Sharpen", for: .normal)
        self.sliderViewContainer.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //rotation of images is available in cropped mode only
    private func _rotateImage(_ direction: ImageRotationDirection) {
        let imageToRotate = _croppedImages[_currentIndexOfImage]
        switch  direction {
        case .left:
            _croppedImages[_currentIndexOfImage] = imageToRotate.rotate(withRotation: direction.rawValue)
        case .right:
            _croppedImages[_currentIndexOfImage] = imageToRotate.rotate(withRotation: direction.rawValue)
        }
        imageView?.image = _croppedImages[_currentIndexOfImage]
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
    
    private func _filterSelected(_ filter: ImageFilters) {
        _editedImagesBuffer[_currentIndexOfImage].append((imageView?.image)!)
        _currentFilter = filter
       
        self.sliderViewContainer.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        switch filter {
        case .black_and_white:
            slider.minimumValue = 0.0
            slider.maximumValue = 1.0
            slider.setValue(lastSliderValueForBlackAndWhite, animated: true)
        case .brightness:
            slider.minimumValue = -1.0
            slider.maximumValue = 1.0
            slider.setValue(lastSliderValueForBrightness, animated: true)
        case .sharpen:
            slider.minimumValue = -4.0
            slider.maximumValue = 4.0
            slider.setValue(lastSliderValueForSharpen, animated: true)
        }
    }
    
    private func _applyFilter(_ intensity: Float) {
        guard let imageToFilter = _editedImagesBuffer[_currentIndexOfImage].last else {
            fatalError("ERROR: No image is found for filtering")
        }
        print(imageToFilter)
        var editedImage: UIImage?
        
        switch _currentFilter {
        case .black_and_white:
            editedImage = GPUImageHelper.shared.convertToBlackAndWhite(imageToFilter, intensity: intensity)
            lastSliderValueForBlackAndWhite = intensity
        case .brightness:
            editedImage = GPUImageHelper.shared.adjustBrightness(imageToFilter, intensity: intensity)
            lastSliderValueForBrightness = intensity
        case .sharpen:
            editedImage = GPUImageHelper.shared.sharpenImage(imageToFilter, intensity: intensity)
            lastSliderValueForSharpen = intensity
        case .none:
            break
        }
        
        guard let newImage = editedImage else { return }
        imageView?.image = newImage
    }
    
    //cancel editing
    @IBAction func didTapEditButtonOne(_ sender: FooterButton) {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        
        if editingMode == .filtering {
            imageEditingMode = .correction
        } else {
            delegate?.cancelImageEditing(_controller: self)
        }
    }
    
    // rescan image
    @IBAction func didTapEditButtonTwo(_ sender: UIButton) {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        
        switch editingMode {
        case .basic:
            delegate?.rescanImage(self)
        case .correction:
            imageView?.image = _croppedImages[_currentIndexOfImage]
        case .filtering:
            _filterSelected(.black_and_white)
        }
    }
    
    @IBAction func didTapEditButtonThree(_ sender: UIButton) {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        
        switch editingMode {
        case .basic:
            break
        case .correction:
            _initiateImageFiltering()
        case .filtering:
            _filterSelected(.brightness)
        }
    }
    
    @IBAction func didTapEditButtonFour(_ sender: UIButton) {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        
        switch editingMode {
        case .basic:
            _editVC.cropImage()
        case .correction:
            _rotateImage(.right)
        case .filtering:
            _filterSelected(.sharpen)
        }
    }
    
    @IBAction func didTapEditButtonFive(_ sender: Any) {
        guard let dataSource = dateSource else {
            fatalError("ERROR: Datasource is not set")
        }
        
        func saveDocument() {
            let alterView = UIAlertController(title: "Saving Image",
                                              message: "Enter document name",
                                              preferredStyle: .alert)
            
            alterView.addTextField { textField in
                textField.placeholder = "Documents Name!"
            }
            
            alterView.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alterView] _ in
                guard let textField = alterView?.textFields![0],
                      let documentName = textField.text,
                      !documentName.isEmpty else {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return
                }
                // Force unwrapping because we know it exists.
                self._saveDocument(withName: documentName)
            }))
            
            alterView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
            present(alterView, animated: true)
        }
        dataSource.isNewDocument ? saveDocument() : _updateDocument()
    }
    
    @IBAction func didChange(_ sender: UISlider) {
        guard  _currentFilter != nil else {
            fatalError("ERROR: Slide shown without filter selection")
        }
        print("Slider Value:" + " \(sender.value)")
        _applyFilter(sender.value)
    }
    
}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        imageEditingMode = .correction
        _presentImageViewInImageEditorView(for: image)
    }
}
