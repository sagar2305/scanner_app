//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import PDFGenerator
import CloudKit

class Document: Codable, Identifiable {
    
    var id: String
    var pages: [Page]
    var name: String
    private var date: Date = Date()
    var tag: String
    
    init?(originalImages: [UIImage], editedImages: [UIImage]) {
        self.tag = ""
        self.name = ""
        id = UUID().uuidString
        guard originalImages.count == editedImages.count else {
            fatalError("ERROR: Document images counts are inconsistent \n Original Images: \(originalImages.count) \n Edited Images \(editedImages.count)")
        }
        var pages = [Page]()
        for index in 0 ..< originalImages.count {
            let newPage = Page(documentID: id,
                               originalImage: originalImages[index],
                               editedImage: editedImages[index]
            )
            guard  let page = newPage else { return nil }
            pages.append(page)
        }
        self.pages = pages
        self.name = creationDate
    }
    
    init?(record: CKRecord, pages: [Page]) {
        print(record)
        guard let id = record[CloudKitConstants.DocumentRecordFields.id] as? String else { return nil }
        guard let name = record[CloudKitConstants.DocumentRecordFields.name] as? String else { return nil }
        guard let tag = record[CloudKitConstants.DocumentRecordFields.tag] as? String else { return nil }
        guard let date = record[CloudKitConstants.DocumentRecordFields.date] as? Date else  { return nil }
        
        self.id = id
        self.pages = pages
        self.name = name
        self.tag = tag
        self.date = date
        
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

// MARK: - CloudKit Operations
extension Document {
    func cloudKitRecord() -> CKRecord {
        let cloudRecord = CKRecord(recordType: CloudKitConstants.Records.document)
        cloudRecord.setValue(id as NSString, forKey: CloudKitConstants.DocumentRecordFields.id)
        cloudRecord.setValue(name as NSString, forKey: CloudKitConstants.DocumentRecordFields.name)
        cloudRecord.setValue(date as NSDate, forKey: CloudKitConstants.DocumentRecordFields.date)
        cloudRecord.setValue(tag as NSString, forKey: CloudKitConstants.DocumentRecordFields.tag)
        return cloudRecord
    }
    
    func saveToCloudKit() {
        CloudKitHelper.shared.save(document: self)
    }
}


