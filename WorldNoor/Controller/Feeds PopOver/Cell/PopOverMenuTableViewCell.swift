//
//  PopOverMenuTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 06/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class PopOverMenuTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(menuItem: PopMenu) {
        
        titleLabel.text = menuItem.title
        iconImageView.image = UIImage(named: menuItem.image)
    }
}
