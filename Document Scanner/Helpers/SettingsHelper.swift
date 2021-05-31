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
        Setting(id: .inviteFriends, name: "Invite Friend", type: .documentScanner),
        Setting(id: .subscription, name: "Upgrade", type: .manage),
        Setting(id: .restorePurchases, name: "Restore Purchase", type: .manage),
        Setting(id: .featureRequest, name: "Request feature", type: .support),
        Setting(id: .reportError, name: "Report a Bug", type: .support),
        Setting(id: .privacyPolicy, name: "Privacy Policy", type: .miscellaneous),
        Setting(id: .termsOfLaw, name: "Terms of Law", type: .miscellaneous),
    ]
    
    
    func getSettings(for type: SettingTypes) -> [Setting] {
        return allSettings.filter { $0.type == type }
    }
}
