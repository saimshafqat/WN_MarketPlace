//
//  CategoryLikePagesResponse.swift
//  WorldNoor
//
//  Created by Awais on 29/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct CategoryLikePagesResponse: Decodable {
    let action: String
    let meta: Meta
    let data: [String: [LikePage]]
}

struct LikePage: Decodable {
    let slug: String
    let title: String
    let pageId: Int
    let userId: Int
    let name: String
    let profile: String?
    
    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case pageId = "page_id"
        case userId = "user_id"
        case name
        case profile
    }
}

struct LeaveGroupResponseModel: Decodable {
    let action: String
    let meta: Meta
    let data: LeaveGroupDataModel
}

struct LeaveGroupDataModel: Decodable {
    let status: Bool
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case status
        case userId = "user_id"
    }
}
