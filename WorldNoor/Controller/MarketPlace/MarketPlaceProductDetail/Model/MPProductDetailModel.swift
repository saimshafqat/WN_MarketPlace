//
//  MarketPlaceProductDetailModelCollectionReusableView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct MPProductDetailModel: Codable {
    let action: String
    let meta: Meta
    let data: MPProductDetailDataModel
}

//struct MPProductDetailDataModel: Codable {
//    let returnResp: MPProductDetailDataModelResp
//}
//
//struct MPProductDetailDataModelResp: Codable {
//    let groups: [MPProductDetailGroupModel]
//    let categories: [Category]
//    let products: [MPProductModel]
//    let totalPages: Int
//    let currentPage: String
//}
//
//struct MPProductModel: Codable {
//    let categoryId: Int
//    let categoryName: String
//    let categorySlug: String
//    let name: String
//    let slug: String
//    let price: String


struct MPProductDetailDataModel: Codable {
    let product: MpProductDetailModel
}

struct MpProductDetailModel: Codable {
    let name: String
    let slug: String
    let price: String
    let lat: String
    let lng: String
    let description: String
    let postDate: String
    let isAvailable: Int
    let isSold: String
    let quantity: Int
    let tags: [String]?
    let address: String
    let condition: String
    let cID: Int?
    let isSaved: Bool
    let isDefaultMsgSent: Bool
    let isAlertCreated: Bool
    let user: MarketplaceUserModel
    let userSettings: MarketPlaceUserSettingsModel
    let images: [String]
    let similarProducts: [MPSimilarProductModel]?
    let relatedProducts: [MPRelatedProductModel]?
    let groups: [MPProductDetailGroupModel]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case slug
        case price
        case lat
        case lng
        case description
        case postDate = "post_date"
        case isAvailable = "is_available"
        case isSold = "is_sold"
        case quantity
        case tags
        case address
        case condition
        case cID = "c_id"
        case isSaved = "is_saved"
        case isDefaultMsgSent = "is_default_msg_sent"
        case isAlertCreated = "is_alert_created"
        case user
        case userSettings = "user_settings"
        case groups
        case images
        case similarProducts = "similar_products"
        case relatedProducts = "related_products"
    }
}

struct MarketplaceUserModel: Codable {
    let userID: Int?
    let name: String?
    let email: String?
    let dob: String?
    let gender: String?
    let profileImage: String?
    let isFollowed: Bool
    let posterJoinDate: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case name
        case email
        case dob
        case gender
        case profileImage = "profile_image"
        case isFollowed = "is_followed"
        case posterJoinDate = "poster_join_date"
    }
}

struct MarketPlaceUserSettingsModel: Codable {
    let showNotificationDots: Int?
    let peopleFollowYou: Int?
    let sellerMode: Int?
    let vactionMode: Int?
    let customSellerMessage: String?
    let customBuyerMesage: String?
    
    enum CodingKeys: String, CodingKey {
        case showNotificationDots = "show_notification_dots"
        case peopleFollowYou = "people_follow_you"
        case sellerMode = "seller_mode"
        case vactionMode = "vaction_mode"
        case customSellerMessage = "custom_seller_message"
        case customBuyerMesage = "custom_buyer_mesage"
    }
}

struct MPSimilarProductModel: Codable {
    let productID: Int?
    let name: String?
    let slug: String?
    let price: String?
    let lat: String?
    let lng: String?
    let description: String?
    let createdAt: String?
    let isAvailable: Int?
    let isSold: String?
    let quantity: Int?
    let marketCategoryId: Int?
    let conditionName: String?
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case name
        case slug
        case price
        case lat
        case lng
        case description
        case createdAt = "created_at"
        case isAvailable = "is_available"
        case isSold = "is_sold"
        case quantity
        case marketCategoryId = "market_category_id"
        case conditionName = "condition_name"
        case images
    }
}

struct MPRelatedProductModel: Codable {
    let productID: Int?
    let name: String?
    let slug: String?
    let price: String?
    let lat: String?
    let lng: String?
    let description: String?
    let createdAt: String?
    let isAvailable: Int?
    let isSold: String?
    let quantity: Int?
    let marketCategoryId: Int?
    let conditionName: String?
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case name, slug, price, lat, lng, description
        case createdAt = "created_at"
        case isAvailable = "is_available"
        case isSold = "is_sold"
        case quantity
        case marketCategoryId = "market_category_id"
        case conditionName = "condition_name"
        case images
    }
}

struct MPProductDetailGroupModel: Codable {
    let id: Int
    let name: String
    let description: String?
    let categoryId: Int
    let locationId: Int?
    let coverPhotoPath: String
    let colorCode: String?
    let urlSlug: String
    let privacy: String
    let visibility: String
    let statusId: Int
    let statusReason: String?
    let createdBy: Int?
    let updatedBy: Int?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let member: [ProductGroupMember]?
    let members: Int
    let lastWeekJoinedMember: Int?
    let todayPosts: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case categoryId = "category_id"
        case locationId = "location_id"
        case coverPhotoPath = "cover_photo_path"
        case colorCode = "color_code"
        case urlSlug = "url_slug"
        case privacy, visibility
        case statusId = "status_id"
        case statusReason = "status_reason"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case lastWeekJoinedMember = "last_week_joined_members"
        case todayPosts = "today_posts"
        case members
        case member
    }
}

struct ProductGroupMember: Codable {
    let name: String?
    let profile_image: String?
}
