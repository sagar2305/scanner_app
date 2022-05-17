//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import PDFGenerator
import CloudKit
import MobileCoreServices

class Document: NSObject, Codable, Identifiable {
    
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
                               editedImage: editedImages[index])
            guard  let page = newPage else { return nil }
            page.pageNumber = index + 1
            print("**************** page info")
            dump(page)
            pages.append(page)
        }
        self.pages = pages
        super.init()
        self.name = creationDate
    }
    
    init?(record: CKRecord,pages: [Page]) {
        print(record)
        guard let id = record[CloudKitConstants.DocumentRecordFields.id] as? String else { return nil }
        guard let name = record[CloudKitConstants.DocumentRecordFields.name] as? String else { return nil }
        guard let tag = record[CloudKitConstants.DocumentRecordFields.tag] as? String else { return nil }
        guard let date = record[CloudKitConstants.DocumentRecordFields.date] as? Date else  { return nil }
        
        var sortedPages = pages
        sortedPages.sort { $0.pageNumber < $1.pageNumber }
        self.id = id
        self.pages = sortedPages
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
        _saveToCloudKit()
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
    }
    
    func update() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        documents.removeAll { $0.id == id }
        documents.append(self)
        UserDefaults.standard.save(documents, forKey: Constants.DocumentScannerDefaults.documentsListKey)
    }
    
    func rename(new name: String, updatedFromCloud: Bool = false) {
        self.name = name
        update()
        if !updatedFromCloud {
            CloudKitHelper.shared.update(document: self)
        }
    }
    
    func updateTag(new tag: String, updatedFromCloud: Bool = false) {
        self.tag = tag
        update()
        if !updatedFromCloud {
            CloudKitHelper.shared.update(document: self)
        }
    }
    
    //for test
    func printIDS() {
        print(id)
    }
}

extension Document {
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
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
    
    private func _saveToCloudKit() {
        CloudKitHelper.shared.saveToCloud(document: self)
    }
}

extension Document: NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            let json = String(data: data, encoding: String.Encoding.utf8)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            
            completionHandler(nil, error)
        }
        return progress
    }
}


extension Document: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        do {
            let myJSON: Document = try decoder.decode(Document.self, from: data)
            return myJSON as! Self
        } catch {
            fatalError("Err")
        }
    }
}


