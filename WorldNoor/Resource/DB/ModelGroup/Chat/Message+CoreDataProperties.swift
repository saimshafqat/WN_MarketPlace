//
//  Message+CoreDataProperties.swift
//
//
//  Created by Awais on 19/10/2023.
//
//

import Foundation
import CoreData


extension Message {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }
    @NSManaged public var id: String
    @NSManaged public var messageTime: String
    @NSManaged public var audio_file: String
    @NSManaged public var audio_msg_url: String
    @NSManaged public var author_id: String
    @NSManaged public var auto_translate: String
    @NSManaged public var body: String
    @NSManaged public var isOriginal: NSNumber!
    @NSManaged public var conversation_id: String
    @NSManaged public var created_at: String
    @NSManaged public var full_name: String
    @NSManaged public var identifierString: String
    @NSManaged public var name: String
    @NSManaged public var new_message_id: String
    @NSManaged public var original_body: String
    @NSManaged public var original_speech_to_text: String
    @NSManaged public var post_type: String
    @NSManaged public var profile_image: String
    @NSManaged public var replied_to_message_id: String
    @NSManaged public var sender_id: String
    @NSManaged public var speech_to_text: String
    @NSManaged public var reply_to: Message?
    @NSManaged public var toChat: Chat?
    @NSManaged public var toMessageFile: NSSet?
    @NSManaged public var audio_translation: String
    @NSManaged public var is_pinned: String
    @NSManaged public var pinnedBy: String
    @NSManaged public var uploadingStatus: String
    @NSManaged public var status: String
    @NSManaged public var toReaction: NSSet
    @NSManaged public var isShowMessageTime: String

}

// MARK: Generated accessors for reply_to
extension Message {
    
    @objc(addReply_toObject:)
    @NSManaged public func addToReply_to(_ value: Message)
    
    @objc(removeReply_toObject:)
    @NSManaged public func removeFromReply_to(_ value: Message)
    
    @objc(addReply_to:)
    @NSManaged public func addToReply_to(_ values: NSSet)
    
    @objc(removeReply_to:)
    @NSManaged public func removeFromReply_to(_ values: NSSet)
    
}

// MARK: Generated accessors for toMessageFile
extension Message {
    
    @objc(addToMessageFileObject:)
    @NSManaged public func addToToMessageFile(_ value: MessageFile)
    
    @objc(removeToMessageFileObject:)
    @NSManaged public func removeFromToMessageFile(_ value: MessageFile)
    
    @objc(addToMessageFile:)
    @NSManaged public func addToToMessageFile(_ values: NSSet)
    
    @objc(removeToMessageFile:)
    @NSManaged public func removeFromToMessageFile(_ values: NSSet)
    
}

// MARK: Generated accessors for toReaction
extension Message {

    @objc(addToReactionObject:)
    @NSManaged public func addToToReaction(_ value: Reaction)

    @objc(removeToReactionObject:)
    @NSManaged public func removeFromToReaction(_ value: Reaction)

    @objc(addToReaction:)
    @NSManaged public func addToToReaction(_ values: NSSet)

    @objc(removeToReaction:)
    @NSManaged public func removeFromToReaction(_ values: NSSet)

}

