//
//  Foundation+Extension.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import Foundation
extension UserDefaults {

    func save<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        let encodedObject = try? encoder.encode(object)
        UserDefaults.standard.set(encodedObject, forKey: key)
    }

    func fetch<T: Codable>(forKey key: String) -> T? {
        if let object = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            }
        }
        return nil
    }
}
