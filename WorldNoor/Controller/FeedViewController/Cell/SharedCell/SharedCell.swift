//
//  PostCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/11/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class SharedCell: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bgView: DesignableView!
    @IBOutlet weak var postTypeView: UIView!
    @IBOutlet weak var postTypeHeightConst: NSLayoutConstraint!
    @IBOutlet weak var viewOrginHeightConst: NSLayoutConstraint!
    @IBOutlet weak var sharedHeaderView: UIView!
    @IBOutlet weak var sharedDescriptionLbl: UILabel!
    @IBOutlet weak var sharedViewOrignalBtn: UIButton!
    @IBOutlet weak var mainSharedView: DesignableView!
    @IBOutlet weak var shareSpeakerBtn: UIButton!
    @IBOutlet weak var linkPreviewHConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewCustom: UIView!
    var linkViewRef:LinkPreview!
    
    var parentview : UIViewController!
    
    var imageSelectedClosure:((Int, Bool)->())?
    var xqAudioPlayer: XQAudioPlayer!
    var feedObj:FeedData? = nil
    var audioLbl:UILabel?
    var audioOrigBtn:UIButton?
    var videoView:VideoView?
//    var galleryView:GalleryView?
    var galleryView : GalleryNewView?
    
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
        likeDislikeUpdated = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
//        self.commentViewRef.commentTextView.delegate = self
        self.sharedDescriptionLbl.dynamicSubheadRegular15()
        self.sharedViewOrignalBtn.titleLabel?.dynamicSubheadRegular15()
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        self.feedObj = feedObj
        self.indexValue = indexValue
        if self.commentViewRef != nil {
            self.updateTableClosure = reloadClosure
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
        }
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.topBar.sizeToFit()
        self.topBar.frame = CGRect.init(x: self.topBar.frame.origin.x, y: self.topBar.frame.origin.y, width: self.topBar.frame.size.width, height: self.headerViewRef.frame.size.height)
        self.commentView.addSubview(self.commentViewRef)
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageCallbackhandler()
        self.headerViewRef.indexValue = indexValue
        self.headerViewRef.postSelected = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure

        self.commentViewRef.commentButtonHandler = didSelect
        self.manageLinkPreview()
        self.manageSharedContent()
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)
//        self.commentViewRef.commentTextView.isScrollEnabled = false
        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
        
        if let commentCoun =  feedObj.commentCount  {
            if commentCoun > 0 {
                self.commentView.frame.size.height = 211
                self.commentViewRef.frame.size.height = 211
            }
        }
    }
    
    func manageLinkPreview() {
        self.linkPreviewHConst.constant = 0
        if self.linkViewRef != nil {
            self.linkViewRef.removeFromSuperview()
        }
        if let linkValue = self.feedObj?.sharedData?.previewLink {
            if linkValue != "" {
                self.linkPreviewHConst.constant = 90
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
    
    @objc func openLinkPreview(){
        FeedCallBManager.shared.linkPreviewUpdateHandler?(self.feedObj?.sharedData?.previewLink ?? "")
    }
    
    @objc func micButtonClicked(sender:UIButton)    {
//        self.commentViewRef.audioOptionView.isHidden = !self.commentViewRef.audioOptionView.isHidden
    }
    
    func manageSharedContent(){
        self.sharedDescriptionLbl.text = self.feedObj?.sharedData?.body
        if self.sharedDescriptionLbl.text != nil {
            self.manageDescriptionOnLoad()
        }
        self.manageSpeakerIcon()
        for view in self.postTypeView.subviews{
            view.removeFromSuperview()
        }
        switch self.feedObj?.sharedData?.postType! {
        case FeedType.post.rawValue:
            self.postTypeHeightConst.constant = 0
        case FeedType.audio.rawValue:
            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            self.xqAudioPlayer.frame = CGRect(x: 30, y: 0, width: self.postTypeView.frame.size.width-60, height:self.xqAudioPlayer.frame.size.height)
            self.postTypeView.addSubview(self.xqAudioPlayer)
            self.audioLbl = UILabel()
            self.audioLbl!.font = UIFont.systemFont(ofSize: 13)
            self.audioLbl!.numberOfLines = 0
            self.audioLbl!.textAlignment = NSTextAlignment.left
            self.getAudioText(audioLbl: self.audioLbl!)
            self.audioLbl!.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x+7, y: self.xqAudioPlayer.frame.origin.y+54, width: self.xqAudioPlayer.frame.size.width, height: SharedManager.shared.heightForView(text: self.audioLbl!.text!, font: self.audioLbl!.font, width: self.xqAudioPlayer.frame.size.width))
            let button = UIButton(frame: CGRect(x: self.xqAudioPlayer.frame.origin.x + 5, y: self.audioLbl!.frame.origin.y + self.audioLbl!.frame.size.height, width: 100, height: 30))
            button.backgroundColor = .clear
            button.setTitle("View Orignal".localized(), for: .normal)
            button.setTitle("View Translated".localized(), for: .selected)
            button.setTitleColor(.systemBlue, for: .normal)
            button.setTitleColor(.systemBlue, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.addTarget(self, action: #selector(viewOrigTranslatedAudio), for: .touchUpInside)
            self.audioOrigBtn = button
            self.postTypeHeightConst.constant = self.xqAudioPlayer.frame.size.height+self.audioLbl!.frame.size.height + 20 + 40
            self.postTypeView.addSubview(self.audioLbl!)
            self.postTypeView.addSubview(button)
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
            videoView.isAppearFrom = "Feed"
            videoView.isPartOf = "Feed"
            videoView.mainIndex = self.indexValue
            videoView.manageVideoData(feedObj: self.feedObj!.sharedData!, shouldPlay: true)
            self.videoView = videoView
        case FeedType.image.rawValue:
            self.postTypeHeightConst.constant = 248
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 400
            }
            let singleImageView = Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView
            singleImageView.frame = CGRect(x: 0, y: 0, width: self.postTypeView.frame.size.width, height: self.postTypeView.frame.size.height)
            self.postTypeView.addSubview(singleImageView)
            singleImageView.manageImageData(feedObj: self.feedObj!.sharedData!)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            singleImageView.userImageView.isUserInteractionEnabled = true
            singleImageView.userImageView.addGestureRecognizer(tapGestureRecognizer)
            
        case FeedType.gallery.rawValue:
            self.postTypeHeightConst.constant = 300
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 400
            }
            let galleryView = Bundle.main.loadNibNamed("GalleryNewView", owner: self, options: nil)?.first as! GalleryNewView
//            galleryView.collectionWidth = self.mainSharedView.frame.size.width
            galleryView.isAppearFrom = "SharedCell"
            galleryView.currentIndexPath = self.indexValue
            galleryView.manageGalleryData(feedObj: self.feedObj!.sharedData!)
            galleryView.frame = CGRect(x: 0, y: 0, width: self.mainSharedView.frame.size.width, height: self.postTypeHeightConst.constant)
            self.postTypeView.addSubview(galleryView)
            self.galleryView = galleryView
            self.galleryView?.layoutIfNeeded()
            
        case FeedType.file.rawValue:
            
            
            
            self.postTypeHeightConst.constant = 131
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.postTypeHeightConst.constant = 231
            }
            
            let attachmentView = Bundle.main.loadNibNamed(Const.KAttachmentView, owner: self, options: nil)?.first as! AttachmentView
            attachmentView.frame = CGRect(x: 0, y: 0, width: self.postTypeView.frame.size.width, height: self.postTypeView.frame.size.height)
            attachmentView.reloadView(feedObj: self.feedObj!.sharedData!)
            attachmentView.btnDownload.addTarget(self, action: #selector(self.downloadAttachment), for: .touchUpInside)
            self.postTypeView.addSubview(attachmentView)
            
        default:
            LogClass.debugLog("no value")
        }
    }
    
    func manageDescriptionOnLoad(){
        let langCode = SharedManager.shared.detectedLangaugeCode(for: self.sharedDescriptionLbl.text!)
        let langDirection = SharedManager.shared.detectedLangauge(for: self.sharedDescriptionLbl.text!) ?? "left"
        (langDirection == "right") ? (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.right): (self.sharedDescriptionLbl.textAlignment = NSTextAlignment.left)
        if langCode == "ar" {
            self.sharedDescriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.sharedDescriptionLbl.font!.pointSize)
        }else {
            self.sharedDescriptionLbl.font = UIFont.systemFont(ofSize: self.sharedDescriptionLbl.font!.pointSize)
        }
    }
    
    @objc func downloadAttachment(sender : UIButton){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            
            do {
                let imageData = try Data(contentsOf: URL.init(string: self.feedObj!.sharedData!.post!.first!.filePath!)!)
                
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.parentview.present(activityViewController, animated: true) {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
                
            } catch {

            }
            
        }
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
    
    func resetSharedElements() {
        if self.galleryView != nil {
            //            self.galleryView!.resetCollectionCell()
//            self.galleryView!.resetVisibleCellVideo()
        }
        if self.videoView != nil {
            self.videoView!.resetVideoPlayer()
        }
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.resetXQPlayer()
        }
    }
}

extension SharedCell:UITextViewDelegate   {
    // text change callback handler inside vm...
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imageSelectedClosure?(self.indexValue.row, true)
    }
    
    func textViewDidChange(_ textView: UITextView){
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < 100 {
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = newFrame.size.height + 5
            textChanged?(textView.text)
        }else {
//            self.commentViewRef.commentTextView.isScrollEnabled = true
        }
    }
    
    func handleEmptyText(){
        self.commentViewRef.textEmptyCallbackHandler =  { (isTextEmpty) in
//            let fixedWidth = self.commentViewRef.commentTextView.frame.size.width
//            self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            let newSize = self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            var newFrame = self.commentViewRef.commentTextView.frame
//            newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = 43
//            self.textChanged?("")
        }
    }
}

extension SharedCell:FeedCallBackProtocol {
    
    func manageCallbackhandler(){
        self.handlingLikeDislike()
        self.handleEmptyText()
        self.handlingCommentCallback()
        self.handlingInstantCommentCallback()
    }
    
    // Hanlding LikeDislikeCallBack...
    func handlingLikeDislike(){
        self.commentViewRef.likeDislikeCallBack =  { (isLike, value) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if isLike {
                if value {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! + 1
                    if feedObjUpdate.isDisliked! {
                        feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                    }
                }else {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                }
                feedObjUpdate.isLiked = value
                feedObjUpdate.isDisliked = false
            }else {
                if value {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! + 1
                    if feedObjUpdate.isLiked! {
                        feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                    }
                }else {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                }
                feedObjUpdate.isDisliked = value
                feedObjUpdate.isLiked = false
            }
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.commentViewRef.manageCount()
        }
    }
    
    func manageLikeDislikeCounter(feedObj:FeedData){
        
        
    }
    
    // comment call back handler to update the comment instantly in feedobject
    func handlingInstantCommentCallback(){
        self.commentViewRef.commentSentInstantlyHandler = {(body) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            let commentObj:Comment = Comment(original_body: body ,body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:false, identifierStr:"")
            var commentCount:Int = 0
            if feedObjUpdate.comments!.count > 0 {
                commentCount = (feedObjUpdate.comments?.count)!
            }
            feedObjUpdate.comments?.insert(commentObj, at: commentCount)
            feedObjUpdate.isPostingNow = false
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.updateTableClosure?(self.indexValue)
        }
    }
    
    // comment callback handler after service call
    func handlingCommentCallback(){
        self.commentViewRef.commentServiceCallbackHandler = {(res) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if res is String {
                return
            }else if res is NSDictionary {
                let respDict:NSDictionary = res as! NSDictionary
                let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
                let commentObj:Comment = Comment(dict: dataDict)
                
                var commentCount:Int = 0
                if feedObjUpdate.comments!.count > 0 {
                    commentCount = (feedObjUpdate.comments?.count)! - 1
                }
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true
                self.feedArray[self.indexValue.row] = feedObjUpdate
                self.updateTableClosure?(self.indexValue)
            }
        }
    }
}

extension SharedCell:XQAudioPlayerDelegate {
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
                let langCode = SharedManager.shared.detectedLangaugeCode(for: audioLbl.text!)
                
                if langCode == "ar" {
                    audioLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: audioLbl.font!.pointSize)
                }else {
                    audioLbl.font = UIFont.systemFont(ofSize: audioLbl.font!.pointSize)
                }
                
                
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
