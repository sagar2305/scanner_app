//
//  DocumentHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 26/05/21.
//

import Foundation

struct DocumentHelper {
    
    static let shared = DocumentHelper()
    
    private init() { }
    
    var documents: [Document] {
        return UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
    }
    
    func deleteDocument(with id: String) {
        
    }
}
