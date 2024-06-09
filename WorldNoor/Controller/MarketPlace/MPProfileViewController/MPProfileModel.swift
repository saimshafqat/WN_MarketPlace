//
//  MPProductModel.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
//
//struct CategoryDetailData: Codable {
//    let action: String?
//    let meta: Meta?
//    let data: CategoryDetailDataResponse?
//}
//
//
//struct CategoryDetailDataResponse: Codable {
//    let returnResp: ReturnResponse?
//}
//
//struct ReturnResponse: Codable {
//    var groups: [MPProductDetailGroupModel]?
//    var products: [MarketPlaceForYouItem]?
//    var total_pages: Int?
//    var current_page: String?
//}
//
//
//struct Product: Codable {
//    let category_id: Int?
//    let category_name: String?
//    let category_slug: String?
//    let id: Int?
//    let name: String?
//    let slug: String?
//    let description: String?
//    let price: String?
//    let address: String?
//    let images: [String]?
//    let created_at: String?
//    let is_saved: Bool?
//    let is_default_msg_sent: Bool?
//    let is_alert_created: Bool?
//}

enum MPProfileCellType : String {
    case settingsInfo = "settingsInfo"
    case holidaySettings = "HolidaySettings"
    case coverPhoto = "coverPhoto"
    case shareButton = "shareButton"
    case aboutMe = "aboutMe"
    case sellerRating = "sellerRating"
    case yourStrengths = "yourStrengths"
    case accessYourRatings = "accessYourRatings"
    case listingHeaderCell = "listingHeaderCell"
    case listingCell = "listingCell"
    case noListinFoundCell = "noListinFoundCell"
    case followAndChatCell = "followAndChatCell"
    case sellerModeMessgae = "sellerModeMessgae"
}

enum UserListing {
    case none
    case serach
    case isSold
    case sortBy

}

enum userTypeForCell {
    case currentUser
    case otheruser
}

enum SortingOrder: String {
    case ascending = "asc"
    case descending = "des"
}
struct UserListingRequestModel: Codable {
    let seller_id: Int?
    let search: String?
    var page: Int?
    var perPage:Int?
}
struct ProfileItem {
    let id: Int
    let name: String
}


class DynamicCellModel {
    
    var cellIndentifier: String
    var type: String?
    var isSelected = false
    var pickerIndex = 0
    
    init(cellIndentifier: String, type: String) {
        self.cellIndentifier = cellIndentifier
        self.type = type
    }
}


struct FollowingUsersItems: Codable {
    let action: String?
    let meta: Meta?
    var data: FollowingUsersDataClass?
}

struct FollowingUsersDataClass: Codable {
    let user: ListingUser?
    let userSettings: UserSettings?
    var products: [UserListingProduct]?
    let totalPages: Int?
    let currentPage: String?

    private enum CodingKeys: String, CodingKey {
        case user, products
        case userSettings = "user_settings"
        case totalPages = "total_pages"
        case currentPage = "current_page"
    }
}

struct UserSettings: Codable {
    let id, userId, showNotificationDots, peopleFollowYou: Int?
    let sellerMode, vactionMode: Int?
    let customSellerMessage, customBuyerMessage: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case showNotificationDots = "show_notification_dots"
        case peopleFollowYou = "people_follow_you"
        case sellerMode = "seller_mode"
        case vactionMode = "vaction_mode"
        case customSellerMessage = "custom_seller_message"
        case customBuyerMessage = "custom_buyer_message"
    }
}

struct ListingUser: Codable {
    let id: Int?
    let name, email: String?
    let dob, gender: String? // Assuming these can be null
    let coverImage, profileImage, country, city: String?
    let worldnoorCountry, worldnoorCity: String?
    let createdAt: Int?
    let aboutMe, responsive, username: String?
    let worldnoorUserId, totalListingsCount, totalFollowersCount: Int?
    let isFollowing: Bool?
    let firstname, lastname, sellerProfileLink: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, email, dob, gender
        case coverImage = "cover_image"
        case profileImage = "profile_image"
        case country, city
        case worldnoorCountry = "worldnoor_country"
        case worldnoorCity = "worldnoor_city"
        case createdAt = "created_at"
        case aboutMe = "about_me"
        case responsive, username
        case worldnoorUserId = "worldnoor_user_id"
        case totalListingsCount = "total_listings_count"
        case totalFollowersCount = "total_followers_count"
        case isFollowing = "is_following"
        case firstname, lastname
        case sellerProfileLink = "seller_profile_link"
    }
}
struct UserListingProduct: Codable {
    let productId, id: Int?
    let name, slug, price, lat: String?
    let lng, description, createdAt: String?
    let isAvailable: Int?
    let isSold: String?
    let quantity: Int?
    let tags: String? // Assuming tags can be null
    let condition: String?
    let images: [String]?

    private enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case id, name, slug, price, lat, lng, description
        case createdAt = "created_at"
        case isAvailable = "is_available"
        case isSold = "is_sold"
        case quantity, tags, condition, images
    }
}
