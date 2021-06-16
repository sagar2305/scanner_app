//
//  Page.swift
//  Document Scanner
//
//  Created by Sandesh on 23/03/21.
//

import Foundation
import WeScan
import QuickLook

class Page: NSObject, Codable {
    
    var id = UUID()
    var originalImageName: String
    var editedImageName: String
    var previewData: Data?
    
    init?(documentID: String,
         originalImage: UIImage,
        editedImage: UIImage) {
        self.originalImageName = documentID.appending("_\(id.uuid)_original")
        self.editedImageName = documentID.appending("_\(id.uuid)_edited")
        super.init()
        guard saveOriginalImage(originalImage) && saveEditedImage(editedImage) else { return nil }
    }
    
    func saveOriginalImage(_ image: UIImage) -> Bool {
        return FileHelper.shared.saveImage(image: image, withName: originalImageName)
    }
    
    func saveEditedImage(_ image: UIImage) -> Bool {
        if FileHelper.shared.saveImage(image: image, withName: editedImageName) {
            previewData = image.jpegData(compressionQuality: 0.7)
            return true
        }
        return false
    }
    
    lazy var originalImage: UIImage? = {
        FileHelper.shared.getImage(originalImageName)
    }()
    
    var editedImage: UIImage? {
        FileHelper.shared.getImage(editedImageName)
    }
    
    var thumbNailImage: UIImage? {
        return UIImage(data: previewData ?? Data())
    }
}

extension Page: QLPreviewItem {
    var previewItemURL: URL? {
        return FileHelper.shared.getLocalURL(for: editedImageName)
    }
}
