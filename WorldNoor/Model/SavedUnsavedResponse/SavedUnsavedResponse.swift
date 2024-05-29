//
//  SaveViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 02/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct SavedUnsavedResponse: Codable {
    let action: String
    let data: SavedUnsavedDataResponse
    let meta: Meta
    
}

struct SavedUnsavedDataResponse: Codable {
    
}
