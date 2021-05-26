//
//  OnboardingCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 26/04/21.
//

import UIKit

class OnboardingCoordinator: Coordinator {

    let window: UIWindow
    let rootVC: DocumentScannerNavigationController
    let onboardVC: OnboardingVC
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return rootVC
    }
    
    init(_ window: UIWindow) {
        self.window = window
        onboardVC = OnboardingVC()
        rootVC = DocumentScannerNavigationController(rootViewController: onboardVC)
        onboardVC.delegate = self
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}

extension OnboardingCoordinator: OnboardingVCDelegate {
    func onboardingVC(_ continue: DocumentScannerViewController) {
        UserDefaults.standard.setValue(true, forKey: Constants.DocumentScannerDefaults.userIsOnboardedKey)
        let subscriptionCoordinator = SubscribeCoordinator(navigationController: rootVC,
                                                           offeringIdentifier: Constants.Offering.annualFullPriceAndSpecialOffer,
                                                           presented: false,
                                                           giftOffer: false,
                                                           hideCloseButton: false,
                                                           showSpecialOffer: true)
        childCoordinators.append(subscriptionCoordinator)
        subscriptionCoordinator.start()
    }
}
