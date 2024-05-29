//
//  MPChatActionCell.swift
//  WorldNoor
//
//  Created by Awais on 28/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatActionCell: UITableViewCell {

    @IBOutlet weak var receiverImageView: UIImageView!
    @IBOutlet weak var viewBuyerDetails: UIView!
    @IBOutlet weak var lblBuyerName: UILabel!
    
    @IBOutlet weak var viewQuickResponse: UIView!
    @IBOutlet weak var lblQuickResponse: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewBuyerDetails.addReceiverChatColor()
        self.viewQuickResponse.addReceiverChatColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureBuyerDetailsCell(dict:MPMessage){
        viewQuickResponse.isHidden = true
        let imageUrlStr = dict.groupImage
        if imageUrlStr.count > 0 {
            self.receiverImageView.loadImageWithPH(urlMain:imageUrlStr)
        }
        
        lblBuyerName.text = dict.conversationName
    }
    
    func configureQuickResponseCell(dict:MPMessage){
        viewBuyerDetails.isHidden = true
        let imageUrlStr = dict.groupImage
        if imageUrlStr.count > 0 {
            self.receiverImageView.loadImageWithPH(urlMain:imageUrlStr)
        }
    }
}
