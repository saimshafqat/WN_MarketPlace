//
//  NotificationPopUpTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NotificationPopUpTableViewCell: UITableViewCell {

    @IBOutlet private weak var optionTitleLabel: UILabel!
    @IBOutlet private weak var optionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(option: NotificationSettingOptionModel) {
        optionTitleLabel.text = option.text
        optionImageView.image = UIImage(named: option.icon ?? "")
    }
}
