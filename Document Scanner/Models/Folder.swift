//
//  Folder.swift
//  Document Scanner
//
//  Created by Sandesh on 16/08/21.
//

import Foundation

struct Folder: Codable, Identifiable {
    var id = UUID()
    var name: String
    let documetCount: Int
}

extension Folder: Hashable {

}
