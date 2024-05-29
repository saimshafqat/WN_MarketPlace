//
//  ReceiveCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import QuartzCore

class ReceiveCell: UITableViewCell {
    @IBOutlet weak var userImageBtn: DesignableButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var audioLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var bgChatView: UIView!
    @IBOutlet weak var chatWidthConst: NSLayoutConstraint!
    @IBOutlet weak var audioViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var bgChatViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var audioViewWidthConst: NSLayoutConstraint!
    @IBOutlet weak var descLblTopConst: NSLayoutConstraint!
    @IBOutlet weak var descLblBottomConst: NSLayoutConstraint!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var btnShowOriginal: UIButton!
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var cstaudiolblHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var replylbl: UILabel!
    @IBOutlet weak var replyUserNamelbl: UILabel!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyViewHeightConst: NSLayoutConstraint!
    
    
    

    var delegateTap : DelegateTapCell!
    
    //AudioPlayer Starts
    var xqAudioPlayer: XQAudioPlayer!
    
    var chatObj = Message()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let screenSize: CGRect = UIScreen.main.bounds
        let screenSize: CGRect = self.frame
        self.chatWidthConst.constant =  screenSize.size.width - 100
        self.audioViewWidthConst.constant =  screenSize.size.width - 100
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        self.bgChatView.addGestureRecognizer(longPressGesture)
        
        let longPressGesture2 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture2.minimumPressDuration = 1.0
        longPressGesture2.delegate = self
        self.audioView.addGestureRecognizer(longPressGesture2)
        
        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressAction))
        self.bgChatView.addGestureRecognizer(tapGesture)
        
        
        self.nameLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.nameLbl)
        
        self.dateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.dateLbl)
        
        self.descLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.descLbl)
        
        self.audioLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.audioLbl)
        
        self.replylbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replylbl)
        
        self.replyUserNamelbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replyUserNamelbl)
        
        
        self.btnShowOriginal.rotateViewForLanguage()
    }
    
    
    @objc func tapPressAction(tapPressGesture: UITapGestureRecognizer) {

        if delegateTap != nil {
            self.delegateTap.delegateOpenforImage(chatObj: self.chatObj, indexRow: self.currentIndex)
        }
    }
    
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizer.State.began {
            if delegateTap != nil {
                self.delegateTap.delegateTapCellActionforCopy(chatObj: self.chatObj, indexRow: self.currentIndex)
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let colorMain = self.bgChatView.backgroundColor
        let colorReply = self.replyView.backgroundColor
        
        
        super.setSelected(selected, animated: animated)
        
        self.delegateTap.delegatRowValueChange(indexPath: currentIndex, selectecion: selected)
        
        self.bgChatView.backgroundColor = colorMain
        self.replyView.backgroundColor = colorReply
        // Configure the view for the selected state
    }
    
    func manageChatBgView(dict:Message, currentIndex:IndexPath)    {
        self.currentIndex = currentIndex
        self.chatObj = dict
        self.bgChatView.roundCorners(cornerRadius: 15.0)
        self.replyView.roundCorners(cornerRadius: 15.0)
        self.descLbl.text = ""
        self.removeXqFromSuper()
        self.descLblTopConst.constant = 5
        self.descLblBottomConst.constant = 5
        self.nameLbl.text = chatObj.full_name
        self.audioLbl.text = chatObj.speech_to_text
        
        if self.audioLbl.text!.count == 0 {
            self.cstaudiolblHeight.constant = 0.0
        }else {
            self.cstaudiolblHeight.constant = self.audioLbl.frame.size.height
        }
        
        self.dateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime, format:Const.dateFormat1)
        
        if chatObj.body.count == 0 {
            self.descLblTopConst.constant = 0
            self.descLblBottomConst.constant = 0
        }else {
            self.descLbl.text = chatObj.body
        }
        
        
        self.replylbl.text = ""
        self.replyUserNamelbl.text = ""
        
        if dict.reply_to != nil {
            self.replyView.isHidden = false
            if let replyModel = dict.reply_to {
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
            
            
            if self.replylbl.text!.count < 35 {
                self.descLblTopConst.constant = 50.0
            }else {
                self.descLblTopConst.constant = 70.0
            }
            
            if (Int(replyModel.author_id) == SharedManager.shared.getUserID()){
                self.replyUserNamelbl.text = "You"
            }else {
                self.replyUserNamelbl.text = replyModel.full_name
            }
            }

        }else {
            self.replyView.isHidden = true
        }
        
        
        
        self.manageAudioData(dict: dict)
        SharedManager.shared.setTextandFont(viewText: self.descLbl as Any)
        SharedManager.shared.setTextandFont(viewText: self.audioLbl as Any)
    }
    
    func manageAudioData(dict:Message){
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.removeFromSuperview()
        }
        if (dict.audio_msg_url.count > 0) {
            var audioFileString = dict.audio_msg_url
            
            
            if dict.isOriginal == 1  {
                
                if dict.audio_file.count == 0 {
                    audioFileString = dict.audio_msg_url
                }else {
                    audioFileString = dict.audio_file
                }
                
            }else {
                if dict.audio_translation.count  > 0 {
                    audioFileString = dict.audio_translation
                }
            }
            
            
            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            self.xqAudioPlayer.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x, y: self.xqAudioPlayer.frame.origin.y, width: self.audioView.frame.size.width, height: self.xqAudioPlayer.frame.size.height)
            self.audioView.addSubview(self.xqAudioPlayer)
            self.audioViewHeightConst.constant = 44
            self.audioConfigurations(file:audioFileString)
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
        // self.xqAudioPlayer.delegate = self
    }
    
    @IBAction func showOriginal(sender : UIButton){
        
        
        if self.btnShowOriginal.isSelected {
            self.descLbl.text = self.chatObj.body
            self.chatObj.isOriginal = false
            self.btnShowOriginal.isSelected = false
            self.btnShowOriginal.setTitle("View Original".localized(), for: .normal)
            
            if self.audioLbl.text!.count == 0 {
                
            }else {
                self.audioLbl.text = chatObj.speech_to_text
            }
            
        }else {
            self.descLbl.text = self.chatObj.original_body
            self.chatObj.isOriginal = true
            self.btnShowOriginal.isSelected = true
            self.btnShowOriginal.setTitle("View Translated".localized(), for: .normal)
            if self.audioLbl.text!.count == 0 {
                
            }else {
                self.audioLbl.text = chatObj.original_speech_to_text
            }
        }
        self.manageAudioData(dict: self.chatObj)
        ChatCallBackManager.shared.reloadTableAtSpecificIndex?(self.currentIndex)
        
    }
    
    @IBAction func speakerButtonClicked(_ sender: Any) {
//        SpeechManager.shared.isFromChat = true
        if self.speakerButton.isSelected {
            SpeechManager.shared.stopSpeaking()
        }else {
            let bodyPlay =  self.descLbl.text!
            SpeechManager.shared.textToSpeech(message: bodyPlay)
            FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
                self?.speakerButton.isSelected  = !(self?.speakerButton.isSelected)!
            }
        }
        self.speakerButton.isSelected = !self.speakerButton.isSelected
    }
}
