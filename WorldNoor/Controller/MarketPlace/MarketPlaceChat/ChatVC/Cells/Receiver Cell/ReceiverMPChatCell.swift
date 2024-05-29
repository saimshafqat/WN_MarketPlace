//
//  ReceiverMPChatCell.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ReceiverMPChatCell: BaseMPChatCell {

    @IBOutlet weak var recieverImageView: UIImageView!
    @IBOutlet weak var recieverImageBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        self.textBubbleView.addReceiverChatColor()
        self.imageBubbleView.addReceiverChatColor()
        self.audioBubbleView.addReceiverChatColor()
        self.attachmentBubbleView.addReceiverChatColor()
        self.buyerDetailsBubbleView.addReceiverChatColor()
        self.quickResponseBubbleView.addReceiverChatColor()
    }
    
    func loadData(dict:MPMessage, index: IndexPath){

        self.chatObj = dict
        self.manageReactionData(objData: dict)
        self.currentIndex = index

        self.recieverImageView.loadImageWithPH(urlMain: dict.senderImage)
        self.recieverImageBottomConstraint.constant = dict.toMessageReaction?.count ?? 0 > 0 ? 20 : -4
                
        self.setViews()
        self.setTopBarView()
        self.setReplyViews()
        self.setBottomBarView()
    }
    
    func setViews()
    {
        self.textBubbleView.isHidden = true
        self.imageBubbleView.isHidden = true
        self.audioBubbleView.isHidden = true
        self.attachmentBubbleView.isHidden = true
        self.buyerDetailsBubbleView.isHidden = true
        self.quickResponseBubbleView.isHidden = true
        
        switch self.chatObj.messageLabel {
        case FeedType.image.rawValue:
            setImageView()
            setReceiverImageView()
        case FeedType.video.rawValue:
            setImageView()
            setReceiverImageView()
        case FeedType.audio.rawValue:
            setAudioView(isSenderCell: false)
            setReceiverAudioView()
        case FeedType.file.rawValue:
            setAttachmentView()
            setReceiverAttachmentView()
        case "buyer_detail":
            setBuyerDetailsView()
        case "quick_response":
            setQuickResponseView()
        default:
            setTextView()
            setReceiverTextView()
        }
    }
    
    func setTopBarView()
    {
        self.viewTopBar.isHidden = true
        self.pinImageView.isHidden = self.chatObj.isPinned != "1"
        
        self.lblTime.text = self.chatObj.createdAt.chatDateFormat(time: self.chatObj.createdAt, format:Const.dateFormat1)
        self.lblTime.isHidden = self.chatObj.isShowMessageTime != "1"
        
        if let chatreplyObj  = self.chatObj.replyTo {
            self.viewTopBar.isHidden = false
            if(Int(chatreplyObj.senderId) == SharedManager.shared.getMPUserID()){
                self.lblTopBar.text = self.chatObj.senderName + " " + "replied to".localized() + " " + "yourself".localized()
            }else {
                self.lblTopBar.text = self.chatObj.senderName + " " + "replied to".localized() + " " + chatreplyObj.senderName
            }
        }
    }
    
    func setReceiverTextView()
    {
        self.textBubbleView.addReceiverChatColor()
    }
    
    func setReceiverImageView()
    {
        self.imageBubbleView.addReceiverChatColor()
    }
    
    func setReceiverAudioView()
    {
        self.audioBubbleView.addReceiverChatColor()
    }
    
    func setReceiverAttachmentView()
    {
        self.attachmentBubbleView.addReceiverChatColor()
    }
}
