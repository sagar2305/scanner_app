//
//  AppDelegate.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import Purchases
import SwiftDate
import Mixpanel
import Amplitude
import TTInAppPurchases
import CloudKit
import FirebaseCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootCoordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customisation after application launch.
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let isUserOnboarded = UserDefaults.standard.bool(forKey: Constants.DocumentScannerDefaults.userIsOnboardedKey)
        
        #if DEBUG
        //b72ebd5fde57d78856963cab243a4afcMixpanel.initialize(token: Constants.APIKeys.mixPanelDevelopmentKey)
        Amplitude.instance().initializeApiKey(Constants.APIKeys.amplitudeDevelopmentKey)
        #else
        //Mixpanel.initialize(token: Constants.APIKeys.mixPanelProductionKey)
        Amplitude.instance().initializeApiKey(Constants.APIKeys.amplitudeProductionKey)
        #endif
        
        if isUserOnboarded {
            rootCoordinator = ApplicationCoordinator(window!)
        } else {
            AnalyticsHelper.shared.saveUserProperty(.appInstallationDate, value: Date().toFormat("yyyy-MM-dd HH:mm"))
            rootCoordinator = OnboardingCoordinator(window!)
        }
        UIApplication.shared.registerForRemoteNotifications()
        NotificationHelper.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
        Purchases.configure(withAPIKey: Constants.APIKeys.revenueCat)
        _ = TTInAppPurchases.SubscriptionHelper.shared // updating whether user is pro or not on app launch
        _ = CloudKitHelper.shared //for running background upadates
        rootCoordinator?.start()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    

}

// MARK: - Remote notifications
extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            // this is ck notification
            CloudKitHelper.shared.handleCloudKit(notification: ckNotification)
        }
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        startSubscriptionCoordinator()
        completionHandler()
    }
    
    private func startSubscriptionCoordinator() {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? DocumentScannerNavigationController else {
            print("Couldn't access navigation controller")
            return
        }
        let subscriptionCoordinator = SubscribeCoordinator(navigationController: navigationController,
                                                           offeringIdentifier: Constants.Offering.weeklyMonthlyAndAnnual,
                                                           presented: true,
                                                           giftOffer: false,
                                                           hideCloseButton: false,
                                                           showSpecialOffer: false)
        rootCoordinator?.childCoordinators.append(subscriptionCoordinator)
        subscriptionCoordinator.start()
        AnalyticsHelper.shared.logEvent(.userClickedOnNotification)
    }
}
