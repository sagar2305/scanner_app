//
//  SettingsCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit
import MessageUI

class SettingsCoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinators: [Coordinator] = []
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
    
    private func _presentEmail(suffix: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.SettingDefaults.feedbackEmail])
            let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
            mail.setSubject("\(appName ?? "Guess the Movie") " + "\(suffix)")
            mail.setMessageBody(messageBody(), isHTML: true)

            navigationController.present(mail, animated: true)
        } else {
            // show failure alert
            let message = "Please configure your device mailbox to send mail"
            let alert = UIAlertController(title: "Mail Not Configured",
                                          message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            }))
        }
    }
}

extension SettingsCoordinator: SettingsVCDelegate {
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting) {
        switch setting.id {
        case .termsOfLaw:
            _presentWebView(for: Constants.WebLinks.termsOfLaw, title: "Terms Of Law")
        case .privacyPolicy:
            _presentWebView(for: Constants.WebLinks.privacyPolicy, title: "Privacy Policy")
        case .featureRequest:
            _presentEmail(suffix: "Feature Request")
        case .subscription:
            SubscriptionHelper.shared.startSubscribeCoordinator(navigationController: navigationController, parentCoordinator: self)
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


// MARK: - MFMailComposeViewControllerDelegate
extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
    
    func messageBody() -> String {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String
        
        var body = """
            <i>Please type your comment below and tap "Send". We'll try our best to get back
            to you as soon as possible.</i>
            """
        body += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
        body += """
            Device: \(UIDevice.current.localizedModel)<br>
            OS: \(UIDevice.current.systemVersion)<br>
            App: \(appName!)<br>
            Version: \(appVersion!)<br>
            Build: \(bundleVersion!)<br>
            \(UIDevice.current.identifierForVendor!.uuidString)
            """
        return body
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
