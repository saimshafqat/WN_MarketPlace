//
//  NewLikeCell.swift
//  WorldNoor
//
//  Created by apple on 8/16/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

class NewLikeCell : UITableViewCell {
    @IBOutlet var lblLike : UILabel!
    @IBOutlet var lblComment : UILabel!
    @IBOutlet var lblDownload : UILabel!
    @IBOutlet var lblShare : UILabel!
    
    
    
    @IBOutlet var btnLike : UIButton!

    @IBOutlet var btnComment : UIButton!
    @IBOutlet var btnDownload : UIButton!
    @IBOutlet var btnShare : UIButton!
    
    @IBOutlet var viewDownload : UIView!
    
    var feedObj : FeedData!
    var indexPathMain : IndexPath!
    
    func reloadData(feedObjP : FeedData ){
        self.feedObj = feedObjP
        self.btnLike.isSelected = self.feedObj?.isLiked ?? false
        self.manageCount()
    }
    
    
    func manageCount(){
        
        if let likeCounter = self.feedObj?.likeCount {
            var counterValue = ""
            if likeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = String(likeCounter)
            }
            self.lblLike.text = counterValue
        }
        if let disLikeCounter = self.feedObj?.simple_dislike_count {
            var counterValue = ""
            if disLikeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = String(disLikeCounter)
            }
        }
        
        if let commentCount = self.feedObj?.commentCount {
            var counterValue = ""
            if commentCount == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(commentCount)
            }
            self.lblComment.text = counterValue
        }
        
        if let shareCount = self.feedObj?.shareCount {
            var counterValue = ""
            if shareCount == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(shareCount)
            }
            self.lblShare.text = counterValue
        }
    }
    
    
    @IBAction func likeAction(sender : UIButton){
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(self.feedObj!.postID!)
        
        var dic = [String : Any]()
        dic["likesCount"] = String(self.feedObj!.likeCount!)
        dic["group_id"] = String(self.feedObj!.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_like_NOTIFICATION"
        
        
        if self.btnLike.isSelected {
            self.btnLike.isSelected = false
            if self.lblLike.text!.count > 0 {
                let textMain = Int(self.lblLike.text!)!
                self.lblLike.text = String(textMain - 1)
            }
        }else {
            self.btnLike.isSelected = true
            SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
            
            if self.lblLike.text!.count > 0 {
                let textMain = Int(self.lblLike.text!)!
                self.lblLike.text = String(textMain + 1)
            }else {
                self.lblLike.text = "1"
            }
        }
        
        self.feedObj!.isLiked = self.btnLike.isSelected
        self.feedObj!.likeCount = Int(self.lblLike.text!)!
        
        var parameters = ["action": "react","token": SharedManager.shared.userToken(), "type": "like_simple_like", "post_id":String(self.feedObj!.postID!)]
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        }else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        UIApplication.topViewController()?.callingAPI(parameters: parameters)
    }
    
    @IBAction func disLikeAction(sender : UIButton){
//        var dicMeta = [String : Any]()
//        dicMeta["post_id"] = String(self.feedObj!.postID!)
//        
//        var dic = [String : Any]()
//        dic["likesCount"] = String(self.feedObj!.likeCount!)
//        dic["group_id"] = String(self.feedObj!.postID!)
//        dic["meta"] = dicMeta
//        dic["type"] = "new_dislike_NOTIFICATION"
//        
//        
//        if self.btnDisLike.isSelected {
//            self.btnDisLike.isSelected = false
//            
//            if self.lblDisLike.text!.count > 0 {
//                let textMain = Int(self.lblDisLike.text!)!
//                self.lblDisLike.text = String(textMain - 1)
//            }
//        }else {
//            self.btnDisLike.isSelected = true
//            self.btnLike.isSelected = false
//            SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
//            
//            if self.lblDisLike.text!.count > 0 {
//                let textMain = Int(self.lblDisLike.text!)!
//                self.lblDisLike.text = String(textMain + 1)
//            }else {
//                self.lblDisLike.text = "1"
//            }
//            
//            if self.lblLike.text!.count > 0 {
//                self.btnLike.isSelected = false
//                if self.lblLike.text!.count > 0 {
//                    let textMain = Int(self.lblLike.text!)!
//                    self.lblLike.text = String(textMain - 1)
//                }
//            }
//        }
//        
//        self.feedObj!.isDisliked = self.btnDisLike.isSelected
//        self.feedObj!.isLiked = self.btnLike.isSelected
//        self.feedObj!.simple_dislike_count = Int(self.lblDisLike.text!)!
//        
//        
//        var parameters = ["action": "react","token": SharedManager.shared.userToken(), "type": "dislike_simple_dislike", "post_id":String(self.feedObj!.postID!)]
//        if SharedManager.shared.isGroup == 1 {
//            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
//        }
//        UIApplication.topViewController()?.callingAPI(parameters: parameters)
    }
    
    @IBAction func shareAction(sender : UIButton){
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedObj.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        
//        if let parentVC = UIApplication.topViewController() as? SavedPostVC{
//            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
//            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
//            parentVC.sheetController.extendBackgroundBehindHandle = true
//            parentVC.sheetController.topCornersRadius = 20
//            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
//            
//        }
    }
    
    @IBAction func downloadAction(sender : UIButton){
        var urlString:String?
        var isImage : Bool?
        if feedObj.post!.count > 0 {
            var postFile:PostFile?
            
            isImage = feedObj.postType == FeedType.image.rawValue ? true : false
            if feedObj.postType == FeedType.image.rawValue ||
                feedObj.postType == FeedType.video.rawValue {
                postFile = feedObj.post![0]
                if postFile!.processingStatus == "done" {
                    urlString = postFile!.filePath
                }
            }

            if urlString != nil {
                UIApplication.topViewController()!.downloadFile(filePath: urlString!, isImage: isImage!, isShare: false , FeedObj: feedObj)
            }
        }
        
    }
    
    @IBAction func commentAction(sender : UIButton){
        
    }
    
}
