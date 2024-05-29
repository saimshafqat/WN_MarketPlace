//
//  SectionInfo.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit


class SectionInfo:SSSection {
    
    var sortId: Int = 0
    var sectionLayout: NSCollectionLayoutSection?
    var cellsClass: AnyClass?
    
    class func section(
        withItems items: [AnyObject]?,
        header: String? = "",
        footer: String? = "",
        identifier: Any? = "",
        sortId: Int = 0,
        layout: NSCollectionLayoutSection? = nil,
        cellClass: AnyClass? = nil) -> SectionInfo {
            let section = SectionInfo()
            if items != nil {
                section.items.addObjects(from: items ?? [])
            }
            section.sortId = sortId
            section.sectionLayout = layout
            section.cellsClass = cellClass
            section.header = header
            section.footer = footer
            section.sectionIdentifier = identifier
            return section
        }
}

enum SectionIdentifier: String {
    
    case images
    case productInfo
    case produceDescription
    case sellerInformation
    case productDetailCondition
    case productMapMeet
    case similarProduct = "Similar listing from sellers"
    case productGroup = "Related buy-and-sell groups"
    case relatedProduct = "Products related to this item"
    
    case PeopleSearch = "People"
    case PageSearch = "Pages"
    case GroupSearch = "Groups"
    case PostSearch = "Post"
    
    // Sell Screen
    case MPSellTag
    case MPSellListCreating
    case MPSellOverview = "Overview"
    case sellPerformance = "Performance"
    
    var type: String {
        return rawValue
    }
}
