//
//  SendCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import QuartzCore

class SendCell: UITableViewCell {
    @IBOutlet weak var userImageBtn: DesignableButton!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var replylbl: UILabel!
    @IBOutlet weak var replyUserNamelbl: UILabel!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyViewHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var replyImageView: UIView!
    @IBOutlet weak var replyViewimageWidthConst: NSLayoutConstraint!
    
    @IBOutlet weak var replyViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var replySuperViewTopConst: NSLayoutConstraint!
    
    
    @IBOutlet weak var bgChatView: UIView!
    
//    @IBOutlet weak var bgChatImgView: UIImageView!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var chatWidthConst: NSLayoutConstraint!
    @IBOutlet weak var audioViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var bgChatViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var audioViewWidthConst: NSLayoutConstraint!
    @IBOutlet weak var dateLbl: UILabel!
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var audioLbl: UILabel!
    @IBOutlet weak var cstaudiolblHeight: NSLayoutConstraint!
    
    var chatObj = Message()
    @IBOutlet weak var btnShowOriginal: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    var delegateTap : DelegateTapCell!
    
    //AudioPlayer Starts
    var xqAudioPlayer: XQAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let screenSize: CGRect = self.frame
        self.audioViewWidthConst.constant =  screenSize.size.width - 100
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        self.bgChatView.addGestureRecognizer(longPressGesture)
        
        
        let longPressGesture2 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture2.minimumPressDuration = 1.0
        longPressGesture2.delegate = self
        self.audioView.addGestureRecognizer(longPressGesture2)
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressAction))
        self.bgChatView.addGestureRecognizer(tapGesture)
        
        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        
        self.descLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.descLbl)
        
        self.replylbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replylbl)
        
        self.replyUserNamelbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replyUserNamelbl)
        
        self.dateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.dateLbl)
        
        self.audioLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.audioLbl)
        
        self.btnShowOriginal.rotateViewForLanguage()
//        self.labelRotateCell(viewMain: self.btnShowOriginal)
//        self.receiverVIewOrignalBtn.rotateViewForLanguage()
        
        
//        
//        self.descLbl.rotateForTextAligment()
//        self.labelRotateCell(viewMain: self.descLbl)
//        
//        self.descLbl.rotateForTextAligment()
//        self.labelRotateCell(viewMain: self.descLbl)
        
    }
    
    
    
    
    @objc func tapPressAction(tapPressGesture: UITapGestureRecognizer) {

        if delegateTap != nil {
            self.delegateTap.delegateOpenforImage(chatObj: self.chatObj, indexRow: self.currentIndex)
        }
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizer.State.began {
            if delegateTap != nil {
                self.delegateTap.delegateTapCellAction(chatObj: self.chatObj, indexRow: self.currentIndex)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let colorMain = self.bgChatView.backgroundColor
        let colorReply = self.replyView.backgroundColor
        let colorAudio = self.audioView.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        self.delegateTap.delegatRowValueChange(indexPath: currentIndex, selectecion: selected)
        
        if selected {
            self.bgChatView.backgroundColor = colorMain
            self.replyView.backgroundColor = colorReply
            self.audioView.backgroundColor = colorAudio
        }
        
        
        // Configure the view for the selected state
    }
    
    func manageChatBgView(dict:Message, currentIndex:IndexPath)    {
        self.currentIndex = currentIndex
        self.descLbl.text = ""
        chatObj = dict
        self.bgChatView.roundCornersLeft(cornerRadius: 15.0)
        
        self.replyView.roundCornersLeft(cornerRadius: 15.0)
        self.removeXqFromSuper()
        self.audioLbl.text = chatObj.speech_to_text
        self.descLbl.text = dict.body
        self.dateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime ?? "", format:Const.dateFormat1)
        
        self.replylbl.text = ""
        self.replyUserNamelbl.text = ""
        
        
        self.replyView.isHidden = true
        if let replyModel = self.chatObj.reply_to {
            self.replyView.isHidden = false

            if replyModel.post_type == FeedType.post.rawValue {
                self.replylbl.text = replyModel.body
            }else if replyModel.post_type == FeedType.image.rawValue {
                self.replylbl.text = "Image"
            }else if replyModel.post_type == FeedType.video.rawValue {
                self.replylbl.text = "Video"
            }else if replyModel.post_type == FeedType.file.rawValue {
                self.replylbl.text = ""
                if replyModel.toMessageFile?.count ?? 0 > 0 {
                    let urlMain = URL.init(string: (replyModel.toMessageFile?.first as! MessageFile).url)
                    self.replylbl.text = urlMain?.lastPathComponent
                }
            }
            
            
            
            
            if (Int(replyModel.author_id) == SharedManager.shared.getUserID()){
                self.replyUserNamelbl.text = "You"
            }else {
                self.replyUserNamelbl.text = replyModel.full_name
            }
            
            self.replyViewHeightConst.constant = 5.0
            self.replyViewTopConst.constant = 5.0

        }else {
            self.replyView.isHidden = true
            self.replyViewHeightConst.constant = -20.0
            self.replyViewTopConst.constant = 0.0
        }
        if dict.post_type == FeedType.audio.rawValue {
            
            var audioFileString = dict.audio_msg_url

            if dict.isOriginal == 1  {
                if dict.audio_file.count == 0 {
                    audioFileString = dict.audio_msg_url
                }else {
                    audioFileString = dict.audio_file
                }
            }else {
                if dict.audio_translation.count > 0 {
                    audioFileString = dict.audio_translation
                }
            }

            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            
            self.xqAudioPlayer.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x, y: self.xqAudioPlayer.frame.origin.y, width: self.audioView.frame.size.width, height: self.xqAudioPlayer.frame.size.height)
            
            self.xqAudioPlayer.isHidden = false
            
            self.audioView.addSubview(self.xqAudioPlayer)
            self.audioViewHeightConst.constant = 50
            self.audioConfigurations(file:audioFileString ?? "")
        }

        if self.audioLbl.text!.count == 0 {
            self.cstaudiolblHeight.constant = 0.0
        }else {
            self.cstaudiolblHeight.constant = self.audioLbl.frame.size.height
        }
        
        self.manageAudioData(dict: self.chatObj)
        self.bgChatView.isHidden = false
        
        
        
        
        if self.descLbl.text!.count == 0 {
            if self.replyView.isHidden {
                self.bgChatView.isHidden = true
            }
            
        }
        
        SharedManager.shared.setTextandFont(viewText: self.descLbl as Any)
        SharedManager.shared.setTextandFont(viewText: self.audioLbl as Any)
        
    }
    
    func manageAudioData(dict:Message){
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.removeFromSuperview()
        }
        if dict.post_type == FeedType.audio.rawValue {
            var audioFileString = dict.audio_msg_url
            if dict.isOriginal == 1  {
                if dict.audio_file.count == 0 {
                    audioFileString = dict.audio_msg_url
                }else {
                    audioFileString = dict.audio_file
                }
            }else {
                if dict.audio_translation.count > 0 {
                    audioFileString = dict.audio_translation
                }
            }
            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            self.xqAudioPlayer.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x, y: self.xqAudioPlayer.frame.origin.y, width: self.audioView.frame.size.width, height: self.xqAudioPlayer.frame.size.height)
            self.audioView.addSubview(self.xqAudioPlayer)
            self.audioViewHeightConst.constant = 44
            self.audioConfigurations(file:audioFileString ?? "")
            
            SharedManager.shared.setTextandFont(viewText: self.descLbl)
        }
    }
    
    func removeXqFromSuper(){
        self.audioViewHeightConst.constant = 0
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.removeFromSuperview()
        }
    }
    
    func audioConfigurations(file: String) {
        // Change progress color
        
        self.xqAudioPlayer.config(urlString:file)
        self.xqAudioPlayer.manageProgressUI()
    }
    
    @IBAction func showOriginalAction(sender : UIButton){
        
        if self.btnShowOriginal.isSelected {
            self.chatObj.isOriginal = false
            self.descLbl.text = self.chatObj.body
            self.btnShowOriginal.isSelected = false
            self.btnShowOriginal.setTitle("View Original".localized(), for: .normal)
            
            if self.audioLbl.text!.count == 0 {
                
            }else {
                
                self.audioLbl.text = chatObj.speech_to_text
            }
            
        }else {
            self.chatObj.isOriginal = true
            self.descLbl.text = self.chatObj.original_body
            self.btnShowOriginal.isSelected = true
            self.btnShowOriginal.setTitle("View Translated".localized(), for: .normal)
            
            if self.audioLbl.text!.count == 0 {
                
            }else {
                
                self.audioLbl.text = chatObj.original_speech_to_text
            }
            
        }
        
        ChatCallBackManager.shared.reloadTableAtSpecificIndex?(self.currentIndex)
        self.manageAudioData(dict: self.chatObj)
    }
    
    @IBAction func speakerButtonClicked(_ sender: Any) {
//        SpeechManager.shared.isFromChat = true
        if self.speakerButton.isSelected {
            SpeechManager.shared.stopSpeaking()
        }else {
            
            var bodyPlay = ""
            
            if self.descLbl.text!.count == 0 {
                
            }else {
                bodyPlay = self.descLbl.text!
            }
            
            SpeechManager.shared.textToSpeech(message: bodyPlay)
            FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
                self?.speakerButton.isSelected  = !(self?.speakerButton.isSelected)!
            }
            
        }
        self.speakerButton.isSelected = !self.speakerButton.isSelected
    }
}
