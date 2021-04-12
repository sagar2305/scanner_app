//
//  SubscriptionViewControllerDelegate.swift
//  CallRecorder
//
//  Created by Sandesh on 29/10/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

protocol SubscriptionViewControllerDelegate: class {
    func viewWillAppear(_ controller: SubscriptionViewControllerProtocol)
    func viewDidAppear(_ controller: SubscriptionViewControllerProtocol)
    func exit(_ controller: SubscriptionViewControllerProtocol)
    func selectPlan(at index: Int, controller: SubscriptionViewControllerProtocol)
    func restorePurchases(_ controller: SubscriptionViewControllerProtocol)
    func showPrivacyPolicy(_ controller: SubscriptionViewControllerProtocol)
    func showTermsOfLaw(_ controller: SubscriptionViewControllerProtocol)
}

protocol UpgradeUIProviderDelegate: class {
    func productsFetched() -> Bool
    func headerMessage(for index: Int) -> String
    func subscriptionTitle(for index: Int) -> String
    func subscriptionPrice(for index: Int, withDurationSuffix: Bool) -> String
    func continueButtonTitle(for index: Int) -> String
    func offersFreeTrial(for index: Int) -> Bool
    func introductoryPrice(for index: Int, withDurationSuffix: Bool) -> String
}
