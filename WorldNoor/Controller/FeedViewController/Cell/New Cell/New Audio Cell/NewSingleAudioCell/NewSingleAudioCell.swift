//
//  NewSingleAudioCell.swift
//  WorldNoor
//
//  Created by apple on 11/9/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewSingleAudioCell : UITableViewCell {
    
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet weak var audioView: UIView!
    
    var postObj : FeedData!
    var xqAudioPlayer: XQAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.xqAudioPlayer = self.getAudioPlayerView()
    }
    
    func stopPlayer(){
        self.xqAudioPlayer.resetXQPlayer()
    }
    
    func manageCellData() {
        
      //  self.audioView.rotateViewForLanguage()
        
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.removeFromSuperview()
        }
        
        self.audioView.addSubview(self.xqAudioPlayer)
        self.xqAudioPlayer.frame = CGRect(x: 0, y: 0, width: self.audioView.frame.size.width, height: self.audioView.frame.size.height)
        self.audioConfigurations(feedObj:self.postObj)
    }
    
    func audioConfigurations(feedObj: FeedData) {
        // Change progress color
        if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
            self.xqAudioPlayer.config(urlString:postFile.filePath ?? "")
        }
        self.xqAudioPlayer.manageProgressUI()
        self.xqAudioPlayer.delegate = self
    }

    
    func getAudioPlayerView()-> XQAudioPlayer   {
           let audioPlayer = Bundle.main.loadNibNamed(Const.XQAudioPlayer, owner: self, options: nil)?.first as! XQAudioPlayer
           return audioPlayer
       }
}

extension NewSingleAudioCell:XQAudioPlayerDelegate {
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime) {
        
    }
    
    /* Player did change time playing
     * You can get current time play of audio in here
     */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime) {
        
    }
    
    // Player begin start
    func playerDidStart(player: XQAudioPlayer) {
        
    }
    
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer) {
        
    }
    
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer) {
        
    }
}
