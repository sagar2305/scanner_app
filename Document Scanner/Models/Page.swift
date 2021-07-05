//
//  Page.swift
//  Document Scanner
//
//  Created by Sandesh on 23/03/21.
//

import Foundation
import UIKit
import CloudKit

class Page: NSObject, Codable {
    
    var id: String
    var originalImageName: String
    var editedImageName: String
    var previewData: Data?

    
    init?(documentID: String,
          originalImage: UIImage,
          editedImage: UIImage) {
        id = UUID().uuidString
        self.originalImageName = documentID.appending("_\(id)_original")
        self.editedImageName = documentID.appending("_\(id)_edited")
        guard saveOriginalImage(originalImage) && saveEditedImage(editedImage) else { return nil }
    }
    
    init?(record: CKRecord) {
        guard let id = record[CloudKitConstants.PageRecordFields.id] as? String else { return nil }
        guard let originalImageName = record[CloudKitConstants.PageRecordFields.originalImageName] as? String else { return nil }
        guard let editedImageName = record[CloudKitConstants.PageRecordFields.editedImageName] as? String else { return nil }
        
        guard let originalImageAsset = record[CloudKitConstants.PageRecordFields.originalImage] as? CKAsset else { return nil }
        guard let editedImageAsset = record[CloudKitConstants.PageRecordFields.editedImage] as? CKAsset else { return nil }
        
        guard let originalImageURL = originalImageAsset.fileURL,
              let originalImage = UIImage(contentsOfFile: originalImageURL.path),
              let editedImageURL = editedImageAsset.fileURL,
              let editedImage = UIImage(contentsOfFile: editedImageURL.path) else {
            return nil
        }
        
        self.id = id
        self.originalImageName = originalImageName
        self.editedImageName = editedImageName
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


extension Page {
    func cloudKitRecord(parent documentRecord: CKRecord) -> CKRecord? {
        let cloudRecord = CKRecord(recordType: CloudKitConstants.Records.page)
        guard let originalImageURL = FileHelper.shared.fileURL(for: originalImageName),
              let editedImageURL = FileHelper.shared.fileURL(for: editedImageName) else {
            return nil
        }
        let originalImageAsset = CKAsset(fileURL: originalImageURL)
        let editedImageAsset = CKAsset(fileURL: editedImageURL)
        
        cloudRecord.setValue(id as NSString, forKey: CloudKitConstants.PageRecordFields.id)
        cloudRecord.setValue(originalImageName as NSString, forKey: CloudKitConstants.PageRecordFields.originalImageName)
        cloudRecord.setValue(editedImageName as NSString, forKey: CloudKitConstants.PageRecordFields.editedImageName)
        cloudRecord.setValue(originalImageAsset, forKey: CloudKitConstants.PageRecordFields.originalImage)
        cloudRecord.setValue(editedImageAsset, forKey: CloudKitConstants.PageRecordFields.editedImage)
        
        let parent = CKRecord.Reference(record: documentRecord, action: .deleteSelf)
        cloudRecord.setValue(parent, forKey: CloudKitConstants.PageRecordFields.document)
        return cloudRecord

}

    extension Page: QLPreviewItem {
        var previewItemURL: URL? {
            return FileHelper.shared.getLocalURL(for: editedImageName)
        }
