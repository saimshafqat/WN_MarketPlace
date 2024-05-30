//
//  MPProductModel.swift
//  WorldNoor
//
//  created by Moeez akram on 14/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct CategoryDetailData: Codable {
    let action: String?
    let meta: Meta?
    let data: CategoryDetailDataResponse?
}


struct CategoryDetailDataResponse: Codable {
    let returnResp: ReturnResponse?
}

struct ReturnResponse: Codable {
    var groups: [MPProductDetailGroupModel]?
    var products: [MarketPlaceForYouItem]?
    var total_pages: Int?
    var current_page: String?
}


struct Product: Codable {
    let category_id: Int?
    let category_name: String?
    let category_slug: String?
    let id: Int?
    let name: String?
    let slug: String?
    let description: String?
    let price: String?
    let address: String?
    let images: [String]?
    let created_at: String?
    let is_saved: Bool?
    let is_default_msg_sent: Bool?
    let is_alert_created: Bool?
}
