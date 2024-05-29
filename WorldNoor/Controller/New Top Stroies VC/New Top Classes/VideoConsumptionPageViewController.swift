//
//  VideoConsumptionPageViewController.swift
//  SilverLabsAssignment
//
//  Created by Bandish Kumar on 21/02/20.
//  Copyright © 2020 Bandish Kumar. All rights reserved.
//

import UIKit

typealias VideoIndex = (feed: String, index: Int)

final class VideoConsumptionPageViewController: UIPageViewController {
    
    //MARK: Properties
    var currentVideoIndex = 0
    var nodeList = [FeedVideoModel]()
    
    var viewController : VideoViewController!
    
    var delegateVideo : TopStoryDelegate!
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presentInitialFeed()
    }
    
    //MARK: Methods
    private func setupUI() {
        self.dataSource = self
        self.delegate = self
    }
    
    private func presentInitialFeed() {
        let strfile = nodeList[currentVideoIndex].videoUrl
        self.viewController = VideoViewController.initialize(urlString: strfile  , andIndex: currentVideoIndex, isPlaying: false)
        self.viewController.parentView = self
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func fetchPreviousVideoIndex() -> VideoIndex? {

        return getVideoIndex(atIndex: currentVideoIndex - 1)
    }
    
    private func fetchNextVideoIndex() -> VideoIndex? {

        
        if FeedCallBManager.shared.videoClipArray.count - 3 == currentVideoIndex {
            self.delegateVideo.nextPageAction()
        }
        return getVideoIndex(atIndex: currentVideoIndex + 1)
    }
    
    private func getVideoIndex(atIndex index: Int) -> VideoIndex? {
        guard index >= 0 && index < nodeList.count else {
            return nil
        }
        let nodeITme = nodeList[index]
        let videoURL = nodeITme.videoUrl
        return (feed:videoURL  , index: index)
    }
    
    private func updateVideoIndex(fromIndex index: Int) {
        currentVideoIndex = index
    }
    
    func playVideo(){
       
        
        if self.viewController.player?.rate == 0 {
            self.viewController.startPlayingVideo()
        }else {
            self.viewController.pausePlayingVideo()
        }
    }
        
    func nextVideoPlay(){
        guard let currentViewController = self.viewControllers?.first else { return 
        }
        guard let nextViewController = self.dataSource?.pageViewController( self, viewControllerAfter: currentViewController) else { return }
        self.updateVideoIndex(fromIndex: self.currentVideoIndex +  1)
        setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
        
        if FeedCallBManager.shared.videoClipArray.count - 3 == currentVideoIndex {
            self.delegateVideo.nextPageAction()
        }
        
    }
    
    func openUserProfile(){
      
    }
    func backAction(){
        self.delegateVideo.gobackAction()
        
        self.navigationController?.popViewController(animated: true)

    }
}

//MARK: UIPageViewControllerDataSource
extension VideoConsumptionPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let previousVideoIndex = fetchPreviousVideoIndex()?.index else {
            return nil
        }
        
        let nodeITme = nodeList[previousVideoIndex]
        let videoURL = nodeITme.videoUrl
        
        let vcNew = VideoViewController.initialize(urlString: videoURL , andIndex: previousVideoIndex, isPlaying: false)
        vcNew.parentView = self
        return vcNew
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let nextVideoIndex = fetchNextVideoIndex()?.index else {
            return nil
        }
        let nodeITme = nodeList[nextVideoIndex]
        let videoURL = nodeITme.videoUrl
        let vcNew = VideoViewController.initialize(urlString: videoURL , andIndex: nextVideoIndex, isPlaying: false)
        vcNew.parentView = self
        return vcNew
    }
}

//MARK: UIPageViewControllerDelegate
extension VideoConsumptionPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        if
            let viewController = pageViewController.viewControllers?.first as? VideoViewController,
            let previousViewController = previousViewControllers.first as? VideoViewController
        {
            previousViewController.pausePlayingVideo()
            viewController.startPlayingVideo()
            viewController.parentView = self
            self.viewController = viewController
            self.updateVideoIndex(fromIndex: viewController.index)
        }
    }
}
