//
//  MPChatHeaderCell.swift
//  WorldNoor
//
//  Created by Awais on 27/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatHeaderCell: UITableViewCell {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var lblNotification: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureHeaderCell(dict:MPMessage){
        
        viewHeader.isHidden = false
        viewNotification.isHidden = true
        let imageUrlStr = dict.groupImage
        if imageUrlStr.count > 0 {
            self.imgGroup.loadImageWithPH(urlMain:imageUrlStr)
        }
        
        lblGroupName.text = dict.conversationName
    }
    
    func configureNotificationCell(dict:MPMessage){
        
        viewNotification.isHidden = false
        viewHeader.isHidden = true
        
        lblNotification.text = dict.content
    }
    
}
