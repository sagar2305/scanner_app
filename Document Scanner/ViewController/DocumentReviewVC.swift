//
//  DocumentReviewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit
import SnapKit
import PMAlertController


protocol DocumentReviewVCDelegate: AnyObject {
    func documentReviewVC(viewDidAppear controller: DocumentScannerViewController)
    func documentReviewVC(edit page: Page, controller: DocumentReviewVC)
    func documentReviewVC(_ share: Document, shareAs: DocumentReviewVC.ShareOptions, controller: DocumentReviewVC)
    func documentReviewVC(exit controller: DocumentReviewVC)
    func documentReviewVC(delete document: Document, controller: DocumentReviewVC)
    func documentReviewVC(rename document: Document, name: String)
    func documentReviewVC(markup page: Page, controller: DocumentReviewVC)
    func documentReviewVC(controller: DocumentReviewVC, markup document: Document, startIndex: Int)
    func documentReviewVC(controller: DocumentReviewVC, addPages to: Document, from: PageScanOption)
}

class DocumentReviewVC: DocumentScannerViewController {
    
    enum ShareOptions {
        case pdf
        case jpg
    }
    
    private lazy var documentPreviewControls: DocumentPreviewControls = {
        let controls = DocumentPreviewControls()
        controls.onEditTap = didTapEdit
        controls.onMarkupTap = didTapMarkup
        controls.onShareTap = didTapShare
        controls.onDeleteTap = didTapDelete
        controls.translatesAutoresizingMaskIntoConstraints = false
        return controls
    }()
    
    private lazy var imagePageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.dataSource = self
        pageController.delegate = self
        return pageController
    }()
    
    weak var delegate: DocumentReviewVCDelegate?
    var pageControllerItems: [UIViewController]?
    var document: Document?
    var currentPageIndex: Int = 0
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var addPageButton: UIButton!
    
    @IBOutlet private weak var footerContainerView: UIView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupPageController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _setupView()
        _setupFooterView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.documentReviewVC(viewDidAppear: self)
        footerContainerView?.hero.id = nil
    }
    
    private func _setupView() {
        navigationController?.navigationBar.isHidden = true
        headerView.hero.id = Constants.HeroIdentifiers.headerIdentifier
        headerLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
        headerLabel.text = document?.name
        containerView.hero.id = document?.id
        addPageButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .title2))
    }
    
    private func _setupFooterView() {
        footerView.addSubview(documentPreviewControls)
        documentPreviewControls.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        footerContainerView?.hero.id = Constants.HeroIdentifiers.footerIdentifier
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
        pageControl.isHidden = pageControllerItems.count == 1
        imagePageController.setViewControllers([pageControllerItems.first!], direction: .forward, animated: true)
    }
    
    private func _presentAlertForDocumentName() {
        guard  let document = document else {
            fatalError("Document is not set")
        }
        let actionSheetController = UIAlertController(title: "Add Pages".localized, message: nil, preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "Scan from camera".localized, style: .default, handler: { _ in
            self.delegate?.documentReviewVC(controller: self, addPages: document, from: .Camera)
        }))
        actionSheetController.addAction(UIAlertAction(title: "Pick from Library".localized, style: .default, handler: { _ in
            self.delegate?.documentReviewVC(controller: self, addPages: document, from: .Library)
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in }))
        present(actionSheetController, animated: true)
    }
    
    
    @IBAction private func didTaBackButton(_ sender: UIButton) {
        delegate?.documentReviewVC(exit: self)
    }
    
    @IBAction func didTapAppPageButton(_ sender: UIButton) {
        _presentAlertForDocumentName()
    }
    
    private func didTapMarkup(_ sender: FooterButton) {
        guard let pageItems = pageControllerItems as? [DocumentPageViewController] else {
            fatalError("ERROR: Cannot typecast pageControllerItems to type [DocumentPageViewController]")
        }
        delegate?.documentReviewVC(markup: pageItems[currentPageIndex].page, controller: self)
    }
    
    private func didTapEdit(_ sender: FooterButton) {
        guard let pageItems = pageControllerItems as? [DocumentPageViewController] else {
            fatalError("ERROR: Cannot typecast pageControllerItems to type [DocumentPageViewController]")
        }
        
        delegate?.documentReviewVC(edit: pageItems[currentPageIndex].page, controller: self)
    }
    
    private func didTapDelete(_ sender: FooterButton) {
        guard let document = document else {
            fatalError("ERROR: No document is set")
        }
        
        let deleteConfirmationAlert = PMAlertController(title: "Delete Page".localized, description: "Are you sure you want to delete the page?".localized, image: nil, style: .alert)
        deleteConfirmationAlert.alertTitle.textColor = .red
        
        
        deleteConfirmationAlert.alertActionStackView.axis = .horizontal
        let yesAction = PMAlertAction(title: "Yes".localized, style: .default) {
            self._updatePageViewControllerFor(document: document)
        }
        yesAction.setTitleColor(.red, for: .normal)
        deleteConfirmationAlert.addAction(yesAction)
        
        let cancelAction = PMAlertAction(title: "No".localized, style: .cancel) {  }
        deleteConfirmationAlert.addAction(cancelAction)
        deleteConfirmationAlert.gravityDismissAnimation = false
        
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
    }
    
    private func _updatePageViewControllerFor(document: Document) {
        guard var pageControllerItems = pageControllerItems as? [DocumentPageViewController] else {
            return
        }
        let index = pageControl.currentPage
        document.deletePage(pageControllerItems[index].page)
        pageControllerItems.remove(at: index)
        self.pageControllerItems = pageControllerItems
        pageControl.numberOfPages = pageControllerItems.count
        pageControl.isHidden = pageControllerItems.count == 1
        if pageControllerItems.count == 0 {
            DocumentHelper.shared.delete(document: document)
            navigationController?.popToRootViewController(animated: true)
        } else {
            let direction: UIPageViewController.NavigationDirection = index == pageControllerItems.count ? .reverse : .forward
            imagePageController.setViewControllers([pageControllerItems[pageControl.currentPage]], direction: direction, animated: true)
        }
        
    }
    
    private func didTapShare(_ sender: FooterButton) {
        let actionSheetController = UIAlertController(title: "Share document as".localized, message: nil, preferredStyle: .actionSheet)
        actionSheetController.addAction(UIAlertAction(title: "PDF".localized, style: .default, handler: { _ in
            self.shareDocument(shareAs: .pdf)
        }))
        actionSheetController.addAction(UIAlertAction(title: "JPG".localized, style: .default, handler: { _ in
            self.shareDocument(shareAs: .jpg)
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in }))
        
        present(actionSheetController, animated: true)
    }
    
    func shareDocument( shareAs: ShareOptions) {
        delegate?.documentReviewVC(document!, shareAs: shareAs, controller: self)
    }
}

extension DocumentReviewVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageControllerItems = pageControllerItems,
              let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
            
        if viewControllerIndex == 0 { return nil }
        return pageControllerItems[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

         guard let pageControllerItems = pageControllerItems,
              let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == pageControllerItems.count - 1 { return nil }
        
        return pageControllerItems[viewControllerIndex + 1]
    }
}

extension DocumentReviewVC: UIPageViewControllerDelegate {
    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
       
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pageControllerItems = pageControllerItems else { fatalError("Items for page control are not set")}
        let index = pageControllerItems.firstIndex(of: pendingViewControllers.first ?? UIViewController())
        currentPageIndex = index ?? 0
        pageControl.currentPage = currentPageIndex
    }
}
