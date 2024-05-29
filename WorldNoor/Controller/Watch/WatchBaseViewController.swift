//
//  WatchBaseViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 20/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import FittedSheets
import SDWebImage
import Photos

class WatchBaseViewController: PaginatedViewController {
    
    // MARK: - Lazy Properties -
    lazy var viewModel: WatchBaseViewModel = {
        var viewModel = setupViewModel()
        if let collectionView {
            viewModel?.initialSetup(collectionView: collectionView, apiService: APITarget())
            viewModel?.parentView = self
        }
        return viewModel!
    }()
    
    
    // MARK: - Properties -
    var isReloadRequired: Bool = false
    var islandscapeTap: Bool = true
    var sheetController = SheetViewController()
    
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedManager.shared.isLanguageChange = true
        
        if SocketSharedManager.sharedSocket.manager == nil &&
            SocketSharedManager.sharedSocket.manager?.status != .connected &&
            SocketSharedManager.sharedSocket.manager?.status != .connecting{
            SocketSharedManager.sharedSocket.establishConnection()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePostNotofication(_:)), name: NSNotification.Name(rawValue: "post_deleted"), object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(applicationDidEnterBackground),name: UIApplication.didEnterBackgroundNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.landscapeNotification(notification:)), name: Notification.Name("LandscapeTap"), object: nil)

        
        navigationController?.isNavigationBarHidden = false
        title = screenTitle()
        veiwModelCallBacks()
        addObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared.clearMemory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
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
        
        LocationManager.shared.manageLocation()
        
        if UserDefaults.standard.value(forKey: "url") != nil {
            
            let stringURL = UserDefaults.standard.value(forKey: "url") as? String
            let stringHAsh = stringURL?.components(separatedBy: "post/")
            
            
            if stringHAsh!.count > 1 {
                let feedController = AppStoryboard.PostDetail.instance.instantiateViewController(withIdentifier: Const.FeedDetailController) as! FeedDetailController
                let dictMain = [String : Any]()
                feedController.feedObj = FeedData.init(valueDict:dictMain)
                feedController.urlHash = stringHAsh!.last!
                feedController.indexPath = IndexPath.init(row: 0, section: 0)
                UserDefaults.standard.removeObject(forKey: "url")
                UserDefaults.standard.synchronize()
                
                self.navigationController?.pushViewController(feedController, animated: true)
            }
            
        }
                
        SharedManager.shared.supportedLanguage()
        SharedManager.shared.timerMain = nil
        
      
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if SharedManager.shared.isNewPostExist {
            SharedManager.shared.isNewPostExist = false
        }
    
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.ChangeTabbarText()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.islandscapeTap {
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
        
        SpeechManager.shared.stopSpeaking()
        if self.islandscapeTap {
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
        if UIApplication.topViewController() != nil {
            UIApplication.topViewController()!.view.viewWithTag(100)?.removeFromSuperview()
            SharedManager.shared.ytPlayer = nil
        }
    }
    
    override func refreshData(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            refreshControl.endRefreshing()
        }
        initialCallService()
    }
    
    // MARK: - Methods -
    func setupViewModel() -> WatchBaseViewModel? {
        return nil
    }
    
    func initialCallService() {
        self.viewModel.feedArray.removeAll()
        self.viewModel.collectionView?.reloadData()
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
    
    func veiwModelCallBacks() {
        viewModel.showAlertMessageClosure = { [weak self] message in
            guard let self else { return }
            SharedManager.shared.showAlert(message: message, view: self)
        }
        
        viewModel.moreClosure = {  [weak self] postObj, indexPath in
            guard let strognSelf = self else { return }
            let reportController = ReportingViewController.instantiate(fromAppStoryboard: .TabBar)
            reportController.currentIndex = indexPath
            reportController.feedObj = postObj
            reportController.delegate = self
            reportController.feedsDelegate = self
            reportController.reportType = "Post"
            strognSelf.openBottomSheet(reportController, sheetSize: [.fullScreen], animated: false)
        }
        
        viewModel.shareClosure = { [weak self] postObj in
            guard let strognSelf = self else { return }
            
            let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
            shareController.postID = String(postObj.postID ?? 0)
            let navigationObj = UINavigationController.init(rootViewController: shareController)
            
            
            strognSelf.openBottomSheet(navigationObj, sheetSize: [.fixed(550), .fullScreen])
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
                strognSelf.downloadFileShare(filePath: filePath, isImage: true, isShare: true , FeedObj: postObj)
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
            let navController = UINavigationController(rootViewController: controller)
            strognSelf.openBottomSheet(navController, sheetSize: [.fixed(400), .fixed(250), .fullScreen], animated: false)
        }
        viewModel.showToastCompletion = { [weak self] in
            guard let strognSelf = self else { return }
            strognSelf.showToast(with: strognSelf.viewModel.errorMessage ?? .emptyString)
        }
        
        viewModel.kalamSendClosure = { [weak self] postObj in
            guard let self else { return }
            let urlString = PostSendURL.strID(postObj.strID ?? .emptyString)
            
            
            OpenKalamTimeLink(webUrl: urlString.detail)
        }
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
        navigationController?.pushViewController(feedController, animated: true)
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


extension WatchBaseViewController: DismissReportSheetDelegate {
    
    func dismissUnSavedWith(msg: String, indexPath: IndexPath) {
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
                // FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.saveTableView.visibleCells)
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
        } else if type == PostTypes.UnSave.type {
            deleteItem(at: currentIndex)
        } else if type == PostTypes.Edit.type {
            let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
            createPost.modalPresentationStyle = .fullScreen
            let createPostController = createPost.viewControllers.first as! CreatePostViewController
            createPostController.isPostEdit = true
            createPostController.feedObj = self.viewModel.feedArray[currentIndex.row] as FeedData
            SharedManager.shared.createPostSelection  = -1
            
            self.present(createPost, animated: false, completion: nil)
        }
    }
    
    func deleteItem(at index: IndexPath) {
        collectionView?.performBatchUpdates({
            viewModel.feedArray.remove(at: index.row)
            collectionView?.deleteItems(at: [index])
        }, completion: nil)
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath){
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

extension WatchBaseViewController: DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        SharedManager.shared.showAlert(message: message, view: self)
    }
}




extension WatchBaseViewController: UIPopoverPresentationControllerDelegate {
    
   
   
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Notification Action -
extension WatchBaseViewController {
    
    @objc func handleDeletePostNotofication(_ notification: Notification) {
        if let postId = notification.object as? Int {
            self.deletePost(postID: postId)
        }
    }
    
    func deletePost(postID: Int) {

        
        var indexObj = -1
        
        if let found = self.viewModel.feedArray.firstIndex(where: { $0.postID == postID }) {
            indexObj = found
        }
        
        if indexObj > -1 {
            self.viewModel.feedArray.remove(at: indexObj)
            self.viewModel.collectionView?.deleteItems(at: [IndexPath.init(row: indexObj, section: 1)])
        }

    }
    
    @objc func applicationDidEnterBackground() {
        SpeechManager.shared.stopSpeaking()
        MediaManager.sharedInstance.player?.pause()
    }
    
    @objc func landscapeNotification(notification: Notification) {
        if let infoUser = notification.userInfo!["isLandscape"] as? Bool {
            self.islandscapeTap = infoUser
            
        }
    }
    

    
    func callingGetGroupService(withID : String) {
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversations?fetch_one=1", "token":userToken, "serviceType":"Node", "convo_id":withID ]
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    //                        SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
                    
                    _ = res as! [AnyObject]
                }
            }
        }, param:parameters)
    }
    
    //MARK: AccessAuth
    func requestAccessForVideo() -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        switch status  {
            // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
            })
            break;
            // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            // 用户明确地拒绝授权，或者相机设备无法访问
            break;
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted:break;
        default:
            break;
        }
    }
    
    func requestAccessForAudio() -> Void {
        let status = AVCaptureDevice.authorizationStatus(for:AVMediaType.audio)
        switch status  {
            // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                
            })
            break;
            // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            break;
            // 用户明确地拒绝授权，或者相机设备无法访问
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted:break;
        default:
            break;
        }
    }
}


extension WatchBaseViewController: FeedsDelegate {
    
    func deletePost(postID: Int, currentIndex: IndexPath?) {

    }
    
    func deleteAllPostsFromAuther(autherID: Int, currentIndex: IndexPath?) {
        LogClass.debugLog("delete all posts from auther")
        self.viewModel.feedArray.removeAll(where: {$0.authorID == autherID})
        self.viewModel.collectionView!.reloadData()
    }
    
    func commentUpdated(feedUpdatedOBJ: FeedData, currentIndex: IndexPath?) {
        if let index = self.viewModel.feedArray.firstIndex(where: { $0.postID == feedUpdatedOBJ.postID }) {
            self.viewModel.feedArray[index].commentCount = feedUpdatedOBJ.commentCount
            self.viewModel.collectionView!.reloadData()
        }
    }
}
