//
//  ArchivedChatTVCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ArchivedChatTVCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.roundTotally()
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func manageViewData(conversation: Chat) {
        
        let userImage = conversation.profile_image
        DispatchQueue.main.async {
            self.imgView.loadImageWithPH(urlMain: userImage)
        }
        
        titleLbl.text = conversation.name
        descriptionLbl.text = conversation.latest_message
        timeLbl.text = conversation.latest_message_time.customDateFormat(time: conversation.latest_message_time, format:Const.dateFormat1)
    }
}
