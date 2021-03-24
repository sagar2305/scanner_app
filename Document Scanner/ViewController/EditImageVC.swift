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
}

protocol EditImageVCDataSource: class {
    var imageSource: EditDocumentCoordinator.ImageSource? { get }
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
    private var _imageView: UIImageView?
    
    // MARK: - Constants
    private var _footerViewHightWithoutSlider: CGFloat = 55
    private var _footerViewHightWithSlider: CGFloat = 110
    
    // MARK: - Variables
    var imageEditingMode: ImageEditingMode? {
        didSet {
            if _editVC != nil {
                _updateViewForEditing()
            }
        }
    }
    
    //set externally
    var quad: Quadrilateral?
    var imagesToEdit: [UIImage]? {
        didSet {
            if imageEditorView != nil {
                _croppedImages = []
                _editedImagesBuffer = []
                imageEditorView.subviews.forEach {  $0.removeFromSuperview() }
                _setupViews()
            }
        }
    } //original image
    weak var delegate: EditImageVCDelegate?
    weak var dateSource: EditImageVCDataSource?
    
    //temporary images
    private var _croppedImages = [UIImage]() //cropped image for filtering
    private var _editedImagesBuffer = [[UIImage]]()
    private var _footerCornerRadius: CGFloat = 8
    private var _currentFilter: ImageFilters?
    private var _currentIndexOfImage = 0
    //last slide values for filters defaults 0
    private var lastSliderValueForBlackAndWhite: Float = 0.0
    private var lastSliderValueForBrightness: Float = 0.0
    private var lastSliderValueForSharpen: Float = 0.0
    
    // MARK:- IBoutlets
    @IBOutlet private weak var imageEditorView: UIView!
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var filterButtonOneContainer: UIView!
    @IBOutlet private weak var filterButtonOne: UIButton!
    @IBOutlet private weak var filterButtonTwoContainer: UIView!
    @IBOutlet private weak var filterButtonTwo: UIButton!
    @IBOutlet private weak var filterButtonThreeContainer: UIView!
    @IBOutlet private weak var filterButtonThree:UIButton!
    @IBOutlet private weak var filterButtonFourContainer: UIView!
    @IBOutlet private weak var filterButtonFour: UIButton!
    @IBOutlet private weak var filterButtonFiveContainer: UIView!
    @IBOutlet private weak var filterButtonFive: UIButton!
    
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sliderViewContainer: UIView!
    @IBOutlet private weak var slider: UISlider!
    
    //button  left to right in xib
    @IBOutlet private weak var editButtonOneContainer: UIView!
    @IBOutlet private weak var editButtonOne: UIButton!
    @IBOutlet private weak var editButtonTwoContainer: UIView!
    @IBOutlet private weak var editButtonTwo: UIButton!
    @IBOutlet private weak var editButtonThreeContainer: UIView!
    @IBOutlet private weak var editButtonThree:UIButton!
    @IBOutlet private weak var editButtonFourContainer: UIView!
    @IBOutlet private weak var editButtonFour: UIButton!
    @IBOutlet private weak var editButtonFiveContainer: UIView!
    @IBOutlet private weak var editButtonFive: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
    }
    
    private func _setupViews() {
        //one time view setups
        guard let imagesToEdit = imagesToEdit, !imagesToEdit.isEmpty else {
            fatalError("ERROR: No images is set for editing")
        }
        
        _setupImageEditorView()
        _setupFooterView()
        //recurring view setups
        _updateViewForEditing()
    }
    
    private func _setupImageEditorView() {
        
        guard  let editingMode = imageEditingMode, let imageToEdit = imagesToEdit?.first else {
            fatalError("ERROR: Image editing mode or image is not set")
        }
        
        imageEditorView.subviews.forEach { $0.removeFromSuperview() }
        
        switch editingMode {
        case .basic:
            if _editVC == nil {
                _editVC = WeScan.EditImageViewController(image: imageToEdit, quad: quad,rotateImage: false, strokeColor: UIColor.primary.cgColor)
            }
            _editVC.view.frame = imageEditorView.bounds
            _editVC.willMove(toParent: self)
            imageEditorView.addSubview(_editVC.view)
            self.addChild(_editVC)
            _editVC.didMove(toParent: self)
            _editVC.delegate = self
        case .correction, .filtering:
            if _imageView == nil {
                _imageView = UIImageView()
            }
            _imageView?.image = _croppedImages[_currentIndexOfImage]
            _imageView?.frame = imageEditorView.bounds
            imageEditorView.addSubview(_imageView!)
            imageEditorView.bringSubviewToFront(_imageView!)
            _imageView?.contentMode = .scaleAspectFit
            _editVC.view.removeFromSuperview()
        }
        
    }
    
    private func _setupFooterView() {
        footerView.clipsToBounds = true
        if UIDevice.current.hasNotch {
            footerView.layer.cornerRadius = _footerCornerRadius
            footerViewLeadingConstraint.constant = 8
            footerViewTrailingConstraint.constant = 8
        } else {
            footerView.layer.cornerRadius = 0
            footerViewLeadingConstraint.constant = 0
            footerViewTrailingConstraint.constant = 0
            footerViewBottomConstraint.constant = 0
        }
    }
    
    private func _setupHeaderView() {
        filterButtonOne.setImage(Icons.blackAndWhite, for: .normal)
        filterButtonTwo.setImage(Icons.brightness, for: .normal)
        filterButtonThree.setImage(Icons.sharpen, for: .normal)
        
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
        
        editButtonOneContainer.isHidden = false
        editButtonTwoContainer.isHidden = false
        editButtonThreeContainer.isHidden = true
        editButtonFourContainer.isHidden = false
        editButtonFiveContainer.isHidden = true
        
        editButtonOne.setImage(Icons.cancel, for: .normal)
        if dateSource?.imageSource == .camera {
            editButtonTwo.setImage(Icons.camera, for: .normal)
        } else {
            editButtonTwo.setImage(Icons.photoLibrary, for: .normal)
        }
        editButtonFour.setImage(Icons.crop, for: .normal)
        
        sliderViewContainer.isHidden = true
        footerViewHeightConstraint.constant = _footerViewHightWithoutSlider
        
        headerView.isHidden = true
        headerViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    private func _setupEditorViewForCorrectionMode() {
        editButtonOneContainer.isHidden = false
        editButtonTwoContainer.isHidden = false
        editButtonThreeContainer.isHidden = false
        editButtonFourContainer.isHidden = false
        editButtonFiveContainer.isHidden = false
        
        editButtonOne.setImage(Icons.cancel, for: .normal)
        editButtonTwo.setImage(Icons.rotateLeft, for: .normal)
        editButtonThree.setImage(Icons.filter, for: .normal)
        editButtonFour.setImage(Icons.rotateRight, for: .normal)
        editButtonFive.setImage(Icons.done, for: .normal)
        
        sliderViewContainer.isHidden = true
        footerViewHeightConstraint.constant = _footerViewHightWithoutSlider
        
        headerView.isHidden = true
        headerViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func _setupEditorViewForFilteringMode() {
    
        editButtonOneContainer.isHidden = false
        editButtonTwoContainer.isHidden = false
        editButtonThreeContainer.isHidden = false
        editButtonFourContainer.isHidden = false
        editButtonFiveContainer.isHidden = false
        
        editButtonOne.setImage(Icons.cancel, for: .normal)
        editButtonTwo.setImage(Icons.blackAndWhite, for: .normal)
        editButtonThree.setImage(Icons.brightness, for: .normal)
        editButtonFour.setImage(Icons.sharpen, for: .normal)
        editButtonFive.setImage(Icons.done, for: .normal)
        
        sliderViewContainer.isHidden = true
        footerViewHeightConstraint.constant = _footerViewHightWithoutSlider
        
        headerView.isHidden = false
        headerViewHeightConstraint.constant = 52
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
        _imageView?.image = _croppedImages[_currentIndexOfImage]
        
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
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        guard  let originalImages = imagesToEdit else {
            fatalError("ERROR: Original Image is not available")
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
            guard  _editedImagesBuffer.count == originalImages.count, let finalImage =  _editedImagesBuffer[_currentIndexOfImage].last else {
                fatalError("ERROR: Edited Images count does not original images count")
            }
            delegate?.finishedImageEditing([finalImage],
                                           originalImage: originalImages,
                                           documentName: name,
                                           controller: self)
        }
    }
    
    private func _filterSelected(_ filter: ImageFilters) {
        _editedImagesBuffer[_currentIndexOfImage].append((_imageView?.image)!)
        _currentFilter = filter
        sliderViewContainer.isHidden = false
        footerViewHeightConstraint.constant = _footerViewHightWithSlider
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        
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
        _imageView?.image = newImage
        
    }
    
    //cancel editing
    @IBAction func didTapEditButtonOne(_ sender: UIButton) {
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
            _rotateImage(.left)
        case .filtering:
            _filterSelected(.black_and_white)
        }
    }
    
    //
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
    
    @IBAction func didChange(_ sender: UISlider) {
        guard  _currentFilter != nil else {
            fatalError("ERROR: Slide shown without filter selection")
        }
        _applyFilter(sender.value)
    }
    
}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        _croppedImages = [image]
        imageEditingMode = .correction
        _setupImageEditorView()
    }
}
