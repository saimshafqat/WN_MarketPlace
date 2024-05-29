//
//  MediaManager.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
class MediaManager {
    var player: EZPlayer?
    var mediaItem: MediaItem?
    var embeddedContentView: UIView?
    var playingTimeInfo: [String: Float]?
    
    static let sharedInstance = MediaManager()
    private init(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackDidFinish(_:)), name: .EZPlayerPlaybackDidFinish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerStatusDidChange(_:)), name: .EZPlayerStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackSeekTimeUpdate(_:)), name: .EZPlayerPlaybackTimeDidChange, object: nil)
    }
    
    func playEmbeddedVideo(url: URL, embeddedContentView contentView: UIView? = nil, userinfo: [AnyHashable : Any]? = nil) {
        var mediaItem = MediaItem()
        mediaItem.url = url
        self.playEmbeddedVideo(mediaItem: mediaItem, embeddedContentView: contentView, userinfo: userinfo )
    }
    
    func playEmbeddedVideo(mediaItem: MediaItem, embeddedContentView contentView: UIView? = nil , userinfo: [AnyHashable : Any]? = nil ) {
        //stop
        self.releasePlayer()
        
        if let skinView = userinfo?["skin"] as? UIView{
            self.player =  EZPlayer(controlView: skinView)
        }else{
            self.player = EZPlayer()
        }
        
        if let boolValue = userinfo?["isHideSound"] as? Bool{
            self.player!.checkSound(boovalue: boolValue)
            if boolValue {
                self.player?.player?.volume = 1.0
            }else {
                self.player?.player?.volume = 0.0
            }
        }
        self.player?.autohiddenTimeInterval = 5.0
        
        if let autoPlay = userinfo?["autoPlay"] as? Bool{
            self.player!.autoPlay = autoPlay
        }
        
        if let autoPlay = userinfo?["hideControl"] as? Bool{
            self.player!.isShowCotrol = autoPlay
        }
        
        
        if let floatMode = userinfo?["floatMode"] as? EZPlayerFloatMode{
            self.player!.floatMode = floatMode
        }
        
        if let fullScreenMode = userinfo?["fullScreenMode"] as? EZPlayerFullScreenMode{
            self.player!.fullScreenMode = fullScreenMode
        }
        
        self.player!.backButtonBlock = { fromDisplayMode in
            if fromDisplayMode == .embedded {
                self.releasePlayer()
            }else if fromDisplayMode == .fullscreen {
                if self.embeddedContentView == nil && self.player!.lastDisplayMode != .float{
                    self.releasePlayer()
                }
                
            }else if fromDisplayMode == .float {
                if self.player!.lastDisplayMode == .none{
                    self.releasePlayer()
                }
            }
        }
        
        self.embeddedContentView = contentView
        let url: URL? = (self.player!.player?.currentItem?.asset as? AVURLAsset)?.url
        self.player!.playWithURL(mediaItem.url! , embeddedContentView: self.embeddedContentView)
        if let url = mediaItem.url?.absoluteString, let timeInfo = MediaManager.sharedInstance.playingTimeInfo?[url]{
//            self.player?.seek(to: TimeInterval(timeInfo))
        }
        self.player?.canSlideProgress = false
    }
    
    func releasePlayer(){
        
        self.player?.stop()
        self.player?.view.removeFromSuperview()
        
        self.player = nil
        self.embeddedContentView = nil
        self.mediaItem = nil
        
    }
    
    @objc  func playerStatusDidChange(_ notifiaction: Notification) {
        
    }
    
    @objc  func playbackDidFinish(_ notifiaction: Notification) {
        
    }
    
    @objc  func playbackSeekTimeUpdate(_ notifiaction: Notification) {
        guard let urlStr = (self.player!.player?.currentItem?.asset as? AVURLAsset)?.url.absoluteString else {
            return
        }
        
        guard let currentTime = self.player?.currentTime else {
            return
        }
        
        if MediaManager.sharedInstance.playingTimeInfo == nil {
            MediaManager.sharedInstance.playingTimeInfo = [urlStr: Float(currentTime)]
        }else{
            MediaManager.sharedInstance.playingTimeInfo?.updateValue(Float(currentTime), forKey: urlStr)
        }
    }
    
    
}


struct MediaItem {
    var url: URL?
    var title: String?
}
