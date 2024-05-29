//
//  TagsViewModell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 06/04/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

class TagsViewModell: NSObject {
    var feedScrollHandler: (()->())?
    var reloadTableViewClosure: (()->())?
    var didSelectTableClosure:((IndexPath)->())?
    var reloadTableViewWithNoneClosure: (()->())?
    var hideFooterClosure: (()->())?
    var showAlertMessageClosure:((String)->())?
    var showloadingBar:(()->())?
    var reloadSpecificRow:((IndexPath)->())?
    var reloadVisibleRows:((IndexPath)->())?
    var cellHeightDictionary = NSMutableDictionary()
    var presentImageFullScreenClosure:((Int, Bool)->())?
    var showShareOption:((Int)->())?
    var feedArray:[FeedData] = []
    var currentlyPlayingIndexPath : IndexPath? = nil
    var isNextFeedExist:Bool = true
    var refreshControl = UIRefreshControl()
    var postID:Int?
    var action:String = ""
    var pageNumber:Int = 1
    var groupObj:GroupValue?
    var isPage:Bool = false
    var parentView : TagsVC!
    
    func initializeMe(action:String){
        self.action = action
        
        if self.feedArray.count == 0 {
            
            DispatchQueue.main.async {
//                SharedManager.shared.showOnWindow()
                Loader.startLoading()
            }
        }
        
        if self.parentView != nil {
            if self.parentView.Hashtags.count != 0 {
                self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
                
                NotificationCenter.default.addObserver(self,selector:#selector(self.newReactionRecived),name: NSNotification.Name(rawValue: "reactions_count_updated"), object: nil)
            }
        }
        
        
        
        
        
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
        
        //        if let feedParent = self.parentView {
        self.parentView.saveTableView.reloadRows(at: self.parentView.saveTableView.indexPathsForVisibleRows!, with: .automatic)
        //        }
    }
    
    @objc open func refresh(sender:AnyObject) {
        self.isNextFeedExist = true
        self.pageNumber = 1
        self.isNextFeedExist = true
        //        self.feedArray.removeAll()
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
}

extension TagsViewModell:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.parentView.lblEmpty.isHidden = false
        if self.feedArray.count > 0 {
            
            self.parentView.lblEmpty.isHidden = true
            return self.feedArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.feedArray.count > 0 {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            var feedCell:FeedParentCell? = nil
            switch feedObj.postType! {
                
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
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellText
                }
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged { [weak self] newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //
                //
                //                    if let viewComment = cell.commentView as? FeedCommentBarView {
                ////                        viewComment.btnUserProfile.tag = feedObj.authorID!
                ////                        viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                    }
                //                }
            case FeedType.audio.rawValue:
                if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewAudioFeedCell", for: indexPath) as? NewAudioFeedCell {
                    cellVideo.postObj = feedObj
                    cellVideo.indexPathMain = indexPath
                    cellVideo.reloadData()
                    cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                    cellVideo.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellVideo
                }
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: AudioCell.identifier, for: indexPath) as? AudioCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //
                //
                //                    if let viewComment = cell.commentView as? FeedCommentBarView {
                ////                        viewComment.btnUserProfile.tag = feedObj.authorID!
                ////                        viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                    }
                //                }
                
            case FeedType.video.rawValue , FeedType.liveStream.rawValue:
                if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewVideoFeedCell", for: indexPath) as? NewVideoFeedCell {
                    cellVideo.postObj = feedObj
                    cellVideo.parentTblView = tableView
                    cellVideo.indexPathMain = indexPath
                    cellVideo.reloadData()
                    cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                    cellVideo.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellVideo
                }
                
                //            case  FeedType.liveStream.rawValue :
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, shouldPlay: self.currentlyPlayingIndexPath == indexPath, indexValue: indexPath,reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //                    cell.videoPlayerIndexCallback = { (indexValue) in
                //                        self.currentlyPlayingIndexPath = indexValue
                //                    }
                //
                //
                //                    if let viewComment = cell.commentView as? FeedCommentBarView {
                ////                        viewComment.btnUserProfile.tag = feedObj.authorID!
                ////                        viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                    }
                //                    cell.btnShare.tag = indexPath.row
                //                    cell.btnShare.addTarget(self, action: #selector(self.DownloadVideo), for: .touchUpInside)
                //                }
            case FeedType.image.rawValue:
                if let cellImage = tableView.dequeueReusableCell(withIdentifier: "NewImageFeedCell", for: indexPath) as? NewImageFeedCell {
                    cellImage.postObj = feedObj
                    cellImage.indexPathMain = indexPath
                    cellImage.reloadData()
                    cellImage.tblViewImg.invalidateIntrinsicContentSize()
                    cellImage.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellImage
                }
                
 
            case FeedType.file.rawValue:
                if let cellAttachment = tableView.dequeueReusableCell(withIdentifier: "NewAttachmentFeedCell", for: indexPath) as? NewAttachmentFeedCell {
                    cellAttachment.postObj = feedObj
                    cellAttachment.indexPathMain = indexPath
                    cellAttachment.reloadData()
                    cellAttachment.tblViewImg.invalidateIntrinsicContentSize()
                    cellAttachment.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellAttachment
                }
      
            case FeedType.gallery.rawValue:
                if let cellGallery = tableView.dequeueReusableCell(withIdentifier: "NewGalleryFeedCell", for: indexPath) as? NewGalleryFeedCell {
                    cellGallery.postObj = feedObj
                    cellGallery.indexPathMain = indexPath
                    cellGallery.reloadData()
                    cellGallery.tblViewImg.invalidateIntrinsicContentSize()
                    cellGallery.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellGallery
                }
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: GalleryCell.identifier, for: indexPath) as? GalleryCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.isAppearFrom = "Feed"
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        DispatchQueue.main.async {
                //                            self!.beginAndEndUpdate(tableView: tableView)
                //                        }
                //                    }
                //
                //
                //                    if let viewComment = cell.commentView as? FeedCommentBarView {
                ////                        viewComment.btnUserProfile.tag = feedObj.authorID!
                ////                        viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                    }
                //
                //
                //                }
            case FeedType.shared.rawValue:
                if let cellShared = tableView.dequeueReusableCell(withIdentifier: "NewSharedFeedCell", for: indexPath) as? NewSharedFeedCell {
                    cellShared.postObj = feedObj
                    cellShared.indexPathMain = indexPath
                    cellShared.reloadData()
                    cellShared.tblViewImg.invalidateIntrinsicContentSize()
                    cellShared.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellShared
                }
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: SharedCell.identifier, for: indexPath) as? SharedCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.parentview = self.parentView
                //                    cell.textChanged {[weak self]newText in
                //                        DispatchQueue.main.async {
                //                            self!.beginAndEndUpdate(tableView: tableView)
                //                        }
                //                    }
                //                    cell.imageSelectedClosure = { (indexValue, isGroup) in
                //                        self.presentImageFullScreenClosure?(indexValue, isGroup)
                //                    }
                //
                //
                //                    if let viewComment = cell.commentView as? FeedCommentBarView {
                ////                        viewComment.btnUserProfile.tag = feedObj.authorID!
                ////                        viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                    }
                //                }
            default:
                LogClass.debugLog("Feed type missing.")
            }
            self.isFeedReachEnd(indexPath: indexPath)
            if feedCell != nil {
                feedCell?.layoutIfNeeded()
                return feedCell!
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonCell.identifier, for: indexPath) as? SkeletonCell{
                cell.layoutIfNeeded()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    @objc func openUSerProfileAction(sender : UIButton){
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = String(sender.tag)
        vcProfile.otherUserisFriend = "1"
        vcProfile.isNavPushAllow = true
        self.parentView.navigationController!.pushViewController(vcProfile, animated: true)
    }
    
    
    @objc func DownloadImage(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    @objc func DownloadVideo(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: false, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedArray.count>0 {
            self.cellHeightDictionary.setObject(cell.frame.size.height, forKey: indexPath as NSCopying)
            if self.isNextFeedExist {
                let lastSectionIndex = tableView.numberOfSections - 1
                let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
                if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                    let spinner = UIActivityIndicatorView(style: .gray)
                    spinner.startAnimating()
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(60))
                    tableView.tableFooterView = spinner
                    tableView.tableFooterView?.isHidden = false
                }
            }else {
                tableView.tableFooterView?.isHidden = true
                tableView.tableFooterView?.removeFromSuperview()
            }
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
                if cell is VideoCell {
                    let cell = cell as! VideoCell
                    cell.resetVideoPlayer()
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.audio.rawValue:
                if cell is AudioCell {
                    let cell = cell as! AudioCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.xqAudioPlayer.resetXQPlayer()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }else if cell is NewAudioFeedCell {
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
                    //                    cell.commentViewRef.removeDropDown()
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
                if cell is GalleryCell {
                    let cell = cell as! GalleryCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.resetCollectionCell()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.image.rawValue:
                if cell is ImageCellSingle {
                    let cell = cell as! ImageCellSingle
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.shared.rawValue:
                if cell is SharedCell {
                    let cell = cell as! SharedCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.resetSharedElements()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                  cell.commentViewRef.removeDropDown()
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
                    //                        return self.feedArray[indexPath.row].cellHeightExpand!
                    return UITableView.automaticDimension
                }
                return self.feedArray[indexPath.row].cellHeight!
               
                
            case FeedType.reelsFeed.rawValue:
                return 280.0
                
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
            if self.cellHeightDictionary.object(forKey: indexPath) != nil {
                let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
                switch feedObj.postType! {
                case FeedType.post.rawValue ,FeedType.file.rawValue
                    ,FeedType.audio.rawValue , FeedType.gallery.rawValue
                    ,FeedType.video.rawValue, FeedType.liveStream.rawValue
                    , FeedType.image.rawValue:
                    //                    return UITableView.automaticDimension
                    
                    if self.feedArray[indexPath.row].isExpand {
                        //                            return self.feedArray[indexPath.row].cellHeightExpand!
                        return UITableView.automaticDimension
                    }
                    return self.feedArray[indexPath.row].cellHeight!
                
                case FeedType.reelsFeed.rawValue:
                    return 250
                case FeedType.Ad.rawValue:
                    return 150
                case FeedType.friendSuggestion.rawValue:
                    return 325
                default:
                    return UITableView.automaticDimension
                }
            }
        }
        return UITableView.automaticDimension
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
            let feedCurrentCount = self.feedArray.count
            if indexPath.row == feedCurrentCount-1 {
                
                self.pageNumber = self.pageNumber + 1
                let postObj:FeedData = self.feedArray[indexPath.row] as FeedData
                self.callingFeedService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }
        }
    }
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        var parameters = ["action": self.action,"token":SharedManager.shared.userToken()]
        parameters["hash_tag_name"] = (self.parentView as? TagsVC)?.Hashtags

        parameters["page"] = String(self.pageNumber)
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedTagsModel), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message!.contains("not found")) != nil) {
                        self.refreshControl.endRefreshing()
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.refreshControl.endRefreshing()
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    
    func handleFeedResponse(feedObj:FeedTagsModel, isRefresh:Bool){
        
        
        
        
        self.parentView.lblTagMain.text = feedObj.data?.hash_tag_name
        self.parentView.lblTagDescription.text = feedObj.data?.hash_tag_description

        
        if self.pageNumber == 1 {
            self.feedArray.removeAll()
        }
        
        if let isFeedData = feedObj.data?.news_feed {
            if isFeedData.count == 0 {

            }else {

                self.isNextFeedExist = true
                var newArray = [FeedData]()
                newArray.append(contentsOf: isFeedData)
                
                for indexObj in 0..<newArray.count {

                    let objectmain = newArray[indexObj]
                    
                    if objectmain.postType == FeedType.image.rawValue
                        || objectmain.postType == FeedType.audio.rawValue
                        || objectmain.postType == FeedType.gallery.rawValue
                        || objectmain.postType == FeedType.post.rawValue
                        || objectmain.postType == FeedType.video.rawValue
                        || objectmain.postType == FeedType.gif.rawValue
                        || objectmain.postType == FeedType.liveStream.rawValue
                    {

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
                                        heightText = 30 + heightText
                                        heightTextExpand = 30 + heightTextExpand
                                    }
                                    
                                }else {
                                    heightText = 30 + heightText
                                    heightTextExpand = 30 + heightTextExpand
                                }
                                
                                if
                                    objectmain.postType == FeedType.video.rawValue ||
                                        objectmain.postType == FeedType.gif.rawValue ||
                                        objectmain.postType == FeedType.liveStream.rawValue
                                {
                                    textHeight = 450 + heightText
                                    textHeightExpand = 450 + heightTextExpand
                                }else if objectmain.postType == FeedType.file.rawValue{
                                    textHeight = 250 + heightText
                                    textHeightExpand = 250 + heightTextExpand
                                    
                                }else if objectmain.postType == FeedType.post.rawValue{
                                    textHeight = 150 + heightText
                                    textHeightExpand = 150 + heightTextExpand
                                    if objectmain.linkImage != nil {
                                        if objectmain.linkImage!.count > 0 {
                                            textHeight = textHeight + 250.0
                                        }else if objectmain.linkTitle!.count > 0 {
                                            textHeight = textHeight + 100.0
                                        }
                                    }else if objectmain.linkTitle != nil  {
                                        if objectmain.linkTitle!.count > 0 {
                                            textHeight = textHeight + 100.0
                                        }
                                    }
                                    
                                }else if objectmain.postType == FeedType.image.rawValue{
                                    textHeight = 450 + heightText
                                    textHeightExpand = 450 + heightTextExpand
                                    
                                }else if objectmain.postType == FeedType.audio.rawValue{
                                    textHeight = 210 + heightText
                                    textHeightExpand = 210 + heightTextExpand
                                    
                                }else if objectmain.postType == FeedType.gallery.rawValue{
                                    textHeight = 450 + heightText
                                    textHeightExpand = 450 + heightTextExpand
                                }else if objectmain.linkImage != nil {
                                    if objectmain.linkImage!.count > 0 {
                                        textHeight = textHeight + 250.0
                                        textHeightExpand = 250 + heightTextExpand
                                    }else if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 150.0
                                        textHeightExpand = 150.0 + heightTextExpand
                                    }
                                }else if objectmain.linkTitle != nil  {
                                    if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 150.0
                                        textHeightExpand = 150.0 + heightTextExpand
                                    }
                                }
                                objectmain.cellHeight =  textHeight
                                objectmain.cellHeightExpand =  textHeightExpand
                                
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
                                if objectmain.linkImage != nil {
                                    if objectmain.linkImage!.count > 0 {
                                        textHeight = textHeight + 250.0
                                    }else if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 100.0
                                    }
                                }else if objectmain.linkTitle != nil  {
                                    if objectmain.linkTitle!.count > 0 {
                                        textHeight = textHeight + 100.0
                                    }
                                }
                                objectmain.cellHeight =  textHeight
                                objectmain.cellHeightExpand =  textHeightExpand
                                
                                self.feedArray.append(objectmain)
                            }
                        }
                    }
                }
            }
        }
//        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
        self.reloadTableViewClosure?()
    }
    
  
    func videoPlayerCallbackHandler()   {
        
    }
    
   
}

//MARK:UITextViewDelegate...
extension TagsViewModell:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        return true
    }
}

extension TagsViewModell:UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && !scrollView.isDragging {
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
        }
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.feedScrollHandler?()
    }
}



extension TagsViewModell : CellDelegate {
    
    func reloadTableDataFriendShipStatus(feedObj: FeedData) {
        
    }
    
    func moreAction(indexObj: IndexPath, feedObj: FeedData) {
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        
        reportController.reportType = "Post"
        reportController.currentIndex = indexObj
        reportController.feedObj = feedObj
        
        if let parentVC = self.parentView as? TagsVC{
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
        
        if let parentVC = self.parentView as? TagsVC{
            if Int(userID) == SharedManager.shared.getUserID() {
                parentVC.tabBarController?.selectedIndex = 3
            } else {
                let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
                vcProfile.isNavPushAllow = true
                parentVC.navigationController?.pushViewController(vcProfile, animated: true)
            }
        }
    }
    
    func sharePostAction(indexObj : IndexPath , feedObj : FeedData){
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedObj.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        
        if let parentVC = self.parentView as? TagsVC{
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
                self.parentView.downloadFile(filePath: urlString!, isImage: isImage!, isShare: false, FeedObj: feedObj)
            }
        }
        
    }
    
    
    
    func imgShowAction(indexObj : IndexPath , feedObj : FeedData){
        
        if let parentVC = self.parentView as? TagsVC{
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var feeddata:FeedData?
            //            if parentVC.isGroup {
            
            //                feeddata = feedObj!.sharedData
            //            }else {
            feeddata = feedObj
            //            }
            fullScreen.isInfoViewShow = false
            fullScreen.collectionArray = feeddata!.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = 0
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = IndexPath.init(row: indexObj.row, section: 0)
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: (parentVC as! TagsVC).saveTableView.visibleCells)
            parentVC.present(fullScreen, animated: false, completion: nil)
            
        }
        
    }
    
    func reloadRow(indexObj : IndexPath , feedObj : FeedData)
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            self.reloadTableViewClosure?()
            self.reloadSpecificRow?(indexObj)
        }
        
    }
    
    
    func commentActions(indexObj : IndexPath , feedObj : FeedData , typeAction: ActionType){
    
    }
}


