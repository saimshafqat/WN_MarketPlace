//
//  FeedViewModelCellDelegate.swift
//  WorldNoor
//
//  Created by apple on 8/17/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

extension FeedViewModel : CellDelegate {
    
    func reloadTableDataFriendShipStatus(feedObj: FeedData) {

        self.feedArray.forEach { feed in
            if feed.authorID == feedObj.authorID {
                feed.isAuthorFriendOfViewer = feedObj.isAuthorFriendOfViewer
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.reloadTableViewClosure?()
        })
    }
    
    func reloadRow(indexObj : IndexPath , feedObj : FeedData){
//        self.reloadSpecificRow?(indexObj)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            self.reloadTableViewClosure?()
            self.reloadSpecificRow?(indexObj)
        }
    }
    
    func moreAction(indexObj: IndexPath, feedObj: FeedData) {
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        
        reportController.reportType = "Post"
        reportController.currentIndex = indexObj
        reportController.feedObj = feedObj
        
        if let parentVC = self.parentView as? FeedViewController{
            reportController.delegate = parentVC
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }
    }
    
    func userProfileAction(indexObj : IndexPath , feedObj : FeedData){
        
        
        let userID = String(feedObj.authorID!)
        
        if let parentVC = self.parentView as? FeedViewController{
            if Int(userID) == SharedManager.shared.getUserID() {
                parentVC.tabBarController?.selectedIndex = 3
            }else {
                let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
                vcProfile.isNavPushAllow = true
                parentVC.navigationController?.pushViewController(vcProfile, animated: true)
            }
            
        }
        
    }
    
    func sharePostAction(indexObj : IndexPath , feedObj : FeedData) {
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedObj.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        
        if let parentVC = self.parentView as? FeedViewController{
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
            
        }
    }
    
    func downloadPostAction(indexObj : IndexPath , feedObj : FeedData){
        
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
                self.parentView.downloadFile(filePath: urlString!, isImage: isImage!, isShare: false , FeedObj: feedObj)
            }
        }
    }
    
    func imgShowAction(indexObj : IndexPath , feedObj : FeedData){
        
        if let parentVC = self.parentView as? FeedViewController{
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var feeddata:FeedData?

                feeddata = feedObj
            fullScreen.isInfoViewShow = false
            fullScreen.collectionArray = feeddata!.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = 0
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = IndexPath.init(row: indexObj.row, section: 0)
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: parentVC.feedTableView.visibleCells)
            parentVC.present(fullScreen, animated: false, completion: nil)
            
        }
    }
    
    func commentActions(indexObj : IndexPath , feedObj : FeedData , typeAction: ActionType){
    }
}
