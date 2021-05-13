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
    
    private lazy var imageCorrectionControls: ImageCorrectionControls = {
        let controls = ImageCorrectionControls()
        controls.onDoneTap = didTapDoneButton
        controls.onEditTap = didTapEditButton
        controls.onRescanTap = didTapRescanButton
        return controls
    }()
    
    private lazy var _imagePageController: UIPageViewController = {
        let pageController = UIPageViewController()
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageController
    }()
    
    private var pageControllerItems: [UIViewController]?
    var currentPageIndex: Int?
    var quad: [Quadrilateral?]?
    /**this is passed to WeScan.EditImageViewController
     - set false if image is scanned from camera
     -  set true if image is picked from documents and there orientation is  left or right
     */
    var shouldRotateImage: Bool?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
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
        _setupPageController()
    }
    
    private func _setupFooterView() {
        footerView.addSubview(imageCorrectionControls)
        imageCorrectionControls.snp.makeConstraints { make in make.left.right.top.bottom.equalToSuperview() }
        footerView.hero.id = Constants.HeroIdentifiers.footerIdentifier
    }
    
    private func _setupPageController() {
        
        if !children.contains(_imagePageController) {
            _imagePageController.willMove(toParent: self)
            addChild(_imagePageController)
            containerView.addSubview(_imagePageController.view)
            _imagePageController.didMove(toParent: self)
        }
        
        guard let pageControllerItems = pageControllerItems, pageControllerItems.count > 0 else {
            fatalError("No items for page controller have been set")
        }

        _imagePageController.setViewControllers([pageControllerItems.last!], direction: .reverse, animated: true)
    }
    
    private func _saveDocument() {
        //delegate?.correctionVC(self, originalImages: images, finalImages: croppedImages ?? images)
    }
    
    func updateEdited(image newImage: UIImage, isRotated: Bool) {
    }
    
    func didTapEditButton(_ sender: UIButton) {
//        guard let imageToEdit = croppedImage ?? image else {
//            fatalError("ERROR: No image found for editing")
//        }
//        delegate?.correctionVC(self, edit: imageToEdit)
    }
    
    func didTapDoneButton(_ sender: UIButton) {
        //TODO: - Get images from individual
    }
    
    func didTapRescanButton(_ sender: FooterButton) {
        delegate?.correctionVC(self, didTapRetake: sender)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapBack: sender)
    }
}

