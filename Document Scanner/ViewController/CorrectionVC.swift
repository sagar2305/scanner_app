//
//  CorrectionVC.swift
//  Document Scanner
//
//  Created by Sandesh on 14/04/21.
//

import UIKit
import WeScan
import PMAlertController
import SnapKit

protocol CorrectionVCDelegate: class {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage)
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, originalImages: [UIImage], finalImages: [UIImage])
}

protocol CorrectionVCDataSource: class {
    func correctionVC(_ viewController: CorrectionVC, titleFor nextPage: UIButton) -> String
}

class CorrectionVC: DocumentScannerViewController {
    
    private var _editVC: EditImageViewController!
    private lazy var _croppedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.frame = imageContainerView.bounds
        return imageView
    }()
    
    private lazy var imageCorrectionControls: ImageCorrectionControls = {
        let controls = ImageCorrectionControls()
        controls.onDoneTap = didTapDoneButton
        controls.onEditTap = didTapEditButton
        controls.onRescanTap = didTapRescanButton
        return controls
    private lazy var _imagePageController: UIPageViewController = {
        let pageController = UIPageViewController()
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageController
    }()
    
    private var croppedImages: [UIImage]?
    private var cropButtonState: CropButtonState = .crop
    private var pageControllerItems: [UIViewController] = []
    
    var images: [UIImage]? {
        didSet {
            if images != nil {
                croppedImages = images!
            }
        }
    }
    var currentPageIndex: Int?
    var quad: [Quadrilateral?]?
    /**this is passed to WeScan.EditImageViewController
     - set false if image is scanned from camera
     -  set true if image is picked from documents and there orientation is  left or right
     */
    var shouldRotateImage: Bool?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var addNewPageButton: UIButton!
    
    weak var delegate: CorrectionVCDelegate?
    weak var dataSource: CorrectionVCDataSource?
    
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
        _setupFooterView()
        _initiateEditImageVC()
    }
    
    private func _setupFooterView() {
        footerView.addSubview(imageCorrectionControls)
        imageCorrectionControls.snp.makeConstraints { make in make.left.right.top.bottom.equalToSuperview() }
        footerView.hero.id = Constants.HeroIdentifiers.footerIdentifier
    }
    
    private func _initiateEditImageVC() {
        guard  let image = image,let shouldRotate = shouldRotateImage else {
            fatalError("ERROR: Image or shouldRotateImage option is not set")
        }
        _editVC = WeScan.EditImageViewController(image: image, quad: quad, rotateImage: shouldRotate, strokeColor: UIColor.primary.cgColor)
        editButton.isHidden = true
        rotateButton.isHidden = true
        let title = dataSource?.correctionVC(self, titleFor: addNewPageButton)
        addNewPageButton.setTitle(title, for: .normal)
        guard let images = images,
              images.count > 0 else {
            fatalError("ERROR: Images or shouldRotateImage option is not set")
        }
        _cropImage(at: images.count - 1)
    }
    
    private func _setupPageController() {
        if !children.contains(_imagePageController) {
            _imagePageController.willMove(toParent: self)
            addChild(_imagePageController)
            _imagePageController.didMove(toParent: self)
        }
        
        
        //TODO: - Add completion
        _imagePageController.setViewControllers([pageControllerItems.last!], direction: .reverse, animated: true)
        
    }
    
    private func _cropImage(at index: Int) {
        guard let shouldRotate = shouldRotateImage,
              let images = images,
              let quadrilaterals = quad else {
            fatalError("ERROR: Images or shouldRotateImage option is not set")
        }
        
        _editVC = WeScan.EditImageViewController(image: images[index],
                                                 quad: quadrilaterals[index],
                                                 rotateImage: shouldRotate,
                                                 strokeColor: UIColor.primary.cgColor)
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
           // self._saveDocument(withName: documentName)
        }
        doneAction.setTitleColor(.primary, for: .normal)
        alertVC.addAction(doneAction)
        
        let cancelAction = PMAlertAction(title: "Cancel", style: .cancel) {  }
        alertVC.addAction(cancelAction)
        alertVC.gravityDismissAnimation = false

        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func croppingImage() {
    }
    
    private func _saveDocument() {
        guard let images = images,
              let croppedImages = croppedImages else {
            fatalError("ERROR: images or cropped images are empty")
        }
        delegate?.correctionVC(self, originalImages: images, finalImages: croppedImages ?? images)
    }
    
    func updateEdited(image newImage: UIImage, isRotated: Bool) {
        image = newImage
        shouldRotateImage = false
        if isRotated { quad = nil }
        imageContainerView.subviews.forEach { $0.removeFromSuperview() }
        _initiateEditImageVC()
    }
    
    func didTapEditButton(_ sender: UIButton) {
        guard let imageToEdit = croppedImage ?? image else {
            fatalError("ERROR: No image found for editing")
        }
        delegate?.correctionVC(self, edit: imageToEdit)
    }
    
    func didTapDoneButton(_ sender: UIButton) {
        _editVC.cropImage()
    }
    
    func didTapRescanButton(_ sender: FooterButton) {
        delegate?.correctionVC(self, didTapRetake: sender)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapBack: sender)
    }
}

extension CorrectionVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        croppedImages.insert(image, at: currentPageIndex)
       _presentCroppedImage(croppedImage!)
        croppedImage = image
       _saveDocument()
    }
}
