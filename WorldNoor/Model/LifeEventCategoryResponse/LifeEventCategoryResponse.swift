//
//  LifeEventCategoryResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

// Define the top-level structure
struct LifeEventCategoryResponse: Codable {
    let action: String
    let meta: Meta
    var data: [LifeEventCategoryModel]
}

// Define the Category structure
struct LifeEventCategoryModel: Codable {
    let id: Int
    let name: String
    let description: String?
    let icon: String
    let categoryImage: String
    var subCategory: [LifeEventSubCategoryModel]
}

// Define the SubCategory structure
struct LifeEventSubCategoryModel: Codable {
    let id: Int
    let name: String
    let description: String?
    let icon: String
    let category_id: Int
}
