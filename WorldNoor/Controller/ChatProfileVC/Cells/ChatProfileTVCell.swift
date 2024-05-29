//
//  ChatProfileTVCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 03/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ChatProfileTVCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.tintColor = .black
        }
    }
    @IBOutlet weak var profView: UIView!{
        didSet{
            profView.roundTotally()
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
