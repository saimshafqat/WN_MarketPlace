//
//  VideoPlayer.swift
//  WorldNoor
//
//  Created by Raza najam on 10/15/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import AVKit

class VideoPlayer: NSObject {
    let player = AVPlayer()
   static let shared = VideoPlayer()

   private override init() {
       
       

    }
    
    func setPlayerItem(playerItem:AVPlayerItem)  {
        self.player.replaceCurrentItem(with: playerItem)
    }
    
    
}
