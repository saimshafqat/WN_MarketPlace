//
//  NSSetExt.swift
//  WorldNoor
//
//  Created by Awais on 23/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

extension NSSet {
    var count: Int {
        return self.allObjects.count
    }
    
    func object(at index: Int) -> Any? {
        guard index >= 0, index < self.count else {
            return nil
        }
        return self.allObjects[index]
    }
    
    var first: Any? {
        return self.object(at: 0)
    }
    
    var last: Any? {
        return self.object(at: self.count - 1)
    }
    
    var array: [Any] {
        return self.allObjects
    }
    
    func toArray<T>() -> [T] {
        let array = self.allObjects as? [T]
        return array ?? []
    }
}
