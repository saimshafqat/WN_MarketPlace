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
    case coverPhoto = "coverPhoto"
    case shareButton = "shareButton"
    case aboutMe = "aboutMe"
    case sellerRating = "sellerRating"
    case yourStrengths = "yourStrengths"
    case accessYourRatings = "accessYourRatings"
    case listingHeaderCell = "listingHeaderCell"
    case listingCell = "listingCell"
    case noListinFoundCell = "noListinFoundCell"
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
