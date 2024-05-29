//
//  ReceiveSendGalleryCell.swift
//  WorldNoor
//
//  Created by Raza najam on 1/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ReceiveSendGalleryCell: UITableViewCell {
    var senderType = ""
    
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var galleryBgView: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var receiverDateLbl: UILabel!
    @IBOutlet weak var senderDateLbl: UILabel!
    @IBOutlet weak var senderViewOrignalBtn: UIButton!
    @IBOutlet weak var receiverVIewOrignalBtn: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var speakerButtonRight: UIButton!
    
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    var chatObj = Message()
    
    var delegateTap : DelegateTapCell!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .default
        tintColor = UIColor.tabSelectionBG
        selectedBackgroundView = SharedManager.shared.selectedCellBackgroundView()
        
        self.descLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.descLbl)
                
        self.nameLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.nameLbl)
                
        self.receiverDateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.receiverDateLbl)
        
        self.senderDateLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.senderDateLbl)
    
        
        self.senderViewOrignalBtn.rotateViewForLanguage()
        self.receiverVIewOrignalBtn.rotateViewForLanguage()
        
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        if self.delegateTap != nil {
            self.delegateTap.delegatRowValueChange(indexPath: currentIndex, selectecion: selected)
        }
        
        // Configure the view for the selected state
    }
    
    func manageChatBgView(dict:Message, currentIndex:IndexPath)    {
        self.currentIndex = currentIndex
        self.chatObj = dict
        self.descLbl.text = ""
        if chatObj.body.count > 0 {
            self.descLbl.text = chatObj.body
        }
        self.galleryBgView.layer.cornerRadius = 10;
        self.galleryBgView.layer.masksToBounds = true;
        
        if self.senderType == "sender" {
            self.manageSenderUI()
            self.senderDateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime, format:Const.dateFormat1)
            
        }else {
            self.manageReceiverUI()
            self.receiverDateLbl.text = dict.messageTime.customDateFormat(time: dict.messageTime, format:Const.dateFormat1)
        }
        
        SharedManager.shared.setTextandFont(viewText: self.descLbl)
        self.manageImage(dict: dict)
        
    }
    
    func manageImage(dict:Message){
        var counter = 0
        for dict in  dict.toMessageFile?.allObjects as? [MessageFile] ?? [] {
            var urlString:URL?
            if dict.url  == "containsFullImage"{
                //                    urlString = dict["localImageUrl"] as? URL
            }else {
                urlString = URL(string:dict.url)
            }
            switch counter {
            case 0:
                if dict.post_type == FeedType.image.rawValue {
                    self.img1.layer.cornerRadius = 10;
                    self.img1.layer.masksToBounds = true;
//                    self.img1.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.img1.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
                    self.img1.loadImageWithPH(urlMain: dict.url)
                    self.labelRotateCell(viewMain: self.img1)
                }
            case 1:
                if dict.post_type == FeedType.image.rawValue {
                    self.img2.layer.cornerRadius = 10;
                    self.img2.layer.masksToBounds = true;
//                    self.img2.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.img2.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.img2.loadImageWithPH(urlMain: dict.url)
                    self.labelRotateCell(viewMain: self.img2)
                }
            case 2:
                if dict.post_type == FeedType.image.rawValue {
                    self.img3.layer.cornerRadius = 10;
                    self.img3.layer.masksToBounds = true;
//                    self.img3.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.img3.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.img3.loadImageWithPH(urlMain: dict.url)
                    self.labelRotateCell(viewMain: self.img3)
                }
            case 3:
                if dict.post_type == FeedType.image.rawValue {
                    self.img4.layer.cornerRadius = 10;
                    self.img4.layer.masksToBounds = true;
//                    self.img4.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                    self.img4.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.img4.loadImageWithPH(urlMain: dict.url)
                    self.labelRotateCell(viewMain: self.img4)
                }
            default:
                LogClass.debugLog("No Case found.")
            }
            counter = counter + 1
        }
    }
    
    func manageSenderUI(){
        let leadingConst = self.galleryBgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15)
        let trailingConst = self.galleryBgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        self.galleryBgView.backgroundColor = UIColor.chatSenderCell
        self.descLbl.textColor = UIColor.white
        leadingConst.isActive = false
        trailingConst.isActive = true
        self.nameLbl.isHidden = true
        self.receiverDateLbl.isHidden = true
        self.receiverVIewOrignalBtn.isHidden = true
        self.senderViewOrignalBtn.isHidden = false
        self.senderDateLbl.isHidden = false
        self.speakerButton.isHidden = self.receiverVIewOrignalBtn.isHidden
        self.speakerButtonRight.isHidden = self.senderViewOrignalBtn.isHidden
    }
    
    func manageReceiverUI(){
        self.nameLbl.text = self.chatObj.full_name
        let leadingConst = self.galleryBgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15)
        let trailingConst = self.galleryBgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        self.galleryBgView.backgroundColor = UIColor.chatReceiverCell
        self.descLbl.textColor = UIColor.chatReceiverCellText
        leadingConst.isActive = true
        trailingConst.isActive = false
        self.nameLbl.isHidden = false
        self.receiverDateLbl.isHidden = false
        self.receiverVIewOrignalBtn.isHidden = false
        self.senderViewOrignalBtn.isHidden = true
        self.senderDateLbl.isHidden = true
        self.speakerButton.isHidden = self.receiverVIewOrignalBtn.isHidden
        self.speakerButtonRight.isHidden = self.senderViewOrignalBtn.isHidden
    }
    
    @IBAction func showOriginal(sender : UIButton){
        
        
        if self.senderViewOrignalBtn.isHidden {
            if self.receiverVIewOrignalBtn.isSelected {
                self.descLbl.text = self.chatObj.body
                self.receiverVIewOrignalBtn.isSelected = false
                self.receiverVIewOrignalBtn.setTitle("View Original".localized(), for: .normal)
            }else {
                self.descLbl.text = self.chatObj.original_body
                self.receiverVIewOrignalBtn.isSelected = true
                self.receiverVIewOrignalBtn.setTitle("View Translated".localized(), for: .normal)
                
            }
        }else
        {
            if self.senderViewOrignalBtn.isSelected {
                self.descLbl.text = self.chatObj.body
                self.senderViewOrignalBtn.isSelected = false
                self.senderViewOrignalBtn.setTitle("View Original".localized(), for: .normal)
            }else {
                self.descLbl.text = chatObj.original_body
                self.senderViewOrignalBtn.isSelected = true
                self.senderViewOrignalBtn.setTitle("View Translated".localized(), for: .normal)
            }
        }
        ChatCallBackManager.shared.reloadTableAtSpecificIndex?(self.currentIndex)
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
            let bodyPlay = self.descLbl.text!
   
            SpeechManager.shared.textToSpeech(message: bodyPlay)
            FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
                self?.speakerButtonRight.isSelected  = !(self?.speakerButtonRight.isSelected)!
            }
        }
        self.speakerButtonRight.isSelected = !self.speakerButton.isSelected
    }
}
