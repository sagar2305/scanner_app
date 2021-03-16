//
//  Setting.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import Foundation

enum SettingIdentifier: Int {
    case termsOfLaw = 6684
    case privacyPolicy = 6685
}

struct Setting {
    let id: SettingIdentifier
    let name: String
}
