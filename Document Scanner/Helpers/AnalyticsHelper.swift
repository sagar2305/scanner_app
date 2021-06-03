//
//  AnalyticsHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 01/06/21.

//https://help.amplitude.com/hc/en-us/articles/115002278527-iOS-SDK-Installation
//https://help.amplitude.com/hc/en-us/articles/115000465251

import UIKit
import CallKit
import PhoneNumberKit
import SwiftDate
import Amplitude
import Mixpanel

class AnalyticsHelper {
    
    static let shared = AnalyticsHelper()
    lazy var amplitudeInstance = Amplitude.instance()
    //lazy var mixpanelInstance = Mixpanel.mainInstance()
    
    private init() {
        amplitudeInstance.trackingSessionEvents = true
    }
    
    // MARK: - Properties
    
    func createAlias(_ userId: String) {
        DispatchQueue.global().async {
            self.amplitudeInstance.setUserId(userId, startNewSession: false)
            // mixpanelInstance.createAlias(userId, distinctId: mixpanelInstance.distinctId)
        }
    }
    
    func setUserId(_ userId: String) {
        DispatchQueue.global().async {
            self.amplitudeInstance.setUserId(userId, startNewSession: false)
            // mixpanelInstance.identify(distinctId: userId)
            //AppsFlyerLib.shared().customerUserID = userId
        }
    }
    
    // MARK: - Event Logging
    func logEvent(_ event: String) {
        DispatchQueue.global().async {
            self.amplitudeInstance.logEvent(event)
            //mixpanelInstance.track(event: event)
            //AppsFlyerHelper.shared.logEvent(event: event, properties: nil)
        }
    }
    
    func logEvent(_ type: Constants.AnalyticsEvent) {
        DispatchQueue.global().async { [self] in
            self.amplitudeInstance.logEvent(type.rawValue)
            //mixpanelInstance.track(event: type.rawValue)
            //AppsFlyerHelper.shared.logEvent(event: type.rawValue, properties: nil)
        }
    }
    
    func logEvent(_ type: Constants.AnalyticsEvent, properties: [Constants.AnalyticsEventProperties: Any]) {
        DispatchQueue.global().async { [self] in
            self.amplitudeInstance.logEvent(type.rawValue, withEventProperties: properties)
            //        let mixpanelProperties = properties.reduce([:]) { (propertiesSoFar, arg1) -> [String: MixpanelType] in
            //            let (key, value) = arg1
            //            var propertiesSoFar = propertiesSoFar
            //            propertiesSoFar[key.rawValue] = value as? MixpanelType ?? ""
            //            return propertiesSoFar
            //        }
            //  mixpanelInstance.track(event: type.rawValue, properties: mixpanelProperties)
            // AppsFlyerHelper.shared.logEvent(event: type.rawValue, properties: properties)
        }
        
    }
    
    func logRevenue(_ revenue: AMPRevenue) {
        DispatchQueue.global().async { [self] in
            amplitudeInstance.logRevenueV2(revenue)
            // mixpanelInstance.people.trackCharge(amount: revenue.price.doubleValue)
        }
    }
    
    func updateUserProperties() {
        guard let userProperties = UserDefaults.standard.value(forKey: Constants.DocumentScannerDefaults.userPropertiesKey) as? [String: Any] else {
            return
        }
        print(userProperties)
        amplitudeInstance.setUserProperties(userProperties)
        //        let mixpanelProperties = userProperties.reduce([:]) { (propertiesSoFar, arg1) -> [String: MixpanelType] in
        //            let (key, value) = arg1
        //            var propertiesSoFar = propertiesSoFar
        //            propertiesSoFar[key] = value as? MixpanelType ?? ""
        //            return propertiesSoFar
        //        }
        //  mixpanelInstance.people.set(properties: mixpanelProperties)
    }
    
    func saveUserProperty(_ property: Constants.AnalyticsUserProperties, value: String) {
        //check if user properties are already stored in user defaults
        DispatchQueue.global().async {
            if var userProperties = UserDefaults.standard.value(forKey: Constants.DocumentScannerDefaults.userPropertiesKey) as? [String: Any] {
                userProperties[property.rawValue] = value
                UserDefaults.standard.set(userProperties, forKey: Constants.DocumentScannerDefaults.userPropertiesKey)
            } else {
                let userProperty = [property.rawValue: value]
                UserDefaults.standard.set(userProperty, forKey: Constants.DocumentScannerDefaults.userPropertiesKey)
            }
            AnalyticsHelper.shared.updateUserProperties()
        }
    }
}
