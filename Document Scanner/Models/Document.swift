//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import PDFGenerator

class Document: Codable {
    
    var id = UUID()
    var pages: [Page]
    var name: String
    private var date: Date
    var tag: String
    
    init?(_ name: String, originalImages: [UIImage], editedImages: [UIImage], quadrilaterals: [[CGPoint]]) {
        self.name = name
        self.tag = ""
        guard originalImages.count == editedImages.count else {
            fatalError("ERROR: Document images counts are inconsistent \n Original Images: \(originalImages.count) \n Edited Images \(editedImages.count) \n Quadrilaterals: \(quadrilaterals.count)")
        }
        date = Date()
        var pages = [Page]()
        for index in 0 ..< originalImages.count {
            let newPage = Page(originalImageName: name.appending("\(index)_original"),
                                   originalImage: originalImages[index],
                                   editedImageName: name.appending("\(index)_edited"),
                                   editedImage: editedImages[index],
                                   quadrilateral: [])
            guard  let page = newPage else { return nil }
            pages.append(page)
        }
        self.pages = pages
    }
    
    var creationDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
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
    
    func convertToPDF() -> String?{
        do {
            var pdfPages: [PDFPage] = []
            for page in pages {
                guard let image = page.editedImage else {
                    fatalError("ERROR: No edited image was found in document")
                }
                pdfPages.append(.image(image))
            }
            
            let temporaryPath = NSTemporaryDirectory().appending("\(name).pfd")
            try PDFGenerator.generate(pdfPages, to: temporaryPath)
            return temporaryPath
        } catch let error {
            print("PDF generation failed: \(error)")
        }
        return nil
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



