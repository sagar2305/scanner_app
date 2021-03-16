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
    
    var parentCoordinator: Coordinator
    var childCoordinator: [Coordinator] = []
    var navigationController: UINavigationController!
    var settingsVC: SettingsVC!
    var webVC: WebViewVC!
    
    
    func start() {
        settingsVC = SettingsVC()
        settingsVC.delegate = self
        navigationController = UINavigationController(rootViewController: settingsVC)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        parentCoordinator.rootViewController.present(navigationController, animated: true)
    }
    
    init(_ parent: Coordinator) {
        parentCoordinator = parent
    }
    
    
    private func _presentWebView(for url: String) {
        webVC = WebViewVC()
        webVC.delegate = self
        webVC.webPageLink = url
        navigationController.pushViewController(webVC, animated: true)
    }
}

extension SettingsCoordinator: SettingsVCDelegate {
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting) {
        switch setting.id {
        case .termsOfLaw:
            _presentWebView(for: Constant.WebLinks.termsOfLaw)
        case .privacyPolicy:
            _presentWebView(for: Constant.WebLinks.privacyPolicy)
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
