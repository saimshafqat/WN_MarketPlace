//
//  ModelCollectionReusableView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct MarketPlaceForYouItem: Codable {
    let category_id: Int?
    let category_name: String?
    let category_slug: String?
    let id: Int
    let name: String
    let slug: String
    let description: String
    let price: String
    let created_at: String
    let address: String
    let distance: Int?
    var is_alert_created: Bool?
    var is_saved: Bool?
    var is_default_msg_sent: Bool?
    let images: [String]
}

struct MarketPlaceForYouProduct: Codable {
    let id: Int?
    let category_name: String
    let slug: String
    let items: [MarketPlaceForYouItem]
}

struct MarketPlaceForYouUser: Codable {
    let id: Int
    let name: String
    let email: String
    let email_verified_at: String?
    let dob: String?
    let gender: String?
    let password: String
    let profile_image: String
    let cover_image: String?
    let about_me: String?
    let firstname: String
    let lastname: String
    let phone: String?
    let country_id: Int
    let country: String
    let state_id: Int
    let city_id: Int
    let county_id: Int
    let ui_language_id: String?
    let website: String?
    let username: String?
    let country_code: String?
    let currency: String
    let city: String
    let created_at: String
    let updated_at: String
    let worldnoor_user_id: Int?
    let latitude: String
    let longitude: String
    let radius: Int
    let worldnoor_country: String?
    let worldnoor_city: String?
    let is_app_updated_location: Int
}

struct MarketPlaceForYouReturnResp: Codable {
    let categories: [String]
    let products: [MarketPlaceForYouProduct]
    let user: MarketPlaceForYouUser
    let total_pages: Int
    let current_page: String
    let is_last_category: Int
}

struct MarketPlaceForYouDataDetail: Codable {
    let returnResp: MarketPlaceForYouReturnResp
}

struct MarketPlaceForYouDataResponse: Codable {
    let action: String
    let meta: Meta
    let data: MarketPlaceForYouDataDetail
}
