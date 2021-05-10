//
//  Constants.swift
//  Document Scanner
//
//  Created by Sandesh on 11/03/21.
//

import Foundation

struct Constants {
    struct DocumentScannerDefaults {
        static let documentsListKey = "DocumentsListKey"
        static let userIsOnboarded = "UserIsOnboarded"
    }
    
    struct WebLinks {
        static let termsOfLaw = "https://eztape.app/terms-and-conditions.html"
        static let privacyPolicy = "https://eztape.app/privacy-policy.html"
    }
    
    struct HeroIdentifiers {
        static let headerIdentifier = "header_view"
        static let footerIdentifier = "footer_view"
    }
    
    struct  SettingDefaults {
        static let feedbackEmail = "support@eztape.app"
    }
    
    struct Offering {
        static let onlyAnnualDiscountedNoTrialOnboarding = "onlyannualdiscounted_notrial_onboarding"
        static let onlyAnnualDiscountedNoTrialHomeScreen = "onlyannualdiscounted_notrial_homescreen"
        static let onlyAnnualDiscountedNoTrialRecordingScreen = "onlyannualdiscounted_notrial_recordingscreen"
        static let weeklyAndAnnualReduced = "weeklyandannualreduced"
        static let annualReducedSpecialOffer = "annualreduced"
        static let lifetime = "lifetime"
    }
    
    enum Fonts: String {
        case avenirBlack = "Avenir Black"
        case avenirBook = "Avenir Book"
        case avenirLight = "Avenir Light"
        case avenirMedium = "Avenir Medium"
        case avenirRegular = "Avenir Regular"
    }
    
}
