//
//  SubscriptionHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 08/04/21.
//

import UIKit
import Purchases

class SubscriptionHelper {
    
    enum InAppPurchaseError: Error {
        case noProductsAvailable
        case purchasedFailed
        case userCancelledPurchase
    }
    
    enum EventForSubscription {
        case call
        case giftOffer
        case onFirstOnBoardingCompletion
        case playRecording
        case transcribeRecording
        case shareRecording
    }
    
    static let shared = SubscriptionHelper()
    typealias CompletionHandler = (_ product: [IAPProduct]?, InAppPurchaseError?) -> Void
    typealias PurchaseCompletion = (_ success: Bool, InAppPurchaseError?) -> Void
    
    private init() {
        refreshPurchaseInfo()
    }
    
    private(set) var isProUser: Bool = false
    
    private func _process(purchaserInfo: Purchases.PurchaserInfo?) {
        guard let purchaserInfo = purchaserInfo else {
            return
        }
        
        if purchaserInfo.entitlements.all["pro"]?.isActive == true {
            isProUser = true
        } else {
            isProUser = false
        }
    }
    
    func refreshPurchaseInfo() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            self._process(purchaserInfo: purchaserInfo)
        }
    }

    func restorePurchases(_ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            guard error == nil else {
                completionHandler(false, .purchasedFailed)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self.isProUser = true
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
    private func _offeringIdentifier(for event: EventForSubscription) -> String {
        switch event {
        case .playRecording,
             .transcribeRecording,
             .shareRecording,
             .giftOffer:
            return Constants.Offering.onlyAnnualDiscountedNoTrialRecordingScreen
        case .onFirstOnBoardingCompletion:
            return Constants.Offering.onlyAnnualDiscountedNoTrialOnboarding
        case .call:
            return Constants.Offering.onlyAnnualDiscountedNoTrialHomeScreen
        }
    }
    
    func startSubscribeCoordinator(navigationController: UINavigationController, parentCoordinator: Coordinator, currentEvent: EventForSubscription = .call) {
//        let identifier = _offeringIdentifier(for: currentEvent)
        let identifier = Constants.Offering.lifetime
        let subscribeCoordinator = SubscribeCoordinator(navigationController: navigationController, offeringIdentifier: identifier)
        subscribeCoordinator.parentCoordinator = parentCoordinator
        subscribeCoordinator.currentEvent = currentEvent
        parentCoordinator.childCoordinators.append(subscribeCoordinator)
        subscribeCoordinator.start()
    }
    
    func fetchAvailableProducts(for offeringIdentifier: String? = nil, completionHandler: @escaping CompletionHandler) {
        var availableProducts: [IAPProduct]?
        Purchases.shared.offerings { (offerings, _) in
            if let offerings = offerings {
                
                if offeringIdentifier == nil {
                    // all available packages
                    if let packages = offerings.current?.availablePackages {
                        availableProducts = packages.map { IAPProduct(package: $0) }
                    }
                } else {
                    //
                    if let packages = offerings.offering(identifier: offeringIdentifier)?.availablePackages {
                        availableProducts = packages.map { IAPProduct(package: $0) }
                    }
                }
                
                // completion before notif to pass on the value
                completionHandler(availableProducts, nil)
            } else {
                completionHandler(availableProducts, InAppPurchaseError.noProductsAvailable)
            }
        }
    }
    
    func purchasePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
        
        Purchases.shared.purchasePackage(package.package) { (transaction, purchaserInfo, error, userCancelled) in
            
            if userCancelled {
                completionHandler(!userCancelled, .userCancelledPurchase)
                return
            }
            
            guard error == nil else {
                completionHandler(false, .purchasedFailed)
                return
            }
            
            guard let transaction = transaction else {
                completionHandler(false, nil)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self.isProUser = true
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
}

