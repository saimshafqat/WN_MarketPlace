//
//  Chat+CoreDataProperties.swift
//  
//
//  Created by Awais on 19/10/2023.
//
//

import Foundation
import CoreData


extension Chat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chat> {
        return NSFetchRequest<Chat>(entityName: "Chat")
    }

    @NSManaged public var arrayAdmin_ids: Array<Int>
    @NSManaged public var author_id: String
    @NSManaged public var conversation_id: String
    @NSManaged public var conversation_type: String
    @NSManaged public var group_image: String
    @NSManaged public var has_blocked_me: String
    @NSManaged public var is_mute: String
    @NSManaged public var is_online: String
    @NSManaged public var is_unread: String
    @NSManaged public var latest_conversation_id: String
    @NSManaged public var latest_message: String
    @NSManaged public var latest_message_language_id: String
    @NSManaged public var latest_message_time: String
    @NSManaged public var last_updated: String
    @NSManaged public var member_id: String
    @NSManaged public var name: String
    @NSManaged public var profile_image: String
    @NSManaged public var unread_messages_count: String
    @NSManaged public var theme_color: String
    @NSManaged public var nickname: String
    @NSManaged public var toMember: NSSet?
    @NSManaged public var toMessage: NSSet?
    @NSManaged public var isArchive:String
    @NSManaged public var isSpam:String
    @NSManaged public var is_leave:String
    @NSManaged public var username:String
    @NSManaged public var is_blocked:String
}

// MARK: Generated accessors for toMember
extension Chat {

    @objc(addToMemberObject:)
    @NSManaged public func addToToMember(_ value: Member)

    @objc(removeToMemberObject:)
    @NSManaged public func removeFromToMember(_ value: Member)

    @objc(addToMember:)
    @NSManaged public func addToToMember(_ values: NSSet)

    @objc(removeToMember:)
    @NSManaged public func removeFromToMember(_ values: NSSet)

}

// MARK: Generated accessors for toMessage
extension Chat {

    @objc(addToMessageObject:)
    @NSManaged public func addToToMessage(_ value: Message)

    @objc(removeToMessageObject:)
    @NSManaged public func removeFromToMessage(_ value: Message)

    @objc(addToMessage:)
    @NSManaged public func addToToMessage(_ values: NSSet)

    @objc(removeToMessage:)
    @NSManaged public func removeFromToMessage(_ values: NSSet)

}
