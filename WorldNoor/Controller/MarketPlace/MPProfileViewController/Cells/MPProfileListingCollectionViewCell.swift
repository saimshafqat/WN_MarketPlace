//
//  MPProfileListingCollectionViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileListingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var itemTitleLbl: UILabel!
    
    static let identifier = "MPProfileListingCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func confirgure(model: UserListingProduct?) {
        itemPriceLbl.text = model?.price?.priceFormat() ?? "0"
        itemTitleLbl.text = model?.name ?? ""
        itemImageView.loadImage(urlMain: model?.images?.first ?? .emptyString)
    }
}
