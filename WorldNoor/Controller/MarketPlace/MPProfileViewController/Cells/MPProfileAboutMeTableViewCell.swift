//
//  MPProfileAboutMeTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileAboutMeTableViewCell: UITableViewCell {
    static let identifier = "MPProfileAboutMeTableViewCell"

    @IBOutlet weak var aboutMeHeadingLabel: UILabel!
    @IBOutlet weak var houseIconImageView: UIImageView!
    @IBOutlet weak var livesInLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var responsiveLabel: UILabel!
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var joinedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
