//
//  VideoView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVKit

protocol VideoPlayingViewProtocol  {
    func playVideoForCell(with indexPath : IndexPath)
}

class VideoView: ParentFeedView {
    @IBOutlet weak var videoImgView: UIImageView!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var videoActualView: UIView!
    @IBOutlet weak var viewTranscriptBtn: UIButton!
    @IBOutlet weak var viewOgrinalLangBtn: UIButton!
    @IBOutlet weak var origTransBarView: UIView!
    @IBOutlet weak var origTransBarHeightConst: NSLayoutConstraint!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var uploadedLangLbl: UILabel!
    
    var muteObservation: NSKeyValueObservation?

    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var currentIndex = IndexPath()
    var mainIndex = IndexPath()
    var timeObserverToken: Any?
    var isAppearFrom:String = ""
    var isPartOf:String = ""
    var videoUrl: URL!
    var playerController : AVPlayerViewController? = nil
    var postObj:PostFile?
    var feedObj:FeedData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func removeViewFRomParent(){
        if playerController != nil {
            if self.playerController?.player != nil {
                self.playerController?.player?.pause()
                self.playerController?.player = nil
                
            }
        }
    }
    
    func manageVideoData(feedObj:FeedData, shouldPlay:Bool, isShowTranslated:Bool = true) {
        self.videoImgView.isHidden = false
        self.dropDownBtn.isHidden = true
        self.origTransBarHeightConst.constant = 30
        self.feedObj = feedObj
        if feedObj.postType == FeedType.liveStream.rawValue {
            
            self.videoImgView.loadImageWithPH(urlMain:feedObj.liveThumbUrlStr ?? "")
            
            self.labelRotateCell(viewMain: self.videoImgView)
            self.videoUrl = URL(string: feedObj.liveUrlStr!)
            self.manageVideo(shouldPlay: shouldPlay)
            self.viewOgrinalLangBtn.isHidden = true
        }
        else if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
            if let thumbnailUrl = postFile.thumbnail {
                if thumbnailUrl != "" {
                    
                    self.videoImgView.loadImageWithPH(urlMain:thumbnailUrl)
                    
                    self.labelRotateCell(viewMain: self.videoImgView)
                }
            }
            if postFile.processingStatus != "done".localized() {
                self.uploadedLangLbl.text = "Processing the video.".localized()
            }else {
                self.uploadedLangLbl.text = String(format: "Uploaded in:".localized() + " %@", postFile.uploadedLang ?? "")
            }
            self.handleOrignalAndTranscriptBtn(postObj: postFile, isShowTranslated: isShowTranslated)
            self.manageVideo(shouldPlay: shouldPlay)
        }
        
        
        self.labelRotateCell(viewMain: self.uploadedLangLbl)
        self.labelRotateCell(viewMain: self.viewTranscriptBtn)
        self.labelRotateCell(viewMain: self.viewOgrinalLangBtn)
        self.viewOgrinalLangBtn.rotateForTextAligment()
        self.uploadedLangLbl.rotateForTextAligment()
        self.viewTranscriptBtn.rotateForTextAligment()
        
        
        muteObservation = self.playerController?.player?.observe(\.isMuted) { player, _ in
            LogClass.debugLog("playerController  isMuted: \(player.isMuted)")
                }
    }
    
    func manageVideoDataToUpload(videoUrl:String, shouldPlay:Bool) {
        self.videoImgView.isHidden = false
        self.dropDownBtn.isHidden = true
        self.viewOgrinalLangBtn.isHidden = true
        self.viewTranscriptBtn.isHidden = true
        self.videoUrl = URL(fileURLWithPath: videoUrl)
        self.origTransBarHeightConst.constant = 0
        self.manageVideo(shouldPlay: shouldPlay)
    }
    
    func manageVideoDataPost(postObj:PostFile, shouldPlay:Bool, isShowTranslated:Bool = true) {
        self.videoImgView.isHidden = false
        self.dropDownBtn.isHidden = true
        self.origTransBarHeightConst.constant = 30
        self.postObj = postObj
        self.viewTranscriptBtn.isHidden = true
        self.viewOgrinalLangBtn.isHidden = true
        self.handleOrignalAndTranscriptBtn(postObj: self.postObj!, isShowTranslated: isShowTranslated)
        
        self.videoImgView.loadImageWithPH(urlMain:postObj.thumbnail ?? "")
        
        self.labelRotateCell(viewMain: self.videoImgView)
        if postObj.processingStatus != "done".localized() {
            self.uploadedLangLbl.text = "Processing the video.".localized()
        }else {
            self.uploadedLangLbl.text = String(format: "Uploaded in:".localized() + " %@", postObj.uploadedLang ?? "")
        }
        self.manageVideo(shouldPlay: shouldPlay)
        
        
        muteObservation = self.playerController?.player?.observe(\.isMuted) { player, _ in
                }
    }
    
    func manageVideo(feedObj:FeedData, shouldPlay:Bool, isShowTranslated:Bool = true) {
        self.videoImgView.isHidden = false
        self.viewTranscriptBtn.isHidden = true
        self.viewOgrinalLangBtn.isHidden = true
        
        if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
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
                    self.videoImgView.loadImageWithPH(urlMain:thumbnailUrl)
                    
                    self.labelRotateCell(viewMain: self.videoImgView)
                }
            }
            if postFile.processingStatus != "done".localized() {
                self.uploadedLangLbl.text = "Processing the video.".localized()
            }else {
                self.uploadedLangLbl.text = String(format: "Uploaded in: %@", postFile.uploadedLang ?? "")
            }
            if  postFile.isSpeechExist! == 1{
                self.viewTranscriptBtn.isHidden = false
                if  postFile.filetranslationlink != nil {
                    self.viewOgrinalLangBtn.isHidden = false
                }else {
                    self.viewOgrinalLangBtn.isHidden = true
                }
            }
            self.videoImgView.loadImageWithPH(urlMain:postFile.thumbnail ?? "")
            
            self.labelRotateCell(viewMain: self.videoImgView)
            self.manageVideo(shouldPlay: true)
        }
    }

    @IBAction func viewOrignalBtnClicked(_ sender: Any) {
        if ((self.isAppearFrom == "FeedDetail")||(self.isAppearFrom == "SharedView") || (self.isAppearFrom == "Feed"))  && self.isPartOf != "Gallery"  {
            self.viewOgrinalLangBtn.isSelected = !self.viewOgrinalLangBtn.isSelected
            if self.viewOgrinalLangBtn.isSelected {
                self.manageVideo(feedObj: self.feedObj!, shouldPlay: true, isShowTranslated: false)
            }else {
                self.manageVideo(feedObj: self.feedObj!, shouldPlay: true)
            }
        }
    }
    
    func handleOrignalAndTranscriptBtn(postObj:PostFile, isShowTranslated:Bool){

        if isShowTranslated {
            if postObj.convertedURL.count > 0 {
                self.videoUrl = URL(string: postObj.convertedURL)
                self.viewOgrinalLangBtn.isHidden = false
            }else {
                self.videoUrl = URL(string: postObj.filePath ?? "")
                self.viewOgrinalLangBtn.isHidden = true
            }
        }else {
            if let orignalString = postObj.filePath {
                self.videoUrl = URL(string:orignalString)
            }
        }
        if let speechExist = postObj.isSpeechExist {
            if speechExist == 1{
                self.viewTranscriptBtn.isHidden = false
                if  postObj.filetranslationlink != nil {
                    self.viewOgrinalLangBtn.isHidden = false
                }else {
                    self.viewOgrinalLangBtn.isHidden = true
                }
            }
        }
    }
    
    func addTitleToDropDownBtn(name:String){
        self.dropDownBtn.setTitle(name, for: .normal)
    }
    
    func manageVideoDataComment(comment:CommentFile, shouldPlay:Bool) {
        self.origTransBarHeightConst.constant = 0
        self.viewTranscriptBtn.isHidden = true
        self.viewOgrinalLangBtn.isHidden = true
        self.dropDownBtn.isHidden = true
        if ((comment.url?.isValidForUrl())!) {
            self.videoUrl = URL(string: comment.url ?? "")
        }else {
            if (comment.url != ""){
                self.dropDownBtn.isHidden = true
                self.videoUrl = URL(fileURLWithPath: (comment.url!))
            }
        }
        if comment.languageID != nil {
            self.uploadedLangLbl.text = String(format:"Uploaded in:".localized() + " %@",SharedManager.shared.getLanguageName(id: String(comment.languageID!)))
        }
        
        self.videoImgView.image = UIImage.init(named: "placeholderBlack.png")
        
        self.labelRotateCell(viewMain: self.videoImgView)
        self.manageVideo(shouldPlay: shouldPlay)
    }
    
    func manageVideo(shouldPlay:Bool){
        if true {
            if self.videoUrl == nil {
                return
            }
            
            let playerItem = AVPlayerItem(url: self.videoUrl)
            let player = AVPlayer(playerItem: playerItem)
            if self.playerController == nil {
                playerController = AVPlayerViewController()
            }
            //pLayer.videoGravity = .resizeAspect
            //self.avPlayerController?.videoGravity = AVLayerVideoGravity.resizeAspect
//            player.isMuted = SharedManager.shared.isWatchMuted
            playerController!.player = player
            playerController!.videoGravity = .resizeAspectFill
            playerController?.showsPlaybackControls = true
            playerController?.delegate = self
            if isAppearFrom == "Gallery" {
                if self.postObj?.videoSeekTime != nil {

                    self.playerController?.player?.seek(to:CMTime(seconds: self.postObj!.videoSeekTime!, preferredTimescale: 1))
                    if shouldPlay == true {
                        if self.currentIndex == SharedManager.shared.currentIndex {
                            SharedManager.shared.timerMain = nil
                            SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                                self.playerController!.player!.play()
                        }
                    }
                }else {
                    if shouldPlay == true {
                        if self.currentIndex == SharedManager.shared.currentIndex {
                            SharedManager.shared.timerMain = nil
                            SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                            self.playerController!.player!.play()
                        }
                    }
                }
            }else if isAppearFrom == "Gallery" {
                if self.feedObj?.sharedData!.videoSeekTime != nil {
                    self.playerController?.player?.seek(to:CMTime(seconds: self.feedObj!.sharedData!.videoSeekTime!, preferredTimescale: 1))
                    
                    
                    if shouldPlay == true {
                        if self.currentIndex == SharedManager.shared.currentIndex {
                            SharedManager.shared.timerMain = nil
                            SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                            self.playerController!.player!.play()
                        }
                    }
                }
            }
            else {
                if self.feedObj?.videoSeekTime != nil {
                    self.playerController?.player?.seek(to:CMTime(seconds: self.feedObj!.videoSeekTime!, preferredTimescale: 1))
                    if shouldPlay == true {
                        if self.currentIndex == SharedManager.shared.currentIndex {
                            SharedManager.shared.timerMain = nil
                            SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                            self.playerController!.player!.play()
                        }

                    }
                }
            }
        }
        else {
            if self.playerController != nil {
                self.playerController!.player?.pause()
                self.playerController!.player = nil
            }
        }
        self.videoActualView.addSubview(self.playerController!.view)
        self.playerController?.view.frame = self.videoActualView.frame
        self.playerController?.view.backgroundColor = .clear
    }
    
    @objc func videoPlayer(){
        if self.playerController?.player != nil {
            if (self.playerController?.player!.rate)! > 0.0 {
                
                if SharedManager.shared.timerMain != nil {
                    SharedManager.shared.timerMain.invalidate()
                }
                self.videoImgView.isHidden = true
            }
        }else {
            SharedManager.shared.timerMain.invalidate()
        }
        
    }
    
    
    @IBAction func videoPlayButtonClicked(_ sender: Any) {
        if playerController?.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing {
            playerController?.player?.pause()
        }else if playerController?.player?.timeControlStatus == AVPlayer.TimeControlStatus.paused {
            
            if self.currentIndex == SharedManager.shared.currentIndex {
                SharedManager.shared.timerMain = nil
                SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                self.playerController!.player!.play()
            }

            if self.isPartOf == "Gallery" {
                self.addPeriodicTimeObserver()
            }
        }else {
            if self.playerController?.player?.currentItem == nil {
                if self.videoUrl != nil {
                    let player = AVPlayer(url: self.videoUrl)
                    playerController!.player = player
                    playerController?.showsPlaybackControls = true
                    playerController?.delegate = self

                    
                    if self.currentIndex == SharedManager.shared.currentIndex {
                        SharedManager.shared.timerMain = nil
                        SharedManager.shared.timerMain = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(videoPlayer), userInfo: nil, repeats: true)
                        self.playerController!.player!.play()
                    }

                    if self.isAppearFrom == "Gallery" {
                        self.addPeriodicTimeObserver()
                    }
                }
            }
        }
    }
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = self.playerController?.player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            if self.isAppearFrom == "Feed" {
                FeedCallBManager.shared.updateVideoViewSeekTimeForNewsFeedHandler?(self.mainIndex, self.currentIndex, time.seconds)
            }else if self.isAppearFrom == "FeedDetail" {
                FeedCallBManager.shared.updateVideoViewSeekTimeForNewsFeedHandler?(self.mainIndex, self.currentIndex, time.seconds)
            }
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.playerController?.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func resetVideoPlayer() {
        if self.playerController?.player != nil {
            self.playerController!.player?.pause()
            self.playerController!.player = nil
        }
        self.removePeriodicTimeObserver()
        
    }
}

extension VideoView: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { transitionContext in
            self.playerController!.player?.play()
        }
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController,willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { transitionContext in
            self.playerController!.player?.play()
        }
    }
    
    
    func isPlayerReady(_ player:AVPlayer?) -> Bool {

        guard let player = player else { return false }

        let ready = player.status == .readyToPlay

        let timeRange = player.currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false } // Fail when loadedTimeRanges is empty
        let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
        let loaded = timeLoaded > 0

        return ready && loaded
    }
}


extension AVPlayer {
    var ready:Bool {
        let timeRange = currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
        let loaded = timeLoaded > 0

        return status == .readyToPlay && loaded
    }
}
