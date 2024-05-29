//
//  BaseMPChatCell.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import ActiveLabel

protocol MPReactionSenderDelegate:AnyObject {
    //    func reactionClicked(reactionBtn:UIButton, msgID:String)
    func showReactionListDelegate(messageID:String, messageObj:MPMessage)
}

class BaseMPChatCell: UITableViewCell {
    
    var chatObj = MPMessage()
    weak var reactionDelegate: MPReactionSenderDelegate?
    @IBOutlet weak var reactionBtn: UIButton!
    @IBOutlet weak var addedReactionView:AddedReactionView?
    
    //Reply Views
    @IBOutlet var viewReply : UIView!
    @IBOutlet var replyTextBubbleView : UIView!
    @IBOutlet var replyImageBubbleView : UIView!
    @IBOutlet var replyAudioBubbleView : UIView!
    @IBOutlet var replyAttachmentBubbleView : UIView!
    @IBOutlet var lblReplyTextBody : UILabel!
    @IBOutlet var lblReplyImageBody : UILabel!
    @IBOutlet var viewReplyImageTextView : UIView!
    @IBOutlet var imgReplyVideo : UIImageView!
    @IBOutlet var imgViewReply : UIImageView!
    @IBOutlet var vwImgReplyLayer : UIView!
    
    //Views
    @IBOutlet var viewBG : UIView!
    @IBOutlet var viewSelected : UIView!
    @IBOutlet var viewSelectedTick : UIView!
    @IBOutlet var viewUnSelectedTick : UIView!
    @IBOutlet var btnShowOriginal : UIButton!
    @IBOutlet var speakerButton : UIButton!
    @IBOutlet var viewSpeaker : UIView!
    
    @IBOutlet var viewImageText : UIView!
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var viewPlay : UIView!
    @IBOutlet var imageBubbleView : UIView!
    @IBOutlet var lblImageBody : ActiveLabel!
    
    @IBOutlet var lblFileName : UILabel!
    @IBOutlet var imgViewFileIcon : UIImageView!
    @IBOutlet var viewAttachmentText : UIView!
    @IBOutlet var attachmentBubbleView : UIView!
    @IBOutlet var lblAttachmentBody : ActiveLabel!
    
    @IBOutlet var audioBubbleView : UIView!
    @IBOutlet var lblAudioBody : ActiveLabel!
    @IBOutlet var viewAudioText : UIView!
    @IBOutlet weak var audioView : AudioPlayerView!
    
    var isSelectionEnable = false
    var isPinned = false
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet var lblOriginal : UILabel!
    
    var delegateTap : DelegateTapMPChatCell!
    
    @IBOutlet var lblTextBody : ActiveLabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblTopBar: UILabel!
    @IBOutlet var viewTopBar: UIView!
    @IBOutlet var textBubbleView : UIView!
    @IBOutlet var pinImageView: UIImageView!
    
    var onSwipeToReply: (() -> Void)?
    var onScrollToReplyMessage: (() -> Void)?
    
    
    @IBOutlet weak var buyerDetailsBubbleView: UIView!
    @IBOutlet weak var lblBuyerName: UILabel!
    @IBOutlet weak var lblBuyerDesc: UILabel!
    
    @IBOutlet weak var quickResponseBubbleView: UIView!
    @IBOutlet weak var lblQuickResponse: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initializeReactionView()
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureCellAction))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(replyViewTapped))
        viewReply.isUserInteractionEnabled = true
        viewReply.addGestureRecognizer(tapgesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgViewMain.image = nil
        
        if audioView != nil {
            audioView.prepareForReuse()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if abs(translation.x) > abs(translation.y) && translation.x > 0 {
                return true
            }
        }
        else if gestureRecognizer is UILongPressGestureRecognizer {
            return true
        }
        return false
    }
    
    @objc func panGestureCellAction(recognizer: UIPanGestureRecognizer) {
//        guard !isPinned, chatObj.toChat?.is_blocked == "0" else { return }
        
        guard !isPinned else { return }
        
        guard self.chatObj.messageLabel != "buyer_detail" else { return }
        
        guard let view = recognizer.view else { return }
        
        let translation = recognizer.translation(in: contentView)
        
        guard view.frame.origin.x >= 0 else { return }
        
        view.center.x += translation.x
        recognizer.setTranslation(CGPoint.zero, in: contentView)
        
        let threshold = UIScreen.main.bounds.size.width * 0.95
        
        if view.frame.origin.x > threshold {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                view.frame = CGRect(x: 0, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
            }
        }
        
        if recognizer.state == .ended {
            let x = view.frame.origin.x
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                view.frame = CGRect(x: 0, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
            } completion: { [weak self] _ in
                guard let self = self, x > (view.frame.size.width / 2) else { return }
                
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                
                if let onSwipeToReply = self.onSwipeToReply {
                    onSwipeToReply()
                }
            }
        }
    }
    
    @objc func replyViewTapped(tapPressGesture: UITapGestureRecognizer) {
        guard !isPinned else { return }
        if let onScrollToReplyMessage = self.onScrollToReplyMessage {
            onScrollToReplyMessage()
        }
    }
    
    @IBAction func reactionTapped(_ sender:UIButton){
        //        self.reactionDelegate?.reactionClicked(reactionBtn: self.reactionBtn, msgID: self.chatObj.id)
    }
    
    @IBAction func showOriginalAction(sender : UIButton){
        
//        if self.btnShowOriginal.isSelected {
//            self.chatObj.isOriginal = false
//            self.setLblText(body: self.chatObj.body)
//            self.btnShowOriginal.isSelected = false
//            self.lblOriginal.text = "View Original".localized()
//
//        }else {
//            self.chatObj.isOriginal = true
//            self.setLblText(body: self.chatObj.original_body)
//            self.btnShowOriginal.isSelected = true
//            self.lblOriginal.text = "View Translated".localized()
//        }
    }
    
    @IBAction func speakerButtonClicked(_ sender: Any) {
        SpeakerUtility.speakerUtility(speakerButton, with: getLblText())
    }
        
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        
        guard self.chatObj.messageLabel != "buyer_detail" else { return }
        
        if longPressGesture.state == UIGestureRecognizer.State.began {
            if delegateTap != nil {
                if !isPinned {
                    self.isSelectionEnable = true
                    self.viewSelected.isHidden = false
                }
                self.delegateTap.delegateTapCellAction(chatObj: self.chatObj, indexRow: self.currentIndex)
            }
        }
    }
    
    func setLblText(body: String)
    {
        switch self.chatObj.messageLabel {
        case FeedType.image.rawValue:
            self.lblImageBody.text = body
        case FeedType.video.rawValue:
            self.lblImageBody.text = body
        case FeedType.audio.rawValue:
            self.lblAudioBody.text = body
        case FeedType.file.rawValue:
            self.lblAttachmentBody.text = body
        case "buyer_detail":
            self.lblAttachmentBody.text = ""
        case "quick_response":
            self.lblAttachmentBody.text = ""
        default:
            self.lblTextBody.text = body
        }
    }
    
    func getLblText() -> String?
    {
        switch self.chatObj.messageLabel {
        case FeedType.image.rawValue:
            return self.lblImageBody.text
        case FeedType.video.rawValue:
            return self.lblImageBody.text
        case FeedType.audio.rawValue:
            return self.lblAudioBody.text
        case FeedType.file.rawValue:
            return self.lblAttachmentBody.text
        case "buyer_detail":
            return ""
        case "quick_response":
            return ""
        default:
            return self.lblTextBody.text
        }
    }
    
    func setBottomBarView()
    {
        self.viewSpeaker.isHidden = true
        
        self.viewSpeaker.layer.cornerRadius = 12
        self.viewSpeaker.addShadowToView(shadowRadius: 1, alphaComponent: 0.3)
        
        if self.getLblText()?.count ?? 0 > 0 {
            self.viewSpeaker.isHidden = false
        }
    }
}

