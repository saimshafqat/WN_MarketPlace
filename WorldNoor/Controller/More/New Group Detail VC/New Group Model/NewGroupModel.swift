//
//  NewGroupModel.swift
//  WorldNoor
//
//  Created by apple on 11/17/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//


import Foundation
import UIKit
import SDWebImage
import SwiftDate
import Photos
import TLPhotoPicker
import AVFoundation
import AVKit
import SKPhotoBrowser
import Photos
import FittedSheets
import TOCropViewController
import GoogleMobileAds
import FTPopOverMenu


class NewGroupModel: NSObject , PickerviewDelegate{
    var reloadTableViewClosure: (()->())?
    var feedScrollHandler: (()->())?
    var hideSkeletonClosure: (()->())?
    var didSelectTableClosure:((IndexPath)->())?
    var reloadTableViewWithNoneClosure: (()->())?
    var hideFooterClosure: (()->())?
    var showAlertMessageClosure:((String)->())?
    var showloadingBar:(()->())?
    var showShareOption:((Int)->())?
    var reloadSpecificRow:((IndexPath)->())?
    var cellHeightDictionary: NSMutableDictionary
    var presentImageFullScreenClosure:((Int, Bool)->())?
    var feedArray:[FeedData] = []
    var currentlyPlayingIndexPath : IndexPath? = nil
    var isNextFeedExist:Bool = true
    var refreshControl = UIRefreshControl()
    var postID:Int?
    var arrayInterest = [InterestModel]()
    var arrayContactGroup = [ContactModel]()
    var feedtble = UITableView.init()
    var parentView : NewGroupDetailVC!
    var arrayBottom = [[String : String]]()
    var selectedTab: selectedUserTab = selectedUserTab.nothing
    var indexImage = 1
    
    var imageType = ""
    var isCoverPhoto = 0
    
    
    override init() {
        cellHeightDictionary = NSMutableDictionary()
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangeNotification),name: NSNotification.Name(Const.KLangChangeNotif),object: nil)
        self.feedArray.removeAll()
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.newReactionRecived),name: NSNotification.Name(rawValue: "reactions_count_updated"), object: nil)
        
        
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
        
        if let feedParent = self.parentView {
            feedParent.profileTableView.reloadRows(at: feedParent.profileTableView.indexPathsForVisibleRows!, with: .automatic)
        }
    }
    
    @objc func languageChangeNotification(){
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    @objc open func refresh(sender:AnyObject) {
        self.isNextFeedExist = true
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    
    func pickerChooseView(text: String , type : Int ) {
        
        var selectedInterests = [InterestModel]()
        let textarray = text.components(separatedBy: ",")
        for indexObj in textarray {
            for indexInner in self.arrayInterest {
                if indexObj == indexInner.name {
                    selectedInterests.append(indexInner)
                }
            }
        }
        
        self.updateInterest(selectedInterests: selectedInterests)
        
    }
    
    func updateInterest(selectedInterests : [InterestModel]){
        
        
        let userToken = SharedManager.shared.userToken()
        
        var action = ""
        var InterestsID = [String]()
        
        
        action = "user/interests/update"
        
        for indexObj in selectedInterests {
            InterestsID.append(indexObj.id)
        }
        
        let parameters = ["action": action,"token": userToken , "interest_id" : InterestsID ] as [String : Any]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        RequestManager.fetchDataPost(Completion: { response in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    SharedManager.shared.userEditObj.InterestArray = selectedInterests
                    self.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 9)
                }
            }
        }, param:parameters)
    }
    
}

extension NewGroupModel:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if self.parentView.groupObj!.isMember && self.selectedTab == .timeline {
                return 4
            }
            return 3
        }
        
        
        
        if self.selectedTab == .friends {
            if self.parentView.groupObj!.is_reviewd {
                return self.feedArray.count + 1
            }else {
                return self.feedArray.count + 2
            }
            
        }
        if self.selectedTab == .timeline {
            if self.feedArray.count > 0 {
                return self.feedArray.count
            }
            return 0
        }else if self.selectedTab == .photos || self.selectedTab == .videos{
            return 1
        }
        
        return self.arrayBottom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                return self.ProfileUserNameCell(tableView: tableView, cellForRowAt: indexPath)
            }else  if indexPath.row == 2 {
                return self.GroupTabCell(tableView: tableView, cellForRowAt: indexPath)
            }else if indexPath.row == 3 && self.parentView.groupObj!.isMember {
                let cellCreate = tableView.dequeueReusableCell(withIdentifier: "NewPageCreateVC", for: indexPath) as! NewPageCreateVC
                
                cellCreate.btnLive.addTarget(self, action: #selector(self.goLiveBtnClicked), for: .touchUpInside)
                
                cellCreate.btnVideo.addTarget(self, action: #selector(self.createPostBtnClicked), for: .touchUpInside)
                cellCreate.btnImage.addTarget(self, action: #selector(self.createPostBtnClicked), for: .touchUpInside)
                cellCreate.btnMore.addTarget(self, action: #selector(self.createPostBtnClicked), for: .touchUpInside)
                cellCreate.btnText.addTarget(self, action: #selector(self.createPostBtnClicked), for: .touchUpInside)
                
                cellCreate.selectionStyle = .none
                return cellCreate
            }else {
                return self.ProfileImageHeaderCell(tableView: tableView, cellForRowAt: indexPath)
            }
        }
        
        if selectedTab == .videos {
            
            if self.feedArray.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return ProfileImageCell(tableView: tableView, cellForRowAt: indexPath)
            }
            
        }else if selectedTab == .photos {
            
            if self.feedArray.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return ProfileImageCell(tableView: tableView, cellForRowAt: indexPath)
            }
            
        }else if self.selectedTab == .aboutMe {
            return self.ProfileUserinfoCell(tableView: tableView, cellForRowAt: indexPath)
        }
        var indexPathain = indexPath.row
        
        var indexPathMain = indexPath
        
        if selectedTab == .friends {
            
            if indexPath.row == 0 {
                return self.NewPageReviewCell(tableView: tableView, cellForRowAt: indexPath)
            }else if indexPath.row == 1 && !self.parentView.groupObj!.is_reviewd{
                return NewPageAddReviewCell(tableView: tableView, cellForRowAt: indexPath)
            }
            
            
            if self.parentView.groupObj!.is_reviewd {
                indexPathain = indexPath.row - 1
            }else {
                indexPathain = indexPath.row - 2
            }
            
            indexPathMain = IndexPath.init(row: indexPathain, section: indexPath.section)
        }
        
        if self.feedArray.count > 0 {
            
            let feedObj:FeedData = self.feedArray[indexPathain] as FeedData
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
                ////                    if let viewComment = cell.commentViewRef {
                ////
                ////                        if feedObj.comments != nil  {
                ////                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                ////                            }
                ////                        }
                ////                    }
                //                }
                
            case FeedType.pageReview.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell {
                    cell.feedArray = self.feedArray
                    cell.manageCellData(feedObj: feedObj, indexValue: indexPathMain, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                    feedCell = cell
                    cell.textChanged {[weak self]newText in
                        DispatchQueue.main.async {
                            self!.beginAndEndUpdate(tableView: tableView)
                        }
                    }
                    
                    if let viewComment = cell.commentViewRef as? FeedCommentBarView {
                        if feedObj.comments != nil  {
                            if feedObj.comments!.count > 0 {
                                //                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                                
                                //                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                                
                            }
                        }
                    }
                    
                }
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
                //                    if let viewComment = cell.commentViewRef {
                //
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
                //                }
                
            case FeedType.video.rawValue, FeedType.liveStream.rawValue :
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
                //                    if let viewComment = cell.commentViewRef {
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
                //                    cell.btnShare.tag = indexPath.row
                //                    cell.btnShare.addTarget(self, action: #selector(self.DownloadVideo), for: .touchUpInside)
                //                }
                if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewVideoFeedCell", for: indexPath) as? NewVideoFeedCell {
                    cellVideo.postObj = feedObj
                    cellVideo.indexPathMain = indexPath
                    cellVideo.reloadData()
                    cellVideo.parentTblView = tableView
                    cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                    cellVideo.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellVideo
                }
                //            case FeedType.liveStream.rawValue:
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, shouldPlay: self.currentlyPlayingIndexPath == indexPathMain, indexValue: indexPathMain,reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //                    cell.videoPlayerIndexCallback = { (indexValue) in
                //                        self.currentlyPlayingIndexPath = indexValue
                //                    }
                //
                //                    if let viewComment = cell.commentViewRef as? FeedCommentBarView {
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                //                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                //                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //
                //                            }
                //                        }
                //                    }
                //                    cell.btnShare.tag = indexPathain
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
                
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCellSingle.identifier, for: indexPath) as? ImageCellSingle {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //                    cell.imageSelectedClosure = { (indexValue, isGroup) in
                //                        self.presentImageFullScreenClosure?(indexValue, isGroup)
                //                    }
                //
                //                    cell.btnShare.tag = indexPath.row
                //                    cell.btnShare.addTarget(self, action: #selector(self.DownloadImage), for: .touchUpInside)
                //
                //                    if let viewComment = cell.commentViewRef {
                //
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                //
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
                //                }
                
            case FeedType.file.rawValue:
                //                if let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentCell.identifier, for: indexPath) as? AttachmentCell {
                //                    cell.feedArray = self.feedArray
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged { [weak self] newText in
                //                        self!.beginAndEndUpdate(tableView: tableView)
                //                    }
                //                    cell.imageSelectedClosure = { (indexValue, isGroup) in
                //                        self.presentImageFullScreenClosure?(indexValue, isGroup)
                //                    }
                //
                //                    cell.showShareOption = { (indexValue) in
                //                        self.showShareOption?(indexValue)
                //                    }
                //
                //
                //                    if let viewComment = cell.commentViewRef {
                //
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                //
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
                //                }
                if let cellAttachment = tableView.dequeueReusableCell(withIdentifier: "NewAttachmentFeedCell", for: indexPath) as? NewAttachmentFeedCell {
                    cellAttachment.postObj = feedObj
                    cellAttachment.indexPathMain = indexPath
                    cellAttachment.reloadData()
                    cellAttachment.tblViewImg.invalidateIntrinsicContentSize()
                    cellAttachment.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellAttachment
                }
                //
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
                //                    cell.isFromFeed = true
                //                    cell.isAppearFrom = "Feed"
                //                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                //                    feedCell = cell
                //                    cell.textChanged {[weak self]newText in
                //                        DispatchQueue.main.async {
                //                            self!.beginAndEndUpdate(tableView: tableView)
                //                        }
                //                    }
                //
                //                    if let viewComment = (cell.commentViewRef) {
                //
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                //
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
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
                //                    if let viewComment = cell.commentViewRef {
                //
                //                        if feedObj.comments != nil  {
                //                            if feedObj.comments!.count > 0 {
                ////                                viewComment.btnUserProfile.tag = feedObj.comments!.first!.userID!
                ////                                viewComment.btnUserProfile.addTarget(self, action: #selector(self.openUSerProfileAction), for: .touchUpInside)
                //                            }
                //                        }
                //                    }
                //                }
                
            default:
                LogClass.debugLog("Feed type missing.")
            }
            self.isFeedReachEnd(indexPath: indexPath)
            if feedCell != nil {
                return feedCell!
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
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true, FeedObj: self.feedArray[sender.tag])
    }
    
    @objc func DownloadVideo(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: false, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    
    func showShareOption(valueIndex : Int){
        let feedObj = self.feedArray[valueIndex] as FeedData
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            
            do {
                let imageData = try Data(contentsOf: URL.init(string: (feedObj.post?.first!.filePath)!)!)
                
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.parentView.present(activityViewController, animated: true) {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
                
            } catch {
                // LogClass.debugLog("Unable to load data: \(error)")
            }
        }
    }
    
    @objc func backAction(sender : UIButton){
        self.parentView.navigationController?.popViewController(animated: true)
    }
    
    
    func ProfileImageHeaderCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellImageHEader = tableView.dequeueReusableCell(withIdentifier: "NewGroupImageCell", for: indexPath) as! NewGroupImageCell
        
        cellImageHEader.groupObj = self.parentView.groupObj
        cellImageHEader.reloadData()
        
        cellImageHEader.selectionStyle = .none
        return cellImageHEader
    }
    
    
    
    
    
    @objc func ProfileAction(){
        let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileImageHeaderCell
        cellMain.viewDelete.isHidden = false
        
    }
    
    func ProfileUserNameCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.parentView.groupObj!.isMember && self.parentView.groupObj!.member_request == "" {
            
            let cellUserName = tableView.dequeueReusableCell(withIdentifier: "GroupNameVC", for: indexPath) as! GroupNameVC
            
            cellUserName.groupObj = self.parentView.groupObj
            cellUserName.reloadName()
            cellUserName.btnMore.addTarget(self, action: #selector(self.MoreActionforGroup), for: .touchUpInside)
            cellUserName.selectionStyle = .none
            return cellUserName
            
        }else {
            
            
            let cellUserName = tableView.dequeueReusableCell(withIdentifier: "GroupJoinCell", for: indexPath) as! GroupJoinCell
            
            cellUserName.groupObj = self.parentView.groupObj
            cellUserName.reloadName()
            cellUserName.lblJoin.text = "Join Group".localized()
            if self.parentView.groupObj!.member_request == "pending" {
                cellUserName.lblJoin.text = "Your request is in pending for approval".localized()
            }
            
            
            cellUserName.btnJoin.addTarget(self, action: #selector(self.joinGroup), for: .touchUpInside)
            cellUserName.selectionStyle = .none
            return cellUserName
            
        }
        
    }
    
    func leaveGroup(){
        let parameters = [
            "action": "group/members/leave",
            "group_id":self.parentView.groupObj!.groupID ,
            "user_id":String(SharedManager.shared.getUserID()),
            "token": SharedManager.shared.userToken()
        ]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
                    if let obj = SharedManager.shared.userEditObj.groupArray.filter({$0.groupID == self.parentView.groupObj!.groupID}).first {
                        let profileGroupModel = ProfileGroupPageModel(tabName: "group", item: obj)
                        NotificationCenter.default.post(name: .CategoryLikePages, object: profileGroupModel)
                        self.parentView.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }, param:parameters as! [String : String])
    }
    
    func reportGroup(){
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.groupObj = self.parentView.groupObj
        reportDetail.delegate = self.parentView
        self.parentView.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.parentView.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.parentView.sheetController.extendBackgroundBehindHandle = true
        self.parentView.sheetController.topCornersRadius = 20
        
        
        self.parentView.present(self.parentView.sheetController, animated: true, completion: nil)
    }
    
    
    func deleteGroup(){
        SharedManager.shared.ShowAlertWithCompletaion(title: "Delete Group".localized(), message: "Are you sure to delete this group?".localized(), isError: false, DismissButton: "Cancel".localized(), AcceptButton: "Yes".localized()) { (statusP) in

            if statusP {
                var parameters = [ "token": SharedManager.shared.userToken()]
                
                parameters["group_id"] = self.parentView.groupObj!.groupID
                parameters["action"] = "group/delete"
                
                
                RequestManager.fetchDataPost(Completion: { response in
                    switch response {
                    case .failure(let error):
                        if error is String {
                        }
                    case .success(let res):

                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {
                        }else {
                            
                            self.parentView.navigationController?.popViewController(animated: true)
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    func inviteGroup(){
        let viewGroupInvite = self.parentView.GetView(nameVC: "GroupInviteUsersVC", nameSB: "Kids") as! GroupInviteUsersVC
        viewGroupInvite.groupObj = self.parentView.groupObj
        self.parentView.navigationController?.pushViewController(viewGroupInvite, animated: true)
    }
    
    @objc func MoreActionforGroup(sender : UIButton){
        
        if self.parentView.groupObj!.isAdmin {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() , "Leave Group".localized() , "Invite Friends".localized() , "Delete Group".localized()  ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                }else if selectedIndex == 1 {
                    self.leaveGroup()
                }else if selectedIndex == 2 {
                    self.inviteGroup()
                }else {
                    self.deleteGroup()
                }
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }else if self.parentView.groupObj!.isMember {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() , "Leave Group".localized()   ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                }else {
                    self.leaveGroup()
                }
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }else {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                self.reportGroup()
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }
        
        
    }
    
    //    func configWithMenuStyle() -> FTPopOverMenuConfiguration {
    //        let config = FTPopOverMenuConfiguration()
    //        config.backgroundColor = UIColor.white
    //        config.borderColor = UIColor.lightGray
    //        config.menuWidth = UIScreen.main.bounds.width / 3
    //        config.separatorColor = UIColor.lightGray
    //        config.menuRowHeight = 40
    //        config.menuCornerRadius = 6
    //        config.textColor = UIColor.black
    //        config.textAlignment = NSTextAlignment.center
    //
    //        return config
    //    }
    
    @objc func joinGroup(sender : UIButton){
        
        if self.parentView.groupObj!.member_request == "pending" {
            return
        }
        var parameters = [ "token": SharedManager.shared.userToken()]
        
        parameters["group_id"] = self.parentView.groupObj!.groupID
        parameters["user_id"] = String(SharedManager.shared.getUserID())
        parameters["action"] = "group/members/join"
        
        
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let resData = res as? [String : Any] {
                        
                        if (resData["status"] as! String) == "pending_approval" {
                            self.parentView.groupObj?.member_request = "pending"
                            self.parentView.groupObj?.isMember = false
                            self.parentView.profileTableView.reloadData()
                        }else {
                            self.parentView.groupObj?.member_request = ""
                            self.parentView.groupObj?.isMember = true
                            self.parentView.profileTableView.reloadData()
                        }
                    }else {
                        self.parentView.groupObj?.member_request = ""
                        self.parentView.groupObj?.isMember = true
                        self.parentView.profileTableView.reloadData()
                    }
                    
                    
                }
            }
        }, param:parameters)
    }
    
    func NoRecordFound(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellUserName = tableView.dequeueReusableCell(withIdentifier: "AllCompetitionHeadingCell", for: indexPath) as? AllCompetitionHeadingCell else {
            return UITableViewCell()
        }
        
        cellUserName.lblInfo.text = "No groups availalbe.".localized()
        cellUserName.lblInfo.textAlignment = .center
        self.parentView.view.labelRotateCell(viewMain: cellUserName.lblInfo)
        cellUserName.viewBG.backgroundColor = UIColor.clear
        
        cellUserName.selectionStyle = .none
        return cellUserName
    }
    
    
    func GroupTabCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "GroupTabCell", for: indexPath) as? GroupTabCell else {
            return UITableViewCell()
        }
        
        cellUserTab.delegate = self
        cellUserTab.selectOverView(value: self.selectedTab.rawValue)
        cellUserTab.lblOverview.text = "Home"
        cellUserTab.lblReviews.text = "Videos"
        cellUserTab.lblPhotos.text = "About"
        cellUserTab.lblVideos.text = "Photos"
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblPhotos)
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblVideos)
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblReviews)
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblOverview)
        
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    func ProfileUserinfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "NewGroupAboutCell", for: indexPath) as! NewGroupAboutCell
        cellUserTab.groupObj = self.parentView.groupObj
        cellUserTab.reloadAbout()
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    func NewPageAddReviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellAddReview = tableView.dequeueReusableCell(withIdentifier: "NewPageAddReviewCell", for: indexPath) as? NewPageAddReviewCell else {
            return UITableViewCell()
        }
        cellAddReview.btnPost.tag = indexPath.row
        cellAddReview.btnRecomnd.tag = indexPath.row
        cellAddReview.btnPost.addTarget(self, action: #selector(self.PostAction), for: .touchUpInside)
        cellAddReview.btnRecomnd.addTarget(self, action: #selector(self.RecomndAction), for: .touchUpInside)
        cellAddReview.selectionStyle = .none
        return cellAddReview
    }
    
    @objc func PostAction(sender : UIButton){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let cellReview = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 1)) as! NewPageAddReviewCell
        
        var parameters = ["action": "post/create","token": SharedManager.shared.userToken(),"body":cellReview.txtViewComment.text!, "privacy_option":"public"]
        
        parameters["page_id"] = self.parentView.groupObj?.groupID
        parameters["review_star_points"] = String(cellReview.ratingview.rating)
        parameters["post_scope_id"] = "1"
        parameters["post_type"] = "page_review"
        
        if cellReview.viewRecomnd.isHidden {
            parameters["recommend_page"] = "0"
        }else {
            parameters["recommend_page"] = "1"
        }
        
        var postObj = [PostCollectionViewObject]()
        CreateRequestManager.uploadMultipartCreateRequests( params: parameters as! [String : String],fileObjectArray: postObj,success: {
            (JSONResponse) -> Void in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue {
                self.parentView.groupObj?.is_reviewd = true
                self.feedArray.removeAll()
                self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true,isReview: true)
                
            }
        },failure: {(error) -> Void in
            // LogClass.debugLog(error)
        }, isShowProgress: false)
        
    }
    
    @objc func RecomndAction(sender : UIButton){
        
        let cellReview = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 1)) as! NewPageAddReviewCell
        
        cellReview.viewRecomnd.isHidden = !cellReview.viewRecomnd.isHidden
        
    }
    
    
    func NewPageReviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellSearch = tableView.dequeueReusableCell(withIdentifier: "NewPageReviewCell", for: indexPath) as? NewPageReviewCell else {
            return UITableViewCell()
        }
        
        if Double(self.parentView.groupObj!.rating) != nil {
            cellSearch.viewStar.rating = Double(self.parentView.groupObj!.rating)!
        }else {
            cellSearch.viewStar.rating = 0.0
        }
        
        cellSearch.lblReview.text = self.parentView.groupObj!.rating
        cellSearch.lblPersons.text = self.parentView.groupObj!.totalReviews
        cellSearch.lblTotalPersons.text = self.parentView.groupObj!.rating + "/5"
        cellSearch.lblPositive.text = self.parentView.groupObj!.positiveReviews
        cellSearch.lblNegative.text = self.parentView.groupObj!.negativeReviews
        cellSearch.lblRecom.text = self.parentView.groupObj!.recommendationReviews
        cellSearch.selectionStyle = .none
        return cellSearch
    }
    
    
    func ProfileContactCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard  let cellContact = tableView.dequeueReusableCell(withIdentifier: "ProfileContactCell", for: indexPath) as? ProfileContactCell else {
            return UITableViewCell()
        }
        
        cellContact.selectionStyle = .none
        return cellContact
    }
    
    func ProfileImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellTab = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as? ProfileImageCell else {
            return UITableViewCell()
        }
        cellTab.arrayImages.removeAll()
        if self.selectedTab == .photos {
            cellTab.isImage = true
            for indexInner in self.feedArray {
                if indexInner.postType == FeedType.gallery.rawValue {
                    
                }else {
                    if indexInner.post!.count > 0 {
                        cellTab.arrayImages.append(indexInner.post!.first?.filePath as Any)
                    }
                    
                }
            }
        }else {
            
            
            for indexInner in self.feedArray {
                if indexInner.postType == FeedType.gallery.rawValue {
                    
                }else {
                    if indexInner.post!.count > 0 {
                        cellTab.arrayImages.append(indexInner.post!.first?.thumbnail as Any)
                    }
                    
                }
            }
            cellTab.isImage = false
        }
        
        cellTab.delegate = self
        cellTab.viewWidth = self.parentView.view.frame.size.width
        cellTab.reloadView()
        
        cellTab.selectionStyle = .none
        return cellTab
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat    {
        
        if indexPath.section == 0 {
            if indexPath.row == 4 {
                return 280
            }
            return UITableView.automaticDimension
        }
        
        if self.selectedTab == .aboutMe {
            return 280
        }

        if self.selectedTab == .timeline {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
            
        }else {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
        }
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 4 {
                return 280
            }
            return UITableView.automaticDimension
        }
        
        if self.selectedTab == .timeline {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
        }
        if self.selectedTab == .aboutMe {
            return 280
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
                let postObj:FeedData = self.feedArray[indexPath.row] as FeedData
                
                if self.selectedTab == .photos {
                    self.callingImageService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
                }else if self.selectedTab == .videos {
                    self.callingVideoService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
                }else {
                    self.callingFeedService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
                }
                
            }
        }
    }
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool , isReview : Bool = false){
        let userToken = SharedManager.shared.userToken()
        self.showloadingBar?()
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = ["action": "group/newsfeed","group_id":self.parentView.groupObj!.groupID, "token": SharedManager.shared.userToken()]
        
        self.selectedTab = .timeline
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        if isReview {
            self.selectedTab = .friends
            parameters["post_type"] = "12" // for REviews
        }
        
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                        self.hideSkeletonClosure?()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    
    func callingImageService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        let userToken = SharedManager.shared.userToken()
        self.showloadingBar?()
        
        var parameters = ["action": "group/photos","group_id":self.parentView.groupObj!.groupID, "token": SharedManager.shared.userToken()]
        
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message?.contains("not found")) != nil)  {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                        self.hideSkeletonClosure?()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    
    func callingVideoService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        let userToken = SharedManager.shared.userToken()
        self.showloadingBar?()
        
        var parameters = ["action": "group/videos","group_id":self.parentView.groupObj!.groupID, "token": SharedManager.shared.userToken()]
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message?.contains("not found")) != nil)  {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                        self.hideSkeletonClosure?()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        
        if let isFeedData = feedObj.data {
            if isFeedData.count == 0 {
                self.isNextFeedExist = false
            }else {
                if isRefresh {
                    self.feedArray.removeAll()
                }
                
                
                //                self.feedArray.append(contentsOf: isFeedData)
                
                // waseem for ads
                var newArray = [FeedData]()
                
                for indexObj in self.feedArray {
                    if indexObj.postType != FeedType.Ad.rawValue {
                        newArray.append(indexObj)
                    }
                }
                
                
                
                newArray.append(contentsOf: isFeedData)
                
                
                self.feedArray.removeAll()
                for indexObj in 0..<newArray.count {
                    let objectmain = newArray[indexObj]
                    if indexObj % 10 == 0 {
                        if (self.parentView as? NewGroupDetailVC) != nil  {
                            if self.selectedTab == .timeline {
                                let mainData = [String : Any]()
                                let newFeed = FeedData.init(valueDict: mainData)
                                newFeed.postType = FeedType.Ad.rawValue
                                self.feedArray.append(newFeed)
                            }
                            
                        }
                        
                    }
                    
                    self.feedArray.append(objectmain)
                }
                
                
            }
        }
        self.refreshControl.endRefreshing()
        self.parentView.profileTableView.reloadData()
    }
    
}

extension NewGroupModel : ProfileTabSelectionDelegate {
    func profileTabSelection(tabValue : Int) {
        
        
        self.arrayBottom.removeAll()
        if tabValue == 1 {
            selectedTab = .timeline
            self.feedArray.removeAll()
            self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
        }else if tabValue == 2 {
            self.arrayBottom.append(["Type" : "1" , "Des" : "About Me".localized()])
            selectedTab = .aboutMe
        }else if tabValue == 3 {
            selectedTab = .photos
            self.feedArray.removeAll()
            self.callingImageService(lastPostID: "", isLastTrue: true, isRefresh: true)
        }else if tabValue == 4 {
            selectedTab = .videos
            self.feedArray.removeAll()
            self.callingVideoService(lastPostID: "", isLastTrue: true, isRefresh: true)
        }else if tabValue == 5 {
            selectedTab = .friends
            self.feedArray.removeAll()
            self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true,isReview: true)
        }
        
        self.reloadTableViewWithNoneClosure?()
    }
    
    func profileRefreshTabSelection(tabValue : Int , refreshValue : Int) {
        
        
    }
}

//MARK:UITextViewDelegate...
extension NewGroupModel:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        return true
    }
    
}

extension NewGroupModel : ProfileImageSelectionDelegate {
    func viewTranscript(tabValue : Int ){
        
    }
    func ReloadNewPage(){
        
        let postObj:FeedData = self.feedArray.last!
        
        if self.selectedTab == .photos {
            self.callingImageService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
        }else if self.selectedTab == .videos {
            self.callingVideoService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
        }
    }
    func profileImageSelection(tabValue : Int , isImage : Bool) {
        
        if isImage {
            
            
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var valueempty = [String : Any]()
            var feedObj = FeedData.init(valueDict: valueempty)
            
            feedObj.postType = FeedType.image.rawValue
            
            var postFiles = [PostFile]()
            for indexObj in self.feedArray {
                for indexObjInner in indexObj.post! {
                    var postObj = PostFile.init()
                    postObj.fileType = FeedType.image.rawValue
                    postObj.filePath = indexObjInner.filePath!
                    postFiles.append(postObj)
                }
            }
            
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = tabValue
            fullScreen.isInfoViewShow = true
            fullScreen.modalTransitionStyle = .crossDissolve
            self.parentView.present(fullScreen, animated: false, completion: nil)
            
            
        }else {
            
            
            
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var valueempty = [String : Any]()
            var feedObj = FeedData.init(valueDict: valueempty)
            
            feedObj.postType = FeedType.video.rawValue
            
            var postFiles = [PostFile]()
            for indexObj in self.feedArray {
                var postObj = PostFile.init()
                postObj.fileType = FeedType.video.rawValue
                postObj.filePath = indexObj.post?.first!.filePath
                postFiles.append(postObj)
            }
            
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = tabValue
            fullScreen.isInfoViewShow = true
            fullScreen.modalTransitionStyle = .crossDissolve
            self.parentView.present(fullScreen, animated: false, completion: nil)
            
            
        }
    }
}






extension NewGroupModel:UIScrollViewDelegate {
    
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


extension NewGroupModel {
    @objc func goLiveBtnClicked(_ sender: Any) {
        SharedManager.shared.groupObj = self.parentView.groupObj
        SharedManager.shared.isGroup = 2
        
        let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "GoLiveController") as! GoLiveController
        self.parentView.present(goLive, animated: true, completion: nil)
    }
    
    
    @objc func createPostBtnClicked(_ sender: UIButton) {
        SharedManager.shared.createPostSelection = sender.tag
        
        
        SharedManager.shared.groupObj = self.parentView.groupObj
        SharedManager.shared.isGroup = 1
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        let imageView = UIImageView(image: self.parentView.view.takeScreenshot())
        imageView.frame = UIScreen.main.bounds
        SharedManager.shared.createPostScreenShot = imageView
        self.parentView.present(createPost, animated: false, completion: nil)
    }
}

extension NewGroupModel : CellDelegate {
    
    func reloadTableDataFriendShipStatus(feedObj: FeedData) {
        
    }
    func reloadRow(indexObj : IndexPath , feedObj : FeedData){
        self.reloadSpecificRow?(indexObj)
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
    
    func sharePostAction(indexObj : IndexPath , feedObj : FeedData){
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
