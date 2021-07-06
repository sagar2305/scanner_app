//
//  DocumentHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 26/05/21.
//

import UIKit

struct DocumentHelper {
    
    static let shared = DocumentHelper()
    
    private init() { }
    
    var documents: [Document] {
        return UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
    }
    
    func deleteDocumentWithID(_ id: String, isNotifiedFromiCloud: Bool) {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.forEach( { $0.printIDS() })
        print("id to delete => \(id)")
        documents.removeAll { document in document.id == id }
        documents.forEach( { $0.printIDS() })
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
        NotificationCenter.default.post(name: .documentDeletedLocally, object: self)
        if !isNotifiedFromiCloud {
            CloudKitHelper.shared.deletedDocumentFromiCloud(with: id)
        }
    }
    
    func delete(document: Document) {
        deleteDocumentWithID(document.id, isNotifiedFromiCloud: false)
    }
    
    func updateEditedImage(_ image: UIImage, for page: Page, of document: Document) -> Bool {
        let result = page.saveEditedImage(image)
        if result {
            document.update()
            CloudKitHelper.shared.addOrUpdatePage(page, of: document)
        }
        return result
    }
    
    func getDocument(with id: String) -> Document? {
        return documents.first { $0.id == id }
    }
    
    func getPageAndDocumentContainingPage(with id: String) -> (page: Page?,document: Document?) {
        for document in documents {
            if let matchingPage = document.pages.first(where: { page in page.id == id }) {
                return (matchingPage, document)
            }
        }
        return (nil, nil)
    }
}
