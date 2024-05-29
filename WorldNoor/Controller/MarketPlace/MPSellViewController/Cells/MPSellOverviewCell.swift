//
//  MPSellOverviewCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 07/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MPSellOverviewCell)
class MPSellOverviewCell: SSBaseCollectionCell {
    
    // MARK: - Properties -
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var counterLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var imgView: UIImageView?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let item =  object as? Item {
            nameLabel?.text = item.name
            counterLabel?.text = item.counterStr
            descLabel?.text = item.description
            imgView?.image = item.iconImage
            
            imgView?.isHidden = item.iconImage == nil
            descLabel?.isHidden = item.description.isEmpty
        }
    }
}
