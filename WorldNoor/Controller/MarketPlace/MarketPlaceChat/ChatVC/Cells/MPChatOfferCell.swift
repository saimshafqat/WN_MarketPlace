//
//  MPChatOfferCell.swift
//  WorldNoor
//
//  Created by Awais on 29/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatOfferCell: UITableViewCell {

    @IBOutlet weak var receiverOfferView: UIView!
    @IBOutlet weak var receiverInnerOfferView: UIView!
    @IBOutlet weak var receiverImageView: UIImageView!
    @IBOutlet weak var lblReceiverOfferTitle: UILabel!
    @IBOutlet weak var lblReceiverOfferDesc: UILabel!
    @IBOutlet weak var receiverButtonsView: UIView!
    
    @IBOutlet weak var senderOfferView: UIView!
    @IBOutlet weak var senderInnerOfferView: UIView!
    @IBOutlet weak var lblSenderOfferTitle: UILabel!
    @IBOutlet weak var lblSenderOfferDesc: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.receiverInnerOfferView.addReceiverChatColor()
        self.senderInnerOfferView.addReceiverChatColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureReceiverOfferCell(dict:MPMessage, isShowActions: Bool = true) {
        senderOfferView.isHidden = true
        let imageUrlStr = dict.groupImage
        if imageUrlStr.count > 0 {
            self.receiverImageView.loadImageWithPH(urlMain:imageUrlStr)
        }
        
        lblReceiverOfferTitle.text = dict.toOfferInfo?.offerInfo ?? ""
        lblReceiverOfferDesc.text = dict.toOfferInfo?.offerDescription.count ?? 0 > 0 ? dict.toOfferInfo?.offerDescription : dict.toOfferInfo?.price
        
        receiverButtonsView.isHidden = !isShowActions
    }
    
    func configureSenderOfferCell(dict: MPMessage) {
        receiverOfferView.isHidden = true
        
        lblSenderOfferTitle.text = dict.toOfferInfo?.offerInfo ?? ""
        lblSenderOfferDesc.text = dict.toOfferInfo?.price ?? ""
    }
}
