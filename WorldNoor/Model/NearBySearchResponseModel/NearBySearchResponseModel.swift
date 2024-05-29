//
//  PeopleNearByResponseModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct NearBySearchResponseModel: Codable {
    var action: String
    var meta: Meta
    var data: [NearByUserModel]
}


struct NearByUserModel: Codable {
    
    var userId: String
    var statusId: String
    var profileImage: String
    var aboutMe: String
    var lastname: String
    var city: String
    var gender: String
    var coverImage: String
    var firstname: String
    var distanceInKm: String
    var countryId: Int
    var username: String
    var email: String
    var dob: String
    var phone: String
    var hideStatus: String
    var isMyFriend: String
    var friendStatus: String
    var alreadySentFriendReq: Bool
    var canISendFr: Bool
    var emailVerifiedAt: String
    var password: String
    var rememberToken: String
    var createdAt: String
    var updatedAt: String
    var apiToken: String
    var stateId: Int
    var languageId: Int
    var frAcceptedNotificationsCount: Int
    var website: String
    var isOnline: Int
    var authorName: String
    var locationId: Int
    var lat: String
    var longitude: String
    var country: String
    var id: Int
    var interests: [NearByInterestModel]
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case statusId = "status_id"
        case profileImage = "profile_image"
        case aboutMe = "about_me"
        case lastname
        case city
        case gender
        case coverImage = "cover_image"
        case firstname
        case distanceInKm = "distance_in_km"
        case countryId = "country_id"
        case username
        case email
        case dob
        case phone
        case hideStatus = "hide_status"
        case isMyFriend = "is_my_friend"
        case friendStatus = "friend_status"
        case alreadySentFriendReq = "already_sent_friend_req"
        case canISendFr = "can_i_send_fr"
        case emailVerifiedAt = "email_verified_at"
        case password
        case rememberToken = "remember_token"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case apiToken = "api_token"
        case stateId = "state_id"
        case languageId = "language_id"
        case frAcceptedNotificationsCount = "fr_accepted_notifications_count"
        case website
        case isOnline = "is_online"
        case authorName = "author_name"
        case locationId = "location_id"
        case lat
        case longitude
        case country
        case id
        case interests
    }
}

struct NearByInterestModel : Codable {
    var id: Int
    var name: String
}
