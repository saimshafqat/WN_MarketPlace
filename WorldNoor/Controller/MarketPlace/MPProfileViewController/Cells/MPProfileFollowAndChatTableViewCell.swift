//
//  MPProfileFollowAndChatTableViewCell.swift
//  WorldNoor
//
//  Created by swift on 09/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileFollowAndChatTableViewCell: UITableViewCell {
    static let identifier = "MPProfileFollowAndChatTableViewCell"
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var chatLbl: UILabel!
    
    @IBOutlet weak var viewProfileLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
