//
//  MarketPlaceCategoryListCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MarketPlaceCategoryListCell)
class MarketPlaceCategoryListCell: SSBaseCollectionCell {
    
    // MARK: - Properties -
    @IBOutlet weak var categoryImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    
    // MARK: - Override -
    override func configureCell(_ cellInfo: Any? = nil, atIndex thisIndex: IndexPath, with object: Any? = nil) {
        let sectionIdentifier = cellInfo as? String
        if sectionIdentifier == Const.genericCategories {
            if let item = object as? GenericCategory {
                nameLabel?.text = item.name
                categoryImageView?.loadImage(urlMain: item.icon)
            }
        } else {
            if let item = object as? Category {
                nameLabel?.text = item.name
                categoryImageView?.loadImage(urlMain: item.icon ?? "")
            }
        }
    }
}
