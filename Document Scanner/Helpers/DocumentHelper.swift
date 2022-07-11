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
    
    var totalDocumentsCount: Int {
        return documents.count
    }
    
    var untaggedDocument: [Document] {
        return documents.filter { $0.tag == "" }
    }
    
    func getDocument(with tag: String) -> [Document] {
        return documents.filter { $0.tag == tag }
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
    
    func deletePage(_ page: Page, of document: Document, fromCloud: Bool = false) {
        document.deletePage(page)
    }
    
    func deleteDocumentWithID(_ id: String, isNotifiedFromiCloud: Bool) {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.forEach( { $0.printIDS() })
        print("id to delete => \(id)")
        documents.removeAll { document in document.id == id }
        documents.forEach( { $0.printIDS() })
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
        AnalyticsHelper.shared.logEvent(.userDeletedDocument, properties: [
                                            .documentID: id,
         ])
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
    
    func move(document: Document, to folder: Folder) {
        document.updateTag(new: folder.name, updatedFromCloud: false)
        var emptyFolders = emptyFolders
        emptyFolders.removeAll { $0.id == folder.id }
        UserDefaults.standard.save(emptyFolders, forKey: Constants.DocumentScannerDefaults.emptyFoldersListKey)
        NotificationCenter.default.post(name: .documentMovedToFolder, object: nil)
        AnalyticsHelper.shared.logEvent(.documentMovedToFolder, properties: [.documentID: document.id,
                                                                             .documentTag : folder.name])
    }
    
    
    var folders: [Folder] {
        dump(documents)
        var folderDictionary: [String: [Document]] = [:]
        var folders: [Folder] = []
        
        for document in documents where document.tag != "" {
            if folderDictionary.keys.contains(document.tag) {
                folderDictionary[document.tag]?.append(document)
            } else {
                folderDictionary[document.tag] = [document]
            }
        }
        folderDictionary.forEach { key, documents in
            let folder = Folder(name: key, documetCount: documents.count)
            folders.append(folder)
        }
        folders += emptyFolders
        return folders
    }
    
    func addNewEmpty(folder: Folder) {
        var emptyFoldersList = emptyFolders
        emptyFoldersList.append(folder)
        UserDefaults.standard.save(emptyFoldersList, forKey: Constants.DocumentScannerDefaults.emptyFoldersListKey)
        AnalyticsHelper.shared.logEvent(.savedEmptyFolder)
    }
    
    var emptyFolders: [Folder] {
        UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.emptyFoldersListKey) ?? []
    }
    
    func renamefolder(_ folder: Folder, with name: String) {
        let documents = documents.filter { $0.tag == folder.name }
        if documents.isEmpty {
            var emptyFolders = emptyFolders
            if let row = self.emptyFolders.firstIndex(where: {$0.name == folder.name}) {
                emptyFolders[row].name = name
            }
            UserDefaults.standard.save(emptyFolders, forKey: Constants.DocumentScannerDefaults.emptyFoldersListKey)
        } else {
            for document in documents {
                document.updateTag(new: name)
            }
        }
        AnalyticsHelper.shared.logEvent(.renamedFolder, properties: [.documentTag : folder.name])
    }
    
    func deleteFolder(_ folder: Folder) {
        let documents = documents.filter { $0.tag == folder.name }
        if documents.isEmpty {
            var emptyFolders = emptyFolders
            emptyFolders.removeAll { $0.id == folder.id }
            UserDefaults.standard.save(emptyFolders, forKey: Constants.DocumentScannerDefaults.emptyFoldersListKey)
        } else {
            for document in documents {
                deleteDocumentWithID(document.id, isNotifiedFromiCloud: false)
            }
        }
        AnalyticsHelper.shared.logEvent(.deletedFolder, properties: [.documentTag : folder.name])
    }
}
