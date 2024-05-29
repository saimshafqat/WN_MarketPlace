//
//  UserFriendResponseModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 15/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct UserFriendResponseModel: Decodable {
    let meta: Meta
    let action: String
    let data: [FriendModel]
}

struct FriendModel: Decodable {
    let phone: String?
    let isOnline: Int?
    let id: Int?
    let lastname: String?
    let firstname: String?
    let email: String?
    let username: String?
    let profileImage: String?
    let latestConversationId: Int?
    
    enum CodingKeys: String, CodingKey {
        case phone, isOnline = "is_online", id, lastname, firstname, email, username, profileImage = "profile_image", latestConversationId = "latest_coversation_id"
    }
}
