//
//  BaseMPChatCell+ReplyViews.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell
{
    func setReplyViews()
    {
        self.viewReply.isHidden = true
        self.replyTextBubbleView.isHidden = true
        self.replyImageBubbleView.isHidden = true
        self.replyAudioBubbleView.isHidden = true
        self.replyAttachmentBubbleView.isHidden = true
        
        self.imgReplyVideo.addShadowToView(shadowRadius: 1, alphaComponent: 0.3)
        self.imgReplyVideo.isHidden = true
        self.vwImgReplyLayer.isHidden = true
        
        self.replyTextBubbleView.addReplyChatColor()
        self.replyImageBubbleView.addReplyChatColor()
        self.replyAudioBubbleView.addReplyChatColor()
        self.replyAttachmentBubbleView.addReplyChatColor()
        
        if let chatreplyObj  = self.chatObj.replyTo {
            self.viewReply.isHidden = false
            
            switch chatreplyObj.messageLabel {
            case FeedType.image.rawValue:
                setReplyImageView(chatreplyObj: chatreplyObj)
            case FeedType.video.rawValue:
                setReplyImageView(chatreplyObj: chatreplyObj)
            case FeedType.audio.rawValue:
                setReplyAudioView()
            case FeedType.file.rawValue:
                setReplyAttachmentView()
            default:
                setReplyTextView(chatreplyObj: chatreplyObj)
            }
        }
    }
    
    func setReplyTextView(chatreplyObj: MPMessage) {
        self.replyTextBubbleView.isHidden = false
        self.lblReplyTextBody.text = chatreplyObj.content
    }
    
    func setReplyImageView(chatreplyObj: MPMessage) {
        self.replyImageBubbleView.isHidden = false
        self.lblReplyImageBody.text = chatreplyObj.content
        self.viewReplyImageTextView.isHidden = chatreplyObj.content.count == 0
            
        if chatreplyObj.toMessageFile?.count ?? 0 > 0 {
            if chatreplyObj.messageLabel == FeedType.image.rawValue {
                if let msgFile = chatreplyObj.toMessageFile?.first as? MessageFile {
                    self.imgViewReply.loadImage(urlMain: msgFile.url)
                }
                
                self.imgReplyVideo.isHidden = true
                self.imgViewReply.isHidden = false
                self.vwImgReplyLayer.isHidden = false
                self.imgViewReply.layer.cornerRadius = 10
                self.vwImgReplyLayer.layer.cornerRadius = 10
                
            }else if chatreplyObj.messageLabel == FeedType.video.rawValue {
                self.imgReplyVideo.isHidden = false
                if let msgFile = chatreplyObj.toMessageFile?.first as? MessageFile {
                    self.imgViewReply.loadImage(urlMain: msgFile.thumbnail_url)
                }
                
                self.imgViewReply.isHidden = false
                self.vwImgReplyLayer.isHidden = false
                self.imgViewReply.layer.cornerRadius = 10
                self.vwImgReplyLayer.layer.cornerRadius = 10
                
            }
        }
    }
    
    func setReplyAudioView() {
        self.replyAudioBubbleView.isHidden = false
    }
    
    func setReplyAttachmentView() {
        self.replyAttachmentBubbleView.isHidden = false
    }
}
