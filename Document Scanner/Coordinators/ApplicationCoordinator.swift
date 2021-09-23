//
//  ApplicationCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import TTInAppPurchases

class ApplicationCoordinator: Coordinator {
    
    var window: UIWindow
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: DocumentScannerNavigationController
    var homeViewController: HomeVC
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    
    init(_ window: UIWindow) {
        self.window = window
        
        if #available(iOS 13.0, *) {
            homeViewController = HomeViewController()
        } else {
            homeViewController = LegacyHomeViewController(nibName: "HomeViewController", bundle: .main)
        }
        navigationController = DocumentScannerNavigationController(rootViewController: homeViewController)
        //navigationController.isNavigationBarHidden = true
        homeViewController.delegate = self
    }
    
    private func startSubscriptionCoordinator() {
        let subscriptionCoordinator = SubscribeCoordinator(navigationController: navigationController,
                                                           offeringIdentifier: Constants.Offering.annualFullPriceAndSpecialOffer,
                                                           presented: true,
                                                           giftOffer: false,
                                                           hideCloseButton: false,
                                                           showSpecialOffer: true)
        childCoordinators.append(subscriptionCoordinator)
        subscriptionCoordinator.start()
    }
}

extension ApplicationCoordinator: HomeViewControllerDelegate {
    
    
    func viewDidAppear(_controller: HomeVC) {
        ReviewHelper.shared.requestAppRating()
    }
    
    func scanNewDocument(_ controller: HomeVC) {
        if SubscriptionHelper.shared.isProUser || DocumentHelper.shared.totalDocumentsCount < 3 {
            let scanDocumentCoordinator = ScanDocumentCoordinator(navigationController)
            scanDocumentCoordinator.delegate = self
            childCoordinators.append(scanDocumentCoordinator)
            scanDocumentCoordinator.start()
        } else {
            startSubscriptionCoordinator()
        }
    }
    
    func pickNewDocument(_ controller: HomeVC) {
        if SubscriptionHelper.shared.isProUser || DocumentHelper.shared.totalDocumentsCount < 3 {
            let pickDocumentCoordinator = PickDocumentCoordinator(navigationController)
            pickDocumentCoordinator.delegate = self
            childCoordinators.append(pickDocumentCoordinator)
            pickDocumentCoordinator.start()
        } else {
            startSubscriptionCoordinator()
        }
    }
    
    func showSettings(_ controller: HomeVC) {
        let settingsCoordinator = SettingsCoordinator(navigationController)
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
    }
    
    func viewDocument(_ controller: HomeVC, document: Document) {
        let documentViewerCoordinator = DocumentViewerCoordinator(navigationController, document: document)
        childCoordinators.append(documentViewerCoordinator)
        documentViewerCoordinator.start()
    }
    
    func openFolder(_ controller: HomeVC, folder: Folder) {
        if #available(iOS 13.0, *) {
            let foldersCoordinator = FoldersCoordinator(navigationController, folder: folder)
            childCoordinators.append(foldersCoordinator)
            foldersCoordinator.start()
        }
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
