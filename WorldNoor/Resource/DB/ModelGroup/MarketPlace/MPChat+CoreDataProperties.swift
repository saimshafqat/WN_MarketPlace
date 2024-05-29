//
//  MPChat+CoreDataProperties.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import Foundation
import CoreData


extension MPChat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MPChat> {
        return NSFetchRequest<MPChat>(entityName: "MPChat")
    }

    @NSManaged public var buyerName: String
    @NSManaged public var conversationId: String
    @NSManaged public var conversationName: String
    @NSManaged public var createdAt: String
    @NSManaged public var deletedAt: String
    @NSManaged public var deletedLastMessage: String
    @NSManaged public var groupImage: String
    @NSManaged public var isArchive: Bool
    @NSManaged public var isGroupLeave: Bool
    @NSManaged public var isOwner: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var label: String
    @NSManaged public var lastMessage: String
    @NSManaged public var lastMessageTime: String
    @NSManaged public var lastMessengerId: String
    @NSManaged public var lastMessageLabel: String
    @NSManaged public var mutedAt: String
    @NSManaged public var mutedTill: String
    @NSManaged public var nickname: String
    @NSManaged public var offerStatus: String
    @NSManaged public var ownerId: String
    @NSManaged public var productPrice: String
    @NSManaged public var toMember: NSSet?
    @NSManaged public var toMessage: NSSet?

}

// MARK: Generated accessors for toMember
extension MPChat {

    @objc(addToMemberObject:)
    @NSManaged public func addToToMember(_ value: MPMember)

    @objc(removeToMemberObject:)
    @NSManaged public func removeFromToMember(_ value: MPMember)

    @objc(addToMember:)
    @NSManaged public func addToToMember(_ values: NSSet)

    @objc(removeToMember:)
    @NSManaged public func removeFromToMember(_ values: NSSet)

}

// MARK: Generated accessors for toMessage
extension MPChat {

    @objc(addToMessageObject:)
    @NSManaged public func addToToMessage(_ value: MPMessage)

    @objc(removeToMessageObject:)
    @NSManaged public func removeFromToMessage(_ value: MPMessage)

    @objc(addToMessage:)
    @NSManaged public func addToToMessage(_ values: NSSet)

    @objc(removeToMessage:)
    @NSManaged public func removeFromToMessage(_ values: NSSet)

}

extension MPChat : Identifiable {

}
