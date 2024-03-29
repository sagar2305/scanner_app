//
//  OnboardingVC.swift
//  Document Scanner
//
//  Created by Sandesh on 26/04/21.
//

import UIKit
import SnapKit

protocol OnboardingVCDelegate: AnyObject {
    func onboardingVC(_ continue: DocumentScannerViewController)
}

class OnboardingVC: DocumentScannerViewController {

    private var pageControllerItems: [UIViewController] = []
    private var currentPageIndex = 0
    
    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.dataSource = self
        controller.delegate = self
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    var delegate: OnboardingVCDelegate?
    
    @IBOutlet weak var pageControllerContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        _generateItemsForPageControls()
       _setupPageController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func _setupView() {
     
        skipButton.titleLabel?.configure(with: UIFont.font(.DMSansMedium, style: .body))
        nextButton.titleLabel?.configure(with: UIFont.font(.DMSansMedium, style: .body))
        
        //TODO: - Localize
        skipButton.setTitle("Skip", for: .normal)
        nextButton.setTitle("Next", for: .normal)
    }
    
    private func _generateItemsForPageControls() {
        let pageControlItem1 = UIViewController()
        pageControlItem1.view = OnboardingView(header: "Easy to scan".localized.uppercased(),
                                               description: "Quickly scan and digitize your important documents",
                                               image: UIImage(named: "store-document")!)
        pageControllerItems.append(pageControlItem1)
        
        let pageControlItem2 = UIViewController()
        pageControlItem2.view = OnboardingView(header: "Organize files easily".localized.uppercased(),
                                               description: "Have all your digital document in one place".localized,
                                               image: UIImage(named: "organize-document")!)
        pageControllerItems.append(pageControlItem2)
        
        let pageControlItem3 = UIViewController()
        pageControlItem3.view = OnboardingView(header: "Share it".localized.uppercased(),
                                               description: "Quickly share the files in the format that you prefer".localized,
                                               image: UIImage(named: "share-document")!)
        pageControllerItems.append(pageControlItem3)
        pageController.setViewControllers([pageControllerItems.first!], direction: .forward, animated: true, completion: nil)
        currentPageIndex = 0
        _logEventForPage(index: currentPageIndex)
    }

    private func _setupPageController() {
        pageController.willMove(toParent: self)
        addChild(pageController)
        pageControllerContainer.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { make in
            make.top.right.left.bottom.equalToSuperview()
           
        }
        pageController.didMove(toParent: self)
    }
    
    private func changePage(direction: UIPageViewController.NavigationDirection) {
       
        if direction == .forward && currentPageIndex < pageControllerItems.count-1 {
            currentPageIndex += 1
        } else if direction == .reverse && currentPageIndex > 0 {
            currentPageIndex -= 1
        }
        
        let nextVC = pageControllerItems[currentPageIndex]
        _logEventForPage(index: currentPageIndex)
        pageController.setViewControllers([nextVC], direction: direction, animated: true)
        pageControl.currentPage = currentPageIndex
    }
    
    private func _logEventForPage(index: Int) {
        switch index {
        case 0: AnalyticsHelper.shared.logEvent(.onboardingScreen1)
        case 1: AnalyticsHelper.shared.logEvent(.onboardingScreen2)
        case 2: AnalyticsHelper.shared.logEvent(.onboardingScreen3)
        default: break
        }
    }
    
    
    
    
    @IBAction func didTapNext(_ sender: UIButton) {
        if currentPageIndex < 2 {
            changePage(direction: .forward)
        } else {
            delegate?.onboardingVC(self)
        }
    }
    
    @IBAction func didTapSkip(_ sender: UIButton) {
        delegate?.onboardingVC(self)
    }
    
    
}

extension OnboardingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
            
        if viewControllerIndex == 0 { return nil }
        currentPageIndex = viewControllerIndex - 1
        _logEventForPage(index: currentPageIndex)
        return pageControllerItems[currentPageIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == pageControllerItems.count - 1 { return nil }
        currentPageIndex = viewControllerIndex + 1
        _logEventForPage(index: currentPageIndex)
        return pageControllerItems[currentPageIndex]
    }
}

extension OnboardingVC: UIPageViewControllerDelegate {
    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
       
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        let index = pageControllerItems.firstIndex(of: pendingViewControllers.first ?? UIViewController())
        pageControl.currentPage = index ?? 0
    }
}
