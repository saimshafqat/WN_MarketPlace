//
//  ProductListCell.swift
//  WorldNoor
//
//  Created by Ahmad on 14/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProductListCell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?

    
    func setProductInfoCell(_ object: Any) {
        if let item =  object as? MarketPlaceForYouItem {
            nameLabel?.text =  "\(item.price) . \(item.name )"
            categoryImageView?.loadImage(urlMain: item.images.first ?? .emptyString)
        } else if let imageCont = object as? String {
            categoryImageView?.loadImage(urlMain: imageCont)
        }
    }
}
