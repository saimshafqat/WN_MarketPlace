//
//  MPConversationModel.swift
//  WorldNoor
//
//  Created by Awais on 21/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct MPConversationResponse: Codable {
    let action: String
    let meta: Meta
    let data: MPConversationData
}

struct MPConversationData: Codable {
    let totalPages: Int
    let conversations: [MPConversation]
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case conversations
    }
}

struct MPConversation: Codable {
    let groupImage: String?
    let lastMessage: String?
    let lastMessageTime: String?
    let lastMessengerId: Int?
    let lastMessageLabel: String?
    let conversationId: Int?
    let conversationName: String?
    let createdAt: String?
    let isArchive: Int?
    let isRead: Int?
    let isGroupLeave: Bool?
    let mutedAt: String?
    let mutedTill: String?
    let deletedAt: String?
    let deletedLastMessage: String?
    let buyerName: String?
    let productPrice: String?
    let label: String?
    let ownerId: Int?
    let isOwner: Bool?
    let offerStatus: String?
    let participants: [MPChatParticipant]?
    
    enum CodingKeys: String, CodingKey {
        case groupImage = "group_image"
        case lastMessage = "last_message"
        case lastMessageTime = "last_message_time"
        case lastMessengerId = "last_messenger_id"
        case lastMessageLabel = "last_message_label"
        case conversationId = "conversation_id"
        case conversationName = "conversation_name"
        case createdAt = "created_at"
        case isArchive = "is_archive"
        case isRead = "is_read"
        case isGroupLeave = "is_group_leave"
        case mutedAt = "muted_at"
        case mutedTill = "muted_till"
        case deletedAt = "deleted_at"
        case deletedLastMessage = "deleted_last_message"
        case buyerName = "buyer_name"
        case productPrice = "product_price"
        case label
        case ownerId = "owner_id"
        case isOwner = "is_owner"
        case offerStatus = "offer_status"
        case participants
    }
}

struct MPChatParticipant: Codable {
    let id: Int?
    let worldnoorUserId: Int?
    let name: String?
    let profileImage: String?
    let username: String?
    let firstname: String?
    let lastname: String?
    let leaveBy: String?
    let nickname: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case worldnoorUserId = "worldnoor_user_id"
        case profileImage = "profile_image"
        case username
        case firstname
        case lastname
        case leaveBy = "leave_by"
        case nickname
    }
}
