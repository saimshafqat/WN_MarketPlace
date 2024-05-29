//
//  VideoClipsVC.swift
//  WorldNoor
//
//  Created by apple on 4/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage

class VideoCollectionViewCell: UICollectionViewCell , AVAudioPlayerDelegate
{
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var lblOriginalText: UILabel!
    @IBOutlet weak var lblCenterText: UILabel!
    
    @IBOutlet weak var viewOriginal: UIView!
    @IBOutlet weak var viewVideoCenter : UIView!
    @IBOutlet weak var viewTranscript : UIView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var imgViewPlaceholder: UIImageView!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    var isVideoPlaying = false
    
    var indexArray = 0
    //    var playingIndex = 0
    var delegate : VideoChooseDelegate!
    var paused: Bool = false
    
    
    var avPlayerController : AVPlayerViewController?
    
    var objMain : Any!
    var videoTranslateUrl = ""
    var videoUrl: String? = nil
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.videoView.addGestureRecognizer(tap)
        self.timeSlider.setThumbImage(UIImage(named: "thumbProgress"), for: .normal)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        
        if self.imgViewPlaceholder.isHidden {
            if self.avPlayerController?.player?.rate == 1.0 {
                self.avPlayerController?.player!.pause()
            }else {
                if self.currentTimeLabel.text == self.durationLabel.text {
                    if self.avPlayerController?.player != nil {
                        self.avPlayerController?.player!.seek(to: CMTime.zero)
                    }
                }
                if self.avPlayerController?.player != nil {
                    if SharedManager.shared.playingVideoIndex == self.indexArray {
                        self.avPlayerController?.player!.play()
                    }
                    
                }
            }
        }
        
    }
    
    func setupMoviePlayer()
    {
        self.addPlayer()
    }
    
    func addPlayer(){
        
        
        self.avPlayerController = AVPlayerViewController()

        if videoUrl == "" {
            return
        }
        let avPlayer = AVPlayer.init(playerItem: AVPlayerItem(url: URL(string: videoUrl!)!))
        avPlayer.volume = 3
        avPlayer.actionAtItemEnd = .none
        avPlayerController?.player = avPlayer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        avPlayerController?.view.frame = self.videoView.bounds
        self.avPlayerController?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.backgroundColor = .clear
        for view in self.videoView.subviews
        {
            if view.tag == 500 {
                
            } else {
                view.removeFromSuperview()
            }
        }
        self.avPlayerController?.showsPlaybackControls = false
        self.videoView.insertSubview(avPlayerController!.view, at: 0)
        self.avPlayerController!.view.bringSubviewToFront(self.videoView)
        self.avPlayerController?.player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        self.viewOriginal.bringSubviewToFront(self.contentView)
        self.viewVideoCenter.bringSubviewToFront(self.contentView)
        self.viewTranscript.bringSubviewToFront(self.contentView)
        if self.avPlayerController?.player != nil {
            if SharedManager.shared.playingVideoIndex == self.indexArray {
                self.avPlayerController?.player!.play()
            }
        }
    }
    
    func reloadView(ObjMainP : Any){
        
        self.viewTranscript.isHidden = true
        self.viewOriginal.isHidden = true
        self.viewVideoCenter.isHidden = true
        self.objMain = ObjMainP
        
        if let newObjMain = ObjMainP as? VideoClipModel {
            if newObjMain.has_speech_to_text == "1" {
                self.viewTranscript.isHidden = false
            }
            if newObjMain.languageVideo.count > 0 {
                self.viewOriginal.isHidden = false
                self.lblOriginalText.text = "View Original".localized()
                self.videoTranslateUrl = newObjMain.path
            }
            if newObjMain.languageSame.count > 0 {
                self.viewOriginal.isHidden = false
            }else {
                self.viewOriginal.isHidden = true
            }
        }else if let newObjMain = ObjMainP as? FeedVideoModel {
            if newObjMain.hasSpeechToText! {
                self.viewTranscript.isHidden = false
            }
        }
        self.setupMoviePlayer()
    }
    
    func stopPlayback()
    {
        self.avPlayerController?.player?.pause()
    }
    
    func startPlayback(){
        if SharedManager.shared.playingVideoIndex == self.indexArray {
            self.avPlayerController?.player?.play()
        }
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        self.avPlayerController?.player?.pause()
        self.delegate.LanguageChoose(videoIndex: self.indexArray)
    }
    
    @IBAction func viewOriginalAction(sender : UIButton){
        if sender.isSelected {
            self.lblOriginalText.text = "View Original".localized()
            sender.isSelected = false
            let avPlayer = AVPlayer.init(playerItem: AVPlayerItem(url: URL(string: videoUrl!)!))
            self.avPlayerController = AVPlayerViewController()
            avPlayer.volume = 3
            avPlayer.actionAtItemEnd = .none
            avPlayerController?.player = avPlayer
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: avPlayer.currentItem)
            avPlayerController?.view.frame = self.videoView.bounds
            
            self.avPlayerController?.videoGravity = AVLayerVideoGravity.resizeAspect
            self.backgroundColor = .clear
            
            for view in self.videoView.subviews
            {
                if view.tag == 500 {
                    
                }else {
                    view.removeFromSuperview()
                }
            }
            self.avPlayerController?.showsPlaybackControls = false
            self.videoView.insertSubview(avPlayerController!.view, at: 0)
            self.avPlayerController!.view.bringSubviewToFront(self.videoView)
            self.avPlayerController?.player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            if SharedManager.shared.playingVideoIndex == self.indexArray {
                self.avPlayerController?.player?.play()
            }
            
        }else {
            
            if videoTranslateUrl.count == 0 {
                self.videoTranslateUrl = self.videoUrl!
            }
            
            self.lblOriginalText.text = "View Translated".localized()
            sender.isSelected = true
            
            self.avPlayerController = AVPlayerViewController()
            let avPlayer = AVPlayer.init(playerItem: AVPlayerItem(url: URL(string: videoTranslateUrl)!))
            
            
            avPlayer.volume = 3
            avPlayer.actionAtItemEnd = .none
            avPlayerController?.player = avPlayer
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: avPlayer.currentItem)
            avPlayerController?.view.frame = self.videoView.bounds
            
            self.avPlayerController?.videoGravity = AVLayerVideoGravity.resizeAspect
            self.backgroundColor = .clear
            
            for view in self.videoView.subviews
            {
                if view.tag == 500 {
                    
                }else {
                    view.removeFromSuperview()
                }
                //                view.removeFromSuperview()
            }
            self.avPlayerController?.showsPlaybackControls = false
            self.videoView.insertSubview(avPlayerController!.view, at: 0)
            
            self.avPlayerController!.view.bringSubviewToFront(self.videoView)
            
            self.avPlayerController?.player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            
            if SharedManager.shared.playingVideoIndex == self.indexArray {
                self.avPlayerController?.player?.play()
            }
            
        }
    }
    
    @IBAction func viewTranscriptAction(sender : UIButton){
        self.delegate.VideoChooseDelegate(videoIndex: self.indexArray, arrayIndex: self.indexArray)
    }
    
    func addTimeObserver() {
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = self.avPlayerController!.player!.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            
            if self!.avPlayerController!.player != nil {
                guard let currentItem = self!.avPlayerController!.player!.currentItem else {return}
                if Float(currentItem.duration.seconds) > 0.0 {
                    self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
                    self?.timeSlider.minimumValue = 0
                    self?.timeSlider.value = Float(currentItem.currentTime().seconds)
                    self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
                    
                    self?.imgViewPlaceholder.isHidden = true
                }
            }
            
        })
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.avPlayerController?.player!.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "duration", let duration = self.avPlayerController!.player?.currentItem?.duration.seconds, duration > 0.0 {
//            self.durationLabel.text = getTimeString(from: (self.avPlayerController?.player?.currentItem!.duration)!)
//        }
//    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    func ReturnValueCheck(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
}
