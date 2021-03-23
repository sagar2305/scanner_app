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
    func filterImage(_ image: UIImage, controller: EditImageVC)
    func rescanImage(_ controller: EditImageVC)
    func finishedImageEditing(_ finalImage: UIImage, originalImage: UIImage,documentName: String, controller: EditImageVC)
}

class EditImageVC: UIViewController {
    
    // MARK: - ViewController specific enums
    enum ImageEditingMode {
        case basic
        case correction
        case filtering
    }
    
    enum ImageRotationDirection {
        case left
        case right
    }
    
    enum ImageFilters {
        case black_and_white
        case brightness
        case sharpen
    }
    
    enum ImageSource {
        case photo_library
        case camera
    }

    // MARK: - Views
    private var _editVC: EditImageViewController!
    private var _imageView: UIImageView?
    
    // MARK: - Constants
    private var _rotateLeftRadians: CGFloat = -1.5708
    private var _rotateRightRadians: CGFloat = 1.5708
    private var _footerViewHightWithoutSlider: CGFloat = 55
    private var _footerViewHightWithSlider: CGFloat = 110
    
    var imageEditingMode: ImageEditingMode? {
        didSet {
            if _editVC != nil {
                _updateViewForEditing()
            }
        }
    }
    
    //set externally
    var quad: Quadrilateral?
    var imageSource: ImageSource!
    var imageToEdit: UIImage? {
        didSet {
            if imageEditorView != nil {
                _croppedImage = nil
                _editedImage = nil
                imageEditorView.subviews.forEach {  $0.removeFromSuperview() }
                _setupViews()
            }
        }
    } //original image
    weak var delegate: EditImageVCDelegate?
    
    //temporary images
    private var _croppedImage: UIImage? //cropped image for filtering
    private var _editedImage: UIImage?
    private var footerCornerRadius: CGFloat = 8
    private var currentFilter: ImageFilters?
    //last slide values for filters defaults 0
    private var lastSliderValueForBlackAndWhite: Float = 0.0
    private var lastSliderValueForBrightness: Float = 0.0
    private var lastSliderValueForSharpen: Float = 0.0
    
    // MARK:- IBoutlets
    @IBOutlet private weak var imageEditorView: UIView!
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func _setupViews() {
        //one time view setups
        guard let imageToEdit = imageToEdit else {
            fatalError("ERROR: No image is set for editing")
        }
        
        _editVC = WeScan.EditImageViewController(image: imageToEdit, quad: quad,rotateImage: false, strokeColor: UIColor.primary.cgColor)
        _editVC.view.frame = imageEditorView.bounds
        _editVC.willMove(toParent: self)
        imageEditorView.addSubview(_editVC.view)
        self.addChild(_editVC)
        _editVC.didMove(toParent: self)
        _editVC.delegate = self
        
        //recurring view setups
        _updateViewForEditing()
    }
    
    private func _setupFooterView() {
        footerView.clipsToBounds = true
        if UIDevice.current.hasNotch {
            footerView.layer.cornerRadius = footerCornerRadius
            footerViewLeadingConstraint.constant = 8
            footerViewTrailingConstraint.constant = 8
        } else {
            footerView.layer.cornerRadius = 0
            footerViewLeadingConstraint.constant = 0
            footerViewTrailingConstraint.constant = 0
        }
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
        if imageSource! == .camera {
            editButtonTwo.setImage(Icons.camera, for: .normal)
        } else {
            editButtonTwo.setImage(Icons.photoLibrary, for: .normal)
        }
        editButtonFour.setImage(Icons.crop, for: .normal)
        
        sliderViewContainer.isHidden = true
        footerViewHeightConstraint.constant = _footerViewHightWithoutSlider
        self.view.layoutIfNeeded()
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
        self.view.layoutIfNeeded()
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
        self.view.layoutIfNeeded()
    }
    
    //rotation of images is available in cropped mode only
    private func _rotateImage(_ direction: ImageRotationDirection) {
        switch  direction {
        case .left:
            _croppedImage = _croppedImage?.rotate(withRotation: _rotateLeftRadians)
        case .right:
            _croppedImage = _croppedImage?.rotate(withRotation: _rotateRightRadians)
        }
        _imageView?.image = _croppedImage
        
    }
    
    private func _initiateImageFiltering() {
        /**
         1 save original image temporary to user defaults
         2 pass edited image(cropped)  to editing VC */
        imageEditingMode = .filtering
        delegate?.filterImage(_croppedImage!, controller: self)
    }
    
    private func _saveDocument(withName name: String) {
        guard let editingMode = imageEditingMode else {
            fatalError("ERROR: Image editing mode not set")
        }
        guard  let originalImage = imageToEdit else {
            fatalError("ERROR: Original Image is not available")
        }
        
        switch editingMode {
        case .basic:
            delegate?.finishedImageEditing(originalImage,
                                           originalImage: originalImage,
                                           documentName: name,
                                           controller: self)
        case .correction:
            guard let croppedImage = _croppedImage else {
                fatalError("ERROR: Cropped Image is not available")
            }
            delegate?.finishedImageEditing(croppedImage,
                                           originalImage: originalImage,
                                           documentName: name,
                                           controller: self)
            
        case .filtering:
            guard let editedImage = _editedImage else {
                fatalError("ERROR: Edited Image is not available")
            }
            delegate?.finishedImageEditing(editedImage,
                                           originalImage: originalImage,
                                           documentName: name,
                                           controller: self)
        }
    }
    
    private func _filterSelected(_ filter: ImageFilters) {
        currentFilter = filter
        sliderViewContainer.isHidden = false
        footerViewHeightConstraint.constant = _footerViewHightWithSlider
        self.view.layoutIfNeeded()
        
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
        guard let imageToFilter = _croppedImage  else {
            fatalError("ERROR: No cropped image available for filtering")
        }
        
        var editedImage: UIImage?
        
        switch currentFilter {
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
        
        guard let newImage = editedImage else {
            return
        }
        _editedImage = newImage
        _imageView?.image = _editedImage
        
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
        guard  let currentFilter = currentFilter else {
            fatalError("ERROR: Slide shown without filter selection")
        }
        _applyFilter(sender.value)
    }
    
}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        _croppedImage = image
        _imageView = UIImageView()
        _imageView?.image = image
        _imageView?.frame = imageEditorView.bounds
        imageEditorView.addSubview(_imageView!)
        imageEditorView.bringSubviewToFront(_imageView!)
        _imageView?.contentMode = .scaleAspectFit
        _editVC.view.removeFromSuperview()
        imageEditingMode = .correction
    }
}
