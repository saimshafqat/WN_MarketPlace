//
//  MPFilterCell.swift
//  WorldNoor
//
//  created by Moeez akram on 20/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPFilterCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubtitle: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFilterUI(_ item: Item) {
        switch item.selectedItem {
        case .availability:
            lblSubtitle?.text = item.isApplyFilter == true ? item.availability : item.description
        case .price:
            lblSubtitle?.text = item.isApplyFilter == true ? "$ \(item.minimumPrice) - $ \(item.maximumPrice)" : item.description
        case .dateListed:
            lblSubtitle?.text =  item.description
        case .condition:
            lblSubtitle?.text = item.description
        case .bathrooms:
            lblSubtitle?.text = item.isApplyFilter == true ? item.bathroom : item.description
        case .bedrooms:
            lblSubtitle?.text = item.isApplyFilter == true ? item.bedroom : item.description
        case .rentalTypes:
            lblSubtitle?.text = item.description
        case .squareMeters:
            lblSubtitle?.text = item.isApplyFilter == true ? "\(item.minimumSq) - \(item.maximumSq)" : item.description
        }
        lblTitle?.text = item.name
    }
}
