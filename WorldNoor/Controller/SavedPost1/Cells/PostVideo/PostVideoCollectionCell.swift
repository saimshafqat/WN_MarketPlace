//
//  PostVideoCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 16/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol PostVideoDelegate {
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath)
}

@objc(PostVideoCollectionCell)
class PostVideoCollectionCell: PostBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet var indicator : UIActivityIndicatorView?
    @IBOutlet var slider : UISlider?
    @IBOutlet var videoView : UIView?
    @IBOutlet var imgviewPH : UIImageView?
    @IBOutlet var imgviewPlay : UIImageView?
    @IBOutlet var btnPlay : UIButton?
    @IBOutlet var playView : UIView?
    @IBOutlet var pauseView : UIView?
    @IBOutlet var lblTime : UILabel?
    @IBOutlet var lblProcessing : UILabel?
    @IBOutlet var collectionViewMain: UICollectionView?
    @IBOutlet weak var videoHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Properties -
    var feedObj:FeedData? = nil
    var videoPlayerIndexCallback: ((IndexPath) -> Void)?
    var videoUrl: URL!
    var indexPathMain : IndexPath!
    var playerSoundValue : Bool = true
    var timeObserver : Any!
    var isPlayVideo : Bool = false
    var videoPostDelegate: PostVideoDelegate?
    
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        let obj = data as? FeedData
        self.imgviewPH?.isHidden = false
        indexPathMain = indexPath
        if let obj {
            setLayoutDesign(obj: obj)
        }
    }
    
    func visibilityImageView(isEnable: Bool) {
        // Create a UIViewPropertyAnimator with desired duration and animation options
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
            self.imgviewPlay?.isHidden = isEnable
            self.btnPlay?.isHidden = isEnable
        }
        // Start the animation
        animator.startAnimation()
    }
    
    func setLayoutDesign(obj: FeedData) {
        let postFile = obj.post?.first
        let cellWidth = UIScreen.main.bounds.width
        
        
        var videoHeight : Int = 0
        var videoWidth : Int = 0
        
        
        LogClass.debugLog("postFile?.video_width ===>")
        LogClass.debugLog(postFile?.video_width)
        LogClass.debugLog(postFile?.video_height)
        
        LogClass.debugLog("postFile?.videoWidth ===>")
        LogClass.debugLog(postFile?.videoWidth)
        LogClass.debugLog(postFile?.videoHeight)
        
        if postFile?.videoWidth != nil && postFile?.videoHeight != nil{
            videoHeight = postFile?.videoHeight ?? 0
            videoWidth = postFile?.videoWidth ?? 0
            
        }else if postFile?.video_width != nil && postFile?.video_height != nil {
            videoHeight = postFile?.video_height ?? 0
            videoWidth = postFile?.video_width ?? 0
        }
        
        
        
        if (videoHeight  > 0) && (videoWidth  > 0) {
            let videoHeight = CGFloat(videoHeight )
            let videoWidth = CGFloat(videoWidth )
            let cellHeight = calculateHeight(originalDimensions: (videoWidth, videoHeight), cellWidth: cellWidth)
            videoHeightConstraint?.constant = cellHeight
        } else {
            videoHeightConstraint?.constant = 350
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    func calculateHeight(originalDimensions: (width: CGFloat, height: CGFloat), cellWidth: CGFloat) -> CGFloat {
        let aspectRation = Double(originalDimensions.width) / Double(originalDimensions.height)
        var calculatedHeight = cellWidth / aspectRation
        // Calculate 65% of screen height
        let maxHeight = UIScreen.main.bounds.height * 0.65
        LogClass.debugLog("cellHeight ===> 555")
        
        LogClass.debugLog(aspectRation)
        LogClass.debugLog(calculatedHeight)
        LogClass.debugLog(width)
        LogClass.debugLog(height)
        if calculatedHeight > maxHeight {
            calculatedHeight = maxHeight
        }
        return calculatedHeight
    }
    
    @IBAction func playAudioTapped(_ sender: UIButton) {
        if self.feedObj?.post?.count ?? 0 > 0 {
            let postFile = self.feedObj?.post?.first
            if postFile?.processingStatus ?? .emptyString != "done" {
                return
            }
        }
        self.isPlayVideo = true
        
        self.btnPlay?.isHidden = true
        self.imgviewPlay?.isHidden = true
        if self.videoUrl != nil {
            if self.videoUrl.absoluteString.count  > 0 {
                MediaManager.sharedInstance.player?.isHideSound = false
                SocketSharedManager.sharedSocket.playVideoSocket(postID: String(self.feedObj!.postID!))
                MediaManager.sharedInstance.playEmbeddedVideo(url: self.videoUrl, embeddedContentView: self.videoView,userinfo: ["isHideSound" : false])
                MediaManager.sharedInstance.player?.indexPath = indexPathMain
                MediaManager.sharedInstance.player?.floatMode = .none
                MediaManager.sharedInstance.player?.scrollCollectionView = collectionViewMain
                MediaManager.sharedInstance.player?.player?.volume = 0.0
                MediaManager.sharedInstance.player?.videoGravity = .aspectFill
                MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
                    self.btnPlay?.isHidden = false
                    self.imgviewPlay?.isHidden = false
                    self.imgviewPH?.isHidden = false
                    MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    @IBAction func pauseAudioTapped(_ sender: UIButton) {
        if self.indexPathMain == MediaManager.sharedInstance.player?.indexPath {
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
            isPlayVideo = false
            visibilityImageView(isEnable: false)
        }
    }
    
    @IBAction func onClickDownload(_ sender: UIButton) {
        if let postObj, let indexPath {
            videoPostDelegate?.tappedvideoPostDownload(with: postObj, at: indexPath)
        }
    }
    
    func resetVideo(feedObjp : FeedData) {
        indicator?.isHidden = true
        self.lblTime?.text = ""
        self.lblTime?.text = "00:00"
        visibilityImageView(isEnable: false)
        SharedManager.shared.playerArray.forEach({$0.pause()})
        self.lblProcessing?.isHidden = true
        self.feedObj = feedObjp
        if self.feedObj?.post?.count ?? 0 > 0 {
            let postFile = self.feedObj?.post?.first
            if postFile?.processingStatus != "done" {
                self.lblProcessing?.isHidden = false
            }
            self.videoUrl = URL(string: postFile?.convertedURL.count ?? 0 > 0 ? postFile?.convertedURL ?? .emptyString : postFile?.filePath ?? .emptyString)
            self.imgviewPH?.loadImageWithPH(urlMain: postFile?.thumbnail ?? .emptyString)
        }
    }
    
    func stopPlayer() {
        pauseAudioTapped(UIButton.init())
    }
    
    func playPlayer() {
        playAudioTapped(UIButton.init())
    }
}

