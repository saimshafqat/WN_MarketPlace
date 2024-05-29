//
//  MPFilterModel.swift
//  WorldNoor
//
//  Created by Ahmad on 21/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct FilterModel: Codable {
//    let action: String?
//    let meta: Meta?
    let data: FilterModelResult?
}


struct FilterModelResult: Codable {
    let results: ResultCondition?
}

struct ResultCondition: Codable {
    let conditions: [FilterCondition]?
}


struct FilterCondition: Codable {
    let id: Int?
    let name: String?
    let slug: String?
}
