//
//  MarketPlaceForYouCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MarketPlaceForYouCollectionCell)
class MarketPlaceForYouCollectionCell: SSBaseCollectionCell {
    
    static let headerName = "MarketPlaceForYouCollectionCell"
    // MARK: - Properties -
    @IBOutlet weak var categoryImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let item =  object as? MarketPlaceForYouItem {
            priceLabel?.text = item.price.priceFormat()
            nameLabel?.text = item.name
            categoryImageView?.loadImage(urlMain: item.images.first ?? .emptyString)
        } else if let imageCont = object as? String {
            categoryImageView?.loadImage(urlMain: imageCont)
        }
    }
}
