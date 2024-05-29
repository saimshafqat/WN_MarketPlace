//
//  CancelFriendRequestModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct CancelFriendRequestModel: Codable {
    let meta: Meta
    let action: String
    let data: CancelFriendRequestData
}

// Define the DataItem struct for the 'data' array
struct CancelFriendRequestData: Codable {
}

