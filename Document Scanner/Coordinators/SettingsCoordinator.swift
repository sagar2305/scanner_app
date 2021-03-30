//
//  SettingsCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit

class SettingsCoordinator: Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinator: [Coordinator] = []
    var navigationController: DocumentScannerNavigationController!
    var settingsVC: SettingsVC!
    var webVC: WebViewVC!
    
    
    func start() {
        settingsVC = SettingsVC()
        settingsVC.delegate = self
        settingsVC.heroModalAnimationType = .fade
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(settingsVC, animated: true)
    }
    
    init(_ navigationController: DocumentScannerNavigationController) {
        self.navigationController = navigationController
    }
    
    
    private func _presentWebView(for url: String, title: String) {
        webVC = WebViewVC()
        webVC.delegate = self
        webVC.webPageTitle = title
        webVC.webPageLink = url
        navigationController.pushViewController(webVC, animated: true)
    }
}

extension SettingsCoordinator: SettingsVCDelegate {
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting) {
        switch setting.id {
        case .termsOfLaw:
            _presentWebView(for: Constant.WebLinks.termsOfLaw, title: "Terms Of Law")
        case .privacyPolicy:
            _presentWebView(for: Constant.WebLinks.privacyPolicy, title: "Privacy Policy")
        }
    }
    
    func settingsViewController(exit controller: SettingsVC) {
        rootViewController.dismiss(animated: true)
    }
}

extension SettingsCoordinator: WebViewVCsDelegate {
    func webViewVC(exit controller: WebViewVC) {
        navigationController.popViewController(animated: true)
    }
}
