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

protocol CorrectionVCDelegate: AnyObject {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage)
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, didFinishCorrectingImages imageVCs: [NewDocumentImageViewController])
}

protocol CorrectionVCDataSource: AnyObject {
    func correctionVC(_ viewController: CorrectionVC, titleFor nextPage: UIButton) -> String
}

class CorrectionVC: DocumentScannerViewController {
    
    private lazy var imageCorrectionControls: ImageCorrectionControls = {
        let controls = ImageCorrectionControls()
        controls.onDoneTap = didTapDoneButton
        controls.onEditTap = didTapEditButton
        controls.onRescanTap = didTapRescanButton
        controls.onPreviousPageTap = didTapPreviousPageButton(_:)
        controls.onNextPageTap = didTapNextPageButton(_:)
        return controls
    }()
    
    private lazy var imagePageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false        
        return pageController
    }()
    
    var pageControllerItems: [UIViewController]?
    var currentPageIndex: Int = 0
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
    @IBOutlet private weak var pageControl: UIPageControl!
    
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
        
        if !children.contains(imagePageController) {
            imagePageController.willMove(toParent: self)
            addChild(imagePageController)
            containerView.addSubview(imagePageController.view)
            imagePageController.view.snp.makeConstraints { make in
                make.top.right.left.bottom.equalToSuperview()
            }
            imagePageController.didMove(toParent: self)
            pageControl.numberOfPages = pageControllerItems?.count ?? 0
        }
        
        guard let pageControllerItems = pageControllerItems, pageControllerItems.count > 0 else {
            fatalError("No items for page controller have been set")
        }
        
        imageCorrectionControls.setNextButtonHidden = pageControllerItems.count == 1
        imageCorrectionControls.setPreviousButtonHidden = pageControllerItems.count == 1
        pageControl.isHidden = pageControllerItems.count == 1
        
        imagePageController.setViewControllers([pageControllerItems.first!], direction: .forward, animated: true)
        imageCorrectionControls.setPreviousButtonHidden = true
    }
    
    private func changePage(direction: UIPageViewController.NavigationDirection) {
        guard let pageControllerItems = pageControllerItems, pageControllerItems.count > 0 else {
            fatalError("No items for page controller have been set")
        }
        if direction == .forward && currentPageIndex < pageControllerItems.count-1 {
            currentPageIndex += 1
        } else if direction == .reverse && currentPageIndex > 0 {
            currentPageIndex -= 1
        }
        
        imageCorrectionControls.setNextButtonHidden = currentPageIndex == pageControllerItems.count - 1
        imageCorrectionControls.setPreviousButtonHidden = currentPageIndex == 0
        let nextVC = pageControllerItems[currentPageIndex]
        imagePageController.setViewControllers([nextVC], direction: direction, animated: true)
        pageControl.currentPage = currentPageIndex
    }
    
    func updateEdited(image newImage: UIImage, isRotated: Bool) {
        guard let pageControllerItems = pageControllerItems,
              pageControllerItems.count > 0,
              let imageVC =  pageControllerItems[currentPageIndex] as? NewDocumentImageViewController else {
            fatalError("No items for page controller have been set")
        }
        imageVC.updatedImage(newImage, was: isRotated)
    }
    
    func didTapEditButton(_ sender: UIButton) {
        guard let pageControllerItems = pageControllerItems,
              pageControllerItems.count > 0,
              let imageVC =  pageControllerItems[currentPageIndex] as? NewDocumentImageViewController else {
            fatalError("No items for page controller have been set")
        }
        delegate?.correctionVC(self, edit: imageVC.finalImage)
    }
    
    func didTapDoneButton(_ sender: UIButton) {
        guard let pageControllerItems = pageControllerItems as? [NewDocumentImageViewController] else {
            fatalError("Cannot convert [pageControllerItems] to [NewDocumentImageViewController]")
        }
        delegate?.correctionVC(self, didFinishCorrectingImages: pageControllerItems)
    }
    
    func didTapRescanButton(_ sender: FooterButton) {
        delegate?.correctionVC(self, didTapRetake: sender)
    }
    
    func didTapPreviousPageButton(_ sender: FooterButton) {
        changePage(direction: .reverse)
    }
    
    func didTapNextPageButton(_ sender: FooterButton) {
        changePage(direction: .forward)
    }
        
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapBack: sender)
    }
}

extension CorrectionVC: UIPageViewControllerDelegate {
    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
       
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pageControllerItems = pageControllerItems else { fatalError("Items for page control are not set")}
        let index = pageControllerItems.firstIndex(of: pendingViewControllers.first ?? UIViewController())
        currentPageIndex = index ?? 0
        pageControl.currentPage = currentPageIndex
    }
}
