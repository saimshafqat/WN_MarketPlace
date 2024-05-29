//
//  ProfileBaseViewController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//


import Foundation
import FittedSheets
import SDWebImage

class ProfileBaseViewController: PaginatedViewController {
    
    // MARK: - Lazy Properties -
    lazy var viewModel: ProfileBaseViewModel = {
        var viewModel = setupViewModel()
        if let collectionView {
            viewModel?.initialSetup(collectionView: collectionView, apiService: APITarget())
            viewModel?.parentView = self
        }
        
        return viewModel!
    }()
    
    // MARK: - Properties -
    var isPostSearch = false
    var searchPost = ""
    var isReloadRequired: Bool = false
    var islandscapeTap = true
    var sheetController = SheetViewController()
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = screenTitle()
        veiwModelCallBacks()
        addObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared.clearMemory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        performOnAppear()
        
        
        
        SharedManager.shared.isGroup = 0
        // when create new post then it will refresh
        if SharedManager.shared.isNewPostExist {
            moveToTop()
            initialCallService()
            SharedManager.shared.isNewPostExist = false
        }
        
        // post will save
        if isReloadRequired {
            moveToTop()
            initialCallService()
            isReloadRequired.toggle()
        }
        
        self.viewModel.reloadData()
    }
    
    func performOnAppear() {
        // override me
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.islandscapeTap {
            LogClass.debugLog("Release player 4")
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
        }
        for currentCell in self.viewModel.collectionView?.visibleCells ?? [] {
            if let videoCell = currentCell as? PostVideoCollectionCell {
                if self.islandscapeTap {
                    videoCell.stopPlayer()
                }
            }
            if let galleryCell = currentCell as? PostGalleryCollectionCell1 {
                galleryCell.stopPlayer()
            }
            
            if let audioCell = currentCell as? PostAudioCollectionCell1 {
                audioCell.stopPlayer()
            }
        }
    }
    
    override func refreshData(_ refreshControl: UIRefreshControl) {
        super.refreshData(refreshControl)
        initialCallService()
    }
    
    // MARK: - Methods -
    func setupViewModel() -> ProfileBaseViewModel? {
        return nil
    }
    
    func initialCallService() {
        Loader.startLoading()
        viewModel.savedPostService(isRefresh: true)
    }
    
    func moveToTop() {
        guard collectionView != nil else {
            return
        }
        collectionView?.setContentOffset(.zero, animated: false)
    }
    
    func screenTitle() -> String {
        return Const.savedPost.localized()
    }
    
    func reportingType() -> String {
        return "Post"
    }
    
    func veiwModelCallBacks() {
        viewModel.showAlertMessageClosure = { [weak self] message in
            guard let self else { return }
            SharedManager.shared.showAlert(message: message, view: self)
        }
        
        viewModel.moreClosure = {  [weak self] postObj, indexPath in
            guard let self else { return }
            let reportController = ReportingViewController.instantiate(fromAppStoryboard: .TabBar)
            reportController.currentIndex = indexPath
            reportController.feedObj = postObj
            reportController.delegate = self
            reportController.reportType = reportingType()
            openBottomSheet(reportController, sheetSize: [.fullScreen])
        }
        
        viewModel.shareClosure = { [weak self] postObj in
            guard let self else { return }
            let shareController = SharePostController.instantiate(fromAppStoryboard: .TabBar)
            shareController.postID = String(postObj.postID ?? 0)
            let navigationObj = UINavigationController.init(rootViewController: shareController)
            openBottomSheet(navigationObj, sheetSize: [.fixed(550), .fullScreen])
        }
        
        viewModel.commentClosure = { [weak self] postObj, indexPath in
            guard let strognSelf = self else { return }
            strognSelf.navigateToPostDetail(postObj)
        }
        
        viewModel.userInfoClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            strognSelf.navigateToProfile(postObj)
        }
        
        viewModel.showDetailClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            strognSelf.navigateToPostDetail(postObj)
        }
        
        viewModel.postTappedClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            strognSelf.showdetail(feedObj: postObj)
        }
        
        viewModel.postDownloadClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            // video & Image
            if let filePath = postObj.post?.first?.filePath {
                strognSelf.downloadFile(filePath: filePath, isImage: true, isShare: true , FeedObj: postObj)
            }
        }
        
        viewModel.postGalleryPreviewClosure = { [weak self] postObj, indexPath, tag in
            guard let strognSelf = self else { return }
            strognSelf.showdetail(feedObj: postObj, currentIndex: tag)
        }
        
        viewModel.likesDetailClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            let controller = WNPagerViewController.instantiate(fromAppStoryboard: .TabBar)
            controller.feedObj = postObj
            controller.parentView = self
            strognSelf.openBottomSheet(controller, sheetSize: [.fixed(400), .fixed(250), .fullScreen])
        }
        viewModel.showToastCompletion = { [weak self] in
            guard let strognSelf = self else { return }
            strognSelf.showToast(with: strognSelf.viewModel.errorMessage ?? .emptyString)
        }
        
//        viewModel.kamlamSendClosure = { [weak self] postObj in
//            guard let self else { return }
//            let urlString = PostSendURL.strID(postObj.strID ?? .emptyString)
//            LogClass.debugLog("\(urlString.detail)")
//            OpenLink(webUrl: urlString.detail)
//        }
        viewModel.showHashTagClosue = { [weak self] value in
            let tagSection = HashTagVC.instantiate(fromAppStoryboard: .Shared)
            tagSection.Hashtags = value
            self?.navigationController?.pushViewController(tagSection, animated: true)
        }
    }
    
    func navigateToProfile(_ postObj: FeedData) {
        let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        if let authorId = postObj.authorID {
            let userID = String(authorId)
            if Int(userID) != SharedManager.shared.getUserID() {
                controller.otherUserID = userID
                controller.otherUserisFriend = "1"
            }
        }
        controller.isNavPushAllow = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToPostDetail(_ postObj: FeedData) {
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        
        feedController.feedObj = postObj
        feedController.feedArray = [postObj]
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        
        var videoWidth = 0
        var videoHeight = 0
        if let post = postObj.post {
            videoWidth = post.first?.videoWidth ?? 0
            videoHeight = post.first?.videoHeight ?? 0
        }
        
        feedController.feedVideoWidth = videoWidth
        feedController.feedVideoHeight = videoHeight
        
        if  (UIApplication.topViewController()?.isKind(of: UISearchController.self) ?? false) { // for search
            UIApplication.topViewController()!.modalPresentationStyle = .fullScreen
        } else {
            UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
        }
        
        //        UIApplication.topViewController()!.present(feedController, animated: true)
        
        UIApplication.topViewController()!.navigationController?.pushViewController(feedController, animated: true)
        
        //        let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FeedNewDetailController") as! FeedNewDetailController
        //        feedController.feedObj = postObj
        //        feedController.feedArray = [postObj]
        //        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        //
        //        if  (UIApplication.topViewController()?.isKind(of: UISearchController.self) ?? false) { // for search
        //            UIApplication.topViewController()!.modalPresentationStyle = .fullScreen
        //        } else {
        //            UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
        //        }
        //
        //        UIApplication.topViewController()!.present(feedController, animated: true)
    }
    
    
    // MARK: - Methods -
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(savedPostSuccessfully(_ :)), name: .SavedPost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(landscapeNotification(_:)), name: .landscape, object: nil)
    }
    
    @objc func landscapeNotification(_ notification: NSNotification) {
        if let infoUser = notification.userInfo!["isLandscape"] as? Bool {
            self.islandscapeTap = infoUser
        }
    }
    
    @objc func savedPostSuccessfully(_ notification: NSNotification) {
        isReloadRequired = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .SavedPost, object: nil)
        NotificationCenter.default.removeObserver(self, name: .landscape, object: nil)
    }
}


extension ProfileBaseViewController: DismissReportSheetDelegate {
    
    func dismissUnSavedWith(msg: String, indexPath: IndexPath) {
//        deleteItem(at: indexPath)
        showToast(with: msg)
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(isPost: false, currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            let feedObj = self.viewModel.feedArray[currentIndex.row]
            if feedObj.comments!.count > 0 {
                var commentCount: Int = 0
                if feedObj.comments!.count > 0 {
                    commentCount = (feedObj.comments?.count)! - 1
                }
                feedObj.comments?.remove(at: commentCount)
                viewModel.feedArray[currentIndex.row] = feedObj
                collectionView?.reloadItems(at: [currentIndex])
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            deleteItem(at: currentIndex)
        } else if type.contains(PostTypes.HideAll.type) {
            viewModel.savedPostService(isRefresh: true)
            moveToTop()
        } else if type.contains(PostTypes.Block.type) {
            viewModel.savedPostService(isRefresh: true)
            moveToTop()
//        } else if type == PostTypes.UnSave.type {
//            deleteItem(at: currentIndex)
        }
    }
    
    func deleteItem(at index: IndexPath) {
        
        LogClass.debugLog("deleteItem ===>")
        LogClass.debugLog(index)
        LogClass.debugLog(viewModel.feedArray.count)
        collectionView?.performBatchUpdates({
            guard index.item < viewModel.feedArray.count else {
                return
            }
            viewModel.feedArray.remove(at: index.item)
            collectionView?.deleteItems(at: [index])
        }, completion: { _ in
            self.collectionView?.reloadData()
        })
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath) {
        let reportDetail = ReportDetailController.instantiate(fromAppStoryboard: .TabBar)
        reportDetail.isPost = ReportType.Post
        reportDetail.feedObj = self.viewModel.feedArray[currentIndex.row] as FeedData
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments![0]
            reportDetail.isPost = ReportType.Comment
        }
        reportDetail.delegate = self
        openBottomSheet(reportDetail, sheetSize: [.fullScreen])
    }
}

extension ProfileBaseViewController: DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        SharedManager.shared.showAlert(message: message, view: self)
    }
}



