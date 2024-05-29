//
//  FeedViewController.swift
//  StreamLabsAssignment
//
//  Created by Jude on 16/02/2019.
//  Copyright © 2019 streamlabs. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import VersaPlayer
import FittedSheets

class FeedVideoViewController: UIViewController, StoryboardScene {
    
    static var sceneStoryboard = UIStoryboard(name: "VideoClipStoryBoard", bundle: nil)
    var index: Int!
    fileprivate var feed: VideoClipModel!
    fileprivate var isPlaying: Bool!
    
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!
    
    @IBOutlet weak var viewTranslation: UIView!
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var viewTransript: UIView!
    
    
    var isOriginal = false
    
    
    var sheetController = SheetViewController()
    
    static func instantiate(feed: VideoClipModel, andIndex index: Int, isPlaying: Bool = false) -> UIViewController {
        let viewController = FeedVideoViewController.instantiate()
        viewController.feed = feed
        viewController.index = index
        viewController.isPlaying = isPlaying
        return viewController
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return  .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = false
        initializeFeed()
        self.viewTransript.isHidden = true
        self.viewTranslation.isHidden = true
        self.lblTranslation.text = "View Original".localized()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.playerView.layer.backgroundColor = UIColor.black.cgColor
        playerView.use(controls: controls)
        if feed.has_speech_to_text == "1" {
            self.viewTransript.isHidden = false
        }
      if playerView.player.currentItem?.currentTime() == nil {
            var urlMAin = ""
            if feed.translatedVideo.count == 0 {
                urlMAin = feed.path
            }else {
                urlMAin = feed.translatedVideo
                self.viewTranslation.isHidden = false
            }
            let item = VersaPlayerItem(url: URL.init(string: urlMAin)!)
            self.playerView.set(item: item)
        }else {
            self.playerView.play()
        }
    }
    
    func playrset(){
            
            var urlMAin = ""
            if self.isOriginal {
                urlMAin = feed.path
            }else {
                urlMAin = feed.translatedVideo
            }
            let item = VersaPlayerItem(url: URL.init(string: urlMAin)!)
            self.playerView.set(item: item)
            
    }
    func play() {
        self.playerView.play()
    }
    
    func pause() {
        self.playerView.pause()
    }
    
    fileprivate func initializeFeed() {
        
    }
    
    
    @IBAction func openTransprit(sender : UIButton){

    }
    
    @IBAction func opentranslation(sender : UIButton){
        if self.isOriginal {
            self.lblTranslation.text = "View Original".localized()
            
        }else {
            self.lblTranslation.text = "View Translated".localized()
        }
        
        self.isOriginal = !self.isOriginal
         self.playrset()
    }
    
}


