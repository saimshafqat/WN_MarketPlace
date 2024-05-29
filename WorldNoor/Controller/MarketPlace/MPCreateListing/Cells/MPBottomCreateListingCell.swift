//
//  MPBottomCreateListingCell.swift
//  WorldNoor
//
//  Created by Awais on 01/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

@objc(MPBottomCreateListingCell)
class MPBottomCreateListingCell: SSBaseCollectionCell {
    
    // MARK: - Properties -
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let item = object as? Item {
            nameLabel?.text = item.name
            imageView?.image = item.iconImage
        }
    }
}
