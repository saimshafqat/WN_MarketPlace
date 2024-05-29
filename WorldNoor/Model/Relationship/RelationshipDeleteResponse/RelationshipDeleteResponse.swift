//
//  RelationshipDeleteResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 18/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

struct RelationshipDeleteResponse: Decodable {
    let meta: Meta
    let action: String
    let data: RelationshipDeleteData
}

struct RelationshipDeleteData: Decodable {
    
}
