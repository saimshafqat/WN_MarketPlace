//
//  NewVideoPlayCell.swift
//  WorldNoor
//
//  Created by apple on 4/19/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class NewVideoPlayCell : UITableViewCell {
    
    @IBOutlet var btnPlay : UIButton!
    @IBOutlet var videoView : UIView!
    @IBOutlet var imgViewPlay : UIImageView!
    @IBOutlet var imgViewPH : UIImageView!
    var indexPathMain : IndexPath!
    
    var feedObj:FeedData? = nil
    var videoPlayerIndexCallback: ((IndexPath) -> Void)?
    var playerController : AVPlayerViewController? = nil
    var videoUrl: URL!
    var timeObserverToken: Any?
    var player = AVPlayer()
    
    
    var parentView : NewVideoFeedCell!
    override func awakeFromNib() {
        
        
        for indexobj in self.videoView.subviews {
            indexobj.removeFromSuperview()
        }
        self.playerController = AVPlayerViewController()
        self.playerController?.showsPlaybackControls = false
        self.videoView.addSubview(self.playerController!.view)
        self.playerController?.view.frame = self.videoView.frame
        
        self.addObserver()
    }
    
    
    @IBAction func downloadImage(sender : UIButton){
        
        let postFile:PostFile = self.feedObj!.post![0]
        
        UIApplication.topViewController()!.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true , FeedObj: self.feedObj!)
    }
    
    
    func addObserver(){

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    
    @objc func playerDidFinishPlaying(){
        self.playerController!.player!.seek(to: CMTime.zero)

    }
    
    func stopPlayer(){
        if self.playerController != nil {
            if self.playerController!.player != nil {
                self.playerController!.player!.pause()
            }
        }
        
    }
    
    func resetVideo(feedObjp : FeedData ){
        self.feedObj = feedObjp
        
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            
            if postFile.convertedURL.count > 0 {
                self.videoUrl = URL(string: postFile.convertedURL)
            }else
            {
                self.videoUrl = URL(string: postFile.filePath ?? "")
            }
        
            self.imgViewPH.loadImageWithPH(urlMain: postFile.thumbnail!)
            
            if self.videoUrl != nil {
                self.player = AVPlayer(url: self.videoUrl)
                self.playerController!.player = player
                self.playerController?.view.backgroundColor = .clear
                
                
            }
        }
    }
    
    
    
     func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
         if player.currentItem?.status == AVPlayerItem.Status.readyToPlay {

        }
    }
    
    @IBAction func playAction(sender : UIButton){
            
            
//            for indexObj in (self.parentView.parentView as! WatchFullScreenVC).saveTableView.visibleCells {
//                if indexObj is NewVideoFeedCell {
//                    if (indexObj as! NewVideoFeedCell).postObj.postID == self.feedObj?.postID {
//                        
//                    }else {
//                        let cell = indexObj as! NewVideoFeedCell
//                        cell.stopPlayer()
//                    }
//                }
//            }
            
            
            if self.playerController!.player!.rate != 0  {
                self.imgViewPlay.isHidden = false
                self.playerController!.player!.pause()
            } else {
                self.imgViewPlay.isHidden = true
//                if self.parentView.parentView != nil {
//                    if let parentVC = self.parentView.parentView as? WatchFullScreenVC {
//                        let visibleCell = parentVC.saveTableView.visibleCells
//                        for indexObj in visibleCell {
//                            if indexObj is NewVideoFeedCell {
//                                (indexObj as! NewVideoFeedCell).stopPlayer()
//                            }
//                        }
//                    }
//                }
                self.playerController!.player!.play()
            }

    }
    
    
}
