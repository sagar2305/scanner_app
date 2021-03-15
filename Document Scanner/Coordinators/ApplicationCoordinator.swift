//
//  ApplicationCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit

class ApplicationCoordinator: Coordinator {
    
    var window: UIWindow
    
    var rootViewController: UIViewController {
        return navigationController
    }
    var childCoordinator: [Coordinator] = []
    
    var navigationController: UINavigationController
    var homeViewController: HomeViewController
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    
    init(_ window: UIWindow) {
        self.window = window
        homeViewController = HomeViewController()
        navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.isNavigationBarHidden = true
        homeViewController.delegate = self
    }
}

extension ApplicationCoordinator: HomeViewControllerDelegate {
    
    func scanNewDocument(_ controller: HomeViewController) {
        let scanDocumentCoordinator = ScanDocumentCoordinator(navigationController)
        scanDocumentCoordinator.delegate = self
        childCoordinator.append(scanDocumentCoordinator)
        scanDocumentCoordinator.start()
    }
    
    func pickNewDocument(_ controller: HomeViewController) {
        
    }
    
    func showSettings(_ controller: HomeViewController) {
        
    }
}

extension ApplicationCoordinator: ScanDocumentCoordinatorDelegate {
    func didFinishScanningDocument(_ coordinator: ScanDocumentCoordinator) {
        navigationController.popToViewController(homeViewController, animated: true)
    }
    
    
}
