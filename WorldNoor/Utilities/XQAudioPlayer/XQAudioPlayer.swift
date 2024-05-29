//
//  XQAudioPlayer.swift
//  AudioPlayer
//
//  Created by PaditechDev1 on 9/15/16.
//  Copyright © 2016 PaditechDev1. All rights reserved.
//

import UIKit
import AVFoundation

enum AVPlayerState {
    case Playing
    case Paused
    case Reserved
    case Unknown
}

@objc protocol XQAudioPlayerDelegate: class {
    
    /* Player did updated duration time
     * You can get duration time of audio in here
     */
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime)
    
    /* Player did change time playing
     * You can get current time play of audio in here
     */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime)
    
    // Player begin start
    func playerDidStart(player: XQAudioPlayer)
    
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer)
    
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer)
    
}

class XQAudioPlayer: UIView {
    
    // MARK: - Variable
    var state: AVPlayerState = .Unknown
    var audioPlayer:AVPlayer? = nil
//    var currentAudioPath:NSURL!
    var delegate : XQAudioPlayerDelegate!
    var progressView: UIView!
    var timer = Timer()
    var audioURLString:String = ""
    var isLocal:String = ""
    
    @IBOutlet weak var audioBgOvalView: DesignableView!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var playerProgressSlider : XQSlider!
    @IBOutlet var timeLabel : UILabel!
    
    deinit {
        if self.audioPlayer?.observationInfo != nil {
            self.audioPlayer!.pause()
            self.audioPlayer!.removeObserver(self, forKeyPath: "rate")
        }
    }
    
//    var progressWidth: CGFloat!
    var progressColor: UIColor! {
        get {
            return self.playerProgressSlider.minimumTrackTintColor
        }
        
        set (newColor) {
            self.playerProgressSlider.minimumTrackTintColor = newColor
        }
    }
    
    var progressBackgroundColor: UIColor! {
        get {
            return self.playerProgressSlider.maximumTrackTintColor
        }
        set (newColor) {
            self.playerProgressSlider.maximumTrackTintColor = newColor
        }
    }
    
//    var timeLabelColor: UIColor! {
//        get {
//            return self.timeLabel.textColor
//        }
//        
//        set (newColor) {
//            self.timeLabel.textColor = newColor
//        }
//    }
    
//    var thumbColor: UIColor {
//        get {
//            return self.playerProgressSlider.thumbTintColor!
//        }
//        set (newColor) {
//            self.playerProgressSlider.thumbTintColor = newColor
//        }
//    }
    
    var playingImage: UIImage! {
        get {
            return  UIImage(named: Const.KPauseImg)
        }
        set (newImage) {
            
        }
    }
    
    var pauseImage: UIImage! {
        get {
            return UIImage(named: Const.KPlayerPlayImg)
        }
        
        set (newImage) {
            
        }
    }
    
    override class func awakeFromNib() {
        
    }
    
    //MARK: Init
    func config(urlString: String) {
        if self.audioPlayer?.currentItem != nil{
            self.audioPlayer = AVPlayer()
        }
        playButton.setImage(self.pauseImage, for:.normal)
        //Init sliderbar Button
        self.playerProgressSlider.value = 0.0
        self.playerProgressSlider.tintColor = UIColor.clear
        self.playerProgressSlider.backgroundColor = UIColor.clear
        self.playerProgressSlider.addTarget(self, action: #selector(self.sliderValueDidChange), for: .valueChanged)
        self.playerProgressSlider.setThumbImage(UIImage(named: "thumbProgress"), for: .normal)
        self.timeLabel.textColor = UIColor.lightGray
        self.timeLabel.textAlignment = .center
        // self.timeLabel.text = "--:--"
        AudioUtility.getAudioDuration(from: urlString) { duration, error in
            if let duration = duration {
                self.timeLabel.text = duration.durationText
            } else {
                self.timeLabel.text = "00:00"
            }
        }
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.audioURLString = urlString
//        self.labelRotateCell(viewMain: self.timeLabel)
//        self.timeLabel.rotateForTextAligment()
    }
    
    func manageProgressUI(){
        self.progressColor = UIColor.progressSliderColor
        self.progressBackgroundColor = UIColor.white
        self.playingImage = UIImage(named:Const.KPauseImg)
        self.pauseImage = UIImage(named:Const.KPlayerPlayImg)
    }
    
    func preparePlayer(){
        self.playButton.setImage(self.playingImage, for: .normal)
//        if self.isLocal.count == 0 {
            var asset = AVAsset(url: NSURL(fileURLWithPath: self.audioURLString) as URL)
            if self.audioURLString.isValidForUrl() {
                asset = AVAsset(url: NSURL(string:self.audioURLString)! as URL)
            }
        
        
            let keys: [String] = ["playable"]
            self.audioPlayer = XQAudioPlayerManager.shared.audioPlayer
            asset.loadValuesAsynchronously(forKeys: keys) {
                DispatchQueue.main.async {
                    let item = AVPlayerItem(asset: asset)
                    if self.audioPlayer != nil {
                    XQAudioPlayerManager.shared.configureSharedAudio(playerItem: item)
                    self.audioPlayer = XQAudioPlayerManager.shared.audioPlayer
                    self.audioPlayer!.rate = 1;
                    self.audioPlayer!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
                    self.audioPlayer!.play()
                    }
                }
            }
        
    }
    
    // MARK: - Button action
    @IBAction func playButtonAction(sender : AnyObject) {
        if self.audioPlayer == nil {
            self.preparePlayer()
        } else {
        if state == .Playing {
            self.audioPlayer!.pause()
        } else {
            if(self.audioPlayer?.currentItem?.currentTime().durationText == self.audioPlayer?.currentItem?.asset.duration.durationText) {
                self.audioPlayer?.seek(to: CMTime.zero)
            }
            self.audioPlayer!.play()
            }
        }
    }
    
    @objc func sliderValueDidChange(sender:UISlider!)
    {
        if self.audioPlayer?.currentItem != nil {
            let seekTime = CMTimeMakeWithSeconds(Double(sender.value) * CMTimeGetSeconds(self.audioPlayer!.currentItem!.asset.duration), preferredTimescale: 1)
            self.audioPlayer!.seek(to: seekTime)
        }
    }
    
    //MARK: Set progress value
//    func setProgress(value: CGFloat) {
//        if value < 0.0 || value > 1.0 {
//            return
//        } else {
//            var frame = self.progressView.frame
//            frame.size.width = value * self.progressWidth
//            self.progressView.frame = frame
//        }
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" {
            if let rate = change?[NSKeyValueChangeKey.newKey] as? Float {
                if rate == 0.0 {
                    if self.delegate != nil {
                        self.delegate.playerDidStoped(player: self)
                    }
                    self.cancelTimer()
                    state = .Paused
                    self.playButton.setImage(self.pauseImage, for: .normal)
                }
                if rate == 1.0 {
                    if self.delegate != nil {
                        self.delegate.playerDidStart(player: self)
                        self.delegate.playerDidUpdateDurationTime(player: self, durationTime: (self.audioPlayer?.currentItem?.asset.duration)!)
                    }
                    self.startTimer()
                    state = .Playing
                    self.playButton.setImage(self.playingImage, for: .normal)
                }
                
                if rate == -1.0 {
                    state = .Reserved
                    self.playButton.setImage(self.pauseImage, for: .normal)
                }
            }
        }
    }
    
    // MARK: - Timer update status of player
    func startTimer() {
        timer.invalidate()
        // just in case this button is tapped multiple times
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    // stop timer
    func cancelTimer() {
        timer.invalidate()
    }
    
    // MARK: - New timer action -
    @objc func timerAction() {
        if self.audioPlayer?.currentItem == nil {
            self.cancelTimer()
            return
        }
        // Use the current time directly
        let currentTime = CMTimeGetSeconds(self.audioPlayer!.currentTime())
        self.timeLabel.text = CMTimeMakeWithSeconds(currentTime, preferredTimescale: 1).durationText

        // Update the slider based on the current time
        let rate = Float(currentTime / CMTimeGetSeconds(self.audioPlayer!.currentItem!.asset.duration))
        self.playerProgressSlider.setValue(rate, animated: false)

        // Call delegate for finish playing
        if CMTimeGetSeconds(self.audioPlayer!.currentItem!.asset.duration) - currentTime < 1 && self.delegate != nil {
            self.playerProgressSlider.setValue(rate+1, animated: false)
            self.delegate.playerDidFinishPlaying(player: self)
        }

        // Call delegate for update current time
        if self.delegate != nil {
            self.delegate.playerDidUpdateCurrentTimePlaying(player: self, currentTime: self.audioPlayer!.currentItem!.currentTime())
        }
    }

    
    func resetXQPlayer() {
        self.cancelTimer()
        state = .Paused
        self.audioPlayer?.pause()
        if self.audioPlayer?.observationInfo != nil {
        self.audioPlayer?.removeObserver(self, forKeyPath: "rate")
        }
        self.audioPlayer = nil
    }
}



class XQSlider: UISlider {
//    var yCenter: CGFloat!
//    var trackHeight: CGFloat = 4
}
