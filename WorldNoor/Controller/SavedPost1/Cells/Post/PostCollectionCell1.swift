//
//  PostCollectionCell1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath)
    func tappedPost(with obj: FeedData, at indexpath: IndexPath)
}

@objc(PostCollectionCell1)
class PostCollectionCell1: PostBaseCollectionCell {
    
    // MARK: - Video
    @IBOutlet var playButton : UIButton!
    @IBOutlet var btnShowUserProfile : UIButton!
    @IBOutlet var videoView : UIView!
    @IBOutlet var playImageView : UIImageView!
    @IBOutlet var phImageView : UIImageView!
    @IBOutlet weak var imageVideoHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var parentView: UIView!
    
    // MARK: - Properties -
    public var postDelegate: PostDelegate!
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        let obj = data as? FeedData
        let parentObj = parentData as? FeedData
        if let obj {
            LogClass.debugLog("Parent Post Type ==> \(parentObj?.postType ?? .emptyString)")
            setImageVideoText(obj: obj)
        }
    }
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        if let postObj, let indexPath {
            postDelegate.tappedPost(with: postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickDownload(_ sender: UIButton) {
        if let postObj, let indexPath {
            postDelegate.tappedPostDownload(with: postObj, at: indexPath)
        }
    }
  
    func setImageVideoText(obj: FeedData) {
        let postFile = obj.post?.first
        let thumbnail = postFile?.thumbnail
        let filePath = postFile?.filePath
        let cellWidth = UIScreen.main.bounds.width
        setLayoutDesign(height: 0, isPlayHide: true, isVideoHide: true, hasText: true)
        switch obj.postType ?? .emptyString {
            // video & Live Strean case handle
        case FeedType.video.rawValue, FeedType.liveStream.rawValue:
            var videoHeight : Int = 0
            var videoWidth : Int = 0
            
            if postFile?.videoWidth != nil && postFile?.videoHeight != nil{
                videoHeight = postFile?.videoHeight ?? 0
                videoWidth = postFile?.videoWidth ?? 0
                
            }else if postFile?.video_width != nil && postFile?.video_height != nil {
                videoHeight = postFile?.video_height ?? 0
                videoWidth = postFile?.video_width ?? 0
            }
            
            
            
            
            if videoHeight != nil && videoWidth != nil && (videoHeight ?? 0 > 0) && (videoWidth ?? 0 > 0) {
                let videoHeight = CGFloat(videoHeight ?? 0)
                let videoWidth = CGFloat(videoWidth ?? 0)
                let cellHeight = calculateHeight(originalDimensions: (videoWidth, videoHeight), cellWidth: cellWidth)
                setLayoutDesign(height: cellHeight, isPlayHide: true, isVideoHide: true, urlStr: filePath)
            } else {
                setLayoutDesign(height: 350, isPlayHide: false, isVideoHide: false, urlStr: thumbnail)
            }
        case FeedType.image.rawValue:
            // image case handlE
            
            var videoHeight : Int = 0
            var videoWidth : Int = 0
            
            if postFile?.videoWidth != nil && postFile?.videoHeight != nil{
                videoHeight = postFile?.videoHeight ?? 0
                videoWidth = postFile?.videoWidth ?? 0
                
            }else if postFile?.video_width != nil && postFile?.video_height != nil {
                videoHeight = postFile?.video_height ?? 0
                videoWidth = postFile?.video_width ?? 0
            }
            
            if  videoHeight != nil && videoWidth != nil && (videoHeight ?? 0 > 0) && (videoWidth ?? 0 > 0) {
                let videoHeight = CGFloat(videoHeight ?? 0)
                let videoWidth = CGFloat(videoWidth ?? 0)
                let cellHeight = calculateHeight(originalDimensions: (videoWidth, videoHeight), cellWidth: cellWidth)
                setLayoutDesign(height: cellHeight, isPlayHide: true, isVideoHide: true, urlStr: filePath)
            } else {
               setLayoutDesign(height: 350, isPlayHide: true, isVideoHide: true, urlStr: filePath)
            }
        default:
            // post case when having link preview and without link preview
            if (obj.postType == FeedType.post.rawValue) && (obj.linkImage?.count ?? 0 > 0) {
                if obj.previewLink!.contains("youtube") {
                    setLayoutDesign(height: 350, isPlayHide: false, isVideoHide: false, urlStr: obj.linkImage)
                } else {
                    setLayoutDesign(height: 350, isPlayHide: true, isVideoHide: true, urlStr: obj.linkImage)
                }
            } else {
                // Shared case ,Text Case // type ==> Post (image link, video link, gallery link)
                setLayoutDesign(height: 0, isPlayHide: true, isVideoHide: true, hasText: true)
            }
        }
    }
    
    func calculateHeight(originalDimensions: (width: CGFloat, height: CGFloat), cellWidth: CGFloat) -> CGFloat {
        // Calculate the corresponding height based on the aspect ratio
        let aspectRatio = originalDimensions.width / cellWidth
        var calculatedHeight = originalDimensions.height / aspectRatio
        // Calculate 65% of screen height
        
        LogClass.debugLog("cellHeight ===> aspectRatio")
        LogClass.debugLog(aspectRatio)
        LogClass.debugLog(calculatedHeight)
        LogClass.debugLog(width)
        LogClass.debugLog(height)
        LogClass.debugLog("height   ===>")
        let maxHeight = UIScreen.main.bounds.height * 0.65
        if calculatedHeight > maxHeight {
            calculatedHeight = maxHeight
        }
        return calculatedHeight
    }

    func setLayoutDesign(height: CGFloat, isPlayHide: Bool, isVideoHide: Bool, hasText: Bool = false, urlStr: String? = nil) {
        imageVideoHeightConstraint?.constant = height
        playImageView.isHidden = isPlayHide
        videoView.isHidden = isVideoHide
        phImageView.isHidden = hasText
        if !(hasText) {
            phImageView.imageLoad(with: urlStr)
        }
    }
    
}
