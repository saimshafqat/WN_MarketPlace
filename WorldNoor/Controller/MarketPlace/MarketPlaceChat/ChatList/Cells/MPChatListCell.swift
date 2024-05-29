//
//  MPChatListCell.swift
//  WorldNoor
//
//  Created by Awais on 20/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatListCell: UITableViewCell {
    
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var lblMessageTime: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var imgViewMute : UIView!
    @IBOutlet weak var viewOnline: UIView!
    @IBOutlet weak var viewMessageStatus: UIView!
    @IBOutlet weak var viewUnreadMessage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureCell(dict:MPChat){
        
        self.itemLbl.text = dict.conversationName
        self.lblMessageTime.text = ""
        
        if dict.lastMessageTime.count > 0  {
            self.lblMessageTime.text = dict.lastMessageTime.mpChatListDateFormat(format:Const.dateFormat1)
        }
        
        self.lastMessageLbl.text = ""
        if dict.lastMessage.count > 0 {
            self.lastMessageLbl.text = dict.lastMessage
        }
        else if dict.lastMessageLabel.count > 0 {
            self.lastMessageLbl.text = dict.lastMessageLabel.replacingOccurrences(of: "_", with: " ")
        }
        
        if dict.groupImage.count > 0 {
            self.userImageView.loadImageWithPH(urlMain:dict.groupImage)
        }
        
        self.viewOnline.isHidden = true
        self.viewMessageStatus.isHidden = true
        
        
        SharedManager.shared.setTextandFont(viewText: self.lastMessageLbl as Any)
        self.labelRotateCell(viewMain: self.userImageView)
        
        self.labelRotateCell(viewMain: self.lblMessageTime)
        self.labelRotateCell(viewMain: self.itemLbl)
        self.labelRotateCell(viewMain: self.lastMessageLbl)
        
        self.lblMessageTime.rotateForTextAligment()
        self.itemLbl.rotateForTextAligment()
        self.lastMessageLbl.rotateForTextAligment()

        self.viewUnreadMessage.isHidden = true
        if !dict.isRead {
            self.viewUnreadMessage.isHidden = false
        }
        
        self.imgViewMute.isHidden = true
        if dict.mutedAt.count > 0 {
            self.imgViewMute.isHidden = false
        }
        
    }
}
