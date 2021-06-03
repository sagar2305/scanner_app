//
//  Setting.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import Foundation

enum SettingTypes: Hashable, CaseIterable, CustomStringConvertible {
    case documentScanner
    case miscellaneous
    case manage
    case support
    
    var description: String {
        switch self {
        case .documentScanner: return "Document Scanner".localized
        case .miscellaneous: return "Misc".localized
        case .manage: return "Manage".localized
        case .support: return "Support".localized
        }
    }
}

enum SettingIdentifier: Int {
    case inviteFriends = 6683
    case termsOfLaw = 6684
    case privacyPolicy = 6685
    case featureRequest = 6686
    case reportError = 6687
    case subscription = 6688
    case restorePurchases = 6689
}

struct Setting {
    let id: SettingIdentifier
    let name: String
    let type: SettingTypes
}
