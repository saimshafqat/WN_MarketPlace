//
//  HiddenContactDetailCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class HiddenContactDetailCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
