//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

struct Document: Codable {
    
    let id = UUID()
    var name: String
    let originalImageName: String
    let quadrilateral: [CGPoint]
    var editedImageName: String
    var tag: String
    
    
    init(_ name: String, originalImage: UIImage, editedImage: UIImage, quadrilateral: [CGPoint]) {
        self.name = name
        self.originalImageName = name.appending("_original")
        self.quadrilateral = quadrilateral
        self.editedImageName = name.appending("_edited")
        self.tag = ""
    }
    
    var originalImage: UIImage? {
        return UIImage()
    }
    
    var editedImage: UIImage? {
        return UIImage()
    }
    
    func saveOriginalImage(_ image: UIImage) -> Bool {
        return FileHelper.shared.saveImage(image: image, withName: editedImageName)
    }
    
    func saveEditedImage(_ image: UIImage) -> Bool {
        return FileHelper.shared.saveImage(image: image, withName: editedImageName)
    }
    
    func save() {
        var documents: [Document] = UserDefaults.standard.fetch(forKey: Constant.DocumentScannerDefaults.documentsListKey) ?? []
        documents.append(self)
        UserDefaults.standard.save(documents, forKey: Constant.DocumentScannerDefaults.documentsListKey)
    }
}

extension Document: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



