//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import PDFGenerator
import CloudKit

class Document: Codable {
    
    private let id = UUID()
    var pages: [Page]
    var name: String
    private let date: Date = Date()
    var tag: String
    
    init?(originalImages: [UIImage], editedImages: [UIImage]) {
        self.tag = ""
        self.name = ""
        guard originalImages.count == editedImages.count else {
            fatalError("ERROR: Document images counts are inconsistent \n Original Images: \(originalImages.count) \n Edited Images \(editedImages.count)")
        }
        var pages = [Page]()
        for index in 0 ..< originalImages.count {
            let newPage = Page(documentID: id.uuidString,
                               originalImage: originalImages[index],
                               editedImage: editedImages[index]
            )
            guard  let page = newPage else { return nil }
            pages.append(page)
        }
        self.pages = pages
        self.name = creationDate
    }
    
    init?(record: CKRecord) {
        print(record)
//        guard let id = record[CloudKitConstants.DocumentRecordFields.id] as? String else { return nil }
//        guard let name = record[CloudKitConstants.DocumentRecordFields.name] as? String else { return nil }
//        guard let name = record[CloudKitConstants.DocumentRecordFields.tag] as? String else { return nil }

    }
    
    var documentID : String {
        return id.uuidString
    }
    
    var creationDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var details: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate + " - \(pages.count) Pages"
    }
    
    func save() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.append(self)
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
    }
    
    func update() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.removeAll { $0.id == id }
        documents.append(self)
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
    }
    
    func delete() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.removeAll { $0.id == id }
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
    }
    
    func rename(new name: String) {
        self.name = name
        update()
    }
}

extension Document: Hashable {
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Document {
    func cloudKitRecord() -> CKRecord {
        let cloudRecord = CKRecord(recordType: CloudKitConstants.Records.document)
     
        cloudRecord.setValue(documentID as NSString, forKey: CloudKitConstants.DocumentRecordFields.id)
        cloudRecord.setValue(name as NSString, forKey: CloudKitConstants.DocumentRecordFields.name)
        cloudRecord.setValue(date as NSDate, forKey: CloudKitConstants.DocumentRecordFields.date)
        cloudRecord.setValue(tag as NSString, forKey: CloudKitConstants.DocumentRecordFields.tag)
        
        var pageIds: [NSString] = []
        for page in pages {
            pageIds.append(page.pageId as NSString)
        }
        
        cloudRecord.setValue(pageIds, forKey: CloudKitConstants.DocumentRecordFields.pages)
        
        return cloudRecord
    }
}


