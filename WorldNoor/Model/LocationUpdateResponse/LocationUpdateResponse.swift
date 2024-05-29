//
//  LocationUpdateResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 23/04/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct LocationUpdateResponse: Codable {
    let action: String
    let data: UserLocationDataDetails
    let meta: Meta
}

struct UserLocationDataDetails: Codable {
    
}
