//
//  ImageViewerExtension.swift
//  WorldNoor
//
//  Created by apple on 9/22/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage


extension UIViewController {
    
   
    func showdetail(feedObj : FeedData , currentIndex : Int = 0 , ShowWatch : Bool = true) {
                
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
        var feeddata:FeedData?
        
        feeddata = feedObj
        if feedObj.postType == FeedType.liveStream.rawValue {
            if feedObj.isLive != nil {
                if feedObj.isLive! == 1 {
                    let poseFileNew = PostFile.init()
                    poseFileNew.fileType = FeedType.video.rawValue
                    poseFileNew.convertedURL = feedObj.liveUrlStr!
                    poseFileNew.filePath = feedObj.liveUrlStr!
                    
                    feeddata?.post = [poseFileNew]
                }else {
                    feeddata?.post = feedObj.post
                }
            }
        }
        fullScreen.collectionArray = feeddata!.post!
        fullScreen.feedObj = feedObj
        fullScreen.movedIndexpath = currentIndex
        fullScreen.modalTransitionStyle = .crossDissolve
        fullScreen.currentIndex = IndexPath.init(row: currentIndex, section: 0)
        self.present(fullScreen, animated: false, completion: nil)
    }
}
