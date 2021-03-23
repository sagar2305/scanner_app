//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class Document: Codable {
    
    var id = UUID()
    var pages: [Page]
    var name: String
    var tag: String
    
    init?(_ name: String, originalImages: [UIImage], editedImages: [UIImage], quadrilaterals: [[CGPoint]]) {
        self.name = name
        self.tag = ""
        guard originalImages.count == editedImages.count && editedImages.count == quadrilaterals.count else {
            fatalError("ERROR: Document images counts are inconsistent \n Original Images: \(originalImages.count) \n Edited Images \(editedImages.count) \n Quadrilaterals: \(quadrilaterals.count)")
        }
        var pages = [Page]()
        for index in 0 ..< originalImages.count {
            let newPage = Page(originalImageName: name.appending("\(index)_original"),
                                   originalImage: originalImages[index],
                                   editedImageName: name.appending("\(index)_edited"),
                                   editedImage: editedImages[index],
                                   quadrilateral: quadrilaterals[index])
            guard  let page = newPage else { return nil }
            pages.append(page)
        }
        self.pages = pages
    }
    
    
    
    func save() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constant.DocumentScannerDefaults.documentsListKey) ?? []
        documents.append(self)
        UserDefaults.standard.save(documents, forKey: Constant.DocumentScannerDefaults.documentsListKey)
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



