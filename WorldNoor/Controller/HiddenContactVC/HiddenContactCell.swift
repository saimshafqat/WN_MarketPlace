//
//  HiddenContactCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class HiddenContactCell: UITableViewCell {
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var imgViewUser: UIImageView!{
        didSet {
            imgViewUser.roundWithClearColor()
        }
    }
    @IBOutlet var btnUnhide: UIButton!
    @IBOutlet var btnBgView: UIView!{
        didSet {
            btnBgView.roundCorners(cornerRadius: 5.0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
