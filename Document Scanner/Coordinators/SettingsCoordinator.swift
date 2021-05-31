//
//  SettingsCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit
import MessageUI
import TTInAppPurchases
import NVActivityIndicatorView

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
            let message = "Please configure your device mailbox to send mail".localized
            let alert = UIAlertController(title: "Mail Not Configured".localized,
                                          message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            }))
        }
    }
}

extension SettingsCoordinator: SettingsVCDelegate {
    func viewDidLoad(_ controller: DocumentScannerViewController) {
        var settings = [[Setting]]()
        settings.append(SettingsHelper.shared.getSettings(for: .documentScanner))
        settings.append(SettingsHelper.shared.getSettings(for: .manage))
        settings.append(SettingsHelper.shared.getSettings(for: .support))
        settings.append(SettingsHelper.shared.getSettings(for: .miscellaneous))
        settingsVC.settings = settings
    }
    
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting) {
        switch setting.id {
        case .termsOfLaw:
            _presentWebView(for: Constants.WebLinks.termsOfLaw, title: "Terms Of Law".localized)
        case .privacyPolicy:
            _presentWebView(for: Constants.WebLinks.privacyPolicy, title: "Privacy Policy".localized)
        case .featureRequest:
            _presentEmail(suffix: "Feature Request".localized)
        case .subscription:
            startSubscriptionCoordinator()
        case .inviteFriends:
            _inviteFriends()
        case .reportError:
            _presentEmail(suffix: "Report a Bug".localized)
        case .restorePurchases:
            _restorePurchases()
        }
    }
    
    private func startSubscriptionCoordinator() {
        
        if SubscriptionHelper.shared.isProUser {
            AlertMessageHelper.shared.presentAlreadyProAlert { }
            return
        }
        
        let subscriptionCoordinator = SubscribeCoordinator(navigationController: navigationController,
                                                           offeringIdentifier: Constants.Offering.annualFullPriceAndSpecialOffer,
                                                           presented: true,
                                                           giftOffer: false,
                                                           hideCloseButton: false,
                                                           showSpecialOffer: true)
        childCoordinators.append(subscriptionCoordinator)
        subscriptionCoordinator.start()
    }
    
    func settingsViewController(exit controller: SettingsVC) {
        rootViewController.dismiss(animated: true)
    }
    
    private func _inviteFriends() {
        if let appURL = URL(string: Constants.SettingDefaults.appUrl) {
            let objectsToShare = ["InviteMessage".localized, appURL] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if #available(iOS 13.0, *) {
                UINavigationBar.appearance().barTintColor = .blue
            }
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                UIActivity.ActivityType.addToReadingList]
            navigationController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func _restorePurchases() {
        NVActivityIndicatorView.start()
        AnalyticsHelper.shared.logEvent(.restoredPurchase)
        SubscriptionHelper.shared.restorePurchases {[weak self] (success, error) in
            NVActivityIndicatorView.stop()
            guard error == nil else {
                self?._presentRestorationFailedAlert()
                return
            }
            if success {
                print("SUCESS *****************")
            } else {
                self?.startSubscriptionCoordinator()
            }
        }
    }
    
    private func _presentRestorationFailedAlert() {
        AlertMessageHelper.shared.presentRestorationFailedAlert(onRetry: self._restorePurchases,
            onCancel: {})
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
