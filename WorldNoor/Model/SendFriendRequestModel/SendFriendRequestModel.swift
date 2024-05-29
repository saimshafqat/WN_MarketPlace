//
//  FriendRequestModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct SendFriendRequestModel: Codable {
    let meta: Meta
    let action: String
    let data: FriendRequestData
}

// Define the DataItem struct for the 'data' array
struct FriendRequestData: Codable {
    var result: Bool
}
