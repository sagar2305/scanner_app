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
    
    func allSettings() -> [Setting] {
        return [
            Setting(id: .privacyPolicy, name: "Privacy Policy"),
            Setting(id: .termsOfLaw, name: "Terms of Law"),
            Setting(id: .featureRequest, name: "Request feature"),
            Setting(id: .subscription, name: "Upgrade")
        ]
    }
}
