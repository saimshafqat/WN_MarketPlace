//
//  User.swift
//  WorldNoor
//
//  Created by Raza najam on 9/30/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation

// MARK: - User
struct User: Codable {
    let action:String?
    var data: DataClass
    let meta : Meta?
}

struct DataClass : Codable {
    let id : Int?
    let emailVerified : String?
    var profile_image : String?
    var cover_image : String? = ""
    var dob : String? = ""
    var city : String? = ""
    var about_me : String? = ""
    var isGoogleAccount : Bool?
    var isProfileCompleted : Bool?
    var gender : String? = ""
    var created_at : String? = ""
    var updated_at : String? = ""
    var apiToken : String? = ""
    var firstname : String? = ""
    var lastname : String? = ""
    var email : String? = ""
    var phone : String? = ""
    let countryID : Int?
    let stateID : Int?
    let language_id : Int?
    let notificationCount : Int?
    let website : String?
    let token:String?
    var jwtToken:String? = ""
    var posh_id:String? = ""
    var custom_gender:String? = ""
    var pronoun:String? = ""
    let country_code : String?
    let address : String?
    let username : String?
    var screenPin : Bool?
    var placesAdded: Bool?
    var workAdded: Bool?
    var RelationAdded: Bool?
    var isSocialLogin: Bool? = false
    
    var fullname : String {
        return self.firstname! + " " + self.lastname!
    }
    
    enum CodingKeys: String, CodingKey {
        case screenPin = "screen_pin"
        case id = "id"
        case emailVerified = "email_verified_at"
        case username = "username"
        case profile_image = "profile_image"
        case cover_image = "cover_image"
        case dob = "dob"
        case city = "city"
        case about_me = "about_me"
        case isGoogleAccount = "is_google_account"
        case isProfileCompleted = "is_profile_completed"
        case gender = "gender"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case apiToken = "api_token"
        case firstname = "firstname"
        case lastname = "lastname"
        case email = "email"
        case phone = "phone"
        case countryID = "country_id"
        case stateID = "state_id"
        case language_id = "language_id"
        case notificationCount = "fr_accepted_notifications_count"
        case website = "website"
        case token = "token"
        case country_code = "country_code"
        case address = "address"
        case jwtToken = "jwtToken"
        case posh_id = "posh_id"
        case custom_gender = "custom_gender"
        case pronoun = "pronoun"
        case placesAdded = "placesAdded"
        case workAdded = "workAdded"
        case RelationAdded = "RelationAdded"
        
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pronoun = try values.decodeIfPresent(String.self, forKey: .pronoun)
        custom_gender = try values.decodeIfPresent(String.self, forKey: .custom_gender)
        jwtToken = try values.decodeIfPresent(String.self, forKey: .jwtToken)
        jwtToken = try values.decodeIfPresent(String.self, forKey: .jwtToken)
        posh_id = try values.decodeIfPresent(String.self, forKey: .posh_id)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        emailVerified = try values.decodeIfPresent(String.self, forKey: .emailVerified)
        profile_image = try values.decodeIfPresent(String.self, forKey: .profile_image)
        cover_image = try values.decodeIfPresent(String.self, forKey: .cover_image)
        dob = try values.decodeIfPresent(String.self, forKey: .dob)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        about_me = try values.decodeIfPresent(String.self, forKey: .about_me)
        isProfileCompleted = try values.decodeIfPresent(Bool.self, forKey: .isProfileCompleted)
        isGoogleAccount = try values.decodeIfPresent(Bool.self, forKey: .isGoogleAccount)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        apiToken = try values.decodeIfPresent(String.self, forKey: .apiToken)
        firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        countryID = try values.decodeIfPresent(Int.self, forKey: .countryID)
        stateID = try values.decodeIfPresent(Int.self, forKey: .stateID)
        language_id = try values.decodeIfPresent(Int.self, forKey: .language_id)
        notificationCount = try values.decodeIfPresent(Int.self, forKey: .notificationCount)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        country_code = try values.decodeIfPresent(String.self, forKey: .country_code)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        screenPin = try values.decodeIfPresent(Bool.self, forKey: .screenPin)
        placesAdded = try values.decodeIfPresent(Bool.self, forKey: .placesAdded)
        workAdded = try values.decodeIfPresent(Bool.self, forKey: .workAdded)
        RelationAdded = try values.decodeIfPresent(Bool.self, forKey: .RelationAdded)
    }
    
}




//struct Places : Codable {
//    
//    let address : String?
//    let city : String?
//    let place : String?
//    let state : String?
//    let country_id : Int?
//    let id : Int?
//    
//    
//    enum CodingKeys: String, CodingKey {
//        case address = "address"
//        case city = "city"
//        case place = "place"
//        case state = "state"
//        case country_id = "country_id"
//        case id = "id"
//    }
//    
//    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        address = try values.decodeIfPresent(String.self, forKey: .address)
//        city = try values.decodeIfPresent(String.self, forKey: .city)
//        place = try values.decodeIfPresent(String.self, forKey: .place)
//        state = try values.decodeIfPresent(String.self, forKey: .state)
//        country_id = try values.decodeIfPresent(Int.self, forKey: .country_id)
//        id = try values.decodeIfPresent(Int.self, forKey: .id)
//        
//    }
//}
