//
//  SubscriptionCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 08/04/21.
//

import UIKit
import NVActivityIndicatorView
import TTInAppPurchases
import Lottie
import StoreKit

class SubscribeCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var parentCoordinator: Coordinator?
    var subscriptionVC: SubscriptionViewControllerProtocol
    var specialOfferVC: SpecialOfferViewControllerProtocol?
    var navigationController: UINavigationController
    var timer: Timer?


    var availableProducts: [IAPProduct]?
    private var _productsFetched = false
    private var window: UIWindow?
    private var _offeringIdentifier: String?
    /// This is presented over some navigation or view controller as modal presentation, false represents that user is presented with subscription screen as part of user flow.
    private var _presented: Bool
    private let _showSpecialOffer: Bool

    private var _lastTimeUserShownSubscriptionScreen: Date?
    private var lastTimeUserShownSubscriptionScreen: Date? {
        get {
            return _lastTimeUserShownSubscriptionScreen
        }

        set {
            _lastTimeUserShownSubscriptionScreen = newValue
            UserDefaults.standard.save(newValue, forKey: Constants.DocumentScannerDefaults.timeWhenUserSawSpecialOfferScreenKey)
        }
    }

    
    init(navigationController: DocumentScannerNavigationController, offeringIdentifier: String? = nil, presented: Bool = true, giftOffer: Bool = false, hideCloseButton: Bool = false, showSpecialOffer: Bool = false) {
        _offeringIdentifier = offeringIdentifier
        _presented = presented
        _showSpecialOffer = showSpecialOffer

        // after onboarding we need to show discounted rate and it will always be presented
        if presented {
            subscriptionVC = WeeklyMonthlyAndAnnualViewController(fromPod: true)
        } else {
            subscriptionVC = WeeklyMonthlyAndAnnualViewController(fromPod: true)
        }
        
        _lastTimeUserShownSubscriptionScreen = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.timeWhenUserSawSpecialOfferScreenKey)
        
        subscriptionVC.giftOffer = giftOffer
        subscriptionVC.hideCloseButton = hideCloseButton
        self.navigationController = navigationController
    }
    
    

    func start() {
        self._fetchAvailableProducts()
        subscriptionVC.delegate = self
        subscriptionVC.uiProviderDelegate = self
        
        if _presented {
            let navigationController = DocumentScannerNavigationController(rootViewController: subscriptionVC)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.modalTransitionStyle = .coverVertical
            navigationController.setNavigationBarHidden(true, animated: true)
            self.navigationController.present(navigationController, animated: true)
        } else {
            navigationController.pushViewController(subscriptionVC, animated: true)
        }
    }

    private func _fetchAvailableProducts() {
        SubscriptionHelper.shared.fetchAvailableProducts(for: _offeringIdentifier) { (allProducts, error) in
            print("**********Fetched allProducts")
            self._productsFetched = true
            if error == nil {
                self.availableProducts = allProducts
                NotificationCenter.default.post(name: .iapProductsFetchedNotification,
                                                object: nil)
                print("*****************Products")
                dump(allProducts)
            } else {
                //TODO: - Present product not available alert
               
            }
        }
    }

    private func _dismiss() {
        if _presented {
            navigationController.dismiss(animated: true)
        } else {
            let applicationCoordinator = ApplicationCoordinator(UIWindow.key!)
            childCoordinators.append(applicationCoordinator)
            applicationCoordinator.start()
        }
    }

    var rootViewController: UIViewController {
        return subscriptionVC
    }

    private func showTermsOfLaw() {
        let callRecordLawsVC = WebViewVC()
        callRecordLawsVC.delegate = self
        callRecordLawsVC.configureUI(title: "Terms of law".localized)
        callRecordLawsVC.webPageLink = Constants.WebLinks.termsOfLaw
        navigationController.pushViewController(callRecordLawsVC, animated: true)
        navigationController.setNavigationBarHidden(true, animated: true)
    }

    private func showPrivacyPolicy() {
        let callRecordLawsVC = WebViewVC()
        callRecordLawsVC.delegate = self
        callRecordLawsVC.configureUI(title: "Privacy policy".localized)
        callRecordLawsVC.webPageLink = Constants.WebLinks.privacyPolicy
        navigationController.pushViewController(callRecordLawsVC, animated: true)
        navigationController.setNavigationBarHidden(true, animated: true)
    }

    private func _updateSpecialOfferTimeLabel(_ timeRemainingForOffer: Double) {
        let hour = Int(timeRemainingForOffer) / 3600
        let minutes = Int(timeRemainingForOffer) / 60 % 60
        let seconds = Int(timeRemainingForOffer) % 60
        self.specialOfferVC?.updateTimer(String(format: "%02d", hour) + ":" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds))
    }



    private func _purchaseProduct(_ product: IAPProduct) {
        print("*********Product requested *********")
        dump(product)
        NVActivityIndicatorView.start()
        SubscriptionHelper.shared.purchasePackage(product) { [weak self] (success, error) in
            NVActivityIndicatorView.stop()
            guard error == nil else {
                switch error! {
                case .purchasedFailed:
                    self?._presentPurchaseFailedAlert(product: product)
                    DispatchQueue.global().async {
                        TTInAppPurchases.AnalyticsHelper.shared.logEvent(.purchaseFailure, properties: [
                                                                            .productId: product.identifier,
                                                                            .errorDescription: error?.localizedDescription ?? ""])
                    }
                case .userCancelledPurchase:
                    DispatchQueue.global().async {
                        TTInAppPurchases.AnalyticsHelper.shared.logEvent(.userCancelledPurchase, properties: [
                                                                            .productId: product.identifier])
                    }
                    break
                case .noProductsAvailable:
                    break
                }
                return
            }

            if success {
                if let self = self {
                    TTInAppPurchases.AnalyticsHelper.shared.logEvent(.purchaseComplete)
                    self._dismiss()
                }
            } else {
                DispatchQueue.global().async {
                    TTInAppPurchases.AnalyticsHelper.shared.logEvent(.purchaseFailure, properties: [
                                                                        .productId: product.identifier,
                                                                        .errorDescription: "nil",
                                                                        .result: success])
                }
                self?._presentPurchaseFailedAlert(product: product)
            }
        }
    }

    private func _restorePurchases() {
        NVActivityIndicatorView.start()
        DispatchQueue.global().async {
            TTInAppPurchases.AnalyticsHelper.shared.logEvent(.restoredPurchase)
        }
        SubscriptionHelper.shared.restorePurchases {[weak self] (success, error) in
            NVActivityIndicatorView.stop()
            guard error == nil else {
                DispatchQueue.global().async {
                    TTInAppPurchases.AnalyticsHelper.shared.logEvent(.restorationFailure)
                }
                self?._presentRestorationFailedAlert()
                return
            }
            if success {
                DispatchQueue.global().async {
                    TTInAppPurchases.AnalyticsHelper.shared.logEvent(.restorationSuccessful)
                }
                //TODO: - localize
                AlertMessageHelper.shared.presentRestorationSuccessAlert { }
                self?._dismiss()
            }
        }
    }

    private func _presentPurchaseFailedAlert(product: IAPProduct) {
        AlertMessageHelper.shared.presentPurchaseFailedAlert {
            self._purchaseProduct(product)
        } onCancel: {
            self._dismiss()
        }
    }

    private func _presentRestorationFailedAlert() {
        AlertMessageHelper.shared.presentRestorationFailedAlert {
            self._restorePurchases()
        } onCancel: {
            self._dismiss()
        }
    }

    static func attributedFeatureText(_ feature: String) -> String {
        return "✓  " + feature
    }

}

// MARK: - UpgradeUIProviderDelegate
extension SubscribeCoordinator: UpgradeUIProviderDelegate {
   
    func animatingAnimationView() -> (view: AnimationView, offsetBy: CGFloat?) {
        return (AnimationView(name: "scanner"), 0)
    }
    
    func productsFetched() -> Bool {
        return _productsFetched
    }

    func headerMessage(for index: Int) -> String {
        return "Unlock Unlimited Access".localized
    }

    func subscriptionTitle(for index: Int) -> String {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return ""
        }

        return availableProducts[index].displayName
    }

    func introductoryPrice(for index: Int, withDurationSuffix: Bool) -> String {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return ""
        }

        if withDurationSuffix {
            return availableProducts[index].introductoryPriceWithDurationSuffix
        } else {
            return availableProducts[index].introductoryPrice
        }
    }

    func subscriptionPrice(for index: Int, withDurationSuffix: Bool) -> String {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return ""
        }

        if withDurationSuffix {
            return availableProducts[index].priceWithDurationSuffix
        } else {
            return availableProducts[index].price
        }
    }

    func continueButtonTitle(for index: Int) -> String {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return ""
        }
        return "Unlock Unlimited Access".localized
    }

    func offersFreeTrial(for index: Int) -> Bool {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return false
        }

        return availableProducts[index].offersFreeTrial
    }
    
    func freeTrialDuration(for index: Int) -> String {
        guard let availableProducts = availableProducts,
              availableProducts.count > index else {
            return ""
        }
        
        return availableProducts[index].freeTrialDuration ?? ""
    }
    
    func monthlyBreakdownOfPrice(withIntroDiscount withDiscount: Bool, withDurationSuffix: Bool) -> String {
        guard let availableProduct = availableProducts?.last else {
            return ""
        }

        if withDiscount {
            if let introductoryPrice = availableProduct.product.introductoryPrice?.price {
                if let price = introductoryPrice.dividing(by: 12).toCurrency(locale: availableProduct.product.introductoryPrice?.priceLocale) {
                    return withDurationSuffix ? price + "/" + "month".localized : price
                }
            }
        } else {
            let regularPrice = availableProduct.product.price
            if let price = regularPrice.dividing(by: 12).toCurrency(locale: availableProduct.product.priceLocale) {
                return withDurationSuffix ? price + "/" + "month".localized : price
            }
        }

        return ""
    }
}

// MARK: - UpgradeViewControllerDelegate
extension SubscribeCoordinator: SubscriptionViewControllerDelegate {
    func viewWillAppear(_ controller: SubscriptionViewControllerProtocol) {
        controller.navigationController?.setNavigationBarHidden(true, animated: true)
        if !_productsFetched {
            NVActivityIndicatorView.start()
        }
    }

    func viewDidAppear(_ controller: SubscriptionViewControllerProtocol) {
        if !_productsFetched {
            NVActivityIndicatorView.start()
        }
        TTInAppPurchases.AnalyticsHelper.shared.logEvent(.presentedSubscriptionScreen)
        
    }

    func exit(_ controller: SubscriptionViewControllerProtocol) {

        DispatchQueue.global().async {
            TTInAppPurchases.AnalyticsHelper.shared.logEvent(.cancelledSubscriptionScreen)
        }
        func showSpecialOffer() {
            specialOfferVC = SpecialOfferViewController(fromPod: true)
            specialOfferVC!.delegate = self
            specialOfferVC?.specialOfferUIProviderDelegate = self
            controller.navigationController?.pushViewController(specialOfferVC!, animated: true)
        }
        
        // - Do Not delete below commented code
        
        if _showSpecialOffer {
            if lastTimeUserShownSubscriptionScreen == nil {
                lastTimeUserShownSubscriptionScreen = Date()
                showSpecialOffer()
            } else {
                let lastTime = lastTimeUserShownSubscriptionScreen!
                if  (300 - Date().timeIntervalSince(lastTime)) > 0 {
                    showSpecialOffer()
                } else {
                    self._dismiss()
                }
            }
        } else {
            _dismiss()
        }
    }

    func selectPlan(at index: Int, controller: SubscriptionViewControllerProtocol) {
        guard let availableProducts = availableProducts, availableProducts.count > index else {
            return
        }
        _purchaseProduct(availableProducts[index])
    }

    func restorePurchases(_ controller: SubscriptionViewControllerProtocol) {
        _restorePurchases()
    }
    
    func showPrivacyPolicy(_ controller: SubscriptionViewControllerProtocol) {
        showPrivacyPolicy()
    }

    func showTermsOfLaw(_ controller: SubscriptionViewControllerProtocol) {
        showTermsOfLaw()
    }
}

// MARK: - SpecialOfferViewControllerDelegate
extension SubscribeCoordinator: SpecialOfferViewControllerDelegate {

    func viewDidLoad(_ controller: SpecialOfferViewController) {
        guard let lastTime = lastTimeUserShownSubscriptionScreen  else {
            navigationController.dismiss(animated: true)
            return
        }

        var timeRemainingForOffer = 300 - Date().timeIntervalSince(lastTime)
        _updateSpecialOfferTimeLabel(timeRemainingForOffer)

        if timeRemainingForOffer > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                timeRemainingForOffer -= 1
                if timeRemainingForOffer > 0 {
                    self._updateSpecialOfferTimeLabel(timeRemainingForOffer)
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.navigationController.dismiss(animated: true)
                }
            })
        } else {
            navigationController.dismiss(animated: true)
        }
    }

    func viewWillAppear(_ controller: SpecialOfferViewController) {
        navigationController.setNavigationBarHidden(true, animated: true)
        DispatchQueue.global().async {
            TTInAppPurchases.AnalyticsHelper.shared.logEvent(.specialOfferScreenDidShow)
        }
    }

    func didTapCancelButton(_ controller: SpecialOfferViewController) {
        DispatchQueue.global().async {
            TTInAppPurchases.AnalyticsHelper.shared.logEvent(.specialOfferCancelled)
        }
        _dismiss()
    }

    func purchaseOffer(_ controller: SpecialOfferViewController) {
        // assuming this is the last which you shouldn't
        // refactor later
        //Sandesh determining offer product based on identifier
        guard let annualReducedProduct = availableProducts?.first(where: { $0.identifier == "AnnualSpecialOffer" }) else {
            return
        }
        _purchaseProduct(annualReducedProduct)
    }
    
    func restorePurchases(_ controller: SpecialOfferViewController) {
        _restorePurchases()
    }

    func didTapBackButton(_ controller: SpecialOfferViewController) {
        timer?.invalidate()
        _dismiss()
    }

    func showPrivacyPolicy(_ controller: SpecialOfferViewController) {
        showPrivacyPolicy()
    }

    func showTermsOfLaw(_ controller: SpecialOfferViewController) {
        showTermsOfLaw()
    }
}
// MARK: - SpecialOfferUIProviderDelegate
extension SubscribeCoordinator: SpecialOfferUIProviderDelegate {
    // Sagar assuming first product is always the one with special offer; refactor later
    // Sandesh : Selecting products based on identifiers rather then assuming indexes
    func originalPrice() -> String {
        guard let annualReducedProduct = availableProducts?.first(where: { $0.identifier == "AnnualSpecialOffer" }) else {
            return ""
        }

        return annualReducedProduct.price
    }

    func discountedPrice() -> String {
        guard let annualReducedProduct = availableProducts?.first(where: { $0.identifier == "AnnualSpecialOffer" }) else {
            return ""
        }

        return annualReducedProduct.introductoryPrice
    }

    func percentDiscount() -> String {
        guard let annualReducedProduct = availableProducts?.first(where: { $0.identifier == "AnnualSpecialOffer" }),
              let introductoryPrice = annualReducedProduct.product.introductoryPrice?.price else {
            return ""
        }

        let originalPrice = annualReducedProduct.product.price
        let discount = originalPrice.subtracting(introductoryPrice).dividing(by: originalPrice).multiplying(by: 100)
        return "\(lround(discount.doubleValue))"
    }

    func monthlyComputedDiscountPrice(withIntroDiscount: Bool, withDurationSuffix: Bool) -> String {
        guard let availableProduct = availableProducts?.first(where: { $0.identifier == "AnnualSpecialOffer" }) else {
            return ""
        }

        if withIntroDiscount {
            if let introductoryPrice = availableProduct.product.introductoryPrice?.price {
                if let price = introductoryPrice.dividing(by: 12).toCurrency(locale: availableProduct.product.introductoryPrice?.priceLocale) {
                    return withDurationSuffix ? price + "/" + "month".localized : price
                }
            }
        } else {
            let regularPrice = availableProduct.product.price
            if let price = regularPrice.dividing(by: 12).toCurrency(locale: availableProduct.product.priceLocale) {
                return withDurationSuffix ? price + "/" + "month".localized : price
            }
        }

        return ""
    }
    
    func featureOne() -> String {
        "Unlimited scans".localized
    }
    
    func featureTwo() -> String {
        "High quality scans".localized
    }
    
    func featureThree() -> String {
        "Organize your scans easily".localized
    }
    
    func featureFour() -> String {
        "Share without limits".localized
    }
}

extension SubscribeCoordinator: WebViewVCsDelegate {
    func webViewVC(exit controller: WebViewVC) {
        navigationController.popViewController(animated: true)
    }
}
