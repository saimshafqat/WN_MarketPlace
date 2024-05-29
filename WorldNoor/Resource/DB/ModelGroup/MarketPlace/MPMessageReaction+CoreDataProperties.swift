//
//  MPMessageReaction+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPMessageReaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPMessageReaction> {
        return NSFetchRequest<MPMessageReaction>(entityName: "MPMessageReaction")
    }

    @NSManaged public var firstname: String
    @NSManaged public var lastname: String
    @NSManaged public var messageId: String
    @NSManaged public var profileImage: String
    @NSManaged public var reactedBy: String
    @NSManaged public var reaction: String
    @NSManaged public var toMessage: MPMessage?

}

extension MPMessageReaction : Identifiable {

}
