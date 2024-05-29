//
//  NewVideoPlayerLayerCell.swift
//  WorldNoor
//
//  Created by apple on 6/3/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Foundation
//import EZPlayer

class NewVideoPlayerLayerCell : UITableViewCell {
    
    var feedObj:FeedData? = nil
    var videoPlayerIndexCallback: ((IndexPath) -> Void)?
    var videoUrl: URL!
    var parentView : NewVideoFeedCell!
    var indexPathMain : IndexPath!
    
    var playerSoundValue : Bool = true
    @IBOutlet var indicator : UIActivityIndicatorView!
    
    @IBOutlet var slider : UISlider!
    var timeObserver : Any!
    
    @IBOutlet var videoView : UIView!
    @IBOutlet var imgviewPH : UIImageView!
    @IBOutlet var imgviewPlay : UIImageView!
    @IBOutlet var btnPlay : UIButton!
    @IBOutlet var playView : UIView!
    @IBOutlet var pauseView : UIView!
    
    @IBOutlet var lblTime : UILabel!
    
    @IBOutlet var lblProcessing : UILabel!
    
    @IBOutlet var tblViewMain : UITableView!
    var isPlaying = false
    override func awakeFromNib() {
        
    }
    
    
    func resetVideo(feedObjp : FeedData ){
        indicator.isHidden = true
        self.imgviewPH.isHidden = false
        self.lblTime.text = ""
        self.lblTime.text = "00:00"
        self.imgviewPlay.isHidden = false
        self.btnPlay.isHidden = false
        for indexObj in SharedManager.shared.playerArray {
            indexObj.pause()
        }
        
        self.lblProcessing.isHidden = true
        
        self.feedObj = feedObjp
        
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            
            if postFile.processingStatus != "done" {
                self.lblProcessing.isHidden = false
            }
            
            if postFile.convertedURL.count > 0 {
                self.videoUrl = URL(string: postFile.convertedURL)
            }else
            {
                self.videoUrl = URL(string: postFile.filePath ?? "")
            }
            
            self.imgviewPH.loadImageWithPH(urlMain: postFile.thumbnail!)
        }
    }
    
    
    @IBAction func downloadImage(sender : UIButton){
        
        let postFile:PostFile = self.feedObj!.post![0]
        
        UIApplication.topViewController()!.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true , FeedObj: self.feedObj!)
    }

    
    @IBAction func playAudio(sender : UIButton){
        
        self.imgviewPlay.isHidden = true
        self.btnPlay.isHidden = true
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            if postFile.processingStatus != "done" {
                return
            }
        }
        self.isPlaying = true
        var boolValue : Bool = false
//        if UIApplication.topViewController() as? WatchFullScreenVC != nil {
//            boolValue = self.playerSoundValue
//            MediaManager.sharedInstance.player?.isHideSound = self.playerSoundValue
//        }else {
            boolValue = false
            MediaManager.sharedInstance.player?.isHideSound = false
//        }
        
        
        SocketSharedManager.sharedSocket.playVideoSocket(postID: String(self.feedObj!.postID!))
        MediaManager.sharedInstance.playEmbeddedVideo(url: self.videoUrl, embeddedContentView: self.videoView,userinfo: ["isHideSound" : boolValue])
        MediaManager.sharedInstance.player?.indexPath = indexPathMain
        MediaManager.sharedInstance.player?.floatMode = .none
        MediaManager.sharedInstance.player?.scrollView = self.tblViewMain
        
        self.btnPlay.isHidden = true
        self.imgviewPlay.isHidden = true
        
        MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
//            LogClass.debugLog("callbackPH ===> 44")
//            LogClass.debugLog(indexRow)
//            LogClass.debugLog(urlString)
//            self.imgviewPH.isHidden = true
            
            self.btnPlay.isHidden = false
            self.imgviewPlay.isHidden = false
            
            
            MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.white
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
            if boolValue {
                MediaManager.sharedInstance.player?.player?.volume = 1.0
            }else {
                MediaManager.sharedInstance.player?.player?.volume = 0.0
            }
        }
    }
    
    @IBAction func pauseAudio(sender : UIButton) {
        if self.indexPathMain == MediaManager.sharedInstance.player?.indexPath {
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
            self.isPlaying = false
            LogClass.debugLog("Release player 7")
            self.imgviewPH.isHidden = false
            self.imgviewPlay.isHidden = false
            self.btnPlay.isHidden = false
        }
    }
}

