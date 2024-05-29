//
//  PostAudioCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 19/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Foundation

class PostAudioCollectionCell1: PostBaseCollectionCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var audioView: UIView!
    
    // MARK: - Properties
    var xqAudioPlayer: XQAudioPlayer!
    
    // MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        xqAudioPlayer = loadNibView(.xQAudioPlayer) as? XQAudioPlayer
    }
    
    // MARK: - Configure Cell
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        let obj = data as? FeedData
        // self.audioView.rotateViewForLanguage()
        if self.xqAudioPlayer != nil {
            xqAudioPlayer.removeFromSuperview()
            audioView.addSubview(xqAudioPlayer)
            self.xqAudioPlayer.frame = CGRect(x: 0, y: 0, width: audioView.frame.size.width, height: 50)
            guard let obj, obj.post?.count ?? 0 > 0 else { return }
            xqAudioPlayer.config(urlString:obj.post?.first?.filePath ?? .emptyString)
            xqAudioPlayer.manageProgressUI()
            xqAudioPlayer.delegate = self
        }
    }
    
    // MARK: - Methods
    func stopPlayer() {
        xqAudioPlayer.resetXQPlayer()
    }
}

extension PostAudioCollectionCell1: XQAudioPlayerDelegate {
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime) { }
    /* Player did change time playing You can get current time play of audio in here */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime) { }
    // Player begin start
    func playerDidStart(player: XQAudioPlayer) { }
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer) { }
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer) { }
}
