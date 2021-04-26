//
//  OnboardingVC.swift
//  Document Scanner
//
//  Created by Sandesh on 26/04/21.
//

import UIKit
import SnapKit

protocol OnboardingVCDelegate: class {
    func onboardingVC(_ continue: DocumentScannerViewController)
}

class OnboardingVC: DocumentScannerViewController {

    private var pageControllerItems: [UIViewController] = []
    
    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.dataSource = self
        controller.delegate = self
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    var delegate: OnboardingVCDelegate?
    
    @IBOutlet weak var pageControllerContainer: UIView!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
        continueButton.layer.cornerRadius = 8
        continueButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .callout))
        continueButton.setTitle("Continue", for: .normal)
    }
    
    private func _generateItemsForPageControls() {
        let pageControlItem1 = UIViewController()
        pageControlItem1.view = OnboardingView(header: "EASY TO SCAN",
                                               description: "Quickly scan or select and generate digital copy of your document",
                                               image: UIImage(named: "store-document")!)
        pageControllerItems.append(pageControlItem1)
        
        let pageControlItem2 = UIViewController()
        pageControlItem2.view = OnboardingView(header: "ORGANISE FILES EASILY",
                                               description: "Have all your digital document in one place",
                                               image: UIImage(named: "organize-document")!)
        pageControllerItems.append(pageControlItem2)
        
        let pageControlItem3 = UIViewController()
        pageControlItem3.view = OnboardingView(header: "SHARE IT",
                                               description: "Quickly share the files in the format that you prefer",
                                               image: UIImage(named: "share-document")!)
        pageControllerItems.append(pageControlItem3)
        pageController.setViewControllers([pageControllerItems.first!], direction: .forward, animated: true, completion: nil)
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
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        delegate?.onboardingVC(self)
    }
    
}

extension OnboardingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
            
        if viewControllerIndex == 0 { return nil }
        return pageControllerItems[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageControllerItems.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == pageControllerItems.count - 1 { return nil }
        
        return pageControllerItems[viewControllerIndex + 1]
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