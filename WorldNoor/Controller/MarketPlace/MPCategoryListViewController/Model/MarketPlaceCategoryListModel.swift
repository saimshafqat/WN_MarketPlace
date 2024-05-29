//
//  MarketPlaceCategoryModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class Item {
    var name: String = ""
    var iconImage: UIImage? = UIImage()
    var description: String = ""
    var counterStr: String = ""
    var selectedItem: NavigationType = .price
    var minimumPrice: String = ""      // Minimum price for the filter
    var maximumPrice: String = ""      // Maximum price for the filter
    var daysSinceListed: String = "Any"
    var availability: String = "Any"
    var condition: String = "Any"
    var isApplyFilter: Bool = false
    var selectedIndex : String = ""
    init(name: String = "", iconImage: UIImage? = UIImage(), description: String = "", counterStr:String = "", selectedItem: NavigationType = .price, minimumPrice: String = "", maximumPrice: String = "", daysSinceListed: String = "Any", availability: String = "Any", condition: String = "Any", isApplyFilter: Bool = false, selectedIndex : String = "") {
        self.name = name
        self.iconImage = iconImage
        self.description = description
        self.counterStr = counterStr
        self.selectedItem = selectedItem
        self.minimumPrice = minimumPrice
        self.maximumPrice = maximumPrice
        self.daysSinceListed = daysSinceListed
        self.availability = availability
        self.condition = condition
        self.isApplyFilter = isApplyFilter
        self.selectedIndex = selectedIndex
    }
}

class Section {
    var name: String = ""
    var iconImage: UIImage? = UIImage()
    var items: [Item] = []
    init(name: String = "", iconImage: UIImage? = UIImage(), items: [Item] = []) {
        self.name = name
        self.iconImage = iconImage
        self.items = items
    }
}

struct CategoryResult: Codable {
    let data: CategoryData
    let action: String
    let meta: Meta
}

struct CategoryData: Codable {
    let results: Results
}

struct Results: Codable {
    let all_categories: [Category]
    let generic_categories: [GenericCategory]
    let top_categories: [Category]
}

struct Category: Codable {
    let created_at: String
    let icon: String?
    let id: Int
    let market_category_type_id: String?
    let name: String
    let parent_id: String?
    let slug: String
    let type: String
    let updated_at: String
}

struct GenericCategory: Codable {
    let icon: String
    let name: String
    let type: String
}

