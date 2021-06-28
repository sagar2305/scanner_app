//
//  FileHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class FileHelper {
    
    static let shared = FileHelper()
    
    private init() { }
    
    func saveImage(image: UIImage, withName name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        let fileName = name.appending(".jpeg");
        let filePath: URL = directory.appendingPathComponent(fileName)!
        

        do {
            let fileManager = FileManager.default

            // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete file
                try fileManager.removeItem(atPath: filePath.path)
            } else {
                print("File does not exist")
            }

        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }

        do {
            try data.write(to: filePath)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getImage(_ name: String) -> UIImage? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        
        let fileName = name.appending(".jpeg")
        let filePath: URL = directory.appendingPathComponent(fileName)!
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath.path) {
            return UIImage(contentsOfFile: filePath.path)
        } else {
            return nil
        }
    }
    
    func fileURL(for imageName: String) -> URL? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        
        let fileName = imageName.appending(".jpeg")
        let filePath: URL = directory.appendingPathComponent(fileName)!
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath.path) {
            return filePath
        } else {
            return nil
        }
        
    }
    
}
