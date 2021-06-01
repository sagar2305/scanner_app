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
        static let userIsOnboardedKey = "UserIsOnboardedKey"
        static let timeWhenUserSawSpecialOfferScreenKey = "TimeWhenUserSawSpecialOfferScreenKey"
    }
    
    struct WebLinks {
        static let termsOfLaw = "https://www.guessinggames.co/terms-and-conditions.html"
        static let privacyPolicy = "https://www.guessinggames.co/privacy-policy.html"
    }
    
    struct HeroIdentifiers {
        static let headerIdentifier = "header_view"
        static let footerIdentifier = "footer_view"
    }
    
    struct  SettingDefaults {
        static let feedbackEmail = "support@indianrails.in"
        static let appUrl = "http://itunes.apple.com/app/id1551911173"
    }
    
    struct Offering {
        static let `default` = "Default"
        static let onlyAnnual = "Only_annual"
        static let weekAndAnnual = "Weekandannual"
        static let weekAndAnnualReduced = "Weeklyandannualreduced"
        static let onlyAnnualDiscountedNoTrailOnboarding = "onlyannualdiscounted_notrial_onboarding"
        static let onlyAnnualDiscountedNoTrailHomeScreen = "onlyannualdiscounted_notrial_homescreen"
        static let onlyAnnualNoDiscountNoTrail = "Onlyannualnodiscountnotrial"
        static let annualFullPriceAndSpecialOffer = "Annualfullpriceandspecialoffer"
        static let annualAndLifeTime = "annualnlifetime"
        static let annualReduced = "annualnlifetime"
        static let lifetime = "Lifetime"
    }
    
    enum Fonts: String {
        case avenirBlack = "Avenir Black"
        case avenirBook = "Avenir Book"
        case avenirLight = "Avenir Light"
        case avenirMedium = "Avenir Medium"
        case avenirRegular = "Avenir Regular"
    }
    
    struct APIKeys {
        static let revenueCat = "uvRhgMynQdAhTwBHRsYuaUabcVPkuxLO"
    }
    
}
