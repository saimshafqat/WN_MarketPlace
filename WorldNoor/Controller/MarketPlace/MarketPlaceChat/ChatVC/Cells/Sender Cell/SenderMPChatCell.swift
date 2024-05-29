//
//  SenderMPChatCell.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class SenderMPChatCell: BaseSendMPChatCell {
    
    @IBOutlet var progressBG : CircularProgressView!
    @IBOutlet var attachmentProgressBG : CircularProgressView!
    @IBOutlet var audioProgressBG : CircularProgressView!
        
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        self.textBubbleView.addSenderChatColor()
        self.imageBubbleView.addSenderChatColor()
        self.audioBubbleView.addSenderChatColor()
        self.attachmentBubbleView.addSenderChatColor()
    }
    
    func loadData(dict:MPMessage, index: IndexPath){

        self.chatObj = dict
        self.manageReactionData(objData: dict)
        self.currentIndex = index
        
//        self.manageMessageStatus(status: self.chatObj.status)
        
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
        
        switch self.chatObj.messageLabel {
        case FeedType.image.rawValue:
            setImageView()
            setSenderImageView()
        case FeedType.video.rawValue:
            setImageView()
            setSenderImageView()
        case FeedType.audio.rawValue:
            setAudioView()
            setSenderAudioView()
        case FeedType.file.rawValue:
            setAttachmentView()
            setSenderAttachmentView()
        default:
            setTextView()
            setSenderTextView()
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
                self.lblTopBar.text = "You replied to ".localized() + "yourself".localized()
            }else {
                self.lblTopBar.text = "You replied to ".localized() + chatreplyObj.senderName
            }
        }
    }
    
    func setSenderTextView()
    {
        self.textBubbleView.addSenderChatColor()
    }
    
    func setSenderImageView()
    {
        self.imageBubbleView.addSenderChatColor()
        self.progressBGView = progressBG
        self.manageUploadingStatus()
    }
    
    func setSenderAudioView()
    {
        self.audioBubbleView.addSenderChatColor()
        self.progressBGView = audioProgressBG
        self.manageUploadingStatus()
    }
    
    func setSenderAttachmentView()
    {
        self.attachmentBubbleView.addSenderChatColor()
        self.progressBGView = attachmentProgressBG
        self.manageUploadingStatus()
    }
    
}
