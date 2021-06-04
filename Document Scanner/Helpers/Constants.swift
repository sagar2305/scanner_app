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
        static let userPropertiesKey = "UserPropertiesKey"
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
        //TODO: - Add missing keys
        static let amplitudeDevelopmentKey = "2b54909aad36f3be61b99e2fcff80370"
        static let amplitudeProductionKey = "b72ebd5fde57d78856963cab243a4afc"
        static let mixPanelDevelopmentKey = ""
        static let mixPanelProductionKey = ""

    }
    
    enum AnalyticsUserProperties: String, CustomStringConvertible {
        
        var description: String {
            return self.rawValue
        }
        
        case appInstallationDate = "Installation Date"
        case userId = "User Id"
        case userPlan = "User Plan"
        case dateOfSubScription = "Date Of Subscription"
        case numberOfDocuments = "Number Of Document"
          case appVersion = "App Version"
    }
    
    enum AnalyticsEvent: String, CustomStringConvertible {
        
        var description: String {
            return self.rawValue
        }
        
        case completedOnboarding = "Completed onboarding" //done
        case onboardingScreen1 = "Viewed Onboarding Screen One" //done
        case onboardingScreen2 = "Viewed Onboarding Screen Two" //done
        case onboardingScreen3 = "Viewed Onboarding Screen Three" //done
        case userPickedDocument = "User Picked Document" //done
        case userScannedDocument = "User Scanned Document" //done
        case savedDocument = "Saved Document"
        case documentSavingFailed = "Document Saving Failed" //done
        case userOpenedDocument = "Opened Document" //done
        case userDeletedDocument = "Deleted Document" // done
        case renamedDocument = "Renamed Document" // done
        case userSharedDocument = "User Shared Document" // done
        case documentSharingFailed = "Document Sharing Failed" //done
        case visitedSettings = "Visited Settings" //done
        case invitedFriend = "Invited Friend" //done
        case sendingInviteFailed = "Sending Invite Failed" //done
        case raisedFeatureRequest = "Requested Feature" //done
        case reportedABug = "Reported A Bug" //done
        case featureRequestFailed = "Requesting Feature Failed" //done
        case reportingBugFailed = "Reporting Bug Failed" //done
        case viewedPrivacyPolicy = "Viewed Privacy Policies" //done
        case viewedTermsAndLaws = "Viewed Terms And Laws" //done
        
        //image editing
        case userEditingImage = "Started Editing Image" //done
        case cancelledEditingImage = "Cancelled Editing Image" //done
        case finishedEditingImage = "Finished Editing Image" //done
        case rotatedImage = "Rotated Image" //done
        case croppedImage = "Cropped Image" //done
        case mirroredImage = "Mirrored Image" //done
        case adjustedBrightness = "Adjusted Brightness" //done
        case adjustedContrast = "Adjusted Contrast" //done
        case adjustedSaturation = "Adjusted Saturation" //done
        case setOriginalImage = "Set Original Image Color" //done
        case setBlackAndWhiteImage = "Set BlackAndWhite Image Color" //done
        case setGrayScaleImage = "Set GrayScale Image Color" //done
        
    }

    enum AnalyticsEventProperties: String, CustomStringConvertible {
    
        var description: String {
            return self.rawValue
        }
        
        case numberOfDocuments = "Number of Documents"
        case numberOfDocumentPages = "Number of Pages"
        case documentID = "Document ID"
        case pageID = "Page ID"
        
        //for registration
        case phoneNumber = "Phone Number"
        case firebaseVerificationId = "Firebase ID"
        case isNewUser = "Is New User"
        
        //iCloud
        case recordId = "Record Id"
        case lastFetchDate = "Last Fetch Date"
        case recordingReceived = "Recording fetched"
        case autoTriggered = "Auto Triggered"
        
        //recording API
        case dateQueryItem = "Query Date"
        
    }
}
