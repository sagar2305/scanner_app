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
    
    func generateDocument(originalImages: [UIImage], editedImages: [UIImage]) -> Document? {
        if let document = Document(originalImages: originalImages, editedImages: editedImages) {
            document.save()
            AnalyticsHelper.shared.logEvent(.savedDocument, properties: [
                .documentID: document.id,
                .numberOfDocumentPages: document.pages.count
            ])
            AnalyticsHelper.shared.saveUserProperty(.numberOfDocuments, value: "\(DocumentHelper.shared.documents.count)")
            let haveUserPickedDocument = UserDefaults.standard.bool(forKey: Constants.DocumentScannerDefaults.documentScannedUsingCameraKey)
            if !haveUserPickedDocument {
                UserDefaults.standard.setValue(true, forKey: Constants.DocumentScannerDefaults.documentScannedUsingCameraKey)
                ReviewHelper.shared.requestAppRating()
            }
            return document
        } else {
            AnalyticsHelper.shared.logEvent(.documentSavingFailed, properties: [
                .numberOfDocumentPages: originalImages.count
            ])
            return nil
        }
    }
    
    func addPages(to document: Document,originalImages: [UIImage], editedImages: [UIImage]) -> Bool{
        let lastPageNumber = document.pages.count + 1
        guard originalImages.count == editedImages.count else {
            fatalError("ERROR: Document images counts are inconsistent \n Original Images: \(originalImages.count) \n Edited Images \(editedImages.count)")
        }
        var pages = [Page]()
        for index in 0 ..< originalImages.count {
            let newPage = Page(documentID: document.id,
                               originalImage: originalImages[index],
                               editedImage: editedImages[index])
            guard  let page = newPage else { return false }
            page.pageNumber = lastPageNumber + index
            print("**************** page info")
            dump(page)
            pages.append(page)
        }
        addPages(pages, to: document)
        return true
    }
    
    func addPages(_ pages: [Page], to document: Document, fromCloud: Bool = false ) {
        document.pages += pages
        document.update()
        if !fromCloud {
            pages.forEach { page in CloudKitHelper.shared.addOrUpdatePage(page, of: document)}
        }
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
    
    func updateEditedImage(_ image: UIImage, for page: Page, of document: Document, fromCloud: Bool = false) -> Bool {
        let result = page.saveEditedImage(image)
        if result {
            document.update()
            if !fromCloud { CloudKitHelper.shared.addOrUpdatePage(page, of: document)}
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
