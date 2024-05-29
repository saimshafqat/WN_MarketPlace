//
//  UserRegistrationResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

struct UserRegistrationResponse: Codable {
    let action: String
    let data: UserData
    let meta: Meta
}

struct UserData: Codable {
    let aboutMe: String?
    let countryCode: String
    let coverImage: String?
    let dob: String
    let email: String?
    let firstname: String
    let gender: String
    let id: Int
    let isPhone: Bool
    let lastname: String
    let phone: Int
    let profileImage: String
    let pronoun: String?

    enum CodingKeys: String, CodingKey {
        case aboutMe = "about_me"
        case countryCode = "country_code"
        case coverImage = "cover_image"
        case dob, email, firstname, gender, id
        case isPhone = "is_phone"
        case lastname, phone
        case profileImage = "profile_image"
        case pronoun
    }
}
