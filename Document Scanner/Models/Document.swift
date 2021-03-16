//
//  Document.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class Document: Codable {
    
    var id = UUID()
    var name: String
    let originalImageName: String
    let quadrilateral: [CGPoint]?
    var editedImageName: String
    var tag: String
    var thumbnailData: Data?
    
    init(_ name: String, originalImage: UIImage, editedImage: UIImage, quadrilateral: [CGPoint]) {
        self.name = name
        self.originalImageName = name.appending("_original")
        self.quadrilateral = quadrilateral
        self.editedImageName = name.appending("_edited")
        self.tag = ""
    }
    
    lazy var originalImage: UIImage? = {
        FileHelper.shared.getImage(originalImageName)
    }()
    
    lazy var editedImage: UIImage? = {
        FileHelper.shared.getImage(editedImageName)
    }()
    
    var thumbNailImage: UIImage? {
        return UIImage(data: thumbnailData ?? Data())
    }
    func saveOriginalImage(_ image: UIImage) -> Bool {
        return FileHelper.shared.saveImage(image: image, withName: editedImageName)
    }
    
    func saveEditedImage(_ image: UIImage) -> Bool {
        if FileHelper.shared.saveImage(image: image, withName: editedImageName) {
            thumbnailData = image.jpegData(compressionQuality: 0.7)
            return true
        }
        return false
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



