//
//  MPProductDetailSimilarProductCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
@objc(MPProductDetailSimilarProductCell)
class MPProductDetailSimilarProductCell: SSBaseCollectionCell {
    
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MPSimilarProductModel {
            productImage.loadImage(urlMain: obj.images?.first ?? .emptyString)
            productPriceLabel?.text = (obj.price ?? .emptyString) + " ⠐ " + (obj.name ?? .emptyString)
        }
    }

}
