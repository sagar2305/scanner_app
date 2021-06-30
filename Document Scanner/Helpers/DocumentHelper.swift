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
    
    func deleteDocumentWithID(_ id: String, isNotifiedFromiCloud: Bool) {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.removeAll { $0.id == id }
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
        
        if !isNotifiedFromiCloud {
            CloudKitHelper.shared.deletedDocumentFromiCloud(with: id)
        }
    }
    
    func delete(document: Document) {
        deleteDocumentWithID(document.id, isNotifiedFromiCloud: false)
    }
    
    func getDocument(with id: String) -> Document? {
        return documents.first { $0.id == id }
    }
    
    func getPageAndDocumentContainingPage(with id: String) -> (page: Page?,document: Document?) {
//        documents.forEach { document in
//            if let matchingPage = document.pages.first(where: { page in page.id == id }) {
//                // page is found
//                return (matchingPage, document)
//            }
//        }
//        return (nil, nil)
        //TODO: - Finish this 
    }
}
