//
//  MPMessageFile+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPMessageFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPMessageFile> {
        return NSFetchRequest<MPMessageFile>(entityName: "MPMessageFile")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var size: String
    @NSManaged public var thumbnailUrl: String
    @NSManaged public var type: String
    @NSManaged public var url: String
    @NSManaged public var length: String
    @NSManaged public var audioWaveform: String
    @NSManaged public var localthumbnailimage: String
    @NSManaged public var localFileURL: String
    @NSManaged public var toMessage: MPMessage?

}

extension MPMessageFile : Identifiable {

}
