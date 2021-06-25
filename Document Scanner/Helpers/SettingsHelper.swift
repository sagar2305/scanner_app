//
//  SettingsHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import Foundation

struct SettingsHelper {
    
    static let shared = SettingsHelper()
    private init() { }
    
    private let allSettings: [Setting] = [
        Setting(id: .inviteFriends, name: "Invite Friends".localized, type: .documentScanner),
        Setting(id: .subscription, name: "Upgrade".localized, type: .manage),
        Setting(id: .restorePurchases, name: "Restore Purchase".localized, type: .manage),
        Setting(id: .featureRequest, name: "Request feature".localized, type: .support),
        Setting(id: .reportError, name: "Report a Bug".localized, type: .support),
        Setting(id: .privacyPolicy, name: "Privacy Policy".localized, type: .miscellaneous),
        Setting(id: .termsOfLaw, name: "Terms of Law".localized, type: .miscellaneous),
    ]
    
    
    func getSettings(for type: SettingTypes) -> [Setting] {
        return allSettings.filter { $0.type == type }
    }
}
