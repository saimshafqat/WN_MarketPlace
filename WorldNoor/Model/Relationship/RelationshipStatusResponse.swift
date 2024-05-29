//
//  RelationshipStatusResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 14/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct RelationshipStatusResponse: Decodable {
    let action: String
    let data: [RelationshipStatus]
    let meta: Meta
}

struct RelationshipStatus: Decodable {

    let status: String
    let id: Int
    let updatedAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case status
        case id
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}
