//
//  SubcriptionHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 20/08/21.
//

import Foundation

struct SubcriptionHelper {
    
    static let shared = SubcriptionHelper()
    private init() { }
    
    
    var packageIdentifier: String {
        return Constants.Offering.weeklyMonthlyAndAnnual
    }
    
    var isSpecialOfferAvailable: Bool {
        packageIdentifier == Constants.Offering.annualFullPriceAndSpecialOffer
    }
}
