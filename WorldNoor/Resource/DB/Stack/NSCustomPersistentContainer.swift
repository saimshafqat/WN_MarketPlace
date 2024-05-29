//
//  NSCustomPersistentContainer.swift
//  WorldNoor
//
//  Created by Awais on 17/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import CoreData

import Foundation
class NSCustomPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ogoul.worldnoor")
        storeURL = storeURL?.appendingPathComponent("Worldnoor.sqlite")
        LogClass.debugLog("dbdebug--------\(storeURL)")
        return storeURL!
    }
}

