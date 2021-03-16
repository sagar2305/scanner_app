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
    }

    // MARK: - Views
    private var _editVC: EditImageViewController!
    private var _imageView: UIImageView?
    
    // MARK: - Constants
    private var _rotateLeftRadians: CGFloat = -1.5708
    private var _rotateRightRadians: CGFloat = 1.5708
    
    var imageEditingMode: ImageEditingMode? {
        didSet {
            if _editVC != nil {
                _updateViewForEditing()
            }
        }
    }
    
    //set externally
    var quad: Quadrilateral?
    var imageToEdit: UIImage? //original image
    weak var delegate: EditImageVCDelegate?
    
    //temporary images
    private var _croppedImage: UIImage? //cropped image for filtering
    private var _editedImage: UIImage?
    
    
    
    // MARK:- IBoutlets
    @IBOutlet weak var imageEditorView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    //button left to right in xib
    @IBOutlet weak var editButtonOneContainer: UIView!
    @IBOutlet weak var editButtonOne: UIButton!
    @IBOutlet weak var editButtonTwoContainer: UIView!
    @IBOutlet weak var editButtonTwo: UIButton!
    @IBOutlet weak var editButtonThreeContainer: UIView!
    @IBOutlet weak var editButtonThree:UIButton!
    @IBOutlet weak var editButtonFourContainer: UIView!
    @IBOutlet weak var editButtonFour: UIButton!
    @IBOutlet weak var editButtonFiveContainer: UIView!
    @IBOutlet weak var editButtonFive: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        //one time view setups
        guard let imageToEdit = imageToEdit , let quad = quad else {
            fatalError("ERROR: No image or quad is set for editing")
        }
        
        _editVC = WeScan.EditImageViewController(image: imageToEdit, quad: quad, strokeColor: UIColor(red: (69.0 / 255.0), green: (194.0 / 255.0), blue: (177.0 / 255.0), alpha: 1.0).cgColor)
        _editVC.view.frame = imageEditorView.bounds
        _editVC.willMove(toParent: self)
        imageEditorView.addSubview(_editVC.view)
        self.addChild(_editVC)
        _editVC.didMove(toParent: self)
        _editVC.delegate = self
        
        //recurring view setups
        _updateViewForEditing()
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
        editButtonTwo.setImage(Icons.camera, for: .normal)
        editButtonFour.setImage(Icons.crop, for: .normal)
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
    }
    
    private func _setupEditorViewForFilteringMode() {
        editButtonOneContainer.isHidden = false
        editButtonTwoContainer.isHidden = false
        editButtonThreeContainer.isHidden = false
        editButtonFourContainer.isHidden = false
        editButtonFiveContainer.isHidden = false
        
        editButtonOne.setImage(Icons.cancel, for: .normal)
        editButtonTwo.setImage(Icons.blackAndWhite, for: .normal)
        editButtonThree.setImage(Icons.filter, for: .normal)
        editButtonFour.setImage(Icons.rotateRight, for: .normal)
        editButtonFive.setImage(Icons.done, for: .normal)
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
    
    private func _applyFilter(_ filter: ImageFilters) {
        switch filter {
        case .black_and_white:
            guard  let filteredImage = GPUImageHelper.shared.convertToBlackAndWhite(_imageView!.image!) else {
                return
            }
            _editedImage = filteredImage
            _imageView?.image = _editedImage
        }
    }
    
    //cancel editing
    @IBAction func didTapEditButtonOne(_ sender: UIButton) {
        delegate?.cancelImageEditing(_controller: self)
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
            _applyFilter(.black_and_white)
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
            break
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
            break
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
