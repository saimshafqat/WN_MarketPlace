//
//  BaseChatCell+ReplyViews.swift
//  WorldNoor
//
//  Created by Awais on 22/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseChatCell
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
        
        if let chatreplyObj  = self.chatObj.reply_to {
            self.viewReply.isHidden = false
            
            switch chatreplyObj.post_type {
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
    
    func setReplyTextView(chatreplyObj: Message) {
        self.replyTextBubbleView.isHidden = false
        self.lblReplyTextBody.text = chatreplyObj.body
    }
    
    func setReplyImageView(chatreplyObj: Message) {
        self.replyImageBubbleView.isHidden = false
        self.lblReplyImageBody.text = chatreplyObj.body
        self.viewReplyImageTextView.isHidden = chatreplyObj.body.count == 0
            
        if chatreplyObj.toMessageFile?.count ?? 0 > 0 {
            if chatreplyObj.post_type == FeedType.image.rawValue {
                if let msgFile = chatreplyObj.toMessageFile?.first as? MessageFile {
                    self.imgViewReply.loadImage(urlMain: msgFile.url)
                }
                
                self.imgReplyVideo.isHidden = true
                self.imgViewReply.isHidden = false
                self.vwImgReplyLayer.isHidden = false
                self.imgViewReply.layer.cornerRadius = 10
                self.vwImgReplyLayer.layer.cornerRadius = 10
                
            }else if chatreplyObj.post_type == FeedType.video.rawValue {
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
