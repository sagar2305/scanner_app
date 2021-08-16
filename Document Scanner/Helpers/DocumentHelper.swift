//
//  DocumentHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 26/05/21.
//

import Foundation

struct DocumentHelper {
    
    static let shared = DocumentHelper()
    
    private init() { }
    
    var documents: [Document] {
        return UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
    }
    
    var untaggedDocument: [Document] {
        return documents.filter { $0.tag == "" }
    }
    
    func deleteDocument(with id: String) {
        
    }
    
    var untaggedDocuments: [Document] {
        return []
    }
    
    var folders: [Folder] {
        dump(documents)
        var folderDictionary: [String: [Document]] = [:]
        var folders: [Folder] = []
        
        for document in documents where document.tag != "" {
            if folderDictionary.keys.contains(document.tag) {
                folderDictionary[document.tag]?.append(document)
            } else {
                folderDictionary[document.tag] = [document]
            }
        }
        
        folderDictionary.forEach { key, documents in
            let folder = Folder(name: key, documetCount: documents.count)
            folders.append(folder)
        }
        return folders
    }
}
