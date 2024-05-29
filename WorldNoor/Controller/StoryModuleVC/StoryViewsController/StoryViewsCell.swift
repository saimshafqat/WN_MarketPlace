//
//  StoryViewsCell.swift
//  kalam
//
//  Created by Raza najam on 12/1/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class StoryViewsCell: UITableViewCell {
    @IBOutlet weak var  userImageView:UIImageView!{
        didSet {
            userImageView.circularView(bordorColor: .lightGray, borderWidth: 0)
        }
    }
    @IBOutlet weak var  nameLbl:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

