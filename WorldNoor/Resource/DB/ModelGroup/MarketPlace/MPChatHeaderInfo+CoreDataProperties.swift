//
//  MPChatHeaderInfo+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPChatHeaderInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPChatHeaderInfo> {
        return NSFetchRequest<MPChatHeaderInfo>(entityName: "MPChatHeaderInfo")
    }

    @NSManaged public var groupImage: String
    @NSManaged public var groupTitle: String
    @NSManaged public var groupInfo: String
    @NSManaged public var createdAt: String
    @NSManaged public var toMessage: MPMessage?

}

extension MPChatHeaderInfo : Identifiable {

}
