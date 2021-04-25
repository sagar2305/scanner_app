//
//  CorrectionVC.swift
//  Document Scanner
//
//  Created by Sandesh on 14/04/21.
//

import UIKit
import WeScan
import PMAlertController

protocol CorrectionVCDelegate: class {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage)
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, saveDocument name: String, originalImage: UIImage, finalImage: UIImage)
}

class CorrectionVC: DocumentScannerViewController {
    
    private enum CropButtonState {
        case crop, undo
    }

    private var _editVC: EditImageViewController!
    private lazy var _croppedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.frame = imageContainerView.bounds
        return imageView
    }()
    
    private var croppedImage: UIImage?
    private var cropButtonState: CropButtonState = .crop
    
    var image: UIImage?
    var quad: Quadrilateral?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var retakeButton: UIButton!
    @IBOutlet private weak var rotateButton: UIButton!
    @IBOutlet private weak var cropButton: UIButton!
    @IBOutlet private weak var imageContainerView: UIView!
    
    weak var delegate: CorrectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func _setupViews() {
        headerLabel.text = ""
        editButton.isHidden = true
        rotateButton.isHidden = true
        _initiateEditImageVC()
    }
    
    private func _initiateEditImageVC() {
        guard  let image = image else {
            fatalError("ERROR: Image is not set")
        }
        _editVC = WeScan.EditImageViewController(image: image, quad: quad,rotateImage: false, strokeColor: UIColor.primary.cgColor)
        _editVC?.view.backgroundColor = .backgroundColor
        _editVC.view.frame = imageContainerView.bounds
        _editVC.willMove(toParent: self)
        imageContainerView.addSubview(_editVC.view)
        self.addChild(_editVC)
        _editVC.didMove(toParent: self)
        _editVC.delegate = self
    }
    
    private func _presentCroppedImage(_ image: UIImage) {
        imageContainerView.addSubview(_croppedImageView)
        _croppedImageView.image = image
        croppedImage = image
        imageContainerView.bringSubviewToFront(_croppedImageView)
        _editVC.view.isHidden = true
        guard  let undoImage = UIImage(named: "undo-ellipse") else {
            fatalError("ERROR: No image found with name undo-ellipse")
        }
        cropButton.setImage(undoImage, for: .normal)
        cropButtonState = .undo
    }
    
    private func _presentEditVC() {
        _editVC.view.isHidden = false
        imageContainerView.bringSubviewToFront(_editVC.view)
        guard  let crop = UIImage(named: "crop-ellipse") else {
            fatalError("ERROR: No image found with name crop-ellipse")
        }
        cropButton.setImage(crop, for: .normal)
        cropButtonState = .crop
    }
    
    private func _presentAlertForDocumentName() {
        let alertVC = PMAlertController(title: "Enter Name", description: nil, image: nil, style: .alert)
        alertVC.alertTitle.textColor = .primary
        
        alertVC.addTextField { (textField) in
                    textField?.placeholder = "Document Name"
                }
        
        alertVC.alertActionStackView.axis = .horizontal
        let doneAction = PMAlertAction(title: "Done", style: .default) {
            let textField = alertVC.textFields[0]
            guard let documentName = textField.text,
                  !documentName.isEmpty else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                return
            }
            self._saveDocument(withName: documentName)
        }
        doneAction.setTitleColor(.primary, for: .normal)
        alertVC.addAction(doneAction)
        
        let cancelAction = PMAlertAction(title: "Cancel", style: .cancel) {  }
        alertVC.addAction(cancelAction)
        alertVC.gravityDismissAnimation = false

        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func _saveDocument(withName: String) {
        guard  let image = image else {
            fatalError("ERROR: Image is not set")
        }
        
        delegate?.correctionVC(self, saveDocument: withName, originalImage: image, finalImage: croppedImage ?? image)
    }
    
    func update(image newImage: UIImage) {
        croppedImage = newImage
        _presentCroppedImage(croppedImage!)
    }
    
    @IBAction func didTapEditButton(_ sender: UIButton) {
        guard let imageToEdit = croppedImage ?? image else {
            fatalError("ERROR: No image found for editing")
        }
        delegate?.correctionVC(self, edit: imageToEdit)
    }
    
    @IBAction func didTapDoneButton(_ sender: UIButton) {
        _presentAlertForDocumentName()
    }
    
    @IBAction func didTapRescanButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapRetake: sender)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapBack: sender)
    }
    
    @IBAction func didTapRotateButton(_ sender: Any) {
        croppedImage = (croppedImage ?? image)?.rotateRight()
        _croppedImageView.image = croppedImage
    }
    
    @IBAction func cropImage(_ sender: UIButton) {
        switch cropButtonState {
        case .crop:
            editButton.isHidden = false
            rotateButton.isHidden = false
            _editVC.cropImage()
        case .undo:
            editButton.isHidden = true
            rotateButton.isHidden = true
            _presentEditVC()
        }
    }
}

extension CorrectionVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        croppedImage = image
       _presentCroppedImage(croppedImage!)
    }
}
