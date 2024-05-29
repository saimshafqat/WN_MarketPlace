//
//  ViewController.swift
//  PlayViewSample
//
//  Created by apple on 9/7/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

typealias IndexedFeed = (feed: VideoClipModel, index: Int)

protocol FeedPageView: class, ProgressIndicatorHUDPresenter {
    func presentInitialFeed(_ feed: VideoClipModel)
}

class MainViewController: UIPageViewController, FeedPageView {
    fileprivate var presenter: FeedPagePresenterProtocol!
    
    
    var indexChoose = 0
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    
    func presentInitialFeed(_ feed: VideoClipModel) {
        let viewController = FeedVideoViewController.instantiate(feed: feed, andIndex: indexChoose, isPlaying: true) as! FeedVideoViewController
        setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = false
        self.dataSource = self
        self.delegate = self
        presenter = FeedPagePresenter(view: self)
        
        presenter.viewDidLoad()
        presenter.updateFeedIndex(fromIndex: self.indexChoose)
        let firstDotPanRecgnzr = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        self.view.addGestureRecognizer(firstDotPanRecgnzr)
        
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return  .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
}


extension MainViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let indexedFeed = presenter.fetchPreviousFeed() else {
            return nil
        }
        return FeedVideoViewController.instantiate(feed: indexedFeed.feed, andIndex: indexedFeed.index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let indexedFeed = presenter.fetchNextFeed() else {
            return nil
        }
        return FeedVideoViewController.instantiate(feed: indexedFeed.feed, andIndex: indexedFeed.index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        if
            let viewController = pageViewController.viewControllers?.first as? FeedVideoViewController,
            let previousViewController = previousViewControllers.first as? FeedVideoViewController
        {
            previousViewController.pause()
            viewController.play()
            presenter.updateFeedIndex(fromIndex: viewController.index)
        }
    }
    
    
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                (UIApplication.shared.delegate as! AppDelegate).restrictRotation = true
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
}


