//
//  UserDefaultsUtility.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 02/05/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

struct UserDefaultsUtility {
    
    // wills use default keys
    enum keys: String {
        case unsavedReelItem = "unsavedReelItem"
        case Lang = "Lang"
        case LangN = "LangN"
        case hasLocationUpdated = "hasLocationUpdated"
        case url = "url"
        case userBasicProfile = "userBasicProfile"
        case isStartApp = "isStartApp"
        case savedPerson = "SavedPerson"
    }
    
    static func save(with key: keys, value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func get(with key: keys) -> Any? {
        let value = UserDefaults.standard.value(forKey: key.rawValue)
        return value
    }
    
    static func remove(with key: keys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
