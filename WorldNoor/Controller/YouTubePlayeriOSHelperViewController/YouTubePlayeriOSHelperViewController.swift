//
//  YouTubePlayeriOSHelperViewController.swift
//  WorldNoor
//
//  Created by apple on 4/28/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//


import UIKit
//import youtube_ios_player_helper
//import YouTubePlayer_Swift

class YouTubePlayeriOSHelperViewController: UIViewController {
    @IBOutlet var playerView: YouTubePlayerView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        playerView.roundedTopOnly()
        
        // If you want to change the video after you loaded the first one, use the following code
//        playerView.cueVideo(byId: "DQuhA5ZCV9M", startSeconds: 0)
    }
    
    func loadVideo(videoID:String){

        playerView.loadVideoURL(URL.init(string: videoID)!)


    }
}

//extension YouTubePlayeriOSHelperViewController: YTPlayerViewDelegate {
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return UIColor.black
//    }
//
////    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
////        let customLoadingView = UIView()
////        Create a custom loading view
////        return customLoadingView
////    }
//}

