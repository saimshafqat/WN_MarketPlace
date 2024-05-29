//
//  MPMessage+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPMessage> {
        return NSFetchRequest<MPMessage>(entityName: "MPMessage")
    }

    @NSManaged public var content: String
    @NSManaged public var conversationCreatedAt: String
    @NSManaged public var conversationId: String
    @NSManaged public var conversationName: String
    @NSManaged public var createdAt: String
    @NSManaged public var groupImage: String
    @NSManaged public var id: String
    @NSManaged public var isShowMessageTime: String
    @NSManaged public var marketImages: String
    @NSManaged public var messageLabel: String
    @NSManaged public var messageType: String
    @NSManaged public var reaction: String
    @NSManaged public var receiverId: String
    @NSManaged public var repliedToContent: String
    @NSManaged public var repliedToMessageId: String
    @NSManaged public var senderId: String
    @NSManaged public var senderImage: String
    @NSManaged public var senderName: String
    @NSManaged public var uploadingStatus: String
    @NSManaged public var identifier: String
    @NSManaged public var isPinned: String
    @NSManaged public var pinnedBy: String
    @NSManaged public var replyTo: MPMessage?
    @NSManaged public var toBuyerInfo: MPChatBuyerInfo?
    @NSManaged public var toChat: MPChat?
    @NSManaged public var toHeaderInfo: MPChatHeaderInfo?
    @NSManaged public var toMessageFile: NSSet?
    @NSManaged public var toMessageReaction: NSSet?
    @NSManaged public var toOfferInfo: MPChatOfferInfo?

}

// MARK: Generated accessors for toMessageFile
extension MPMessage {

    @objc(addToMessageFileObject:)
    @NSManaged public func addToToMessageFile(_ value: MPMessageFile)

    @objc(removeToMessageFileObject:)
    @NSManaged public func removeFromToMessageFile(_ value: MPMessageFile)

    @objc(addToMessageFile:)
    @NSManaged public func addToToMessageFile(_ values: NSSet)

    @objc(removeToMessageFile:)
    @NSManaged public func removeFromToMessageFile(_ values: NSSet)

}

// MARK: Generated accessors for toMessageReaction
extension MPMessage {

    @objc(addToMessageReactionObject:)
    @NSManaged public func addToToMessageReaction(_ value: MPMessageReaction)

    @objc(removeToMessageReactionObject:)
    @NSManaged public func removeFromToMessageReaction(_ value: MPMessageReaction)

    @objc(addToMessageReaction:)
    @NSManaged public func addToToMessageReaction(_ values: NSSet)

    @objc(removeToMessageReaction:)
    @NSManaged public func removeFromToMessageReaction(_ values: NSSet)

}

extension MPMessage : Identifiable {

}
