//
//  RecentSearchModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 30/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit


struct RecentSearchResponse: Codable {
    let action: String
    let data: [RecentSearchData]
    let meta: Meta
}

struct RecentSearchData: Codable {
    
    let createdAt: String
    let id: Int
    let searchQuery: String
    let updatedAt: String
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case searchQuery = "search_query"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
}
