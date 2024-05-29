//
//  VideoCell.swift
//  WorldNoor
//
//  Created by Raza najam on 9/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVKit
import Photos
//import RSLoadingView

class VideoCell: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var videoImgView: UIImageView!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var topConnectorConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConnectorConst: NSLayoutConstraint!
    @IBOutlet weak var videoTranscriptView: UIView!
    @IBOutlet weak var viewTranscriptBtn: UIButton!
    @IBOutlet weak var viewOgrinalLangBtn: UIButton!
    @IBOutlet weak var videoLangLbl: UILabel!
    
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLoader: UIView!

    @IBOutlet weak var btnShare: UIButton!
    var feedObj:FeedData? = nil
    var videoPlayerIndexCallback: ((IndexPath) -> Void)?
    var playerController : AVPlayerViewController? = nil
    var videoUrl: URL!
    var timeObserverToken: Any?
    var player = AVPlayer()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // self.resetVideoPlayer()
        textChanged = nil
        likeDislikeUpdated = nil
        self.videoPlayerIndexCallback = nil
        // self.videoPlayButtonClicked(UIButton())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
        self.playerController = AVPlayerViewController()
//        self.commentViewRef.commentTextView.delegate = self
        self.videoView.addSubview(self.playerController!.view)
        self.playerController?.view.frame = self.videoView.frame
        
        self.labelRotateCell(viewMain: self.viewOgrinalLangBtn)
        self.labelRotateCell(viewMain: self.videoView)
//        self.viewOgrinalLangBtn.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.viewTranscriptBtn)
//        self.viewTranscriptBtn.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.videoLangLbl)
        self.labelRotateCell(viewMain: self.videoImgView)
//        self.videoLangLbl.rotateForTextAligment()
        
        viewOgrinalLangBtn.setTitle("watch".localized(), for: .normal)
        
        self.videoLangLbl.dynamicSubheadRegular15()
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, shouldPlay:Bool, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        if self.commentViewRef != nil {
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
        }
        self.feedObj = feedObj
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.commentView.addSubview(self.commentViewRef)
        self.indexValue = indexValue
        self.updateTableClosure = reloadClosure
        self.headerViewRef.nameLbl.text = feedObj.authorName
//        self.headerViewRef.userImageView.sd_setImage(with: URL(string: feedObj.profileImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        
        self.headerViewRef.userImageView.loadImageWithPH(urlMain: feedObj.profileImage ?? "")
        self.labelRotateCell(viewMain: self.headerViewRef.userImageView)
        self.headerViewRef.dateLbl.text = feedObj.postedOn
        self.headerViewRef.descriptionLbl.text = feedObj.body
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageVideo(feedObj: feedObj, shouldPlay: shouldPlay)
        self.manageCallbackhandler()
        self.headerViewRef.indexValue = indexValue
        self.headerViewRef.postSelected = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure

        self.commentViewRef.commentButtonHandler = didSelect
        self.topBar.sizeToFit()
    }
    
    func manageVideo(feedObj:FeedData, shouldPlay:Bool, isShowTranslated:Bool = true) {
        self.videoLangLbl.text = ""
        self.viewShare.isHidden = false
        self.viewLoader.isHidden = true
        self.viewTranscriptBtn.isHidden = true
        self.viewOgrinalLangBtn.isHidden = true
        if feedObj.postType == FeedType.liveStream.rawValue {
//            self.videoImgView.sd_setImage(with: URL(string: feedObj.liveThumbUrlStr ?? ""), placeholderImage: UIImage(named: "placeholderBlack.png"))
            
            
            self.videoImgView.loadImageWithPH(urlMain: feedObj.liveThumbUrlStr ?? "")
            
            self.labelRotateCell(viewMain: self.videoImgView)
            self.videoUrl = URL(string: feedObj.liveUrlStr!)
            if self.videoUrl != nil {
                self.player = AVPlayer(url: self.videoUrl)
                self.playerController!.player = player
                self.playerController?.view.backgroundColor = .clear
            }
        }else {
            
//            self.videoBtn.isHidden = false
            for indexObj in self.videoView.subviews {
                indexObj.removeFromSuperview()
            }
            if feedObj.post!.count > 0 {
                let postFile:PostFile = feedObj.post![0]
                self.playerController?.view.isHidden = false
                if postFile.processingStatus != "done" {
                    self.videoLangLbl.text = "We are processing the video...".localized()
                    self.playerController?.view.isHidden = true
                    self.viewShare.isHidden = true
                    self.viewLoader.isHidden = false
//                    let loadingView = RSLoadingView()
//                    loadingView.sizeInContainer = CGSize.init(width: 125, height: 125)
//                    loadingView.prepareForResize()
//                    loadingView.show(on: viewLoader)
                    
                }else {
//                    self.videoLangLbl.text = String(format: "Uploaded in:".localized() + " %@", postFile.uploadedLang ?? "")
                }
                if isShowTranslated {
                    if postFile.convertedURL.count > 0 {
                        self.videoUrl = URL(string: postFile.convertedURL)
                    }else
                    {
                        self.videoUrl = URL(string: postFile.filePath ?? "")
                    }
                }else {
                    if let orignalString = postFile.filePath {
                        self.videoUrl = URL(string:orignalString)
                    }
                }
                if let thumbnailUrl = postFile.thumbnail {
                    if thumbnailUrl != "" {
//                        self.videoImgView.sd_setImage(with: URL(string: thumbnailUrl ), placeholderImage: UIImage(named: "placeholderBlack.png"))
                        
                        self.videoImgView.loadImageWithPH(urlMain: thumbnailUrl ?? "")
                        
                        self.labelRotateCell(viewMain: self.videoImgView)
                    }
                }
                if  postFile.isSpeechExist! == 1 {
                    self.viewTranscriptBtn.isHidden = false
                    if  postFile.filetranslationlink != nil {
                        self.viewOgrinalLangBtn.isHidden = false
                    }else {
                        self.viewOgrinalLangBtn.isHidden = true
                    }
                }
                
                self.player = AVPlayer(url: self.videoUrl)
                self.playerController!.player = player
                self.playerController?.view.backgroundColor = .clear
//                self.videoImgView.sd_setImage(with: URL(string: postFile.thumbnail ?? ""), placeholderImage: UIImage(named: "placeholderBlack.png"))
                
                self.videoImgView.loadImageWithPH(urlMain: postFile.thumbnail ?? "")
                
                self.labelRotateCell(viewMain: self.videoImgView)
                self.videoImgView.isHidden = true
            }
        }
    }
    
//    @IBAction func playAction(sender : UIButton){
//        self.playerController?.player?.play()
//    }
    func resetVideoPlayer(){
        self.playerController!.player?.pause()
        self.playerController!.player = nil
        self.removePeriodicTimeObserver()
    }
    
    func testVideoCallFunc (){
        let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
        if feedObjUpdate.videoSeekTime != nil {
            self.playerController!.player?.currentItem!.seek(to:CMTime(seconds: feedObjUpdate.videoSeekTime!, preferredTimescale: 1))
        }
        self.playerController?.showsPlaybackControls = true
        self.playerController!.player!.play()
        self.addPeriodicTimeObserver()
    }
    
    @IBAction func videoPlayButtonClicked(_ sender: Any) {
        

        if playerController?.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing {
            self.playerController!.player?.pause()
        }else if playerController?.player?.timeControlStatus == AVPlayer.TimeControlStatus.paused {
            self.playerController!.player?.currentItem!.seek(to:(playerController?.player?.currentTime())!)
            self.playerController!.player!.play()
            self.addPeriodicTimeObserver()
        }else {
            if self.playerController!.player == nil {
                self.manageVideo(feedObj: self.feedObj!, shouldPlay: true)
            }
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if feedObjUpdate.videoSeekTime != nil {
                self.playerController!.player?.currentItem!.seek(to:CMTime(seconds: feedObjUpdate.videoSeekTime!, preferredTimescale: 1))
            }
            self.playerController?.showsPlaybackControls = true
            if self.videoUrl != nil {
                self.playerController!.player!.play()
                self.addPeriodicTimeObserver()
            }
        }
        self.videoPlayerIndexCallback?(self.indexValue)
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = self.playerController?.player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            feedObjUpdate.videoSeekTime = time.seconds
            self.feedArray[self.indexValue.row] = feedObjUpdate
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.playerController?.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)
        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
        self.topConnectorConst.constant = 11
        self.bottomConnectorConst.constant = 42
        if self.headerViewRef.descriptionLbl.text == "" {
            self.topConnectorConst.constant = 0
            self.bottomConnectorConst.constant = 42
        }
        if let commentCoun =  feedObj.commentCount  {
            if commentCoun > 0 {
                self.commentView.frame.size.height = 180
                self.commentViewRef.frame.size.height = 180
            }
        }
        self.handlingLikeDislike()
    }
    
    @objc func micButtonClicked(sender:UIButton)    {
    }
    

    @IBAction func viewOrignalVideoBtnClicked(_ sender: Any) {
        self.viewOgrinalLangBtn.isSelected = !self.viewOgrinalLangBtn.isSelected
        if self.viewOgrinalLangBtn.isSelected {
            self.commentViewRef.viewOgrinalLangBtn = true
            self.manageVideo(feedObj: self.feedObj!, shouldPlay: true, isShowTranslated: false)
        }else {
            self.commentViewRef.viewOgrinalLangBtn = false
            self.manageVideo(feedObj: self.feedObj!, shouldPlay: true)
        }
    }
}

extension VideoCell:UITextViewDelegate   {
    // text change callback handler inside vm...
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView){
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < 100 {
            textChanged?(textView.text)
        }
    }
    
    func handleEmptyText(){
        self.commentViewRef.textEmptyCallbackHandler =  { (isTextEmpty) in

            self.textChanged?("")
        }
    }
}

extension VideoCell:FeedCallBackProtocol {
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
    
    // comment call back handler to update the comment instantly in feedobject
    func handlingInstantCommentCallback(){
        self.commentViewRef.commentSentInstantlyHandler = {(body) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            let commentObj:Comment = Comment(original_body:body ,body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:false, identifierStr:"")
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
                if feedObjUpdate.comments!.count > 0 {
                    feedObjUpdate.comments![commentCount] = commentObj
                    feedObjUpdate.isPostingNow = true
                    self.feedArray[self.indexValue.row] = feedObjUpdate
                    self.updateTableClosure?(self.indexValue)
                }
            }
        }
    }
}
