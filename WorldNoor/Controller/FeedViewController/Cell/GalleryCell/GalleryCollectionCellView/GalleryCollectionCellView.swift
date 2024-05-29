//
//  GalleryCollectionCellView.swift
//  WorldNoor
//
//  Created by Waseem Shah on 24/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit


class GalleryCollectionCellView: UIView {
    @IBOutlet weak var bgView: UIView!
    var postObj:PostFile? = nil
    var singleImageView:SingleImageView? = nil
    var videoView:VideoView? = nil
    var audioView:AudioView? = nil
    var mainIndex = IndexPath()
    var currentIndex = IndexPath()
    var isAppearFrom = ""
    
    override func awakeFromNib() {
        
    }
    
    func addImageView(){
        self.singleImageView?.removeFromSuperview()
        self.singleImageView = (Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView)

        self.singleImageView?.manageImageData(postObj: self.postObj!)
        
        self.bgView.addSubview(self.singleImageView!)
        self.singleImageView?.btnDownload.addTarget(self, action: #selector(self.downloadFile), for: .touchUpInside)
        self.singleImageView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
    func addVideoView() {
        guard let postObj = self.postObj,
              let postID = postObj.postID,
              let filePathString = postObj.filePath,
              let filePathURL = URL(string: filePathString) else {
            // Handle the case where any of the required properties are nil
            print("One or more required properties are nil")
            return
        }
        
        MediaManager.sharedInstance.player?.isHideSound = false
        
        SocketSharedManager.sharedSocket.playVideoSocket(postID: String(postID))
        MediaManager.sharedInstance.playEmbeddedVideo(url: filePathURL, embeddedContentView: self, userinfo: ["isHideSound": true, "hideControl": true])
        MediaManager.sharedInstance.player?.indexPath = self.currentIndex
        
        LogClass.debugLog("self.currentIndex   self.currentIndex")
        LogClass.debugLog(self.currentIndex)
        MediaManager.sharedInstance.player?.floatMode = .none
        MediaManager.sharedInstance.player?.scrollView = nil
        MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
            LogClass.debugLog("callbackPH ===> 55")
            MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.white
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Ensure that MediaManager.sharedInstance.player is not nil before accessing its player
            MediaManager.sharedInstance.player?.player?.volume = 0.0
        }
    }

    
    @objc func downloadFile(){
        if isAppearFrom == "Feed" {
            FeedCallBManager.shared.downloadShareFile?(self.mainIndex , self.currentIndex)
        }
    }
    
    @objc func viewTranscriptBtnClicked(){

    }
    
    @objc func viewOrignalBtnClicked(){
        self.videoView?.viewOgrinalLangBtn.isSelected = !(self.videoView?.viewOgrinalLangBtn.isSelected)!
        if (self.videoView?.viewOgrinalLangBtn.isSelected)! {
            self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true, isShowTranslated: false)
        }else {
            self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true)
        }
    }
    
    func addAudioView(){
        self.audioView?.removeFromSuperview()
        self.audioView = (Bundle.main.loadNibNamed(Const.audioView, owner: self, options: nil)?.first as! AudioView)
        self.audioView?.manageAudio(postObj: self.postObj!)
        self.bgView.addSubview(self.audioView!)
        self.audioView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
    func resizeImageView(){
        
    }
    
    func managePostData(postObj:PostFile, mainIndex:IndexPath, currentIndex:IndexPath, isAppearFrom:String){
        self.postObj = postObj
        self.isAppearFrom = isAppearFrom
        self.mainIndex = mainIndex
        self.currentIndex = currentIndex
        if postObj.fileType == FeedType.image.rawValue {
            self.addImageView()
            self.videoView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
        }else if postObj.fileType == FeedType.video.rawValue {
            self.singleImageView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
            self.addImageView()
//            self.addVideoView()
            
        }else if postObj.fileType == FeedType.audio.rawValue {
            self.singleImageView?.removeFromSuperview()
            self.videoView?.removeFromSuperview()
            self.addAudioView()
        }else if postObj.fileType == FeedType.file.rawValue {
            self.addImageView()
            self.videoView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
        }
    }
    
    func stopPlayingVideo(){
        if self.videoView != nil {
            if self.videoView?.playerController != nil {
                self.videoView?.playerController?.player?.pause()
            }
        }
    }
    
    func stopPlayingAudio(){
        if self.audioView != nil {
            if self.audioView?.xqAudioPlayer != nil {
                if self.audioView?.xqAudioPlayer.audioPlayer != nil {
                    self.audioView?.xqAudioPlayer?.audioPlayer!.pause()
                }
            }
        }
    }
    
    func manageSingleImageRemove(){
        self.singleImageView?.removeFromSuperview()
    }
}


