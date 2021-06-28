//
//  Page.swift
//  Document Scanner
//
//  Created by Sandesh on 23/03/21.
//

import Foundation
import UIKit
import CloudKit

class Page: Codable {
    
    private var id = UUID()
    var originalImageName: String
    var editedImageName: String
    var previewData: Data?
    
    var pageId: String {
        id.uuidString
    }
    
    init?(documentID: String,
         originalImage: UIImage,
        editedImage: UIImage) {
        self.originalImageName = documentID.appending("_\(id.uuid)_original")
        self.editedImageName = documentID.appending("_\(id.uuid)_edited")
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


extension Page {
    func cloudKitRecord(parent documentRecord: CKRecord) -> CKRecord? {
        let cloudRecord = CKRecord(recordType: CloudKitConstants.Records.page)
        guard let originalImageURL = FileHelper.shared.fileURL(for: originalImageName),
              let editedImageURL = FileHelper.shared.fileURL(for: editedImageName) else {
            return nil
        }
        let originalImageAsset = CKAsset(fileURL: originalImageURL)
        let editedImageAsset = CKAsset(fileURL: editedImageURL)
        
        cloudRecord.setValue(pageId as NSString, forKey: CloudKitConstants.PageRecordFields.id)
        cloudRecord.setValue(originalImageName as NSString, forKey: CloudKitConstants.PageRecordFields.originalImageName)
        cloudRecord.setValue(editedImageName as NSString, forKey: CloudKitConstants.PageRecordFields.editedImageName)
        cloudRecord.setValue(originalImageAsset, forKey: CloudKitConstants.PageRecordFields.originalImage)
        cloudRecord.setValue(editedImageAsset, forKey: CloudKitConstants.PageRecordFields.editedImage)
        
        let parent = CKRecord.Reference(record: documentRecord, action: .deleteSelf)
        cloudRecord.setValue(parent, forKey: CloudKitConstants.PageRecordFields.document)
        return cloudRecord
    }
}
