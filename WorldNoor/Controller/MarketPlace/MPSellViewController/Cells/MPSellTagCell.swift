//
//  MPSellTagCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 07/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MPSellTagCell)
class MPSellTagCell: SSBaseCollectionCell {
    
    // MARK: - Properties -
    @IBOutlet weak var nameLabel: UILabel?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let item = object as? Item {
            nameLabel?.text = item.name
        }
    }
}
