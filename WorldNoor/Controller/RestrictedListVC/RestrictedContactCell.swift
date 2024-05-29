//
//  RestrictedContactCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 13/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class RestrictedContactCell: UITableViewCell {
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var imgViewUser: UIImageView!{
        didSet {
            imgViewUser.roundWithClearColor()
        }
    }
    @IBOutlet var btnUnRestrict: UIButton!
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
