//
//  Page.swift
//  Document Scanner
//
//  Created by Sandesh on 23/03/21.
//

import Foundation
import WeScan

class Page: Codable {
    
    var originalImageName: String
    var editedImageName: String
    var quadrilateral: [CGPoint]?
    var previewData: Data?
    
    init?(originalImageName: String,
         originalImage: UIImage,
         editedImageName: String,
        editedImage: UIImage,
        quadrilateral: [CGPoint]) {
        self.originalImageName = originalImageName
        self.quadrilateral = quadrilateral
        self.editedImageName = editedImageName
        guard saveOriginalImage(originalImage) && saveEditedImage(editedImage) else { return nil }
    }
    
    func saveOriginalImage(_ image: UIImage) -> Bool {
        return FileHelper.shared.saveImage(image: image, withName: originalImageName)
    }
    
    func saveEditedImage(_ image: UIImage) -> Bool {
        if FileHelper.shared.saveImage(image: image, withName: editedImageName) {
            previewData = image.jpegData(compressionQuality: 0.7)
            editedImage = image
            return true
        }
        return false
    }
    
    lazy var originalImage: UIImage? = {
        FileHelper.shared.getImage(originalImageName)
    }()
    
    lazy var editedImage: UIImage? = {
        FileHelper.shared.getImage(editedImageName)
    }()
    
    var thumbNailImage: UIImage? {
        return UIImage(data: previewData ?? Data())
    }
}
