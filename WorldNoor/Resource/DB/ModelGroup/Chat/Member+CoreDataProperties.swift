//
//  Member+CoreDataProperties.swift
//  
//
//  Created by Awais on 17/10/2023.
//
//

import Foundation
import CoreData


extension Member {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Member> {
        return NSFetchRequest<Member>(entityName: "Member")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var is_admin: String?
    @NSManaged public var is_online: String?
    @NSManaged public var lastname: String?
    @NSManaged public var profile_image: String?
    @NSManaged public var username: String?
    @NSManaged public var nickname: String?
    @NSManaged public var toChat: Chat?

}
