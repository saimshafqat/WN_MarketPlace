//
//  MPMember+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 03/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPMember {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPMember> {
        return NSFetchRequest<MPMember>(entityName: "MPMember")
    }

    @NSManaged public var id: String
    @NSManaged public var worldnoorUserId: String
    @NSManaged public var name: String
    @NSManaged public var profileImage: String
    @NSManaged public var username: String
    @NSManaged public var firstname: String
    @NSManaged public var lastname: String
    @NSManaged public var leaveBy: String
    @NSManaged public var nickname: String
    @NSManaged public var toChat: MPChat?

}

extension MPMember : Identifiable {

}
