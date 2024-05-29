//
//  MPSellDashboardResponse.swift
//  WorldNoor
//
//  Created by Awais on 03/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct MPSellDashboardResponse: Codable {
    let action: String
    let meta: Meta
    let data: MPSellDashboardData
}

struct MPSellDashboardData: Codable {
    let userReviewsCount: Int
    let userClicksCount: Int
    let activeItemsCount: Int
    let draftItemsCount: Int
    let soldItemsCount: Int
    let savedItemsCount: Int
    let sharedItemsCount: Int
    let followersCount: Int
    let chatsToAnswer: Int
    let renewListingsCount: Int
    let userClicksCount7Days: Int
    let followersCount7Days: Int
    let lastItemListed: MPSellDashboardLastItemListed
    
    enum CodingKeys: String, CodingKey {
        case userReviewsCount = "user_reviews_count"
        case userClicksCount = "user_clicks_count"
        case activeItemsCount = "active_items_count"
        case draftItemsCount = "draft_items_count"
        case soldItemsCount = "sold_items_count"
        case savedItemsCount = "saved_items_count"
        case sharedItemsCount = "shared_items_count"
        case followersCount = "followers_count"
        case chatsToAnswer = "chats_to_answer"
        case renewListingsCount = "renew_listings_count"
        case userClicksCount7Days = "user_clicks_count_7_days"
        case followersCount7Days = "followers_count_7_days"
        case lastItemListed = "last_item_listed"
    }
}

struct MPSellDashboardLastItemListed: Codable {
    let productId: Int
    let name: String
    let slug: String
    let price: String
    let lat: String
    let lng: String
    let description: String
    let createdAt: String
    let isAvailable: Int
    let isSold: String
    let address: String
    let clicksOnListing: Int
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case name
        case slug
        case price
        case lat
        case lng
        case description
        case createdAt = "created_at"
        case isAvailable = "is_available"
        case isSold = "is_sold"
        case address
        case clicksOnListing = "clicks_on_listing"
        case images
    }
}
