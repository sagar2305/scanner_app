//
//  CorrectionVC.swift
//  Document Scanner
//
//  Created by Sandesh on 14/04/21.
//

import UIKit
import WeScan
import PMAlertController
import QCropper

protocol CorrectionVCDelegate: class {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage)
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, originalImage: UIImage, finalImage: UIImage)
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
    }()
    
    private var croppedImage: UIImage?
    
    var image: UIImage?
    var quad: Quadrilateral?
    /**this is passed to WeScan.EditImageViewController
     - set false if image is scanned from camera
     -  set true if image is picked from documents
     */
    var shouldRotateImage: Bool?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var footerView: UIView!
    
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
    }
    
    private func _presentEditVC() {
        _editVC.view.isHidden = false
        imageContainerView.bringSubviewToFront(_editVC.view)
    }
    
    private func _saveDocument() {
        guard  let image = image else {
            fatalError("ERROR: Image is not set")
        }
        delegate?.correctionVC(self, originalImage: image, finalImage: croppedImage ?? image)
    }
    
    func update(image newImage: UIImage) {
        croppedImage = newImage
        _presentCroppedImage(croppedImage!)
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
        croppedImage = image
       _saveDocument()
    }
}
