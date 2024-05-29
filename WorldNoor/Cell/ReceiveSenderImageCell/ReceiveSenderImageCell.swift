//
//  ReceiveSenderImageCell.swift
//  WorldNoor
//
//  Created by Raza najam on 1/2/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ReceiveSenderImageCell: UITableViewCell {
    
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var viewlbl: UIView!
    @IBOutlet weak var descLblBottomLbl: NSLayoutConstraint!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var btnImageViewer: UIButton!
    @IBOutlet weak var senderDateLbl: UILabel!
    @IBOutlet weak var receiverDateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var viewOrignalReceiverBtn: UIButton!
    @IBOutlet weak var viewOrignalSenderBtn: UIButton!
    
    @IBOutlet weak var viewVideoTop: UIView!
    @IBOutlet weak var btnViewOriginal: UIButton!
    @IBOutlet weak var btnViewTranscript: UIButton!
    
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    var chatObj = Message()
    var leadingImageConst:NSLayoutConstraint? = nil
    var trailingImageConst:NSLayoutConstraint? = nil
    var senderType = ""
    
    var delegateTap : DelegateTapCell!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var speakerButtonRight: UIButton!
    
    
    @IBOutlet weak var replylbl: UILabel!
    @IBOutlet weak var replyUserNamelbl: UILabel!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cstImageViewTop: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // self.imgView.addgest
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        self.imgBgView.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressAction))
        self.imgBgView.addGestureRecognizer(tapGesture)
        
        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        
        self.descLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.descLbl)
                
        self.receiverDateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.receiverDateLbl)
        
        self.senderDateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.senderDateLbl)
        
        self.nameLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.nameLbl)
                
        self.replylbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replylbl)
        
        self.replyUserNamelbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.replyUserNamelbl)
        
        
        self.btnViewOriginal.rotateViewForLanguage()
        self.btnViewTranscript.rotateViewForLanguage()
        
        self.viewOrignalSenderBtn.rotateViewForLanguage()
        self.viewOrignalReceiverBtn.rotateViewForLanguage()
        

    }
    
    
    @objc func tapPressAction(tapPressGesture: UITapGestureRecognizer) {

        if delegateTap != nil {
            self.delegateTap.delegateOpenforImage(chatObj: self.chatObj, indexRow: self.currentIndex)
        }
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizer.State.began {
            if delegateTap != nil {

                self.delegateTap.delegateTapCellActionforImage(chatObj: self.chatObj, indexRow: self.currentIndex)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let colorBG = self.imgBgView.backgroundColor
        let colorReply = self.replyView.backgroundColor
        let colorTop = self.viewVideoTop.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        
        self.delegateTap.delegatRowValueChange(indexPath: currentIndex, selectecion: selected)
        
        self.imgBgView.backgroundColor = colorBG
        self.replyView.backgroundColor = colorReply
        self.viewVideoTop.backgroundColor = colorTop
        // Configure the view for the selected state
    }
    
    func manageChatBgView(dict:Message, currentIndex:IndexPath)    {
        self.btnImageViewer.isHidden = true
        self.currentIndex = currentIndex
        self.chatObj = dict
        self.descLbl.text = ""
        self.videoBtn.isHidden = false
        self.descLblBottomLbl.constant = 0
        
        self.cstImageViewTop.constant = 0.0
        
        
        self.descLbl.text = dict.body
        if dict.body.count > 0 {
            self.descLblBottomLbl.constant = 5
        }
        self.imgBgView.layer.cornerRadius = 10;
        self.imgBgView.layer.masksToBounds = true;
        if  leadingImageConst != nil {
            self.contentView.removeConstraint(leadingImageConst!)
            self.contentView.removeConstraint(trailingImageConst!)
        }
        leadingImageConst = self.imgBgView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15)
        trailingImageConst = self.imgBgView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15)
        if self.senderType == "sender" {
            self.manageSenderUI()
            self.senderDateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime, format:Const.dateFormat1)
        }else {
            self.manageReceiverUI()
            self.receiverDateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime, format:Const.dateFormat1)
        }
        
        
        SharedManager.shared.setTextandFont(viewText: self.descLbl!)
        self.manageImage(dict: dict)
        
        
        
        
        self.replylbl.text = ""
        self.replyUserNamelbl.text = ""
        
        if let replyModel = dict.reply_to {
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
            
            
            
            self.replyViewHeightConst.constant = 75.0
            self.cstImageViewTop.constant = 0.0
            
            
            if self.senderType == "sender" {

                self.replyView.backgroundColor = UIColor.init(red: (63/255), green: (77/255), blue: (151/255), alpha: 1.0)
                self.imgBgView.backgroundColor = UIColor.init(red: (111/255), green: (129/255), blue: (217/255), alpha: 1.0)

                self.replylbl.textColor = UIColor.white
                self.replyUserNamelbl.textColor = UIColor.white
            }else {
                self.replyView.backgroundColor = UIColor.init(red: (226/255), green: (229/255), blue: (231/255), alpha: 1.0)
                self.imgBgView.backgroundColor = UIColor.init(red: (239/255), green: (239/255), blue: (250/255), alpha: 1.0)

                self.replylbl.textColor = UIColor.init(red: (71/255), green: (78/255), blue: (115/255), alpha: 1.0)
                self.replyUserNamelbl.textColor = UIColor.init(red: (71/255), green: (78/255), blue: (115/255), alpha: 1.0)
            }
            
            
        }else {
            self.replyView.isHidden = true
            self.replyViewHeightConst.constant = 0.0
            if self.descLbl.text?.count == 0 {
                self.cstImageViewTop.constant = -15.0
            }else {
                self.cstImageViewTop.constant = 0.0
            }
            
        }
        
    }
    
    func manageImage(dict:Message){
        self.viewVideoTop.isHidden = true
        var messageArray = [MessageFile]()
        self.videoBtn.isHidden = true
        self.imgView.image = nil
        if dict.toMessageFile?.count ?? 0 > 0 {
            messageArray = dict.toMessageFile?.allObjects as! [MessageFile]
        }
        if messageArray.count == 1  {
            let dictMain = messageArray[0]
            if dictMain.post_type == FeedType.video.rawValue {
                self.videoBtn.isHidden = false
                if let image = SharedManager.shared.loadImage(fileName: dictMain.localthumbnailimage) {
                    self.imgView.image = image
                    
                }else {
                    
                    self.imgView.loadImageWithPH(urlMain: dictMain.thumbnail_url)
//                    self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.imgView.sd_setImage(with: URL.init(string: dictMain.thumbnail_url), placeholderImage: UIImage(named: "placeholder.png"))
                    self.labelRotateCell(viewMain: self.imgView)
                }
                
                
                self.viewVideoTop.isHidden = false
                
            }else if dictMain.post_type == FeedType.image.rawValue {
                self.videoBtn.isHidden = true
                self.btnImageViewer.isHidden = false
                
                if dictMain.post_type == FeedType.image.rawValue{
                    
                    if dictMain.localimage.count == 0 {
//                        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                        self.imgView.sd_setImage(with: URL.init(string: dictMain.url), placeholderImage: UIImage(named: "placeholder.png"))
                        
                        self.imgView.loadImageWithPH(urlMain: dictMain.url )
                        self.labelRotateCell(viewMain: self.imgView)
                    }else {
//                        self.imgView.image = dictMain.localthumbnailimage // Waseem Here
                        if let image = SharedManager.shared.loadImage(fileName: dictMain.localthumbnailimage) {
                            self.imgView.image = image
                        }
                    }
                    
                }else if dictMain.url == "containsFullImage"{
//                    self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.imgView.sd_setImage(with: URL.init(string: dictMain.url), placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.imgView.loadImageWithPH(urlMain: dictMain.url )
                    self.labelRotateCell(viewMain: self.imgView)
                }else {
                    let imageUrlString = dict.audio_msg_url
//                    self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.imgView.sd_setImage(with: URL(string: imageUrlString ), placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.imgView.loadImageWithPH(urlMain: imageUrlString )
                    self.labelRotateCell(viewMain: self.imgView)
                }
            }
        }
        
    }
    
    func manageSenderUI(){
        self.nameLbl.text = ""
        
        self.descLbl.textColor = UIColor.white
        trailingImageConst!.isActive = true
        leadingImageConst!.isActive = false
        self.nameLbl.isHidden = true
        self.senderDateLbl.isHidden = false
        self.receiverDateLbl.isHidden = true
        self.viewOrignalReceiverBtn.isHidden = true
        self.viewOrignalSenderBtn.isHidden = false
        
        self.speakerButton.isHidden = self.viewOrignalReceiverBtn.isHidden
        self.speakerButtonRight.isHidden = self.viewOrignalSenderBtn.isHidden
    }
    
    func manageReceiverUI(){
        self.nameLbl.text = self.chatObj.full_name
        self.nameLbl.isHidden = false
        self.senderDateLbl.isHidden = true
        self.receiverDateLbl.isHidden = false
        
        
        self.imgBgView.backgroundColor = UIColor.chatReceiverCell
        self.descLbl.textColor = UIColor.chatReceiverCellText
        trailingImageConst!.isActive = false
        leadingImageConst!.isActive = true
        self.viewOrignalReceiverBtn.isHidden = false
        self.viewOrignalSenderBtn.isHidden = true
        
        self.speakerButton.isHidden = self.viewOrignalReceiverBtn.isHidden
        self.speakerButtonRight.isHidden = self.viewOrignalSenderBtn.isHidden
    }
    
    @IBAction func showOriginal(sender : UIButton){
        if self.viewOrignalSenderBtn.isHidden {
            if self.viewOrignalReceiverBtn.isSelected {
                self.descLbl.text = self.chatObj.body
                self.viewOrignalReceiverBtn.isSelected = false
                self.viewOrignalReceiverBtn.setTitle("View Original".localized(), for: .normal)
            }else {
                self.descLbl.text = self.chatObj.original_body
                self.viewOrignalReceiverBtn.isSelected = true
                self.viewOrignalReceiverBtn.setTitle("View Translated".localized(), for: .normal)
            }
        }else {
            if self.viewOrignalSenderBtn.isSelected {
                self.descLbl.text = self.chatObj.body
                self.viewOrignalSenderBtn.isSelected = false
                self.viewOrignalSenderBtn.setTitle("View Original".localized(), for: .normal)
            }else {
                self.descLbl.text = self.chatObj.original_body
                self.viewOrignalSenderBtn.isSelected = true
                self.viewOrignalSenderBtn.setTitle("View Translated".localized(), for: .normal)
            }
            ChatCallBackManager.shared.reloadTableAtSpecificIndex?(self.currentIndex)
        }
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
    
    
    @IBAction func speakerButtonRightClicked(_ sender: Any) {
//        SpeechManager.shared.isFromChat = true
        if self.speakerButtonRight.isSelected {
            SpeechManager.shared.stopSpeaking()
        }else {
            
            let bodyPlay =  self.descLbl.text!

            SpeechManager.shared.textToSpeech(message: bodyPlay)
            
            FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
                self?.speakerButtonRight.isSelected  = !(self?.speakerButtonRight.isSelected)!
            }
        }
        self.speakerButtonRight.isSelected = !self.speakerButtonRight.isSelected
    }
}
