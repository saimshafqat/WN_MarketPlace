//
//  FCMStoreResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

struct FCMStoreResponseModel: Decodable {
    let action: String
    let data: FCMData
    let meta: Meta
}

struct FCMData: Decodable {
    let createdAt: String
    let deviceType: String
    let id: Int
    let token: String
    let updatedAt: String
    let userId: Int
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case deviceType = "device_type"
        case id
        case token
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}
