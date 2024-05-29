//
//  ProfileViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
import FittedSheets
//import IQKeyboardManagerSwift
import TLPhotoPicker
import Photos
import MediaPlayer
import Combine

class ProfileViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var commentGifBrowseBtn: UIButton!
    @IBOutlet weak var commentCameraBtn: UIButton!
    @IBOutlet weak var commentRecordBtn: UIButton!
    
    var loadSkeleton:Bool = true
    var isNavigationEnable:Bool = false
    var isNavigateToDetail:Bool = false
    var currentIndex = IndexPath()
    var isCommentCamera:Bool = true
    var isFromNewPageScreen: Bool = false
    var sheetController = SheetViewController()
    var selectedAssets = [PostCollectionViewObject]()
    var isReload = true
    var otherUserID = ""
    var otherUserisFriend = ""
    var otherUserSearchObj : SearchUserModel!
    var otherUserObj = UserProfile.init()
    var isPushing = true
    var commentOptionState = -1
    var musicPlayer: MPMediaPickerController?
    var isNavPushAllow: Bool = false
    let cellDic = [CategoryLikeCell.className, ProfileLifeEventCell.className, ProfileCurrencyCell.className, ProfileWebsiteCell.className, ProfileFamilyRelationCell.className, ProfileRelationViewCell.className, ProfileFriendStatusCell.className, ProfileUserinfoCell.className, ProfileUserBasicinfoCell.className, ProfileUserHeadingCell.className, ProfileDetailInfoCell.className, ProfileDetailAddInfoCell.className, ProfileWorkDetailInfoCell.className, ProfilePlaceDetailInfoCell.className, ProfileImageCell.className, ProfileContactCell.className, ProfileSearchContactsCell.className, AllCompetitionHeadingCell.className, SharedCell.className, ProfileUserNameCell.className, ProfileSectionTableViewCell.className, ReelTabTableViewCell.className, ProfileMessageCell.className, AdCell.className, LoginSessionHeaderCell.className, ProfileInfoTextCell.className, ProfileNewImageHeaderCell.className, AttachmentCell.className, PostCell.className, VideoCell.className, NewVideoFeedCell.className, NewAudioFeedCell.className, NewGalleryFeedCell.className, NewAttachmentFeedCell.className, NewTextFeedCell.className, NewSharedFeedCell.className, AudioCell.className, SkeletonCell.className, GalleryCell.className, ImageCellSingle.className, NewImageFeedCell.className, AttachmentCell.className, ShimmerAdCell.className , ShimmerPostCell.className, ProfileGroupCell.className]
    
    private var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    fileprivate let viewModel = ProfileViewModel()
    fileprivate let headerViewModel = ProfileHeaderViewModel()
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    
    lazy var editProfileVc: EditProfileTextVC = {
        return EditProfileTextVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileLocationVc: EditProfileLocationVC = {
        return EditProfileLocationVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileAboutMeVc: EditProfileAboutMEVC = {
        return EditProfileAboutMEVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileVisitedLocationVc: EditProfileVisitedLocationVC = {
        return EditProfileVisitedLocationVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileEducation: EditProfileEducationVC = {
        return EditProfileEducationVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileWork: EditProfileWorkVC = {
        return EditProfileWorkVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    lazy var editProfileOverview: EditProfileOverViewVC = {
        return EditProfileOverViewVC.instantiate(fromAppStoryboard: .EditProfile)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        ManageTableView()
        manageUI()
        callBackScreenHandling()
        // api service to get relation
        viewModel.getRelationships()
        viewModel.getFamilyRelationships()
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePostNotofication(_:)), name: NSNotification.Name(rawValue: "post_deleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePageLikeCategory(_:)), name: .CategoryLikePages, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileTableView.rotateViewForLanguage()
        if isPushing {
            self.profileTableView.isHidden = true
        }
        isPushing = false
        self.navigationController?.removeLefttButton(self)
        if self.isReload {
            SharedManager.shared.isGroup = 0
        }
        if !isNavigationEnable   {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !(isFromNewPageScreen) {
            if self.viewModel.feedArray.count == 0 {
                ManageTableView()
                manageUI()
                callBackScreenHandling()
            }
            if isReload {
                manageUI()
                callBackHandling()
                self.viewModel.refresh(sender: UIButton.init())
                SharedManager.shared.feedRef = self
                if self.tabBarController?.selectedIndex == 3 {
                    self.viewModel.selectedTab = selectedUserTab.timeline
                    self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
                } else {
                    if self.isNavigateToDetail {
                        self.isNavigateToDetail = false
                    } else {
                        self.viewModel.selectedTab = selectedUserTab.timeline
                        self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
                    }
                }
            }
            self.isReload = true
            self.profileTableView.isHidden = false
            if !isNavigationEnable   {
                navigationController?.setNavigationBarHidden(true, animated: animated)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let header = profileTableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.stopPayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func stopPayer() {
        for indexObj in self.profileTableView.visibleCells {
            if let galleryCell = indexObj as? NewGalleryFeedCell {
                galleryCell.stopPlayer()
            }
        }
    }
    
    func manageUI() {
        self.otherUserObj.places.removeAll()
        self.otherUserObj.institutes.removeAll()
        self.otherUserObj.workExperiences.removeAll()
        SharedManager.shared.userEditObj.places.removeAll()
        SharedManager.shared.userEditObj.institutes.removeAll()
        SharedManager.shared.userEditObj.workExperiences.removeAll()
        self.viewModel.feedtble = self.profileTableView
        self.viewModel.parentView = self
        if self.viewModel.imageType.count == 0 {
            self.viewModel.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
            self.getUsernfo()
        }
    }
    
    func ManageTableView() {
        profileTableView.dataSource = viewModel
        profileTableView.delegate = viewModel
        profileTableView.registerCustomCells(cellDic)
        
        profileTableView.estimatedRowHeight = 900
        profileTableView.rowHeight = UITableView.automaticDimension
        self.viewModel.refreshControl.addTarget(viewModel, action: #selector(self.viewModel.refresh(sender:)), for: UIControl.Event.valueChanged)
        profileTableView.addSubview(self.viewModel.refreshControl)
    }
    
    func handleRefresh() {
        DispatchQueue.main.async {
            self.profileTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        }
        self.viewModel.refreshControl.beginRefreshingManually()
        self.viewModel.refresh(sender: UIButton())
    }
    
    @objc func handleDeletePostNotofication(_ notification: Notification) {
        if let postId = notification.object as? Int {
            self.viewModel.feedArray.removeAll(where: {$0.postID == postId})
            self.profileTableView.reloadData()
        }
    }
    
    @objc func updatePageLikeCategory(_ notification: Notification) {
        if let likePageModel = notification.object as? CategoryLikePageModel {
            LogClass.debugLog("likePageModel \(likePageModel)")
            if likePageModel.tabName == "sport" { //
                SharedManager.shared.userEditObj.sportArray = SharedManager.shared.userEditObj.sportArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 60)
            } else if likePageModel.tabName == "movie" {
                SharedManager.shared.userEditObj.movieArray = SharedManager.shared.userEditObj.movieArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 61)
            } else if likePageModel.tabName == "tv" {
                SharedManager.shared.userEditObj.tvShowArray = SharedManager.shared.userEditObj.tvShowArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 62)
            } else if likePageModel.tabName == "game" {
                SharedManager.shared.userEditObj.gameArray = SharedManager.shared.userEditObj.gameArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 63)
            } else if likePageModel.tabName == "athlete" {
                SharedManager.shared.userEditObj.athleteArray = SharedManager.shared.userEditObj.athleteArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 64)
            } else if likePageModel.tabName == "music" {
                SharedManager.shared.userEditObj.musicArray = SharedManager.shared.userEditObj.musicArray.filter({$0.pageId != likePageModel.item.pageId})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 65)
            }
        } else if let pageGroupModel = notification.object as? ProfileGroupPageModel {
            if pageGroupModel.tabName == "group" {
                SharedManager.shared.userEditObj.groupArray = SharedManager.shared.userEditObj.groupArray.filter({$0.groupID != pageGroupModel.item?.groupID})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 66)
            }
        }
    }
    
    func callBackHandling() {
        self.editProfileVc.refreshParentView = { () in
            self.profileTableView.reloadData()
        }
        
        self.editProfileOverview.refreshParentView = { () in
            self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 5)
        }
        self.editProfileWork.refreshParentView = { () in
            self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 6)
        }
        
        self.editProfileLocationVc.refreshParentView = { () in
            self.profileTableView.reloadData()
        }
        
        self.editProfileAboutMeVc.refreshParentView = { () in
            self.profileTableView.reloadData()
        }
        
        self.editProfileVisitedLocationVc.refreshParentView = { () in
            self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 7)
        }
        self.editProfileEducation.refreshParentView = { () in
            self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 10)
        }
        
        self.viewModel.reloadTableViewClosure = { () in
            self.profileTableView.reloadData()
        }
        
        self.viewModel.showShareOption = { (indexValue) in
            let feedObj = self.viewModel.feedArray[indexValue] as FeedData
            Loader.startLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                do {
                    let imageData = try Data(contentsOf: URL.init(string: (feedObj.post?.first!.filePath)!)!)
                    let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                    self.stopPayer()
                    self.present(activityViewController, animated: true) {
                        Loader.stopLoading()
                    }
                } catch {
                    
                }
            }
        }
        
        self.viewModel.feedScrollHandler = { () in
            
        }
        
        self.viewModel.didSelectTableClosure = { [weak self](indexValue) in
            
        }
        
        self.viewModel.reloadSpecificRow = { (indexValue) in
            self.profileTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
        }
        self.viewModel.hideFooterClosure = { () in
            self.profileTableView.tableFooterView?.removeFromSuperview()
        }
        self.viewModel.showAlertMessageClosure = { (message) in
            SharedManager.shared.showAlert(message: message, view: self)
        }
        
        self.viewModel.presentImageFullScreenClosure = { (indexValue, isGroup) in
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            var feedObj:FeedData?
            if isGroup {
                feedObj = self.viewModel.feedArray[indexValue] as FeedData
                feedObj = feedObj?.sharedData
            }else {
                feedObj = self.viewModel.feedArray[indexValue] as FeedData
            }
            fullScreen.collectionArray = feedObj!.post!
            fullScreen.modalTransitionStyle = .crossDissolve
            self.stopPayer()
            self.present(fullScreen, animated: false, completion: nil)
        }
        self.viewModel.reloadTableViewWithNoneClosure = { () in
            self.profileTableView.reloadData()
        }
        //New handlers...
        FeedCallBManager.shared.likeCallBackManager = { (currentIndex) in
            self.manageFeedLikeDislikeSheet(currentIndex: currentIndex)
        }
        FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
            var arr:[UITableViewCell] = []
            for cell in self!.profileTableView.visibleCells {
                if cell is PostCell || cell is AudioCell || cell is VideoCell || cell is ImageCellSingle || cell is GalleryCell {
                    arr.append(cell)
                }
            }
            FeedCallBManager.shared.manageSpeakerForVisibleCell(tableCellArr: arr, currentIndex:currentIndex, feedArray: self!.viewModel.feedArray)
        }
        
        FeedCallBManager.shared.dropDownFeedHanlder = { [weak self] (currentIndex) in
            let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
            reportController.delegate = self
            reportController.reportType = "Post"
            reportController.currentIndex = currentIndex
            reportController.feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
            //            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            self!.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self!.sheetController.extendBackgroundBehindHandle = true
            self!.sheetController.topCornersRadius = 20
            self!.present(self!.sheetController, animated: false, completion: nil)
        }
        
        FeedCallBManager.shared.dropDownFeedCommentHanlder = { [weak self] (currentIndex) in
            let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
            //            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            reportController.delegate = self
            reportController.isPartOf = "Feed"
            reportController.reportType = "Comment"
            reportController.currentIndex = currentIndex
            reportController.feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
            var commentCount:Int = 0
            if (reportController.feedObj?.comments!.count)! > 0 {
                commentCount = (reportController.feedObj?.comments?.count)! - 1
            }
            reportController.commentObj = reportController.feedObj?.comments![commentCount]
            self!.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self!.sheetController.extendBackgroundBehindHandle = true
            self!.sheetController.topCornersRadius = 20
            self!.present(self!.sheetController, animated: false, completion: nil)
        }
        
        FeedCallBManager.shared.commentOptionBtnHandler = { [weak self] (currentIndex, btn) in
            var offset = 0
            if self!.commentOptionState == btn.tag {
//                if self!.commentDropDownView.isHidden {
//                    self!.commentDropDownView.isHidden = false
//                }else {
//                    self!.commentDropDownView.isHidden = true
//                }
            }else {
//                self!.commentDropDownView.isHidden = false
            }
            if btn.tag == 0 {
                self!.commentCameraBtn.isHidden = false
                self!.commentGifBrowseBtn.isHidden = true
                self!.commentRecordBtn.isHidden = true
            }else if btn.tag == 1 {
                self!.commentCameraBtn.isHidden = true
                self!.commentGifBrowseBtn.isHidden = false
                self!.commentRecordBtn.isHidden = true
            }else if btn.tag == 3 {
                offset = -30
                self!.commentCameraBtn.isHidden = true
                self!.commentGifBrowseBtn.isHidden = true
                self!.commentRecordBtn.isHidden = false
            }
            self?.currentIndex = currentIndex
            let frame = btn.superview!.convert(btn.frame, to: self!.view)
//            self?.commentDropDownView.frame = CGRect(x: frame.origin.x  + CGFloat(offset), y: frame.origin.y - self!.commentDropDownView.frame.size.height + 7 , width: self!.commentDropDownView.frame.size.width, height: self!.commentDropDownView.frame.size.height)
            self!.commentOptionState = btn.tag
        }
        
        FeedCallBManager.shared.galleryCellIndexCallbackHandler = { [weak self] (currentIndex, galleryIndexPath, isGroup) in
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var feedObj:FeedData?
            if isGroup {
                feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
                feedObj = feedObj?.sharedData
            }else {
                feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
            }
            fullScreen.isInfoViewShow = false
            fullScreen.collectionArray = feedObj!.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = galleryIndexPath.row
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = currentIndex
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self!.profileTableView.visibleCells)
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        FeedCallBManager.shared.commentImageTappedHandler = { [weak self] (indexValue) in
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            fullScreen.typeOfImage = "comment"
            let feedObj = self!.viewModel.feedArray[indexValue.row] as FeedData
            var commentCount:Int = 0
            if feedObj.comments!.count > 0 {
                commentCount = (feedObj.comments?.count)! - 1
            }
            fullScreen.commentObj = (feedObj.comments![commentCount]).commentFile![0]
            fullScreen.modalTransitionStyle = .crossDissolve
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        self.viewLanguageModel.reloadSpecificRowCommentImageUpload = {[weak self] (indexValue) in
            self!.profileTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
        }
        
        //        FeedCallBManager.shared.videoTranscriptCallBackHandler = { [weak self] (currentIndex, isGroup) in
        //            let videoTranscript = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "VideoTranscriptController") as! VideoTranscriptController
        //            if isGroup {
        //                let feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
        //                videoTranscript.feedObj = feedObj.sharedData
        //            }else {
        //                videoTranscript.feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
        //            }
        //            videoTranscript.postIndex = IndexPath(row: 0, section: 0)
        //            self!.sheetController = SheetViewController(controller: videoTranscript, sizes: [.fullScreen])
        //            self!.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        //            self!.sheetController.extendBackgroundBehindHandle = true
        //            self!.sheetController.topCornersRadius = 20
        //            self!.present(self!.sheetController, animated: false, completion: nil)
        //        }
        //
        //        FeedCallBManager.shared.videoTranscriptGalleryCallBackHandler = { [weak self] (mainIndex, currentIndex, isShared) in
        //            let videoTranscript = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "VideoTranscriptController") as! VideoTranscriptController
        //            videoTranscript.feedObj = self!.viewModel.feedArray[mainIndex.row] as FeedData
        //            if isShared {
        //                let feedObj = self!.viewModel.feedArray[mainIndex.row] as FeedData
        //                videoTranscript.feedObj = feedObj.sharedData!
        //            }
        //            videoTranscript.postIndex = currentIndex
        //            self!.sheetController = SheetViewController(controller: videoTranscript, sizes: [.fullScreen])
        //            self!.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        //            self!.sheetController.extendBackgroundBehindHandle = true
        //            self!.sheetController.topCornersRadius = 20
        //            self!.present(self!.sheetController, animated: false, completion: nil)
        //        }
        
        FeedCallBManager.shared.downloadShareFile = { [weak self] (mainIndex, currentIndex) in
            let feedObjUpdate:FeedData = self!.viewModel.feedArray[mainIndex.row]
            let postObj = feedObjUpdate.post![currentIndex.row]
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // your code here
                do {
                    let imageData = try Data(contentsOf: URL.init(string: postObj.filePath!)!)
                    let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                    self!.present(activityViewController, animated: true) {
                        // DispatchQueue.main.async {
                        //                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                        Loader.stopLoading()
                        // }
                    }
                } catch {
                    
                }
            }
        }
        
        FeedCallBManager.shared.updateVideoViewSeekTimeForNewsFeedHandler = { [weak self] (feedIndex, currentIndex, seekTime) in
            let feedObjUpdate:FeedData = self!.viewModel.feedArray[feedIndex.row]
            let postObj = feedObjUpdate.post![currentIndex.row]
            postObj.videoSeekTime = seekTime
            feedObjUpdate.post![currentIndex.row] = postObj
            self!.viewModel.feedArray[feedIndex.row] = feedObjUpdate
        }
        
        FeedCallBManager.shared.linkPreviewUpdateHandler = { (link) in
            if link != "" {
                if let url = URL(string:link), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
        
        FeedCallBManager.shared.showMessageAlertyHandler = {[weak self] (message) in
            SharedManager.shared.showAlert(message: message, view: self!)
        }
        
        FeedCallBManager.shared.userProfileHandler = {[weak self] (userID) in
            if Int(userID) == SharedManager.shared.getUserID() {
                self?.tabBarController?.selectedIndex = 3
            }else {
                let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
                //  vcProfile.isNavigationEnable = false
                vcProfile.isNavPushAllow = true
                self?.navigationController?.pushViewController(vcProfile, animated: true)
            }
        }
        
        //MARK: - Uploading handelrs
        FeedCallBManager.shared.uploadingCloseHandler = {[weak self] (currentIndex) in
            self!.profileTableView.reloadRows(at: [currentIndex], with: UITableView.RowAnimation.none)
        }
        
        FeedCallBManager.shared.uploadingInstantHandler  = { [weak self] (currentIndex, uploadObj, body) in
            let feedObj:FeedData = self!.viewModel.feedArray[currentIndex.row]
            feedObj.uploadObj = nil
            self!.viewLanguageModel.handlingInstantCommentCallback(currentIndex: self!.currentIndex, fileType:uploadObj.type, selectLang: true, videoUrl: uploadObj.url, isPosting: false,imgUrl: uploadObj.imageUrl, imageObj: uploadObj.imageObj ?? UIImage(), isImageObjExist: uploadObj.isImageExist, identifier: uploadObj.identifier)
            if uploadObj.type == "image" {
                //                self?.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode,identifier: uploadObj.identifier, bodyString: body )
            }else if uploadObj.type == "video" {
                //                self?.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
            }else if uploadObj.type == "GIF" {
                //                self?.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier, bodyString: body )
            }else if uploadObj.type == "audio" {
                //                self?.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
            }
        }
        
        FeedCallBManager.shared.downloadFileHandler  = { [weak self] (currentIndex, commentFile) in
            self?.downloadAttachment(commentFile: commentFile)
        }
    }
    
    func callBackScreenHandling() {
        
        viewModel.contactGroupProfileCompletion = {[weak self] contact in
            guard let self else { return }
            let userID = String(contact.id)
            let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            if Int(userID) != SharedManager.shared.getUserID() {
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
            }
            vcProfile.isNavPushAllow = false
            vcProfile.isNavigationEnable = false
            let controller = UINavigationController(rootViewController: vcProfile)
            presentFullVC(controller)
        }
        
        viewModel.backTappedCompletion = {[weak self] sender in
            guard let self else { return }
            if isNavPushAllow {
                navigationController?.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        }
        
        viewModel.websiteURLCompletion = { type, index in
            let controller = EditProfileWebsiteVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.parentView = self
            controller.reloadView(type: type, rowIndexP: index ?? 0)
            controller.refreshParentView = {
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 57)
            }
            self.presentFullVC(controller)
        }
        
        viewModel.relationshipCompletion = { type ,index in
            let controller = EditProfileRelationshipVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.parentView = self
            controller.relationshipArray = self.viewModel.arrayRelationStatus
            controller.otherUserID = self.otherUserID
            controller.otherUserObj = self.otherUserObj
            controller.reloadView(type: type, rowIndexP: index ?? 0)
            controller.refreshParentView = {
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 55)
            }
            self.presentFullVC(controller)
        }
        
        viewModel.familyRelationshipCompletion = { type, index in
            let controller = EditProfileFamilyRelationshipVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.parentView = self
            controller.relationshipArray = self.viewModel.arrayFamilyRelationStatus
            controller.otherUserID = self.otherUserID
            controller.reloadView(type: type, rowIndexP: index ?? 0)
            controller.refreshParentView = {
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 56)
            }
            self.presentFullVC(controller)
        }
        
        viewModel.currencyCompletion = { type, index in
            let controller = EditProfileCurrencyVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.refreshParentView = {
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 58)
            }
            self.presentFullVC(controller)
        }
        
        viewModel.lifeEventsCompletion = { type, index in
            let controller = EditProfileLifeEventCategoryVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.reloadView(type: type, rowIndexP: index ?? 0)
            let navController = UINavigationController(rootViewController: controller)
            self.presentFullVC(navController)
        }
        
        viewModel.lifeEventsDeleteCompletion = { type, index in
            SharedManager.shared.ShowAlertWithCompletaion(title: "Delete Life event", message: "Are you sure you want to delete life event?.", isError: false) { status in
                if status {
                    let lifeEventID = SharedManager.shared.userEditObj.userLifeEventsArray[index ?? 0].lifeEventId
                    self.lifeEventDeleteRequest(with: lifeEventID)
                }
            }
        }
        
        viewModel.lifeEventDetailCompletion = { type, index in
            let controller = LifeEventCategoryListVC.instantiate(fromAppStoryboard: .EditProfile)
            controller.reloadView(type: type, rowIndexP: index ?? 0)
            self.presentFullVC(controller)
        }
        
        viewModel.categoryLikePagesCompletion = { type, pageTab, arr in
            let controller = CategoryLikePagesVC.instantiate(fromAppStoryboard: .TabBar)
            controller.arrayData = arr
            controller.titleStr = type
            controller.pageTab = pageTab
            let navController = UINavigationController(rootViewController: controller)
            self.presentFullVC(navController)
        }
        
        viewModel.groupSeeAllCompletion = { type, pageTab, arr in
            let controller = ProfileGroupPageController.instantiate(fromAppStoryboard: .TabBar)
            controller.arrayData = arr
            controller.titleStr = type
            controller.pageTab = pageTab
            let navController = UINavigationController(rootViewController: controller)
            self.presentFullVC(navController)
        }
        
        viewModel.openLikePage = { pageObj, categoryType in
            let controller = NewPageDetailVC.instantiate(fromAppStoryboard: .Kids)
            let page = GroupValue.init()
            page.groupID = String(pageObj.pageId)
            page.category = pageObj.name
            page.groupName = pageObj.title
            page.title = pageObj.title
            page.profilePicture = pageObj.profile ?? .emptyString
            page.slug = pageObj.slug
            controller.groupObj = page
            controller.pageCategoryType = categoryType
            controller.isFromProfileScreen = true
            let categoryModel = CategoryLikePageModel(tabName: categoryType ?? .emptyString, item: pageObj)
            controller.categoryLikePageItem = categoryModel
            let navController = UINavigationController(rootViewController: controller)
            self.presentFullVC(navController)
        }
        viewModel.groupCompletion = { groupObj, categoryType in
            let controller = NewGroupDetailVC.instantiate(fromAppStoryboard: .Kids)
            controller.groupObj = groupObj
            controller.isFromProfileScreen = true
            let navController = UINavigationController(rootViewController: controller)
            self.presentFullVC(navController)
        }
        
    }
    
    func lifeEventDeleteRequest(with lifeEventID: String) {
        let params = ["life_event_id" : lifeEventID]
        Loader.startLoading()
        apiService.deleteLifeEventRequest(endPoint: .deleteLifeEvent(params))
            .sink { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Delete life event complete successfully")
                    Loader.stopLoading()
                case .failure(let err):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: err.localizedDescription)
                }
            } receiveValue: { response in
                Loader.stopLoading()
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                SharedManager.shared.userEditObj.userLifeEventsArray = SharedManager.shared.userEditObj.userLifeEventsArray.filter({$0.lifeEventId != lifeEventID})
                self.viewModel.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 59) // refresh life category
            }.store(in: &subscription)
    }
    
    func openMusicAlbum(){
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        self.musicPlayer = MPMediaPickerController(mediaTypes: .anyAudio)
        self.musicPlayer!.delegate = self
        self.musicPlayer!.allowsPickingMultipleItems = false
        self.stopPayer()
        self.present(self.musicPlayer!, animated: true, completion: nil)
    }
    
    func getUsernfo() {
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "profile/about","token": userToken]
        if self.otherUserID.count > 0 {
            parameters["user_id"] = self.otherUserID
        }
        //        SharedManager.shared.showOnWindow()
        //        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            //            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [String : Any] {
                    if self.otherUserID.count > 0 {
                        self.otherUserObj = UserProfile.init(fromDictionary: res as! [String : Any])
                        if self.otherUserID.count == 0 {
                            var userObj = SharedManager.shared.userObj
                            userObj?.data.profile_image = self.otherUserObj.profileImage
                        }
                    }else {
                        let userObj = UserProfile.init(fromDictionary: res as! [String : Any])
                        if String(SharedManager.shared.userObj!.data.id!) == userObj.id {
                            SharedClass.shared.saveXDataApp()
                        }
                        SharedManager.shared.userEditObj = UserProfile.init(fromDictionary: res as! [String : Any])
                    }
                }
                if self.tabBarController?.selectedIndex == 3 {
                    self.viewModel.selectedTab = selectedUserTab.timeline
                    self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
                } else {
                    self.viewModel.selectedTab = selectedUserTab.timeline
                    self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
                }
                
                
                if SharedManager.shared.userEditObj.places.count > 0 {
                    SharedManager.shared.userObj?.data.placesAdded = true
                }
                
                self.otherUserisFriend = self.otherUserObj.is_friend
                self.otherUserSearchObj = nil
                self.profileTableView.reloadData()
            }
        }, param:parameters)
    }
    
    func manageFeedLikeDislikeSheet(currentIndex:Int){
        let feedObj = self.viewModel.feedArray[currentIndex]
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        pagerController.feedObj = feedObj
        pagerController.parentView = self
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.stopPayer()
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    // Comment Handling Started
    //    @IBAction func commentDropDownOption(_ sender: Any) {
    //        self.commentDropDownView.isHidden = true
    //        let btn = sender as! UIButton
    //        if self.commentOptionState == 0 {
    //            if btn.tag == 0 {
    //                SharedManager.shared.isVideoPickerFromHeader = false
    //                VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    //            }else {
    //                self.showImageBrowse()
    //            }
    //        }else if self.commentOptionState == 1{
    //            if btn.tag == 0 {
    //                let gifObj = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "GifListController") as! GifListController
    //                gifObj.delegate = self
    //                gifObj.isMultiple = false
    //                gifObj.indexPath = self.currentIndex
    //                gifObj.modalPresentationStyle = .fullScreen
    //                self.present(gifObj, animated: true, completion: nil)
    //            }else {
    //                self.showImageBrowse()
    //            }
    //        }else if self.commentOptionState == 3 {
    //            if btn.tag == 0 {
    //                FeedCallBManager.shared.showAudioRecorder(cell:self.profileTableView.cellForRow(at: self.currentIndex)!)
    //            }else {
    //                self.openMusicAlbum()
    //            }
    //        }
    //    }
    
    //    func showImageBrowse()  {
    //        let viewController = TLPhotosPickerViewController()
    //        viewController.configure.maxSelectedAssets = 1
    //        viewController.delegate = self
    //        var arrayAsset = [TLPHAsset]()
    //        for indexObj in self.selectedAssets {
    //            if indexObj.isType == PostDataType.Image && indexObj.assetMain != nil {
    //                arrayAsset.append(indexObj.assetMain)
    //            }
    //        }
    //        viewController.selectedAssets = arrayAsset
    //        self.present(viewController, animated: true) {
    ////            viewController.albumPopView.show(viewController.albumPopView.isHidden, duration: 0.1)
    //        }    }
}

//extension ProfileViewController:TLPhotosPickerViewControllerDelegate {
//    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
//        // use selected order, fullresolution image
//
//        for indexObj in withTLPHAssets {
//            if indexObj.type == .photo {
//                let newObj = PostCollectionViewObject.init()
//                self.selectedAssets.append(newObj)
//                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
//                    if urlString != nil{
//                        newObj.photoUrl = urlString
//                        self?.viewLanguageModel.feedArray = self!.viewModel.feedArray
//                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
//                    }
//                }
//            }else if indexObj.type == .livePhoto {
//                let newObj = PostCollectionViewObject.init()
//                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
//                    if urlString != nil{
//                        newObj.photoUrl = urlString
//                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
//                    }
//                }
//                newObj.isType = PostDataType.Image
//                newObj.assetMain = indexObj
//                self.selectedAssets.append(newObj)
//            }
//            else if indexObj.type == .video {
//                let newObj = PostCollectionViewObject.init()
//                do {
//                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
//                    options.version = .original
//                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {[weak self] (asset, audioMix, info) in
//                        if let urlAsset = asset as? AVURLAsset {
//                            newObj.videoURL = urlAsset.url
//                            let thumbImage:UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                self!.viewLanguageModel.feedArray = self!.viewModel.feedArray
//                                FileBasedManager.shared.encodeVideo(videoURL: newObj.videoURL as URL) { (newUrl) in
//                                    DispatchQueue.main.async {
//                                        newObj.videoURL = newUrl
//                                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType:"video", selectLang: true, videoUrl: newObj.videoURL!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
//                                    }
//                                }
//                            }
//                        }
//                    })
//                }
//                self.selectedAssets.append(newObj)
//            }
//        }
//    }
//
//    @IBAction func notficationAction(sender : UIButton){
//
//    }
//}

//extension ProfileViewController:UIImagePickerControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        self.viewLanguageModel.feedArray = self.viewModel.feedArray
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
//            let fileName = "myImageToUpload.jpg"
//            FileBasedManager.shared.saveFileTemporarily(fileObj: pickedImage, name: fileName)
//            self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType: "image", selectLang: false, videoUrl: "", imgUrl:FileBasedManager.shared.getSavedImagePath(name: fileName), isPosting: false)
//            picker.dismiss(animated: true, completion: nil)
//        }else if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String,
//            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
//
//            let thumbImage:UIImage = SharedManager.shared.videoSnapshot(filePathLocal: url)!
//            self.viewLanguageModel.feedArray = self.viewModel.feedArray
//            FileBasedManager.shared.encodeVideo(videoURL: url) { (newUrl) in
//                DispatchQueue.main.async {
//                    self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType:"video", selectLang: true, videoUrl: newUrl!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
//                }
//            }
//            picker.dismiss(animated: true, completion: nil)
//        }
//    }
//
//    func uploadFile(filePath:String, fileType:String, langID:String = "", identifier:String = "", bodyString:String = ""){
//        self.viewLanguageModel.feedArray = self.viewModel.feedArray
//        let feedObj = self.viewModel.feedArray[self.currentIndex.row]
//        var parameters = ["action": "comment",
//                          "token": SharedManager.shared.userToken(),
//                          "body": bodyString,
//                          "post_id":String(feedObj.postID!),
//                          "identifier":identifier,
//                          "fileType":fileType, "fileUrl":filePath]
//        if langID != "" {
//            if fileType == "audio" {
//                parameters["recording_language_id"] = langID
//                parameters["file_language_id"] = langID
//
//            }else {
//                parameters["file_language_id"] = langID
//            }
//        }
//
//        self.callingServiceToUpload(parameters: parameters, action: "comment")
//
//        //// MARK: Socket Event For Comment
//        var dicMeta = [String : Any]()
//        dicMeta["post_id"] = String(feedObj.postID!)
//
//        var dic = [String : Any]()
//        dic["group_id"] = String(feedObj.postID!)
//        dic["meta"] = dicMeta
//        dic["type"] = "new_comment_NOTIFICATION"
//        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
//    }
//
//
//    func callingServiceToUpload(parameters:[String:String], action:String)  {
//        RequestManager.fetchDataMultipart(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
//            switch response {
//            case .failure(let error):
//                if error is String {
//                }
//            case .success(let res):
//
//                if (action == "comment") {
//                    if res is String {
//                        // self.commentServiceCallbackHandler?(res as! String)
//                    }else {
//                        self.viewLanguageModel.handlingCommentCallback(currentIndex: self.currentIndex, res: res)
//                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
//                    }
//                }
//            }
//        }, param:parameters, fileUrl: "")
//    }
//}


extension ProfileViewController:DismissReportSheetDelegate {
    
    func dismissReportWithMessage(message:String)   {
        self.sheetController.closeSheet()
        
        
        if message == "-1" {
            self.hideUser()
        }else if message == "-2" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportProfile()
            }
        }else if message == "-3" {
            
            self.blockUser()
            
        }else if message == "-4" {
            
            if self.otherUserObj.is_blocked_by_me == "1" {
                self.unBlockUser()
            }
        } else {
            SharedManager.shared.showAlert(message: message, view: self)
        }
        
    }
    
    func hideUser(){
        let parameters = ["action": "post/hide_of_author", "token": SharedManager.shared.userToken(), "user_id":self.otherUserID]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    let msg = res as? String ?? .emptyString
                    SharedManager.shared.showAlert(message: msg.capitalized , view: self)
                }
            }
        }, param:parameters)
    }
    
    
    func blockUser() {
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":self.otherUserID]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                }else{
                    let someDict = res as! NSDictionary
                    SharedManager.shared.showAlert(message: "User blocked successfully".localized(), view: self)
                    self.otherUserObj.is_blocked_by_me = "1"
                }
            }
        }, param:parameters)
    }
    
    func unBlockUser(){
        let parameters = ["action": "user/unblock_user", "token": SharedManager.shared.userToken(), "user_id":self.otherUserID]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                    self.otherUserObj.is_blocked_by_me = "0"
                }else {
                    self.otherUserObj.is_blocked_by_me = "0"
                }
            }
        }, param:parameters)
    }
    
    func reportUser(){
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":self.otherUserID]
        
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                }
            }
        }, param:parameters)
        
        
    }
    
    func dimissReportSheetHideAll(type: String, currentIndex: IndexPath) {
        self.sheetController.closeSheet()
        if type.contains("Hide all") {
            self.handleRefresh()
        }
    }
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
            }
        }else if type == "Delete" || type == "Hide"  {
            let feedObj = self.viewModel.feedArray[currentIndex.row]
            if feedObj.comments!.count > 0 {
                var commentCount:Int = 0
                if feedObj.comments!.count > 0 {
                    commentCount = (feedObj.comments?.count)! - 1
                }
                feedObj.comments?.remove(at: commentCount)
                self.viewModel.feedArray[currentIndex.row] = feedObj
                self.profileTableView.reloadRows(at: [currentIndex], with: .none)
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        
        self.stopPayer()
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(currentIndex: currentIndex)
            }
        } else if type == "Delete"  || type == "Hide" {
            self.viewModel.feedArray.remove(at: currentIndex.row)
            if self.viewModel.feedArray.count > 0 {
                self.profileTableView.deleteRows(at: [currentIndex], with: .fade)
            }
            self.profileTableView.reloadData()
        } else if type == "Edit" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let feedObj = self.viewModel.feedArray[currentIndex.row]
                let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
                createPost.modalPresentationStyle = .fullScreen
                let createPostController = createPost.viewControllers.first as! CreatePostViewController
                createPostController.isPostEdit = true
                createPostController.feedObj = feedObj
                
                SharedManager.shared.createPostSelection  = -1
                
                self.present(createPost, animated: false, completion: nil)
            }
        }
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath) {
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.isPost = ReportType.Post
        reportDetail.delegate = self
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        reportDetail.feedObj = self.viewModel.feedArray[currentIndex.row] as FeedData
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments![0]
            reportDetail.isPost = ReportType.Comment
        }
        self.stopPayer()
        self.present(self.sheetController, animated: true, completion: nil)
    }
    
    
    func showReportProfile() {
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.isPost = ReportType.User
        reportDetail.delegate = self
        reportDetail.userObj = self.otherUserObj
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.stopPayer()
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension ProfileViewController:DismissReportDetailSheetDelegate   {
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}

extension ProfileViewController:GifImageSelectionDelegate  {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        self.currentIndex = currentIndex
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        if gifDict.count > 0 {
            for (_, gifObj) in gifDict {
                self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType: "GIF", selectLang: false, videoUrl: "",imgUrl:gifObj.url, isPosting: false)
            }
        }
    }
}

extension ProfileViewController: MPMediaPickerControllerDelegate  {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection)  {
        
        self.musicPlayer!.dismiss(animated: true, completion: {
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let item: MPMediaItem = mediaItemCollection.items[0]
            let pathURL: NSURL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            if pathURL == nil {
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                SharedManager.shared.showAlert(message: "Not able to get the audio file.".localized(), view: self)
                return
            }
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "myAudioFile"
            FileBasedManager.shared.saveAudioFileTemporarily(pathURL: pathURL!, name: title)
            FileBasedManager.shared.audioFileSavedInTemp = { fileUrl in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType: "audio", selectLang: true, videoUrl: fileUrl.path, imgUrl:"", isPosting: false)
            }
        })
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)   {
        mediaPicker.dismiss(animated: true, completion: nil)
        //        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
    }
}

extension ProfileViewController: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        let types = ["public.item"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = false
        } else {
            // Fallback on earlier versions
        }
        documentPicker.modalPresentationStyle = .formSheet
        if #available(iOS 13, *) {
            documentPicker.overrideUserInterfaceStyle = .dark
            documentPicker.shouldShowFileExtensions = true
        }
        self.present(documentPicker, animated: true) {}
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}
        self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType: "attachment", selectLang: true, videoUrl: url.path, imgUrl:"", isPosting: false,  fileExt:url.pathExtension)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismiss(animated: true) {
        }
    }
    
    func downloadAttachment(commentFile:CommentFile){
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                let imageData = try Data(contentsOf: URL.init(string: commentFile.orignalUrl!)!)
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.present(activityViewController, animated: true) {
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
            } catch {
                
            }
        }
    }
}
