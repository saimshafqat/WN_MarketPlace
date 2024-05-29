//
//  XQAudioPlayerManager.swift
//  WorldNoor
//
//  Created by Raza najam on 11/15/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class XQAudioPlayerManager: NSObject {
    var audioPlayer:AVPlayer = AVPlayer()
    static let shared = XQAudioPlayerManager()
    
    private override init() {
        
    }
    
    func configureSharedAudio(playerItem:AVPlayerItem){
        self.audioPlayer = AVPlayer(playerItem: playerItem)
    }
}
