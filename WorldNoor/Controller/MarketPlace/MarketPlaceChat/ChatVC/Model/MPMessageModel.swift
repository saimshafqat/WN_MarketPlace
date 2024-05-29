//
//  MPMessageModel.swift
//  WorldNoor
//
//  Created by Awais on 25/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct MPMessageResponse: Codable {
    let action: String
    let meta: Meta
    let data: [MPMessageModel]
}

struct MPMessageModel: Codable {
    var conversationId: Int?
    var senderId: Int?
    var receiverId: Int?
    var createdAt: String?
    var content: String?
    var senderName: String?
    var id: Int?
    var repliedToMessageId: Int?
    var repliedToContent: String?
    var senderImage: String?
    var marketImages: String?
    var reaction: String?
    var messageType: Int?
    var messageLabel: String?
    var groupImage: String?
    var conversationName: String?
    var conversationCreatedAt: String?
    var identifier: String?
    var pinnedBy: Int?
    var buyerInfo: MPChatBuyerInfoModel?
    var offerInfo: MPChatOfferInfoModel?
    var headerInfo: MPChatHeaderInfoModel?
    var files: [MPMessageFileModel]?
    var messageReaction: [MPMessageReactionModel]?
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case createdAt = "created_at"
        case content
        case senderName = "sender_name"
        case id
        case repliedToMessageId = "replied_to_message_id"
        case repliedToContent = "replied_to_content"
        case senderImage = "sender_image"
        case marketImages = "market_images"
        case reaction
        case messageType = "message_type"
        case messageLabel = "message_label"
        case groupImage = "group_image"
        case conversationName = "conversation_name"
        case conversationCreatedAt = "conversation_created_at"
        case buyerInfo
        case offerInfo
        case headerInfo
        case files
        case messageReaction = "message_reaction"
        case identifier
        case pinnedBy = "pinned_by"
    }
    
    init() {
        self.conversationId = nil
        self.senderId = nil
        self.receiverId = nil
        self.createdAt = nil
        self.content = nil
        self.senderName = nil
        self.id = nil
        self.repliedToMessageId = nil
        self.repliedToContent = nil
        self.senderImage = nil
        self.marketImages = nil
        self.reaction = nil
        self.messageType = nil
        self.messageLabel = nil
        self.groupImage = nil
        self.conversationName = nil
        self.conversationCreatedAt = nil
        self.buyerInfo = nil
        self.offerInfo = nil
        self.headerInfo = nil
        self.files = []
        self.messageReaction = nil
        self.identifier = nil
        self.pinnedBy = nil
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        self.id = SharedManager.shared.ReturnValueAsInt(value: dictionary["id"] as Any)
        self.repliedToMessageId = SharedManager.shared.ReturnValueAsInt(value: dictionary["replied_to_message_id"] as Any)
        self.repliedToContent = SharedManager.shared.ReturnValueAsString(value: dictionary["replied_to_content"] as Any)
        
        self.content = SharedManager.shared.ReturnValueAsString(value: dictionary["content"] as Any)
        self.senderId = SharedManager.shared.ReturnValueAsInt(value: dictionary["sender_id"] as Any)
        self.createdAt = SharedManager.shared.ReturnValueAsString(value: dictionary["created_at"] as Any)
        self.conversationId = SharedManager.shared.ReturnValueAsInt(value: dictionary["conversation_id"] as Any)
        self.senderImage = SharedManager.shared.ReturnValueAsString(value: dictionary["sender_image"] as Any)
        self.senderName = SharedManager.shared.ReturnValueAsString(value: dictionary["sender_name"] as Any)
        self.reaction = SharedManager.shared.ReturnValueAsString(value: dictionary["reaction"] as Any)
        self.messageLabel = SharedManager.shared.ReturnValueAsString(value: dictionary["message_label"] as Any)
        self.messageType = SharedManager.shared.ReturnValueAsInt(value: dictionary["message_type"] as Any)
        self.identifier = SharedManager.shared.ReturnValueAsString(value: dictionary["identifier"] as Any)
        self.pinnedBy = SharedManager.shared.ReturnValueAsInt(value: dictionary["pinnedBy"] as Any)
        
        self.files = []
        if let arrayMessage = dictionary["files"] as? [[String : Any]] {
            for indexObj in arrayMessage {
                self.files?.append(MPMessageFileModel.init(fromDictionary: indexObj))
            }
        }
        
        if let reactionMessage = dictionary["message_reaction"] as? [[String : Any]] {
            for indexObj in reactionMessage {
                self.messageReaction?.append(MPMessageReactionModel.init(fromDictionary: indexObj))
            }
        }
    }
}

struct MPMessageMarketImage: Codable {
    let id: Int?
    let url: String?
    let type: String?
}

struct MPChatBuyerInfoModel: Codable {
    let name: String?
    let title: String?
    let buttonText: String?
    let id: Int?
    let token: String?
    let worldnoorUserId: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case title
        case buttonText = "button_text"
        case id
        case token
        case worldnoorUserId = "worldnoor_user_id"
    }
}

struct MPChatOfferInfoModel: Codable {
    let offerInfo: String?
    let offerDescription: String?
    let offerId: Int?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case offerInfo = "offer_info"
        case offerDescription = "offer_description"
        case offerId = "offer_id"
        case price
    }
}

struct MPChatHeaderInfoModel: Codable {
    let groupImage: String?
    let groupTitle: String?
    let groupInfo: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case groupImage = "group_image"
        case groupTitle = "group_title"
        case groupInfo = "group_info"
        case createdAt = "created_at"
    }
}

struct MPMessageFileModel: Codable {
    var id: String?
    var name: String?
    var size: String?
    var thumbnailUrl: String?
    var type: String?
    var url: String?
//    var audioWaveform: [Int]?
    var length: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case size
        case thumbnailUrl = "thumbnail_url"
        case type
        case url
//        case audioWaveform = "audio_waveform"
        case length
    }
    
    init() {
        self.id = nil
        self.name = nil
        self.size = nil
        self.thumbnailUrl = nil
        self.type = nil
        self.url = nil
//        self.audioWaveform = nil
        self.length = nil
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        self.id = SharedManager.shared.ReturnValueAsString(value: dictionary["id"] as Any)
        self.name = SharedManager.shared.ReturnValueAsString(value: dictionary["name"] as Any)
        self.size = SharedManager.shared.ReturnValueAsString(value: dictionary["size"] as Any)
        self.thumbnailUrl = SharedManager.shared.ReturnValueAsString(value: dictionary["thumbnail_url"] as Any)
        self.type = SharedManager.shared.ReturnValueAsString(value: dictionary["type"] as Any)
        self.url = SharedManager.shared.ReturnValueAsString(value: dictionary["url"] as Any)
//        self.audioWaveform = SharedManager.shared.ReturnValueAsString(value: dictionary["audioWaveform"] as Any)
        self.length = SharedManager.shared.ReturnValueAsString(value: dictionary["length"] as Any)
    }
}

struct MPMessageReactionModel: Codable {
    let firstname: String?;
    let lastname: String?;
    let messageId: Int?
    let profileImage: String?
    let reactedBy: Int?
    let reaction: String?
    
    enum CodingKeys: String, CodingKey {
        case firstname
        case lastname
        case messageId = "message_id"
        case profileImage = "profile_image"
        case reactedBy = "reacted_by"
        case reaction
    }
    
    init() {
        self.firstname = nil
        self.lastname = nil
        self.messageId = nil
        self.profileImage = nil
        self.reactedBy = nil
        self.reaction = nil
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        self.firstname = SharedManager.shared.ReturnValueAsString(value: dictionary["firstname"] as Any)
        self.lastname = SharedManager.shared.ReturnValueAsString(value: dictionary["lastname"] as Any)
        self.messageId = SharedManager.shared.ReturnValueAsInt(value: dictionary["message_id"] as Any)
        self.profileImage = SharedManager.shared.ReturnValueAsString(value: dictionary["profile_image"] as Any)
        self.reactedBy = SharedManager.shared.ReturnValueAsInt(value: dictionary["reacted_by"] as Any)
        self.reaction = SharedManager.shared.ReturnValueAsString(value: dictionary["reaction"] as Any)
    }
}
