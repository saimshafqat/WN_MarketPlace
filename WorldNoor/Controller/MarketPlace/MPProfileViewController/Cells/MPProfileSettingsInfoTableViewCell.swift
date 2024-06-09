//
//  MPProfileSettingsInfoTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileSettingsInfoTableViewCell: UITableViewCell {
    static let identifier = "MPProfileSettingsInfoTableViewCell"
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var turnOffBtn: UIButton!
    var descriptiontext = "Your Worldnoor profile privacy setttings controlls what people, including Marketplace user, can see on yourWorldnoor profile. Go to Settings"
    var subString = "Go to Settings"
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLbl.attributedText = descriptiontext.coloredAndClickableAttributedString(substringToColor: subString)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
