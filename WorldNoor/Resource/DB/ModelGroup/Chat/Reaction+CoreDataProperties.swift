//
//  Reaction+CoreDataProperties.swift
//  
//
//  Created by Raza najam on 20/12/2023.
//
//

import Foundation
import CoreData


extension Reaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reaction> {
        return NSFetchRequest<Reaction>(entityName: "Reaction")
    }
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var messageID: String
    @NSManaged public var reactedBy: String
    @NSManaged public var reaction: String
    @NSManaged public var reactionID: String
    @NSManaged public var profileImage: String
    @NSManaged public var toMessage: Message?
}
