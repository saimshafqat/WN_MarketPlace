//
//  FeedPagePresenter.swift
//  StreamLabsAssignment
//
//  Created by on Jude on 16/02/2019.
//  Copyright © 2019 streamlabs. All rights reserved.
//

import Foundation
import AVFoundation
//import ProgressHUD

protocol FeedPagePresenterProtocol: class {
    func viewDidLoad()
    func fetchNextFeed() -> IndexedFeed?
    func fetchPreviousFeed() -> IndexedFeed?
    func updateFeedIndex(fromIndex index: Int)
}

class FeedPagePresenter: FeedPagePresenterProtocol {
    fileprivate unowned var view: FeedPageView
//    fileprivate var fetcher: FeedFetchProtocol
    fileprivate var feeds: [VideoClipModel] = []
    fileprivate var currentFeedIndex = 1
    
    init(view: FeedPageView) {
        self.view = view
//        self.fetcher = fetcher
        self.feeds = SharedManager.shared.arrayVideoClip
    }
    
    
    func viewDidLoad() {
//        fetcher.delegate = self
        configureAudioSession()
        fetchFeeds()
    }
    
    func fetchNextFeed() -> IndexedFeed? {
        return getFeed(atIndex: currentFeedIndex + 1)
    }
    
    func fetchPreviousFeed() -> IndexedFeed? {
        return getFeed(atIndex: currentFeedIndex - 1)
    }
    
    func updateFeedIndex(fromIndex index: Int) {
        currentFeedIndex = index
    }
    
    
    fileprivate func configureAudioSession() {
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
    }
    
    fileprivate func fetchFeeds() {
        self.currentFeedIndex = SharedManager.shared.videoClipIndex
        view.presentInitialFeed(self.feeds[self.currentFeedIndex])
    }
    
    fileprivate func getFeed(atIndex index: Int) -> IndexedFeed? {
        guard index >= 0 && index < feeds.count else {
            return nil
        }
        return (feed: feeds[index], index: index)
    }
    
    
}

