//
//  ReviewHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 08/06/21.
//

import StoreKit

class ReviewHelper {
    
    static let shared = ReviewHelper()
    
    private var requestDate: Date? {
        get {
            let date = UserDefaults.standard.object(forKey: Constants.DocumentScannerDefaults.lastReviewRequestDate) as? Date
            return date
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.DocumentScannerDefaults.lastReviewRequestDate)
        }
    }
    
    private init() {}
    
    func requestAppRating() {
        
        if let requestDate = requestDate, Date().minutes(from: requestDate) < 5 {
            return
        }
        requestDate = Date()
        AnalyticsHelper.shared.logEvent(.reviewPromptRequested)
        SKStoreReviewController.requestReview()
    }
}
