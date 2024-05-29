//
//  ReceiverChatCell.swift
//  WorldNoor
//
//  Created by Awais on 19/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ReceiverChatCell: BaseChatCell {

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
    }
    
    func loadData(dict:Message , index : IndexPath){

        self.chatObj = dict
        self.manageReactionData(objData: dict)
        self.currentIndex = index

        self.recieverImageView.loadImageWithPH(urlMain: dict.profile_image)
        self.recieverImageBottomConstraint.constant = dict.toReaction.count > 0 ? 20 : -4
                
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
        
        switch self.chatObj.post_type {
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
        default:
            setTextView()
            setReceiverTextView()
        }
    }
    
    func setTopBarView()
    {
        self.viewTopBar.isHidden = true
        self.pinImageView.isHidden = self.chatObj.is_pinned != "1"
        
        self.lblTime.text = self.chatObj.messageTime.chatDateFormat(time: self.chatObj.messageTime, format:Const.dateFormat1)
        self.lblTime.isHidden = self.chatObj.isShowMessageTime != "1"
        
        if let chatreplyObj  = self.chatObj.reply_to {
            self.viewTopBar.isHidden = false
            if(Int(chatreplyObj.author_id) == SharedManager.shared.getUserID()){
                self.lblTopBar.text = self.chatObj.full_name + " " + "replied to".localized() + " " + "yourself".localized()
            }else {
                self.lblTopBar.text = self.chatObj.full_name + " " + "replied to".localized() + " " + chatreplyObj.full_name
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
