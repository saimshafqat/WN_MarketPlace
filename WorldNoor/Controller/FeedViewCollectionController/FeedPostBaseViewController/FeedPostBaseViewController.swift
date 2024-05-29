//
//  FeedPostBaseViewController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 03/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//


import Foundation
import FittedSheets
import SDWebImage
import Photos

enum PostSendURL {
    case strID(String)
    var detail: String {
        switch self {
        case .strID(let id):
            return "https://worldnoor.com/post/\(id)"
        }
    }
}

class FeedPostBaseViewController: PaginatedViewController {
    
    // MARK: - Lazy Properties -
    lazy var viewModel: FeedPostBaseViewModel? = {
        var viewModel = setupViewModel()
        if let collectionView {
            viewModel?.initialSetup(collectionView: collectionView, apiService: APITarget())
            viewModel?.parentView = self
        }
        return viewModel
    }()
    
    
    // MARK: - Properties -
    var isPostSearch = false
    var searchPost = ""
    var isReloadRequired: Bool = false
    var islandscapeTap: Bool = true
    var sheetController = SheetViewController()
    var locationHandler: LocationHandler?

    // MARK: - IBOutlet -
    @IBOutlet weak var notifCounterView: DesignableView?
    @IBOutlet weak var notifCounterLbl: UILabel?
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedManager.shared.isLanguageChange = true
        
        if SocketSharedManager.sharedSocket.manager == nil &&
            SocketSharedManager.sharedSocket.manager?.status != .connected &&
            SocketSharedManager.sharedSocket.manager?.status != .connecting{
            SocketSharedManager.sharedSocket.establishConnection()
        }
        
        AccessAuthorizationManager.shared.requestAccessForPhotoLibrary()
                
        navigationController?.isNavigationBarHidden = false
        title = screenTitle()
        veiwModelCallBacks()
        addObserver()
        // recent search api
        RecentSearchRequestUtility.shared.recentUserCallRequest()
        // user location update to server
        setupLocation()
    }
    
    func setupLocation() {
        locationHandler = LocationHandler()
        locationHandler?.delegate = self
        locationHandler?.checkLocationAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared.clearMemory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SharedManager.shared.isGroup = 0
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
        
        self.manageNotificationCounter()
        
        FeedPostBaseViewModel.shared.notificationBadgeHandler = { [weak self] in
            guard let self else { return }
            manageNotificationCounter()
        }
        
        FireConfiguration.shared.callingFirebaseTokenService()
        moveToPostDetailHandling()
        SharedManager.shared.supportedLanguage()
        SharedManager.shared.timerMain = nil
        
        if SharedManager.shared.isLanguageChange {
            SharedManager.shared.getPrivacySetting()
            SharedManager.shared.isLanguageChange = false
            callingBasicProfileService()
            SocketSharedManager.sharedSocket.newsFeedProcessingHandler()
            SocketSharedManager.sharedSocket.newsFeedProcessingHandlerGlobal()
            
        }
        SharedManager.shared.isGroup = 0
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if SharedManager.shared.isNewPostExist {
            SharedManager.shared.isNewPostExist = false
        }
        self.manageNotificationCounter()
        GenericNotification.shared.callingNotificationCountService()
        
        // for setting newsfeed Date from post detail
        viewModel?.setNotificationObserver()
    }
    
    private func moveToPostDetailHandling() {
        let postDetailURL = UserDefaultsUtility.get(with: .url)
        if postDetailURL != nil {
            let stringURL = postDetailURL as? String
            let stringHAsh = stringURL?.components(separatedBy: "post/")
            if stringHAsh?.count ?? 0 > 1 {
                let feedController = AppStoryboard.PostDetail.instance.instantiateViewController(withIdentifier: Const.FeedDetailController) as? FeedDetailController
                let dictMain = [String : Any]()
                feedController?.feedObj = FeedData.init(valueDict:dictMain)
                feedController?.urlHash = stringHAsh?.last ?? .emptyString
                feedController?.indexPath = IndexPath.init(row: 0, section: 0)
                UserDefaultsUtility.remove(with: .url)
                if let feedController {
                    self.navigationController?.pushViewController(feedController, animated: true)
                }
            }
        }
    }
        
    func callingBasicProfileService() {
        let parameters = ["action": "profile/basic", "token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if let dictRes = res as? NSDictionary {
                    SharedManager.shared.userBasicInfo = dictRes.mutableCopy() as! NSMutableDictionary
                    for (k, v) in SharedManager.shared.userBasicInfo {
                        SharedManager.shared.userBasicInfo[k] = v is NSNull ? "" : v
                    }
                    UserDefaultsUtility.save(with: .userBasicProfile, value: SharedManager.shared.userBasicInfo)
                }
            }
        }, param: parameters)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.ChangeTabbarText()
        UserDefaultsUtility.save(with: .isStartApp, value: "yes")
        
        guard let remoteNotification = appDelegate.remoteNotificationAtLaunch else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            return
        }
        
        appDelegate.remoteNotificationAtLaunch = nil
        
        if let typeNotification = remoteNotification["type"] as? String {
            if typeNotification == "new_friend_request" {
                self.tabBarController?.selectedIndex = 1
                (self.tabBarController as? MyTabController)?.addTabbarIndicatorView(index: 1)
            } else if let dataNotification = remoteNotification["data"] as? String {
                let arrayMain = dataNotification.components(separatedBy: ",")
                
                var findString = ""
                var notificationType = ""
                var conversationID = ""
                
                for indexObj in arrayMain {
                    if indexObj.lowercased().contains("post_id") {
                        findString = indexObj
                    }
                    if indexObj.lowercased().contains("type") {
                        notificationType = indexObj
                    }
                    if indexObj.lowercased().contains("conversation_id") {
                        conversationID = indexObj
                    }
                }
                
                let arrayID = findString.components(separatedBy: ":")
                let arrayIDNotification = notificationType.components(separatedBy: ":")
                let arrayIDConversation = conversationID.components(separatedBy: ":")
                
                guard let lastID = arrayID.last,
                      let lastNotification = arrayIDNotification.last,
                      let lastConversation = arrayIDConversation.last else { return }
                
                let trimmedLastNotification = lastNotification.replacingOccurrences(of: "\"", with: "")
                
                if trimmedLastNotification == "post" {
                    let trimmedLastConversation = lastConversation.replacingOccurrences(of: "\"", with: "")
                    self.callingGetGroupService(withID: trimmedLastConversation)
                } else if trimmedLastNotification == "new_post_share_NOTIFICATION" ||
                            trimmedLastNotification == "new_dislike_NOTIFICATION" ||
                            trimmedLastNotification == "live_stream_NOTIFICATION" ||
                            trimmedLastNotification == "new_comment_NOTIFICATION" ||
                            trimmedLastNotification == "new_like_NOTIFICATION" {
                    let trimmedLastID = lastID.replacingOccurrences(of: "\"", with: "")
                    self.loadFeed(id: trimmedLastID)
                }
            }
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.islandscapeTap {
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
        }
        for currentCell in self.viewModel?.collectionView?.visibleCells ?? [] {
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
    }
    
    override func refreshData(_ refreshControl: UIRefreshControl) {
        super.refreshData(refreshControl)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil,userInfo: nil)
        self.reloadData()
    }
    
    
    func reloadData(){
        FeedCallBManager.shared.videoClipArray.removeAll()
        FeedCallBManager.shared.watchArray.removeAll()
        initialCallService()
    }

    // MARK: - Methods -
    func setupViewModel() -> FeedPostBaseViewModel? {
        return nil
    }
    
    func initialCallService() {
        Loader.startLoading()
        viewModel?.savedPostService(isRefresh: true)
    }
    
    
    @IBAction func searchBtnClicked(_ sender: Any) {
        let controller = GlobalSearchViewController.instantiate(fromAppStoryboard: .EditProfile)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    
    @IBAction func messageBtnClicked(_ sender: Any) {
        let vc = NewChatListVC.instantiate(fromAppStoryboard: .TabBar)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showAppsFeed(sender : UIButton) {
        let popoverContentController = FeedPopOverViewController()
        popoverContentController.delegate = self
        popoverContentController.modalPresentationStyle = .popover
        if let popoverPresentationController = popoverContentController.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .init([.up])
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.delegate = self
        }
        self.present(popoverContentController, animated: true)
    }
    
    @IBAction func languageAction(sender : Any){
        let viewApps = AppStoryboard.Shared.instance.instantiateViewController(withIdentifier: "AppsFeedViewController") as! AppsFeedViewController
        
        
        self.sheetController = SheetViewController(controller: viewApps, sizes: [.fixed(450)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func notficationAction(sender : UIButton) {
                let vc = Container.Notification.getNotificationCenterScreen()
        self.navigationController?.pushViewController(vc, animated: true)
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
        viewModel?.showAlertMessageClosure = { [weak self] message in
            guard let self else { return }
            SharedManager.shared.showAlert(message: message, view: self)
        }
        
        viewModel?.moreClosure = {  [weak self] postObj, indexPath in
            guard let self else { return }
            let reportController = ReportingViewController.instantiate(fromAppStoryboard: .TabBar)
            reportController.currentIndex = indexPath
            reportController.feedObj = postObj
            reportController.delegate = self
            reportController.feedsDelegate = self
            reportController.reportType = "Post"
            openBottomSheet(reportController, sheetSize: [.fullScreen], animated: false)
        }
        
        viewModel?.shareClosure = { [weak self] postObj in
            guard let self else { return }
            let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
            shareController.postID = String(postObj.postID ?? 0)
            let navigationObj = UINavigationController.init(rootViewController: shareController)
            openBottomSheet(navigationObj, sheetSize: [.fixed(550), .fullScreen])
        }
        
        viewModel?.commentClosure = { [weak self] postObj, indexPath in
            guard let self else { return }
            navigateToPostDetail(postObj ,indexpath: indexPath)
        }
        
        viewModel?.userInfoClosure = { [weak self] postObj in
            guard let self else { return }
            navigateToProfile(postObj)
        }
        
        viewModel?.showDetailClosure = { [weak self] postObj in
            guard let self else { return }
            let indexpath = IndexPath(row: 0, section: 0)
            navigateToPostDetail(postObj, indexpath: indexpath)
        }
        
        viewModel?.postTappedClosure = { [weak self] postObj in
            guard let self else { return }
            showdetail(feedObj: postObj)
        }
        
        viewModel?.postDownloadClosure = { [weak self] postObj in
            guard let self else { return }
            // video & Image
            if let filePath = postObj.post?.first?.filePath {
                downloadFileShare(filePath: filePath, isImage: true, isShare: true , FeedObj: postObj)
            }
        }
        
        viewModel?.postGalleryPreviewClosure = { [weak self] postObj, indexPath, tag in
            guard let self else { return }
            showdetail(feedObj: postObj, currentIndex: tag)
        }
        
        viewModel?.likesDetailClosure = { [weak self] postObj in
            guard let self else { return }
            let controller = WNPagerViewController.instantiate(fromAppStoryboard: .TabBar)
            controller.feedObj = postObj
            controller.parentView = self
            let navController = UINavigationController(rootViewController: controller)
            openBottomSheet(navController, sheetSize: [.fixed(400), .fixed(250), .fullScreen], animated: false)
        }
        viewModel?.showToastCompletion = { [weak self] in
            guard let self else { return }
            showToast(with: viewModel?.errorMessage ?? .emptyString)
        }
        
        viewModel?.kalamSendClosure = { [weak self] postObj in
            guard let self else { return }
            let urlString = PostSendURL.strID(postObj.strID ?? .emptyString)
            OpenKalamTimeLink(webUrl: urlString.detail)
        }
        viewModel?.showHashTagClosue = { [weak self] value in
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
    
    func navigateToPostDetail(_ postObj: FeedData, indexpath : IndexPath) {
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        var videoWidth = 0
        var videoHeight = 0
        feedController.feedObj = postObj
        feedController.feedArray = [postObj]
        feedController.selectedIndexPath = indexpath
        feedController.hidesBottomBarWhenPushed = true
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
//        if let post = postObj.post {
//            videoWidth = post.first?.videoWidth ?? 0
//            videoHeight = post.first?.videoHeight ?? 0
//        }
//        feedController.feedVideoWidth = videoWidth
//        feedController.feedVideoHeight = videoHeight
        navigationController?.pushViewController(feedController, animated: true)
    }
    
    
    // MARK: - Methods -
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(savedPostSuccessfully(_ :)), name: .SavedPost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(landscapeNotification(_:)), name: .landscape, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRecived), name: .notificationRecieved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePostNotofication(_:)), name: .postDeleted, object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(applicationDidEnterBackground),name: .enterBackground,object: nil)

    }
    
    @objc func landscapeNotification(_ notification: NSNotification) {
        if let infoUser = notification.userInfo!["isLandscape"] as? Bool {
            self.islandscapeTap = infoUser
        }
    }
    
    @objc func savedPostSuccessfully(_ notification: NSNotification) {
        isReloadRequired = true
    }
    
    @objc func applicationDidEnterBackground() {
        SpeechManager.shared.stopSpeaking()
        MediaManager.sharedInstance.player?.pause()
    }

    @objc func handleDeletePostNotofication(_ notification: Notification) {
        if let postId = notification.object as? Int {
            self.deletePost(postID: postId)
        }
    }
    
    func deletePost(postID: Int) {
        var indexObj = -1
        if let found = viewModel?.feedArray.firstIndex(where: { $0.postID == postID }) {
            indexObj = found
        }
        if indexObj > -1 {
            viewModel?.feedArray.remove(at: indexObj)
            viewModel?.collectionView?.deleteItems(at: [IndexPath.init(row: indexObj, section: 1)])
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .SavedPost, object: nil)
        NotificationCenter.default.removeObserver(self, name: .landscape, object: nil)
    }
}


extension FeedPostBaseViewController: DismissReportSheetDelegate {
    
    func dismissUnSavedWith(msg: String, indexPath: IndexPath) {
        showToast(with: msg)
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(isPost: false, currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            if let feedObj = viewModel?.feedArray[currentIndex.row] {
                let commentCount = feedObj.comments?.count ?? 0
                if commentCount > 0 {
                    var resetCommentCount: Int = 0
                    if commentCount > 0 {
                        resetCommentCount = commentCount - 1
                    }
                    feedObj.comments?.remove(at: resetCommentCount)
                    viewModel?.feedArray[currentIndex.row] = feedObj
                    collectionView?.reloadItems(at: [currentIndex])
                }
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            deleteItem(at: currentIndex)
        } else if type.contains(PostTypes.HideAll.type) {
            viewModel?.savedPostService(isRefresh: true)
            moveToTop()
        } else if type.contains(PostTypes.Block.type) {
            viewModel?.savedPostService(isRefresh: true)
            moveToTop()
        } else if type == PostTypes.UnSave.type {
            deleteItem(at: currentIndex)
        } else if type == PostTypes.Edit.type {
            let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
            createPost.modalPresentationStyle = .fullScreen
            let createPostController = createPost.viewControllers.first as! CreatePostViewController
            createPostController.isPostEdit = true
            createPostController.feedObj = viewModel?.feedArray[currentIndex.row] as? FeedData
            SharedManager.shared.createPostSelection  = -1
            self.present(createPost, animated: false, completion: nil)
        }
    }
    
    func deleteItem(at index: IndexPath) {
        collectionView?.performBatchUpdates({
            viewModel?.feedArray.remove(at: index.row)
            collectionView?.deleteItems(at: [index])
        }, completion: nil)
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath){
        let reportDetail = ReportDetailController.instantiate(fromAppStoryboard: .TabBar)
        reportDetail.isPost = ReportType.Post
        reportDetail.feedObj = viewModel?.feedArray[currentIndex.row] as? FeedData
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments![0]
            reportDetail.isPost = ReportType.Comment
        }
        reportDetail.delegate = self
        openBottomSheet(reportDetail, sheetSize: [.fullScreen])
    }
}

extension FeedPostBaseViewController: DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        SharedManager.shared.showAlert(message: message, view: self)
    }
}

extension FeedPostBaseViewController {
    func manageNotificationCounter() {
        let counter = GenericNotification.shared.notificationCounter
        if counter == 0 {
            self.notifCounterView?.isHidden = true
        } else {
            self.notifCounterView?.isHidden = false
            self.notifCounterLbl?.text = String(GenericNotification.shared.notificationCounter)
        }
    }
}


extension FeedPostBaseViewController: FeedPopOverMenuDelegate, UIPopoverPresentationControllerDelegate {
    
    func openPostTapped() {
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        self.present(createPost, animated: true, completion: nil)
    }
    
    func openStoryTapped() {
        let viewController = self.GetView(nameVC: "StoryModuleVC", nameSB: "StoryModule")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func openReelTapped() {
        let vc = CreateReelViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openLiveTapped() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch (authStatus) {
        case .restricted, .denied:
            
            SharedManager.shared.showAlert(message:"To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app." , view: self.parent!)
        case .authorized ,.notDetermined:
            let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "GoLiveController") as! GoLiveController
            self.present(goLive, animated: true, completion: nil)
        @unknown default:
            LogClass.debugLog("default ===>")
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Notification Action -
extension FeedPostBaseViewController {
    @objc func notificationRecived(notification: NSNotification) {

        
        if appDelegate.remoteNotificationAtLaunch != nil {
            
         
            let dataNotification = appDelegate.remoteNotificationAtLaunch!["data"]
            
            let typeNotification = (appDelegate.remoteNotificationAtLaunch!["type"] as? String) ?? ""
            
            appDelegate.remoteNotificationAtLaunch = nil
            
            if typeNotification == "new_friend_request" {
                self.tabBarController?.selectedIndex = 1
                (self.tabBarController as? MyTabController)?.addTabbarIndicatorView(index: 1)
                
            }else if let stringMAin = dataNotification as? String {
                
                let arrayMain = stringMAin.components(separatedBy: ",")
                
                var findString = ""
                var NotificationType = ""
                var conversationID = ""
                
                for indexObj in arrayMain {
                    
                    if indexObj.lowercased().contains("post_id") {
                        findString = indexObj
                    }
                    
                    if indexObj.lowercased().contains("type") {
                        NotificationType = indexObj
                    }
                    
                    if indexObj.lowercased().contains("conversation_id") {
                        conversationID = indexObj
                    }
                }
                
                let arrayID = findString.components(separatedBy: ":")
                let arrayIDNotification = NotificationType.components(separatedBy: ":")
                let arrayIDConversaation = conversationID.components(separatedBy: ":")
                if arrayID.count > 0 {
                    if arrayIDNotification.count > 0 {
                        var lastValue = arrayIDNotification.last!
                        lastValue = lastValue.replacingOccurrences(of: "\"", with: "")
                        if lastValue == "post" {
                            var valueConversation = arrayIDConversaation.last ?? .emptyString
                            valueConversation = valueConversation.replacingOccurrences(of: "\"", with: "")
                            self.callingGetGroupService(withID: valueConversation)
                        } else if lastValue == "new_post_share_NOTIFICATION" ||
                                    lastValue == "new_dislike_NOTIFICATION" ||
                                    lastValue == "live_stream_NOTIFICATION" ||
                                    lastValue == "new_comment_NOTIFICATION" ||
                                    lastValue == "new_like_NOTIFICATION" {
                            var lastValue = arrayID.last ?? .emptyString
                            lastValue = lastValue.replacingOccurrences(of: "\"", with: "")
                            self.loadFeed(id: String(lastValue))
                        }
                    }
                }
            }
        }
    }
    
   
    func loadFeed(id : String){
        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token":SharedManager.shared.userToken()]
        
        RequestManagerGen.fetchDataGetNotification(Completion: { (response: Result<(FeedSingleModel), Error>) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        self.ShowAlert(message: "No post found".localized())
                    }
                }else {
                    self.ShowAlert(message: "No post found".localized())
                }
            case .success(let res):
                self.pushNewView(mainBody: res.data!.post!)
            }
        }, param:parameters)
    }
    
    func pushNewView(mainBody : FeedData){
        let feedController = AppStoryboard.PostDetail.instance.instantiateViewController(withIdentifier: Const.FeedDetailController) as! FeedDetailController
        feedController.feedObj = mainBody
        feedController.feedArray = [mainBody]
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        UIApplication.topViewController()?.navigationController?.pushViewController(feedController, animated: true)
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
//          SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                } else {
                    _ = res as! [AnyObject]
                }
            }
        }, param:parameters)
    }
}


extension FeedPostBaseViewController: FeedsDelegate {
    
    func deletePost(postID: Int, currentIndex: IndexPath?) {

    }
    
    func deleteAllPostsFromAuther(autherID: Int, currentIndex: IndexPath?) {
        LogClass.debugLog("delete all posts from auther")
        self.viewModel?.feedArray.removeAll(where: {$0.authorID == autherID})
        self.viewModel?.collectionView?.reloadData()
    }
    
    func commentUpdated(feedUpdatedOBJ: FeedData, currentIndex: IndexPath?) {
        if let index = self.viewModel?.feedArray.firstIndex(where: { $0.postID == feedUpdatedOBJ.postID }) {
            self.viewModel?.feedArray[index].commentCount = feedUpdatedOBJ.commentCount
            self.viewModel?.collectionView?.reloadData()
        }
    }    
}

extension FeedPostBaseViewController: LocationHandlerDelegate {
    
    func locationUpdated(location: CLLocation) {
        viewModel?.callServiceUpdateLocation(loc: location)
    }
    
    func locationAuthorizationStatusChanged() {
        // locationAuthorizationCompletion?()
    }
}

