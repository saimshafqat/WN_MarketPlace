//
//  FeedViewModel.swift
//  WorldNoor
//
//  Created by Raza najam on 9/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import FTPopOverMenu
import FittedSheets
import Kingfisher

class FeedViewModel: NSObject {
    
    var feedScrollHandler: (()->())?
    var reloadTableViewClosure: (()->())?
    var didSelectTableClosure:((IndexPath)->())?
    var reloadTableViewWithNoneClosure: (()->())?
    var hideFooterClosure: (()->())?
    var showAlertMessageClosure:((String)->())?
    var showloadingBar:(()->())?
    var reloadSpecificRow:((IndexPath)->())?
    var reloadVisibleRows:((IndexPath)->())?
    var refreshTable:(()->())?
//    var cellHeightDictionary = NSMutableDictionary()
    var presentImageFullScreenClosure:((Int, Bool)->())?
    var showShareOption:((Int)->())?
    var feedArray:[FeedData] = []
    var currentlyPlayingIndexPath : IndexPath? = nil
    var isNextFeedExist:Bool = true
    var refreshControl = UIRefreshControl()
    var postID:Int?
    var action:String = ""
    var groupObj:GroupValue?
    var isPage:Bool = false
    var isMainFeedView:Bool = false
    var parentView : UIViewController!
    //    var FeedModelObj : FeedModel!
    var isReelsAdded = false
    var isFoundFriend = false
    
    var indexObj : IndexPath!
    var indexPlaying : IndexPath!
    
    var pageCount = 2
    var arrayAds = [GADNativeAd]()
    
    var NextAPICall = -1
    
    
    func initializeMe(action:String){
        self.action = action
//        cellHeightDictionary = NSMutableDictionary.init()
//        self.feedArray.removeAll()
        
        
        
        
        if isMainFeedView {
            if SharedManager.shared.getFeedArray().count > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.feedArray =  SharedManager.shared.getFeedArray()
                    self.resetHeight()
                }
            }
        }
        
        
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.newReactionRecived),name: NSNotification.Name(rawValue: "reactions_count_updated"), object: nil)
        
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    @objc open func refresh(sender:AnyObject) {
        self.isNextFeedExist = true
        self.refreshTable?()
        //        SharedManager.shared.showOnWindow()
        self.feedArray.removeAll()
        pageCount = 2
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    @objc func newReactionRecived(_ notification: Notification){
        
        if let userInfo = notification.userInfo as? [String : Any] {
            
            let postID = (userInfo["post_id"] as? Int)
            let likesCount = (userInfo["likesCount"] as? Int)
            let isReaction = (userInfo["isReaction"] as? String)
            for indexObj in self.feedArray {
                if indexObj.postID == postID {
                    indexObj.isReaction = isReaction
                    indexObj.likeCount = likesCount
                }
            }
        }
        
        if let feedParent = self.parentView as? FeedViewController {
            feedParent.feedTableView.reloadRows(at: feedParent.feedTableView.indexPathsForVisibleRows!, with: .automatic)
        }else 
        if let feedParent = self.parentView as? HiddenFeedViewController {
            // feedParent.feedTableView.reloadRows(at: feedParent.feedTableView.indexPathsForVisibleRows!, with: .automatic)
        }
    }
}

extension FeedViewModel:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.feedArray.count > 0 {
            return self.feedArray.count
        }
        
        return 0
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.feedArray.count > 0 {
            
            if let feedObj: FeedData = self.feedArray[indexPath.row] as? FeedData {
                
                let feedCell:FeedParentCell? = nil
                switch feedObj.postType! {
                case FeedType.friendSuggestion.rawValue :
                    
                    let cellFrind = tableView.dequeueReusableCell(withIdentifier: "FeedFriendSuggestionCell", for: indexPath) as! FeedFriendSuggestionCell
                    
                    
                    cellFrind.reloadData()
                    return cellFrind
                    
                case FeedType.reelsFeed.rawValue :
                    
                    let cellFeed = tableView.dequeueReusableCell(withIdentifier: "FeedReelCell", for: indexPath) as! FeedReelCell
                    
                    cellFeed.reloadData()
                    return cellFeed
                    
                case FeedType.Ad.rawValue:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: AdCell.identifier, for: indexPath) as? AdCell {
                        
                        DispatchQueue.main.async {
                            cell.bannerView.rootViewController = self.parentView
                        }
                        
                        cell.reloadData(parentview: self.parentView ,indexMain: indexPath)
                        
                        return cell
                    }
                    
                case FeedType.post.rawValue:
                    
                    if let cellText = tableView.dequeueReusableCell(withIdentifier: "NewTextFeedCell", for: indexPath) as? NewTextFeedCell {
                        cellText.postObj = feedObj
                        cellText.indexPathMain = indexPath
                        cellText.reloadData()
                        cellText.tblViewImg.invalidateIntrinsicContentSize()
                        cellText.cellDelegate = self
                        //                        self.isFeedReachEnd(indexPath: indexPath)
                        return cellText
                    }
                    
                case FeedType.audio.rawValue:
                    if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewAudioFeedCell", for: indexPath) as? NewAudioFeedCell {
                        cellVideo.postObj = feedObj
                        cellVideo.indexPathMain = indexPath
                        cellVideo.reloadData()
                        cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                        cellVideo.cellDelegate = self
                        //                        self.isFeedReachEnd(indexPath: indexPath)
                        return cellVideo
                    }
                    
                case FeedType.video.rawValue, FeedType.liveStream.rawValue:
                    if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewVideoFeedCell", for: indexPath) as? NewVideoFeedCell {
                        cellVideo.postObj = feedObj
                        cellVideo.parentTblView = tableView
                        cellVideo.indexPathMain = indexPath
                        cellVideo.reloadData()
                        cellVideo.isPlayVideo = false
                        cellVideo.isForWatch = true
                        cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                        cellVideo.cellDelegate = self
                        //                        self.isFeedReachEnd(indexPath: indexPath)
                        return cellVideo
                    }
                    
                case FeedType.image.rawValue:
                    if let cellImage = tableView.dequeueReusableCell(withIdentifier: "NewImageFeedCell", for: indexPath) as? NewImageFeedCell {
                        cellImage.postObj = feedObj
                        cellImage.indexPathMain = indexPath
                        cellImage.reloadData()
                        cellImage.tblViewImg.invalidateIntrinsicContentSize()
                        cellImage.cellDelegate = self
                        //                        self.isFeedReachEnd(indexPath: indexPath)
                        return cellImage
                    }
                    
                case FeedType.file.rawValue:
                    if let cellAttachment = tableView.dequeueReusableCell(withIdentifier: "NewAttachmentFeedCell", for: indexPath) as? NewAttachmentFeedCell {
                        cellAttachment.postObj = feedObj
                        cellAttachment.indexPathMain = indexPath
                        cellAttachment.reloadData()
                        cellAttachment.tblViewImg.invalidateIntrinsicContentSize()
                        cellAttachment.cellDelegate = self
                        return cellAttachment
                    }
                    
                case FeedType.gallery.rawValue:
                    if let cellGallery = tableView.dequeueReusableCell(withIdentifier: "NewGalleryFeedCell", for: indexPath) as? NewGalleryFeedCell {
                        cellGallery.postObj = feedObj
                        cellGallery.indexPathMain = indexPath
                        cellGallery.reloadData()
                        cellGallery.tblViewImg.invalidateIntrinsicContentSize()
                        cellGallery.cellDelegate = self
                        return cellGallery
                    }
                    
                case FeedType.shared.rawValue:
                    if let cellShared = tableView.dequeueReusableCell(withIdentifier: "NewSharedFeedCell", for: indexPath) as? NewSharedFeedCell {
                        cellShared.postObj = feedObj
                        cellShared.indexPathMain = indexPath
                        cellShared.reloadData()
                        cellShared.tblViewImg.invalidateIntrinsicContentSize()
                        cellShared.cellDelegate = self
                        //                        self.isFeedReachEnd(indexPath: indexPath)
                        return cellShared
                    }
                    
                default:
                    LogClass.debugLog("Feed type missing.")
                }
                //                self.isFeedReachEnd(indexPath: indexPath)
                if feedCell != nil {
                    feedCell?.layoutIfNeeded()
                    return feedCell!
                }
            }
            
        } else {
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    @objc func showMoreReels(sender : UIButton){
        
    }
    @objc func DownloadImage(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    @objc func DownloadVideo(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: false, isShare: true, FeedObj: self.feedArray[sender.tag])
    }
    
    
    
    
    @objc func openUSerProfileAction(sender : UIButton) {
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = String(sender.tag)
        vcProfile.otherUserisFriend = "1"
        vcProfile.isNavPushAllow = true
        self.parentView.navigationController!.pushViewController(vcProfile, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedArray.count>0 {
            self.isFeedReachEnd(indexPath: indexPath)
            
            //            self.cellHeightDictionary.setObject(cell.frame.size.height, forKey: indexPath as NSCopying)
            //            if self.isNextFeedExist {
            //                let lastSectionIndex = tableView.numberOfSections - 1
            //                let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            //                if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            //                    let spinner = UIActivityIndicatorView(style: .gray)
            //                    spinner.startAnimating()
            //                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(60))
            //                    tableView.tableFooterView = spinner
            //                    tableView.tableFooterView?.isHidden = false
            //                }
            //            }else {
            //                tableView.tableFooterView?.isHidden = true
            //                tableView.tableFooterView?.removeFromSuperview()
            //            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedArray.count > 0 {
            if indexPath.row > self.feedArray.count-1 {
                return
            }
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            switch feedObj.postType! {
            case FeedType.video.rawValue, FeedType.liveStream.rawValue:
                
                if cell is NewVideoFeedCell {
                    
                    let cell = cell as! NewVideoFeedCell
                    if cell.videoCell != nil {
                        if cell.videoCell!.isPlaying {
                            cell.stopPlayer()
                            LogClass.debugLog("Release player 8")
                            MediaManager.sharedInstance.player?.pause()
                            MediaManager.sharedInstance.releasePlayer()
                        }
                    }
                }
            case FeedType.audio.rawValue:
                
                if cell is NewAudioFeedCell {
                    let cell = cell as! NewAudioFeedCell
                    cell.stopPlayer()
                }
            case FeedType.post.rawValue:
                if cell is PostCell {
                    let cell = cell as! PostCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                }
            case FeedType.file.rawValue:
                if cell is AttachmentCell {
                    let cell = cell as! AttachmentCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                }
            case FeedType.gallery.rawValue:
                if cell is NewGalleryFeedCell {
                    let cell = cell as! NewGalleryFeedCell
                    cell.stopPlayer()
                }
            case FeedType.image.rawValue:
                if cell is ImageCellSingle {
                    let cell = cell as! ImageCellSingle
                    
                }
            case FeedType.shared.rawValue:
                if cell is SharedCell {
                    let cell = cell as! SharedCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.resetSharedElements()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                }
            default:
                LogClass.debugLog("Case not deailing.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat    {
        
        if self.feedArray.count>0   {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            switch feedObj.postType! {
            case FeedType.post.rawValue , FeedType.audio.rawValue
                , FeedType.gallery.rawValue , FeedType.video.rawValue
                , FeedType.image.rawValue , FeedType.file.rawValue :
                if self.feedArray[indexPath.row].isExpand {
                    return UITableView.automaticDimension
                }

                return self.feedArray[indexPath.row].cellHeight!
               
            case FeedType.reelsFeed.rawValue:
                return 320.0
                
            case FeedType.friendSuggestion.rawValue:

                return 325.0
            case FeedType.Ad.rawValue:
                return 150.0
            default:
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.feedArray.count>0   {
                let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
                switch feedObj.postType! {
                case FeedType.post.rawValue ,FeedType.file.rawValue
                    ,FeedType.audio.rawValue , FeedType.gallery.rawValue
                    ,FeedType.video.rawValue, FeedType.liveStream.rawValue
                    , FeedType.image.rawValue:
                    
                    if self.feedArray[indexPath.row].isExpand {
                        return UITableView.automaticDimension
                    }
                    return self.feedArray[indexPath.row].cellHeight!
                  
                case FeedType.reelsFeed.rawValue:
                    return 320
                case FeedType.Ad.rawValue:
                    return 150
                case FeedType.friendSuggestion.rawValue:
                    return 325
                default:
                    return UITableView.automaticDimension
                }
        }
        return UITableView.automaticDimension
    }
    
    
    func showCompitetion(){
        
    }
    
    // Begin and update
    func beginAndEndUpdate(tableView:UITableView){
        DispatchQueue.main.async {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    //Manage pagging
    func isFeedReachEnd(indexPath:IndexPath){
        
        
        if  self.isNextFeedExist {
        
            if indexPath.row == self.NextAPICall {
                self.isNextFeedExist = false
                
                let postObj:FeedData = self.feedArray[indexPath.row] as FeedData
                self.callingFeedService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }
        }
        
    }
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        
        var parameters = ["action": self.action,"token":SharedManager.shared.userToken()]
        
        if self.groupObj?.groupID != nil {
            if isPage {
                parameters["page_id"] = self.groupObj?.groupID
            }else {
                parameters["group_id"] = self.groupObj?.groupID
            }
        }
        parameters["page"] = String(pageCount)
//        parameters["user_id"] = String(SharedManager.shared.getUserID())
        
        if isLastTrue {
            pageCount = pageCount + 1
            parameters["fetch_public_posts_only"] = "1"
            parameters["d"] = "1"
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                        self.refreshControl.endRefreshing()
                        self.hideFooterClosure?()
                        //                        self.isNextFeedExist = false
                        
//                        if let hidenView = self.parentView as? HiddenFeedViewController {
//                           // hidenView.lblEmpty.isHidden = true
//                            if self.feedArray.count == 0 {
//                                hidenView.lblEmpty.isHidden = false
//                            }
//                            
//                        }
                        
                        self.reloadTableViewClosure?()
                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                        
//                        if let hidenView = self.parentView as? HiddenFeedViewController {
//                            hidenView.lblEmpty.isHidden = true
//                            if self.feedArray.count == 0 {
//                                hidenView.lblEmpty.isHidden = false
//                            }
//                            
//                        }
                        self.reloadTableViewClosure?()
                    }
                    
                }else {
                    self.refreshControl.endRefreshing()
                    
                    
//                    if let hidenView = self.parentView as? HiddenFeedViewController {
//                        hidenView.lblEmpty.isHidden = true
//                        if self.feedArray.count == 0 {
//                            hidenView.lblEmpty.isHidden = false
//                        }
//                    }
                    
                    
                    self.reloadTableViewClosure?()
                }
                
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    
    func resetHeight(){
        for indexObj in 0..<self.feedArray.count {
            let objectmain = self.feedArray[indexObj]
            
            if objectmain.postType == FeedType.image.rawValue
                || objectmain.postType == FeedType.audio.rawValue
                || objectmain.postType == FeedType.gallery.rawValue
                || objectmain.postType == FeedType.post.rawValue
                || objectmain.postType == FeedType.video.rawValue
                || objectmain.postType == FeedType.gif.rawValue
                || objectmain.postType == FeedType.liveStream.rawValue {
                
                if objectmain.post != nil {
                    if objectmain.post!.count > 0 {
                        var textHeight = 140.0 + 75
                        var textHeightExpand = 140.0 + 75
                        
                        
                        var heightText = 0.0
                        var heightTextExpand = 0.0
                        
                        
                        if objectmain.body != nil {
                            if objectmain.body!.count > 0 {
                                let heightBody = objectmain.body!.heightString(withConstrainedWidth: UIScreen.main.bounds.size.width - 20, font: UIFont.systemFont(ofSize: 20.0))
                                
                                if heightBody < 25 {
                                    heightText = 65 + heightBody
                                    heightTextExpand = 65 + heightBody
                                }else {
                                    if heightBody < 60 {
                                        heightText = 55 + heightBody
                                    }else {
                                        heightText = 55 + 60
                                    }
                                    heightTextExpand = 55 + heightBody
                                }
                                
                            }else {
                                heightText = heightText + 15
                                heightTextExpand = 15 + heightTextExpand
                            }
                            
                        }
                        
                        if objectmain.postType == FeedType.video.rawValue ||
                            objectmain.postType == FeedType.gif.rawValue ||
                            objectmain.postType == FeedType.liveStream.rawValue {
                            
                            textHeight = 480 + heightText
                            textHeightExpand = 480 + heightTextExpand
                            
                        } else if objectmain.postType == FeedType.file.rawValue{
                            textHeight = 250 + heightText
                            textHeightExpand = 250 + heightTextExpand
                            
                        } else if objectmain.postType == FeedType.post.rawValue{
                            textHeight = 150 + heightText
                            textHeightExpand = 150 + heightTextExpand
                            
                            if objectmain.linkImage != nil &&
                                !(objectmain.linkImage?.contains(".svg") ?? false) {
                                
                                if objectmain.linkImage!.count > 0  {
                                    
                                    textHeight = textHeight + 310.0
                                } else if objectmain.linkTitle!.count > 0 {
                                    textHeight = textHeight + 100.0
                                }
                                
                            } else if objectmain.linkTitle != nil  {
                                
                                if objectmain.linkTitle!.count > 0 {
                                    textHeight = textHeight + 100.0
                                }
                            }
                            
                        } else if objectmain.postType == FeedType.image.rawValue{
                            textHeight = 480 + heightText
                            textHeightExpand = 480 + heightTextExpand
                            
                        } else if objectmain.postType == FeedType.audio.rawValue{
                            textHeight = 210 + heightText
                            textHeightExpand = 210 + heightTextExpand
                            
                        } else if objectmain.postType == FeedType.gallery.rawValue{
                            textHeight = 450 + heightText
                            textHeightExpand = 450 + heightTextExpand
                        } else if objectmain.linkImage != nil &&  !(objectmain.linkImage?.contains(".svg") ?? false) {
                            
                            if objectmain.linkImage!.count > 0 {
                                textHeight = textHeight + 250.0
                                textHeightExpand = 250 + heightTextExpand
                            } else if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 150.0
                                textHeightExpand = 150.0 + heightTextExpand
                            }
                        } else if objectmain.linkTitle != nil  {
                            if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 150.0
                                textHeightExpand = 150.0 + heightTextExpand
                            }
                        }
                        
                        objectmain.cellHeight =  textHeight
                        objectmain.cellHeightExpand =  textHeightExpand
//                        arraySaveFeed.append(objectmain)
//                        self.feedArray.append(objectmain)
                        self.feedArray[indexObj] = objectmain
                        
                    }else { //
                        var textHeight = 140.0 + 75
                        var textHeightExpand = 140.0 + 75
                        
                        
                        var heightText = 0.0
                        var heightTextExpand = 0.0
                        
                        
                        if objectmain.body != nil {
                            if objectmain.body!.count > 0 {
                                let heightBody = objectmain.body!.heightString(withConstrainedWidth: UIScreen.main.bounds.size.width - 20, font: UIFont.systemFont(ofSize: 20.0))
                                
                                if heightBody < 25 {
                                    heightText = 65 + heightBody
                                    heightTextExpand = 65 + heightBody
                                }else {
                                    if heightBody < 60 {
                                        heightText = 55 + heightBody
                                    }else {
                                        heightText = 55 + 60
                                    }

                                    heightTextExpand = 55 + heightBody
                                }
                                
                            }
                        }
                        
                        textHeight = 150 + heightText
                        textHeightExpand = 150 + heightTextExpand
                        if objectmain.linkImage != nil &&
                            !(objectmain.linkImage?.contains(".svg") ?? false) {
                            if objectmain.linkImage!.count > 0 {
                                textHeight = textHeight + 250.0
                            }else if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 100.0
                            }
                        } else if objectmain.linkTitle != nil  {
                            if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 100.0
                            }
                        }
                        
                        

                        objectmain.cellHeight =  textHeight
                        objectmain.cellHeightExpand =  textHeightExpand
                        
                        
                        
//                        arraySaveFeed.append(objectmain)
//                        self.feedArray.append(objectmain)
                        self.feedArray[indexObj] = objectmain
                    }
                }
            }
        }
        
        self.reloadTableViewClosure?()
    }
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        
        if self.pageCount % 2 == 0 {
            ImageCache.default.memoryStorage.removeAll()
            ImageCache.default.clearMemoryCache()
            ImageCache.default.clearDiskCache()
            ImageCache.default.cleanExpiredDiskCache()
            
        }
//        if feedObj.data?.count == 0 {
            if feedObj.data!.count > 0 {
                let mainData = [String : Any]()
                let newFeed = FeedData.init(valueDict: mainData)
                newFeed.postType = FeedType.Ad.rawValue
                self.feedArray.append(newFeed)
                
//                SharedManager.shared.saveFeedArray(arrayFeedModel: feedObj.data!)
                
            }
//        }
        
        
        var arraySaveFeed = [FeedData]()
        if let isFeedData = feedObj.data {
            if isFeedData.count == 0 {
                
            } else {
                self.isNextFeedExist = true
                var newArray = [FeedData]()
                newArray.append(contentsOf: isFeedData)
                
                self.NextAPICall = self.feedArray.count + (isFeedData.count/3)
                
                
                if SharedManager.shared.postCreateTop != nil {
                    newArray.insert(SharedManager.shared.postCreateTop!, at: 0)
                    SharedManager.shared.postCreateTop = nil
                }
                
                for indexObj in 0..<newArray.count {
                    let objectmain = newArray[indexObj]
                    
                    if objectmain.postType == FeedType.image.rawValue
                        || objectmain.postType == FeedType.audio.rawValue
                        || objectmain.postType == FeedType.gallery.rawValue
                        || objectmain.postType == FeedType.post.rawValue
                        || objectmain.postType == FeedType.video.rawValue
                        || objectmain.postType == FeedType.gif.rawValue
                        || objectmain.postType == FeedType.liveStream.rawValue {
                        
                        if objectmain.post != nil {
                            if objectmain.post!.count > 0 {
                                var textHeight = 140.0 + 75
                                var textHeightExpand = 140.0 + 75
                                
                                
                                var heightText = 0.0
                                var heightTextExpand = 0.0
                                
                                
                                if objectmain.body != nil {
                                    if objectmain.body!.count > 0 {
                                        let heightBody = objectmain.body!.heightString(withConstrainedWidth: UIScreen.main.bounds.size.width - 20, font: UIFont.systemFont(ofSize: 20.0))
                                        
                                        if heightBody < 25 {
                                            heightText = 65 + heightBody
                                            heightTextExpand = 65 + heightBody
                                        }else {
                                            if heightBody < 60 {
                                                heightText = 55 + heightBody
                                            }else {
                                                heightText = 55 + 60
                                            }
                                            heightTextExpand = 55 + heightBody
                                        }
                                        
                                    }else {
                                        heightText = heightText + 15
                                        heightTextExpand = 15 + heightTextExpand
                                    }
                                    
                                }
                                
                                if objectmain.postType == FeedType.video.rawValue ||
                                    objectmain.postType == FeedType.gif.rawValue ||
                                    objectmain.postType == FeedType.liveStream.rawValue {
                                    
                                    textHeight = 480 + heightText
                                    textHeightExpand = 480 + heightTextExpand
                                    
                                } else if objectmain.postType == FeedType.file.rawValue{
                                    textHeight = 250 + heightText
                                    textHeightExpand = 250 + heightTextExpand
                                    
                                } else if objectmain.postType == FeedType.post.rawValue{
                                    textHeight = 150 + heightText
                                    textHeightExpand = 150 + heightTextExpand
                                    
                                    if objectmain.linkImage != nil &&
                                        !(objectmain.linkImage?.contains(".svg") ?? false) {
                                        
                                        if objectmain.linkImage!.count > 0  {
                                            
                                            textHeight = textHeight + 310.0
                                        } else if objectmain.linkTitle!.count > 0 {
                                            textHeight = textHeight + 100.0
                                        }
                                        
                                    } else if objectmain.linkTitle != nil  {
                                        
                                        if objectmain.linkTitle!.count > 0 {
                                            textHeight = textHeight + 100.0
                                        }
                                    }
                                    
                                } else if objectmain.postType == FeedType.image.rawValue{
                                    textHeight = 480 + heightText
                                    textHeightExpand = 480 + heightTextExpand
                                    
                                } else if objectmain.postType == FeedType.audio.rawValue{
                                    textHeight = 210 + heightText
                                    textHeightExpand = 210 + heightTextExpand
                                    
                                } else if objectmain.postType == FeedType.gallery.rawValue{
                                    textHeight = 450 + heightText
                                    textHeightExpand = 450 + heightTextExpand
                                } else if objectmain.linkImage != nil &&  !(objectmain.linkImage?.contains(".svg") ?? false) {
                                    
                                    if objectmain.linkImage!.count > 0 {
                                        textHeight = textHeight + 250.0
                                        textHeightExpand = 250 + heightTextExpand
                                    } else if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 150.0
                                        textHeightExpand = 150.0 + heightTextExpand
                                    }
                                } else if objectmain.linkTitle != nil  {
                                    if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 150.0
                                        textHeightExpand = 150.0 + heightTextExpand
                                    }
                                }
                                
                                objectmain.cellHeight =  textHeight
                                objectmain.cellHeightExpand =  textHeightExpand
                                arraySaveFeed.append(objectmain)
                                self.feedArray.append(objectmain)
                            }else { //
                                var textHeight = 140.0 + 75
                                var textHeightExpand = 140.0 + 75
                                
                                
                                var heightText = 0.0
                                var heightTextExpand = 0.0
                                
                                
                                if objectmain.body != nil {
                                    if objectmain.body!.count > 0 {
                                        let heightBody = objectmain.body!.heightString(withConstrainedWidth: UIScreen.main.bounds.size.width - 20, font: UIFont.systemFont(ofSize: 20.0))
                                        
                                        if heightBody < 25 {
                                            heightText = 65 + heightBody
                                            heightTextExpand = 65 + heightBody
                                        }else {
                                            if heightBody < 60 {
                                                heightText = 55 + heightBody
                                            }else {
                                                heightText = 55 + 60
                                            }

                                            heightTextExpand = 55 + heightBody
                                        }
                                        
                                    }
                                }
                                
                                textHeight = 150 + heightText
                                textHeightExpand = 150 + heightTextExpand
                                if objectmain.linkImage != nil &&
                                    !(objectmain.linkImage?.contains(".svg") ?? false) {
                                    if objectmain.linkImage!.count > 0 {
                                        textHeight = textHeight + 250.0
                                    }else if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 100.0
                                    }
                                } else if objectmain.linkTitle != nil  {
                                    if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 100.0
                                    }
                                }
                                
                                
 
                                objectmain.cellHeight =  textHeight
                                objectmain.cellHeightExpand =  textHeightExpand
                                
                                
                                
                                arraySaveFeed.append(objectmain)
                                self.feedArray.append(objectmain)
                            }
                        }
                    }
                }
            }
        }
        
        
        SharedManager.shared.saveFeedArray(arrayFeedModel: arraySaveFeed)
        if self.parentView.isKind(of: FeedViewController.self) {
            let mainData = [String : Any]()
            let newFeedReels = FeedData.init(valueDict: mainData)
            newFeedReels.postType = FeedType.reelsFeed.rawValue
            newFeedReels.cellHeight = 320.0
            newFeedReels.cellHeightExpand = 320.0
            if !self.isReelsAdded {
                if self.feedArray.count > 16 {
                    self.feedArray.insert(newFeedReels, at: 16)
                    self.isReelsAdded = true
                }
            }
        }
        
        if self.parentView.isKind(of: FeedViewController.self) {
            let mainDataFriend = [String : Any]()
            let newFeedFriend = FeedData.init(valueDict: mainDataFriend)
            newFeedFriend.postType = FeedType.friendSuggestion.rawValue
            newFeedFriend.cellHeight = 250.0
            newFeedFriend.cellHeightExpand = 250.0
            
            if !isFoundFriend {
                if self.feedArray.count > 9 {
                    self.feedArray.insert(newFeedFriend, at: 8)
                    self.isFoundFriend = true
                }
            }
        }
        
        
        self.refreshControl.endRefreshing()
//        if let hidenView = self.parentView as? HiddenFeedViewController {
//            hidenView.lblEmpty.isHidden = true
//            if self.feedArray.count == 0 {
//                hidenView.lblEmpty.isHidden = false
//            }
//        }
        
        self.reloadTableViewClosure?()
    }
    
    func videoPlayerCallbackHandler()   {
        
    }
    
}

//MARK:UITextViewDelegate...
extension FeedViewModel:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        return true
    }
}

extension FeedViewModel:UIScrollViewDelegate {
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //        if !scrollView.isDecelerating && !scrollView.isDragging {
    //
    //        }
    //    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { playVideo() }
    }
    
    
    func playVideo(){
        if let parentVC = self.parentView as? FeedViewController  {
            let indexPath = parentVC.feedTableView.indexPathForRow(at: parentVC.feedTableView.bounds.center)
            
            if indexPath == nil {
                return
            }
            
            if let cellVideo = parentVC.feedTableView.cellForRow(at:indexPath!) as? NewVideoFeedCell {
                
                if MediaManager.sharedInstance.player != nil {
                    if (MediaManager.sharedInstance.player?.isPlaying != nil) {
                        if (MediaManager.sharedInstance.player!.isPlaying)  {
                            
                        }else {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                                cellVideo.isPlayVideo = true
                                cellVideo.playPlayer()
                            }
                        }
                    }else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                            cellVideo.isPlayVideo = true
                            cellVideo.playPlayer()
                        }
                    }
                }else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                        cellVideo.isPlayVideo = true
                        cellVideo.playPlayer()
                    }
                }
                
            }else if let cellVideo = parentVC.feedTableView.cellForRow(at:indexPath!) as? NewGalleryFeedCell {
                cellVideo.playGalleryVideo()
            }else{
                if (MediaManager.sharedInstance.player?.isPlaying != nil) {
                    if (MediaManager.sharedInstance.player!.isPlaying)  {
                        MediaManager.sharedInstance.player?.stop()
                    }
                }
            }
        }
        
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.feedScrollHandler?()
    }
}



extension FeedViewModel : DelegateAdData {
    func delegateAdReturnFunction(dataMain:Any) {
        
    }
}
