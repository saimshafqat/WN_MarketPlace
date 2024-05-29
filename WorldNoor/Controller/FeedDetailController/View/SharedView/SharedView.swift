//
//  SharedView.swift
//  WorldNoor
//
//  Created by Raza najam on 4/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class SharedView: ParentFeedView {
    @IBOutlet weak var postTypeView: UIView!
    @IBOutlet weak var postTypeHeightConst: NSLayoutConstraint!
    @IBOutlet weak var viewOrginHeightConst: NSLayoutConstraint!
    @IBOutlet weak var sharedHeaderView: UIView!
    @IBOutlet weak var sharedDescriptionLbl: UILabel!
    @IBOutlet weak var sharedViewOrignalBtn: UIButton!
    @IBOutlet weak var mainSharedView: DesignableView!
    @IBOutlet weak var shareSpeakerBtn: UIButton!
    @IBOutlet weak var lblHeightConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewCustom: UIView!
    var linkViewRef:LinkPreview!
    var audioLbl:UILabel?
    var audioOrigBtn:UIButton?
    var videoView:VideoView?
    var galleryView:GalleryView?
    var xqAudioPlayer: XQAudioPlayer!
    var indexValue:IndexPath = IndexPath(row: 0, section: 0)
    var feedObj:FeedData? = nil
    
    func manageData(feedObj:FeedData){
        self.feedObj = feedObj
        self.manageSharedContent()
    }
    
    func manageSharedContent(){
        self.manageSpeakerIcon()
        self.manageDescText()
        self.manageLinkPreview()
        switch self.feedObj?.sharedData?.postType! {
        case FeedType.post.rawValue:
            self.postTypeHeightConst.constant = 0
            self.postTypeView.removeFromSuperview()
            self.sharedHeaderView.bottomAnchor.constraint(equalTo: self.mainSharedView.bottomAnchor, constant: 0).isActive = true
        case FeedType.audio.rawValue:
            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            self.xqAudioPlayer.frame = CGRect(x: 30, y: 0, width: self.postTypeView.frame.size.width-60, height:self.xqAudioPlayer.frame.size.height)
            self.postTypeView.addSubview(self.xqAudioPlayer)
            self.audioLbl = UILabel()
            self.audioLbl!.font = UIFont.systemFont(ofSize: 13)
            self.audioLbl!.numberOfLines = 0
            self.audioLbl!.textAlignment = NSTextAlignment.left
            self.getAudioText(audioLbl: self.audioLbl!)
            let audioHeight = (self.audioLbl!.text!.heightString(withConstrainedWidth: self.xqAudioPlayer.frame.size.width, font: self.audioLbl!.font))
            self.audioLbl!.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x+7, y: self.xqAudioPlayer.frame.origin.y+54, width: self.xqAudioPlayer.frame.size.width, height: audioHeight)
            let button = UIButton(frame: CGRect(x: self.xqAudioPlayer.frame.origin.x + 5, y: self.audioLbl!.frame.origin.y + self.audioLbl!.frame.size.height, width: 100, height: 30))
            
            button.backgroundColor = .clear
            button.setTitle("View Orignal".localized(), for: .normal)
            button.setTitle("View Translated".localized(), for: .selected)
            button.setTitleColor(.systemBlue, for: .normal)
            button.setTitleColor(.systemBlue, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.addTarget(self, action: #selector(viewOrigTranslatedAudio), for: .touchUpInside)
            self.audioOrigBtn = button
            self.postTypeView.addSubview(self.audioLbl!)
            self.postTypeView.addSubview(button)
            self.postTypeHeightConst.constant = self.xqAudioPlayer.frame.size.height + audioHeight + 60
            self.audioXQConfiguration()
        case FeedType.video.rawValue, FeedType.liveStream.rawValue:
            self.postTypeHeightConst.constant = 290
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 400
            }
            let videoView = Bundle.main.loadNibNamed(Const.VideoView, owner: self, options: nil)?.first as! VideoView
            self.postTypeView.addSubview(videoView)
            videoView.frame = CGRect(x: 0, y: 0, width: self.postTypeView.frame.size.width, height: self.postTypeView.frame.size.height)
            videoView.isAppearFrom = "SharedView"
            videoView.isPartOf = "NotGallery"
            videoView.mainIndex = self.indexValue
            videoView.manageVideoData(feedObj: self.feedObj!.sharedData!, shouldPlay: true)
            self.videoView = videoView
        case FeedType.image.rawValue:
            self.postTypeHeightConst.constant = 230
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 400
            }
            let singleImageView = Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView
            singleImageView.frame = CGRect(x: 0, y: 0, width: self.postTypeView.frame.size.width, height: self.postTypeView.frame.size.height)
            self.postTypeView.addSubview(singleImageView)
            singleImageView.manageImageData(feedObj: self.feedObj!.sharedData!)

        case FeedType.gallery.rawValue:
            self.postTypeHeightConst.constant = 255
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 400
            }
            let galleryView = Bundle.main.loadNibNamed(Const.KGalleryView, owner: self, options: nil)?.first as! GalleryView
            galleryView.collectionWidth = self.mainSharedView.frame.size.width
            galleryView.isAppearFrom = "SharedView"
            galleryView.currentIndexPath = self.indexValue
            galleryView.manageGalleryData(feedObj: self.feedObj!.sharedData!)
            galleryView.frame = CGRect(x: 0, y: 0, width: self.mainSharedView.frame.size.width, height: self.postTypeView.frame.size.height)
            self.postTypeView.addSubview(galleryView)
            self.galleryView = galleryView
        default:
            LogClass.debugLog("no value")
        }
    }
    
    func manageDescriptionOnLoad(){
        let langCode = SharedManager.shared.detectedLangaugeCode(for: self.sharedDescriptionLbl.text!)

        if langCode == "ar" {
                       self.sharedDescriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.sharedDescriptionLbl.font!.pointSize)
                   }else {
                       self.sharedDescriptionLbl.font = UIFont.systemFont(ofSize: self.sharedDescriptionLbl.font!.pointSize)
                   }
        
    }
    
    func manageDescText(){
        self.lblHeightConst.constant = 0
        self.sharedDescriptionLbl.text = self.feedObj!.sharedData?.body
        if self.sharedDescriptionLbl.text != nil {
            let langDirection = SharedManager.shared.detectedLangauge(for: self.sharedDescriptionLbl.text!) ?? "left"
            (langDirection == "right") ? (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.right): (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.left)
            self.manageDescriptionOnLoad()

        }
        var heightStr:CGFloat = 0
        if (self.feedObj?.sharedData?.body!.count)! > 0 {
            heightStr = (self.feedObj?.sharedData?.body?.heightString(withConstrainedWidth: self.sharedDescriptionLbl.frame.size.width, font: self.sharedDescriptionLbl.font))!
            if !self.sharedViewOrignalBtn.isHidden {
                self.lblHeightConst.constant = heightStr + 7
            }else {
                self.lblHeightConst.constant = heightStr
            }
        }else {
            self.lblHeightConst.constant = 0
        }
    }
    
    func manageLinkPreview() {
        self.linkPreviewHeightConst.constant = 0
        if self.linkViewRef != nil {
            self.linkViewRef.removeFromSuperview()
        }
        if let linkValue = self.feedObj?.sharedData?.previewLink {
            if linkValue != "" {
                self.linkPreviewHeightConst.constant = 90
                let linkView = Bundle.main.loadNibNamed(Const.klinkPreview, owner: self, options: nil)?.first as! LinkPreview
                self.linkPreviewCustom.addSubview(linkView)
                self.linkViewRef = linkView
                self.linkViewRef.manageData(feedObj: self.feedObj!.sharedData!)
                linkView.translatesAutoresizingMaskIntoConstraints = false
                linkView.leadingAnchor.constraint(equalTo: self.linkPreviewCustom.leadingAnchor, constant: 0).isActive = true
                linkView.trailingAnchor.constraint(equalTo: self.linkPreviewCustom.trailingAnchor, constant: 0).isActive = true
                linkView.topAnchor.constraint(equalTo: self.linkPreviewCustom.topAnchor, constant: 0).isActive = true
                linkView.bottomAnchor.constraint(equalTo: self.linkPreviewCustom.bottomAnchor, constant: 0).isActive = true
                self.linkViewRef.linkPreviewBtn.addTarget(self, action: #selector(openLinkPreview), for: .touchUpInside)
            }
        }
    }
    
    func getHeightOfView()->CGFloat{
        var offset:CGFloat = 0.0
        if let linkValue = self.feedObj?.sharedData?.previewLink {
            if linkValue != "" {
                offset = 95.0
            }
        }
        return self.viewOrginHeightConst.constant + self.postTypeHeightConst.constant + self.lblHeightConst.constant + offset
    }
    
    @objc func openLinkPreview(){
        FeedDetailCallbackManager.shared.FeedDetailPreviewLinkHandler?(self.feedObj?.sharedData?.previewLink ?? "")
    }
    
    func manageSpeakerIcon() {
        if self.feedObj?.sharedData!.isSpeakerPlaying == false {
            self.shareSpeakerBtn.isSelected = false
        }else {
            self.shareSpeakerBtn.isSelected = true
        }
        self.shareSpeakerBtn.isHidden = false
        self.viewOrginHeightConst.constant = 30
        if let someMessage = self.feedObj?.sharedData!.body {
            if someMessage == "" {
                self.viewOrginHeightConst.constant = 0
                self.shareSpeakerBtn.isHidden = true
                self.sharedViewOrignalBtn.isHidden = true
            }else {
                let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
                if let contentLangCode = self.feedObj?.sharedData!.language?.codeID {
                    if langCode == contentLangCode {
                        self.sharedViewOrignalBtn.isHidden = true
                    }else {
                        self.sharedViewOrignalBtn.isHidden = false
                    }
                }else {
                    self.sharedViewOrignalBtn.isHidden = true
                }
            }
        }else {
            self.viewOrginHeightConst.constant = 0
            self.shareSpeakerBtn.isHidden = true
            self.sharedViewOrignalBtn.isHidden = true
        }
    }
    
    @IBAction func textToSpeechSharedPostBtnClicked(_ sender: Any) {
        if self.shareSpeakerBtn.isSelected {
            SpeechManager.shared.stopSpeaking()
        }
        else {
            SpeechManager.shared.textToSpeech(message: (self.sharedDescriptionLbl.text)!)
        }
        self.shareSpeakerBtn.isSelected = !self.shareSpeakerBtn.isSelected
//        SpeechManager.shared.isAppearFrom = "FeedDetail"
        FeedDetailCallbackManager.shared.speakerHandlerFeedDetail = {[weak self] (indexPath) in
            self?.shareSpeakerBtn.isSelected = false
        }
    }
    
    @IBAction func viewOrignalTranslationBtnClicked(_ sender: Any) {
        self.sharedViewOrignalBtn.isSelected = !self.sharedViewOrignalBtn.isSelected
        if self.sharedViewOrignalBtn.isSelected {
            self.sharedDescriptionLbl.text = self.feedObj?.sharedData!.orignalBody
        }else {
            self.sharedDescriptionLbl.text = self.feedObj?.sharedData!.body
        }
        if self.sharedDescriptionLbl.text != nil {
            let langDirection = SharedManager.shared.detectedLangauge(for: self.sharedDescriptionLbl.text!) ?? "left"
            (langDirection == "right") ? (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.right): (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.left)
            self.manageDescriptionOnLoad()

        }
    }
    
    func resetAllOption(){
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.resetXQPlayer()
        }
        if self.videoView != nil {
            self.videoView!.resetVideoPlayer()
        }
        if self.galleryView != nil {
            self.galleryView?.resetVisibleCellVideo()
        }
    }
    
}

extension SharedView:XQAudioPlayerDelegate {
    @objc func viewOrigTranslatedAudio(sender: UIButton!) {
        self.xqAudioPlayer.resetXQPlayer()
        if sender.isSelected {
            self.manageAudioToggle(isOrig: false)
        }else {
            self.manageAudioToggle(isOrig: true)
        }
        sender.isSelected = !sender.isSelected
    }
    
    func manageAudioToggle(isOrig:Bool) {
        if self.feedObj!.sharedData!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.sharedData!.post![0]
            let orignalLink = postFile.filePath
            let translatedLink = postFile.filetranslationlink
            if isOrig {
                self.getAudioText(audioLbl: self.audioLbl!, isShowOrig: true)
                self.xqAudioPlayer.config(urlString: orignalLink!)
            }else {
                self.getAudioText(audioLbl: self.audioLbl!, isShowOrig: false)
                self.xqAudioPlayer.config(urlString: translatedLink!)
            }
        }
    }
    
    func audioXQConfiguration() {
        self.audioOrigBtn?.isHidden = true
        if self.feedObj!.sharedData!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.sharedData!.post![0]
            if let convertedUrl = postFile.filetranslationlink {
                self.xqAudioPlayer.config(urlString: convertedUrl)
                self.audioOrigBtn?.isHidden = false
            }else {
                self.xqAudioPlayer.config(urlString:postFile.filePath ?? "")
            }
        }
        self.xqAudioPlayer.playingImage = UIImage(named:"icon_playing")
        self.xqAudioPlayer.pauseImage = UIImage(named:"icon_pause")
        self.xqAudioPlayer.delegate = self
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.manageProgressUI()
        }
    }
    
    func getAudioText(audioLbl:UILabel, isShowOrig:Bool = false) {
        audioLbl.text = ""
        if self.feedObj!.sharedData!.post!.count > 0 {
            let postObj:PostFile = self.feedObj!.sharedData!.post![0]
            let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
            if let contentLangCode = postObj.orignalLanguageID {
                if langCode == contentLangCode || isShowOrig {
                    if let message = postObj.speechToText {
                        audioLbl.text = message
                    }
                }else {
                    if let message = postObj.SpeechToTextTranslated {
                        audioLbl.text = message
                    }
                }
            }
            if audioLbl.text != nil {
                let langDirection = SharedManager.shared.detectedLangauge(for: audioLbl.text!) ?? "left"
                (langDirection == "right") ? (audioLbl.textAlignment = NSTextAlignment.right): (audioLbl.textAlignment = NSTextAlignment.left)
            }
        }
    }
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime) {
        
    }
    
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime) {
        
    }
    func playerDidStart(player: XQAudioPlayer) {
        
    }
    
    func playerDidStoped(player: XQAudioPlayer) {
        
    }
    
    func playerDidFinishPlaying(player: XQAudioPlayer) {
        
    }
}
