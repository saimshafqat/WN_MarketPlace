//
//  FeedStatCell.swift
//  WorldNoor
//
//  Created by Raza najam on 1/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FeedStatCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!

    @IBOutlet weak var thankBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
