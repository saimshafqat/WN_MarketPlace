//
//  VideoViewController.swift
//  SilverLabsAssignment
//
//  Created by Bandish Kumar on 21/02/20.
//  Copyright © 2020 Bandish Kumar. All rights reserved.
//

import UIKit
import AVKit

final class VideoViewController: AVPlayerViewController {
    
    //MARK: Properties
    var index: Int! = 0
    private var urlString: String!
    private var isPlaying: Bool!
    
    var viewBack : UIView = UIView()
    
    
    var parentView: VideoConsumptionPageViewController!
    
    static var sceneIdentifier: String {
        return String(describing: self)
    }
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseVideoURL()
        self.loadViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishVideo),
                                               name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    @objc func finishVideo(){

        self.parentView.nextVideoPlay()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func loadViews(){
        self.viewBack.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.viewBack.backgroundColor = UIColor.clear
        self.addUserImage()
        self.contentOverlayView?.addSubview(self.viewBack)
    }
    
    
    func addUserImage(){
        
        let likeView = Bundle.main.loadNibNamed("TopStoriesView", owner: self, options: nil)?.first as! TopStoriesView
        
        likeView.frame = self.viewBack.frame
        likeView.modelObj = FeedCallBManager.shared.videoClipArray[self.index]
        likeView.reloadData()
        self.viewBack.addSubview(likeView)
        
    }
    

    //MARK: Initializer
    static func initialize(urlString: String, andIndex index: Int, isPlaying: Bool = false) -> VideoViewController {
        let viewController = VideoViewController.getInstanceOfVideoVC()
        viewController.urlString = urlString
        viewController.index = index
        viewController.isPlaying = isPlaying
        return viewController
    }
    
    static func getInstanceOfVideoVC() -> Self {
        let viewController = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: self.sceneIdentifier)
        guard let conformingViewController = viewController as? Self else {
            fatalError("Error " + "\(self)")
        }
        return conformingViewController
    }
    
    //MARK: Methods
    func initialiseVideoURL() {
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        isPlaying ? startPlayingVideo() : nil
    }
    
    func startPlayingVideo() {
        player?.play()
    }
    
    func pausePlayingVideo() {

        player?.pause()
    }
}
