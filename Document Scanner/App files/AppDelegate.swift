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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootCoordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customisation after application launch.
        
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
        
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        Purchases.configure(withAPIKey: Constants.APIKeys.revenueCat)
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

