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
    
    var navigationController: DocumentScannerNavigationController
    var homeViewController: HomeViewController
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    
    init(_ window: UIWindow) {
        self.window = window
        homeViewController = HomeViewController()
        navigationController = DocumentScannerNavigationController(rootViewController: homeViewController)
        //navigationController.isNavigationBarHidden = true
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
        let pickDocumentCoordinator = PickDocumentCoordinator(navigationController)
        pickDocumentCoordinator.delegate = self
        childCoordinator.append(pickDocumentCoordinator)
        pickDocumentCoordinator.start()
    }
    
    func showSettings(_ controller: HomeViewController) {
        let settingsCoordinator = SettingsCoordinator(navigationController)
        childCoordinator.append(settingsCoordinator)
        settingsCoordinator.start()
    }
    
    func viewDocument(_ controller: HomeViewController, document: Document) {
        let documentViewerCoordinator = DocumentViewerCoordinator(navigationController, document: document)
        childCoordinator.append(documentViewerCoordinator)
        documentViewerCoordinator.start()
    }
}

extension ApplicationCoordinator: ScanDocumentCoordinatorDelegate {
    
    func didFinishScanningDocument(_ coordinator: ScanDocumentCoordinator) {
        navigationController.popToViewController(homeViewController, animated: true)
    }
    
    func didCancelScanningDocument(_ coordinator: ScanDocumentCoordinator) {
        navigationController.popToViewController(homeViewController, animated: true)
    }
}

extension ApplicationCoordinator: PickerDocumentCoordinatorDelegate {
    func didFinishedPickingImage(_ coordinator: PickDocumentCoordinator) {
        navigationController.popToViewController(homeViewController, animated: true)
    }
    
    func didCancelPickingImage(_ coordinator: PickDocumentCoordinator) {
        navigationController.popToViewController(homeViewController, animated: true)
    }
    
    
}
