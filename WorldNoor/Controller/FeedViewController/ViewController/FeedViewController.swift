//
//  FeedViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 9/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Accelerate
import SDWebImage
//import IQKeyboardManagerSwift
import Speech
import FittedSheets
import TLPhotoPicker
import Photos
import MediaPlayer
import GoogleMobileAds
import FTPopOverMenu

protocol FeedsDelegate {
    func deletePost(postID: Int, currentIndex: IndexPath?)
    func deleteAllPostsFromAuther(autherID: Int, currentIndex: IndexPath?)
    func commentUpdated(feedUpdatedOBJ: FeedData, currentIndex: IndexPath?)
}

class FeedViewController: UIViewController, UINavigationControllerDelegate , GADBannerViewDelegate{
    
    var currentIndex = IndexPath()
    var selectedLangID = ""
    var selectedLangModel:LanguageModel?
    var sheetController = SheetViewController()
    var selectionHeaderType = ""
    var commentOptionState = -1
    var musicPlayer:MPMediaPickerController?
    
    
    @IBOutlet var viewStory : UIView!
    @IBOutlet var viewReel : UIView!
    @IBOutlet var viewRoom : UIView!
    
    
    @IBOutlet var lblStory : UILabel!
    @IBOutlet var lblReel : UILabel!
    @IBOutlet var lblRoom : UILabel!
    
    @IBOutlet var imgViewStory : UIImageView!
    @IBOutlet var imgViewReel : UIImageView!
    @IBOutlet var imgViewRoom : UIImageView!
    
    var viewLanguage : LanguagePopUpVC!
    
    
    @IBOutlet weak var btnWish: UIButton!
    
    @IBOutlet weak var feedCustomHeaderView: FeedHeaderView!
    @IBOutlet weak var imgViewTop: UIView!
    @IBOutlet weak var videoViewTop: UIView!
    
    @IBOutlet weak var notifCounterView: DesignableView!
    @IBOutlet weak var notifCounterLbl: UILabel!
    
    @IBOutlet weak var headerCustomView: UIView!
    @IBOutlet weak var topHeaderCustomView: UIView!
    @IBOutlet weak var feedTableBottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var feedTableView: UITableView!
    //    @IBOutlet weak var microphoneButton: UIButton!
    //    @IBOutlet weak var wordTextField: UILabel!
    //    @IBOutlet weak var waverBGView: UIView!
    @IBOutlet weak var viewPlayer: UIView!
    //    @IBOutlet public weak var waveformView: SFWaveformView?
    
    //    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    let dropDown = MakeDropDown()
    var dropDownRowHeight: CGFloat = 35
    var selectedAssets = [PostCollectionViewObject]()
    
    var height : CGFloat = 0.0
    fileprivate let viewModel = FeedViewModel()
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    
    var islandscapeTap = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedManager.shared.isLanguageChange = true
        
        
        if SocketSharedManager.sharedSocket.manager == nil && 
            SocketSharedManager.sharedSocket.manager?.status != .connected &&
            SocketSharedManager.sharedSocket.manager?.status != .connecting{
            SocketSharedManager.sharedSocket.establishConnection()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRecived), name: NSNotification.Name(rawValue: "notification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePostNotofication(_:)), name: NSNotification.Name(rawValue: "post_deleted"), object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(applicationDidEnterBackground),name: UIApplication.didEnterBackgroundNotification,object: nil)
        
        self.getPhotoAccess()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.landscapeNotification(notification:)), name: Notification.Name("LandscapeTap"), object: nil)
        let isUserObj:User = SharedManager.shared.getProfile()!
        
//        if  isUserObj.data.isProfileCompleted == false {
//            let hiddenVC = self.GetView(nameVC: "GoogleSignupProfileVC", nameSB: "EditProfile" ) as! GoogleSignupProfileVC
//            hiddenVC.modalPresentationStyle = .overCurrentContext
//            hiddenVC.modalTransitionStyle = .crossDissolve
//            self.present(hiddenVC, animated: true, completion: nil)
//            
//        }
    }
    
    @objc func applicationDidEnterBackground() {
        SpeechManager.shared.stopSpeaking()
        LogClass.debugLog("Release player 9")
        MediaManager.sharedInstance.player?.pause()
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        
    }
    
    @IBAction func segmentAction(sender : UIButton){
        
        if !feedCustomHeaderView.viewLoader.isHidden  {
            return
        }
        self.viewReel.isHidden = true
        self.viewRoom.isHidden = true
        self.viewStory.isHidden = true
        
        self.lblReel.font = UIFont.systemFont(ofSize: 15.0)
        self.lblRoom.font = UIFont.systemFont(ofSize: 15.0)
        self.lblStory.font = UIFont.systemFont(ofSize: 15.0)
        
        self.lblReel.textColor = UIColor.lightGray
        self.lblRoom.textColor = UIColor.lightGray
        self.lblStory.textColor = UIColor.lightGray
        
        self.imgViewStory.image = UIImage.init(named: "Icon-Stories.png")
        self.imgViewReel.image = UIImage.init(named: "Icon-Reels.png")
        self.imgViewRoom.image = UIImage.init(named: "Icon-Rooms.png")
        
        if self.height == 0 {
            self.height = self.feedCustomHeaderView.frame.size.height
        }
        
        
        if sender.tag == 1 {
            self.imgViewReel.image = UIImage.init(named: "Icon-Reels-S.png")
            self.viewReel.isHidden = false
            self.lblReel.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.lblReel.textColor = UIColor.init(named: "Blue Color")
            feedCustomHeaderView.isWatch = true
            
        } else if sender.tag == 0 {
            self.imgViewStory.image = UIImage.init(named: "Icon-Stories-S.png")
            self.viewStory.isHidden = false
            self.lblStory.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.lblStory.textColor = UIColor.init(named: "Blue Color")
            feedCustomHeaderView.isWatch = false
        }
        
        if sender.tag == 2 {
            self.imgViewRoom.image = UIImage.init(named: "Icon-Rooms-S.png")
            self.viewRoom.isHidden = false
            self.lblRoom.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.lblRoom.textColor = UIColor.init(named: "Blue Color")
            self.feedCustomHeaderView.videoCollectionView.isHidden = true
            self.feedCustomHeaderView.frame.size.height = 150.0
            self.feedCustomHeaderView.cstCreatePostHeight.constant = 155.0
        } else {
            self.feedCustomHeaderView.changeView()
            self.headerCustomView.isHidden = false
            self.feedCustomHeaderView.videoCollectionView.isHidden = false
            self.feedCustomHeaderView.frame.size.height = self.height
            self.feedCustomHeaderView.cstHeaderHeight.constant = 100.0
            self.feedCustomHeaderView.cstCreatePostHeight.constant = 155.0
        }
        
        DispatchQueue.main.async {
            self.feedTableView.reloadData()
        }
        
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            
            self.feedTableView.setContentOffset(CGPoint.zero, animated: true)
        }
        
    }
    
    @objc func landscapeNotification(notification: Notification) {
        if let infoUser = notification.userInfo!["isLandscape"] as? Bool {
            self.islandscapeTap = infoUser
            
        }
    }
    
    func getPhotoAccess() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // as above
                    LogClass.debugLog("authorized")
                case .denied, .restricted:
                    // as above
                    LogClass.debugLog("restricted")
                case .notDetermined:
                    // won't happen but still
                    LogClass.debugLog("notDetermined")
                case .limited:
                    LogClass.debugLog("limited")
                default:
                    LogClass.debugLog("default")
                }
            }
        }
    }
    
    func handleRefresh(){
         self.feedTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
         viewModel.refreshControl.beginRefreshingManually()
         viewModel.refresh(sender: UIButton())
         
         MediaManager.sharedInstance.playEmbeddedVideo(url: URL.init(string: "https://cdn.worldnoordev.com/files/wn263870a278791063870a278791363870a2787914_6033681.mp4")!, embeddedContentView:self.viewPlayer ,userinfo: ["isHideSound" : true])
         
//        self.btnPlay.isHidden = true
//        self.imgviewPlay.isHidden = true
        
        MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
//            LogClass.debugLog("callbackPH ===> 66")
//            LogClass.debugLog(indexRow)
//            LogClass.debugLog(urlString)
//            self.btnPlay.isHidden = false
//            self.imgviewPlay.isHidden = false
            
            MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.clear
//            self.imgviewPH.isHidden = true
        }
     }
    
    override func viewDidAppear(_ animated: Bool) {
        
        SharedManager.shared.feedRef = self
        self.ChangeTabbarText()
        
        
        UserDefaults.standard.setValue("yes", forKey: "isStartApp")
        UserDefaults.standard.synchronize()
        if SharedManager.shared.postCreatedReload {
            
            if self.feedTableView != nil {
                if self.feedTableView.indexPathsForVisibleRows != nil && self.feedTableView.indexPathsForVisibleRows?.count ?? 0 > 0 {
                    if viewModel.feedArray.count > 0 {
                        self.feedTableView.reloadRows(at: self.feedTableView.indexPathsForVisibleRows!, with: .automatic)
                    }
                }
            }
        }
        
        
        SharedManager.shared.postCreatedReload = false
        self.headerCustomView.dropShadow()
        self.topHeaderCustomView.dropShadow()
        LocationManager.shared.manageLocation()
        
        if appDelegate.remoteNotificationAtLaunch != nil {
            let dataNotification = appDelegate.remoteNotificationAtLaunch!["data"]
            
            appDelegate.remoteNotificationAtLaunch = nil
            
            if let stringMAin = dataNotification as? String {
                
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
                            var valueConversation = arrayIDConversaation.last!
                            valueConversation = valueConversation.replacingOccurrences(of: "\"", with: "")
                            self.callingGetGroupService(withID: valueConversation)
                        }else if lastValue == "new_post_share_NOTIFICATION" ||
                                    lastValue == "new_dislike_NOTIFICATION" ||
                                    lastValue == "live_stream_NOTIFICATION" ||
                                    lastValue == "new_comment_NOTIFICATION" ||
                                    lastValue == "new_like_NOTIFICATION"
                        {
                            
                            var lastValue = arrayID.last!
                            lastValue = lastValue.replacingOccurrences(of: "\"", with: "")
                            self.loadFeed(id: String(lastValue))
                        }
                        
                    }
                    
                }
            }
        }

    }
    
    @objc func notificationRecived(notification: NSNotification) {
        if appDelegate.remoteNotificationAtLaunch != nil {
            let dataNotification = appDelegate.remoteNotificationAtLaunch!["data"]
            
            appDelegate.remoteNotificationAtLaunch = nil
            
            if let stringMAin = dataNotification as? String {
                
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
                            var valueConversation = arrayIDConversaation.last!
                            valueConversation = valueConversation.replacingOccurrences(of: "\"", with: "")
                            self.callingGetGroupService(withID: valueConversation)
                        }else if lastValue == "new_post_share_NOTIFICATION" ||
                                    lastValue == "new_dislike_NOTIFICATION" ||
                                    lastValue == "live_stream_NOTIFICATION" ||
                                    lastValue == "new_comment_NOTIFICATION" ||
                                    lastValue == "new_like_NOTIFICATION"
                        {
                            
                            var lastValue = arrayID.last!
                            lastValue = lastValue.replacingOccurrences(of: "\"", with: "")
                            self.loadFeed(id: String(lastValue))
                        }
                    }
                }
            }
        }
    }
    
    func callingGetGroupService(withID : String) {
        //        SharedManager.shared.showOnWindow()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversations?fetch_one=1", "token":userToken, "serviceType":"Node", "convo_id":withID ]
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
            
            
            
            
            self.headerCustomView.dropShadow()
            if SharedManager.shared.isLanguageChange {
                SharedManager.shared.getPrivacySetting()
                SharedManager.shared.isLanguageChange = false
                
                self.viewLanguageModel.callingBasicProfileService()
                ManageTableView()
                manageUI()
                SharedManager.shared.selectedTabController = self
                SocketSharedManager.sharedSocket.newsFeedProcessingHandler()
                SocketSharedManager.sharedSocket.newsFeedProcessingHandlerGlobal()
                
            }
            self.btnWish.setTitle("wish".localized(), for: .normal)
            self.btnWish.rotateForTextAligment()
            self.ChangeTabbarText()
            callBackHandling()
            SharedManager.shared.isGroup = 0
            SocketSharedManager.sharedSocket.commentDelegate = self
            navigationController?.setNavigationBarHidden(true, animated: animated)
            if SharedManager.shared.isNewPostExist {
                SharedManager.shared.isNewPostExist = false
                self.handleRefresh()
            }
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            let fileName = "myImageToUpload.jpg"
            self.userImageView.image = FileBasedManager.shared.loadImage(pathMain: fileName)
            self.view.labelRotateCell(viewMain: self.userImageView)
            self.manageNotificationCounter()
            
        // omnia comment this line to show new created story
//            self.feedCustomHeaderView.reloadTableWithNewdata()
            
            self.feedCustomHeaderView.resetAndReload()
            GenericNotification.shared.callingNotificationCountService()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SpeechManager.shared.stopSpeaking()
        if self.islandscapeTap {
            LogClass.debugLog("Release player 10")
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func manageUI(){
        self.feedCustomHeaderView.manageFeedHeader()
        self.feedCustomHeaderView.parentControl = self
        //        self.waveformView(show: false, animationDuration: 0)
        FireConfiguration.shared.callingFirebaseTokenService()
    }
    
    func manageNotificationCounter() {
    
        
        let counter = GenericNotification.shared.notificationCounter

        if counter == 0 {
            self.notifCounterView.isHidden = true
        } else {
            self.notifCounterView.isHidden = false
            self.notifCounterLbl.text = String(GenericNotification.shared.notificationCounter)
        }
    }
    
    func ManageTableView()    {
        self.viewModel.isMainFeedView = true
        self.viewModel.initializeMe(action:"newsfeed")
        
        self.viewModel.parentView = self
        feedTableView.dataSource = viewModel
        feedTableView.delegate = viewModel
        feedTableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.identifier)
        feedTableView.register(UINib.init(nibName: "AdCell", bundle: nil), forCellReuseIdentifier: "AdCell")
        
        feedTableView.register(UINib.init(nibName: "FeedReelCell", bundle: nil), forCellReuseIdentifier: "FeedReelCell")
        feedTableView.register(UINib.init(nibName: "FeedFriendSuggestionCell", bundle: nil), forCellReuseIdentifier: "FeedFriendSuggestionCell")
        
        
        feedTableView.register(UINib.init(nibName: "NewImageFeedCell", bundle: nil), forCellReuseIdentifier: "NewImageFeedCell")
        feedTableView.register(UINib.init(nibName: "NewVideoFeedCell", bundle: nil), forCellReuseIdentifier: "NewVideoFeedCell")
        feedTableView.register(UINib.init(nibName: "NewAudioFeedCell", bundle: nil), forCellReuseIdentifier: "NewAudioFeedCell")
        feedTableView.register(UINib.init(nibName: "NewGalleryFeedCell", bundle: nil), forCellReuseIdentifier: "NewGalleryFeedCell")
        feedTableView.register(UINib.init(nibName: "NewAttachmentFeedCell", bundle: nil), forCellReuseIdentifier: "NewAttachmentFeedCell")
        feedTableView.register(UINib.init(nibName: "NewTextFeedCell", bundle: nil), forCellReuseIdentifier: "NewTextFeedCell")
        feedTableView.register(UINib.init(nibName: "NewSharedFeedCell", bundle: nil), forCellReuseIdentifier: "NewSharedFeedCell")
        
        
        feedTableView.register(VideoCell.nib, forCellReuseIdentifier: VideoCell.identifier)
        feedTableView.register(AudioCell.nib, forCellReuseIdentifier: AudioCell.identifier)
        feedTableView.register(SkeletonCell.nib, forCellReuseIdentifier: SkeletonCell.identifier)
        feedTableView.register(GalleryCell.nib, forCellReuseIdentifier: GalleryCell.identifier)
        feedTableView.register(ImageCellSingle.nib, forCellReuseIdentifier: ImageCellSingle.identifier)
        feedTableView.register(SharedCell.nib, forCellReuseIdentifier: SharedCell.identifier)
        feedTableView.register(AttachmentCell.nib, forCellReuseIdentifier: AttachmentCell.identifier)
        
        feedTableView.estimatedRowHeight = 50
        feedTableView.rowHeight = UITableView.automaticDimension
        self.viewModel.refreshControl.addTarget(viewModel, action: #selector(self.viewModel.refresh(sender:)), for: UIControl.Event.valueChanged)
        feedTableView.addSubview(self.viewModel.refreshControl)
    }
    
    @IBAction func searchBtnClicked(_ sender: Any) {
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
    
    
    
    @IBAction func audioBtnClicked(_ sender: Any) {
        
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch (authStatus) {
            
        case .restricted, .denied:
            showAlert(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
        case .authorized ,.notDetermined:
            let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "GoLiveController") as! GoLiveController
            self.present(goLive, animated: true, completion: nil)
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            // Take the user to Settings app to possibly change permission.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        alert.addAction(settingsAction)
        
        self.present(alert, animated: true, completion: nil)
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
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func headerOptionBtn1Clicked(_ sender: Any) {
        
        FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
        if self.selectionHeaderType == "Image" {
            SharedManager.shared.createPostSelection = 4
        }else if self.selectionHeaderType == "GIF" {
            SharedManager.shared.createPostSelection = 8
        }else if self.selectionHeaderType == "Video" {
            SharedManager.shared.createPostSelection = 6
        }else if self.selectionHeaderType == "Audio" {
            SharedManager.shared.createPostSelection = 3
        }else if self.selectionHeaderType == "Attachment" {
            SharedManager.shared.createPostSelection = 10
        }
        
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        let imageView = UIImageView(image: self.view.takeScreenshot())
        imageView.frame = UIScreen.main.bounds
        SharedManager.shared.createPostScreenShot = imageView
        self.present(createPost, animated: false, completion: nil)
    }
    
    @IBAction func headerOptionBtn2Clicked(_ sender: Any) {
        
        FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
        
        if self.selectionHeaderType == "Image"{
            SharedManager.shared.createPostSelection = 0
        }else if self.selectionHeaderType == "GIF"{
            SharedManager.shared.createPostSelection = 0
        }else if self.selectionHeaderType == "Audio"{
            SharedManager.shared.createPostSelection = 9
        }
        
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        let imageView = UIImageView(image: self.view.takeScreenshot())
        imageView.frame = UIScreen.main.bounds
        SharedManager.shared.createPostScreenShot = imageView
        self.present(createPost, animated: false, completion: nil)
    }
    
    @IBAction func createPostBtnClicked(_ sender: Any) {
        
        let btn = sender as! UIButton
        SharedManager.shared.createPostSelection = btn.tag
        
        
        if SharedManager.shared.createPostSelection == 0 {
            self.selectionHeaderType = "Image"
            FTPopOverMenu.show(forSender: btn, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.headerOptionBtn1Clicked(sender)
                }else {
                    self.headerOptionBtn2Clicked(sender)
                }
            } dismiss: {
                
            }
        } else if SharedManager.shared.createPostSelection == 1 {
            self.selectionHeaderType = "Video"
            
            FTPopOverMenu.show(forSender: btn, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.headerOptionBtn1Clicked(sender)
                }else {
                    self.headerOptionBtn2Clicked(sender)
                }
            } dismiss: {
                
            }
            
        } else if SharedManager.shared.createPostSelection == 5 {
            let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
            createPost.modalPresentationStyle = .fullScreen
            
            self.present(createPost, animated: true, completion: nil)
        }
    }
    
    
    func callBackHandling() {
        
        if(SharedManager.shared.isfromStory) {
//            self.feedCustomHeaderView.resetAndReload()
            SharedManager.shared.isfromStory = false
        }
        self.viewModel.feedScrollHandler = { () in
        }
        self.viewModel.refreshTable = { () in
            MediaManager.sharedInstance.playEmbeddedVideo(url: URL.init(string: "https://cdn.worldnoordev.com/files/wn263870a278791063870a278791363870a2787914_6033681.mp4")!, embeddedContentView:self.viewPlayer ,userinfo: ["isHideSound" : true])
            
            self.feedCustomHeaderView.resetAndReload()
            
//            self.btnPlay.isHidden = true
//            self.imgviewPlay.isHidden = true
            
            MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
//                LogClass.debugLog("callbackPH ===> 77")
//                LogClass.debugLog(indexRow)
//                LogClass.debugLog(urlString)
                
//                self.btnPlay.isHidden = false
//                self.imgviewPlay.isHidden = false
                
                MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.clear
//                self.imgviewPH.isHidden = true
            }
        }
        
        self.viewModel.reloadTableViewClosure = { () in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                UIView.setAnimationsEnabled(false)
                self.feedTableView.reloadData()
                self.feedTableView.isHidden = false
            }
        }
        
        self.viewModel.didSelectTableClosure = { [weak self](indexValue) in
//            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self!.feedTableView.visibleCells)
//            
//            let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FeedDetailController) as! FeedDetailController
//            feedController.feedObj = self!.viewModel.feedArray[indexValue.row] as FeedData
//            feedController.feedArray = self!.viewModel.feedArray
//            feedController.indexPath = indexValue
//            self!.navigationController?.pushViewController(feedController, animated: true)
//            feedController.updateTableFromFeed = { (indexValue) in
//                self!.feedTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
//            }
//            feedController.feedDeletedFromDetailHandler =  {[weak self] (currentIndex) in
//                self?.viewModel.feedArray.remove(at: currentIndex.row)
//                self?.feedTableView.deleteRows(at: [currentIndex], with: .fade)
//                self?.feedTableView.reloadData()
//            }
//            feedController.feedHideAllFromDetailHandler  =  {[weak self] (currentIndex) in
//                self?.handleRefresh()
//            }
//            
//            feedController.commentDeletedFromDetailHandler = {[weak self] (currentIndex) in
//                self?.feedTableView.reloadRows(at: [currentIndex], with: UITableView.RowAnimation.none)
//            }
        }
        
        self.viewModel.reloadSpecificRow = { (indexValue) in
            self.feedTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
        }
        self.viewModel.reloadVisibleRows = { (indexValue) in
            self.feedTableView.reloadRows(at: self.feedTableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.none)
        }
        self.viewModel.hideFooterClosure = { () in
            self.feedTableView.tableFooterView?.removeFromSuperview()
        }
        self.viewModel.showAlertMessageClosure = { (message) in
            SharedManager.shared.showAlert(message: message, view: self)
        }
        self.viewModel.reloadTableViewWithNoneClosure = { () in
            self.feedTableView.reloadData()
        }
        self.viewModel.showShareOption = { (indexValue) in
            
            let feedObj = self.viewModel.feedArray[indexValue] as FeedData
            //            SharedManager.shared.showOnWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                do {
                    let imageData = try Data(contentsOf: URL.init(string: (feedObj.post?.first!.filePath)!)!)
                    let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                    self.present(activityViewController, animated: true) {
//                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                        Loader.stopLoading()
                    }
                } catch {
                    
                }
                
            }
        }
        
//        self.viewModel.presentImageFullScreenClosure = { (indexValue, isGroup) in
//
//            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
//            var feedObj:FeedData?
//            if isGroup {
//                feedObj = self.viewModel.feedArray[indexValue] as FeedData
//                feedObj = feedObj?.sharedData
//            }else {
//                feedObj = self.viewModel.feedArray[indexValue] as FeedData
//            }
//
//            fullScreen.collectionArray = feedObj!.post!
//            fullScreen.feedObj = feedObj
//            fullScreen.movedIndexpath = 0
//            fullScreen.isInfoViewShow = false
//            fullScreen.modalTransitionStyle = .crossDissolve
//            fullScreen.currentIndex = IndexPath.init(row: indexValue, section: 0)
//            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
//            self.present(fullScreen, animated: false, completion: nil)
//        }
        
        FeedCallBManager.shared.galleryCellIndexCallbackHandler = { [weak self] (currentIndex, galleryIndexPath, isGroup) in
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var feedObj:FeedData?
            if isGroup {
                feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
                feedObj = feedObj?.sharedData
            }else {
                feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
            }
            
            fullScreen.collectionArray = feedObj!.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = galleryIndexPath.row
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = currentIndex
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self!.feedTableView.visibleCells)
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        
        FeedCallBManager.shared.commentImageTappedHandler = { [weak self] (indexValue) in
//            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
//            fullScreen.typeOfImage = "comment"
//            let feedObj = self!.viewModel.feedArray[indexValue.row] as FeedData
//            var commentCount:Int = 0
//            if feedObj.comments!.count > 0 {
//                commentCount = (feedObj.comments?.count)! - 1
//            }
//            fullScreen.commentObj = (feedObj.comments![commentCount]).commentFile![0]
//            fullScreen.modalTransitionStyle = .crossDissolve
//            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        FeedCallBManager.shared.likeCallBackManager = { (currentIndex) in
            self.manageFeedLikeDislikeSheet(currentIndex: currentIndex)
        }
        
        FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
            FeedCallBManager.shared.manageSpeakerForVisibleCell(tableCellArr: self!.feedTableView.visibleCells, currentIndex:currentIndex, feedArray: self!.viewModel.feedArray, isComment: isComment)
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
                //                self!.commentCameraBtn.isHidden = false
                //                self!.commentGifBrowseBtn.isHidden = true
                //                self!.commentRecordBtn.isHidden = true
            }else if btn.tag == 1 {
                //                self!.commentCameraBtn.isHidden = true
                //                self!.commentGifBrowseBtn.isHidden = false
                //                self!.commentRecordBtn.isHidden = true
            }else if btn.tag == 2 {
                //                self!.commentDropDownView.isHidden = true
                self!.didPressDocumentShare()
            }else if btn.tag == 3 {
                offset = -30
                //                self!.commentCameraBtn.isHidden = true
                //                self!.commentGifBrowseBtn.isHidden = true
                //                self!.commentRecordBtn.isHidden = false
            }
            
            self?.currentIndex = currentIndex
            //            let frame = btn.superview!.convert(btn.frame, to: self!.view)
            //            self?.commentDropDownView.frame = CGRect(x: frame.origin.x  + CGFloat(offset), y: frame.origin.y - self!.commentDropDownView.frame.size.height + 7 , width: self!.commentDropDownView.frame.size.width, height: self!.commentDropDownView.frame.size.height)
            self!.commentOptionState = btn.tag
        }
        
        self.viewLanguageModel.reloadSpecificRowCommentImageUpload = {[weak self] (indexValue) in
            self!.feedTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
        }
        
        FeedCallBManager.shared.downloadShareFile = { [weak self] (mainIndex, currentIndex) in
            let feedObjUpdate:FeedData = self!.viewModel.feedArray[mainIndex.row]
            let postObj = feedObjUpdate.post![currentIndex.row]
            
            
            //            SharedManager.shared.showOnWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                do {
                    let imageData = try Data(contentsOf: URL.init(string: postObj.filePath!)!)
                    let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                    self!.present(activityViewController, animated: true) {
//                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                        Loader.stopLoading()
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
        
        FeedCallBManager.shared.videoProcessingCompletedHandler = {[weak self] (postID, indexValue) in
            let tableIndex:Int = FeedCallBManager.shared.getIndexPathFromVisibleCell(tableCellArr: (self?.feedTableView.visibleCells)!, postID: postID, indexValue: indexValue)
            if tableIndex != -1 {
                self?.feedTableView.reloadRows(at: [IndexPath(row: tableIndex, section: 0)], with: UITableView.RowAnimation.none)
            }
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
            self!.feedTableView.reloadRows(at: [currentIndex], with: UITableView.RowAnimation.none)
        }
        
        FeedCallBManager.shared.uploadingInstantHandler  = { [weak self] (currentIndex, uploadObj, body) in
            let feedObj:FeedData = self!.viewModel.feedArray[currentIndex.row]
            feedObj.uploadObj = nil
            self!.viewLanguageModel.handlingInstantCommentCallback(currentIndex: self!.currentIndex, fileType:uploadObj.type, selectLang: true, videoUrl: uploadObj.url, isPosting: false,imgUrl: uploadObj.imageUrl, imageObj: uploadObj.imageObj ?? UIImage(), isImageObjExist: uploadObj.isImageExist, identifier: uploadObj.identifier)
            if uploadObj.type == "image" {
                self?.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode,identifier: uploadObj.identifier, bodyString: body )
            }else if uploadObj.type == "video" {
                self?.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
            }else if uploadObj.type == "GIF" {
                self?.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier, bodyString: body )
            }else if uploadObj.type == "audio" {
                self?.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
            }else if uploadObj.type == "attachment" {
                self?.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
            }
        }
        
        FeedCallBManager.shared.downloadFileHandler  = { [weak self] (currentIndex, commentFile) in
            self?.downloadAttachment(commentFile: commentFile)
        }
        
        FeedCallBManager.shared.notificationBadgeHandler = { [weak self] in
            self!.manageNotificationCounter()
        }
    }
    
    func openMusicAlbum() {
        
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        self.musicPlayer = MPMediaPickerController(mediaTypes: .anyAudio)
        self.musicPlayer!.delegate = self
        self.musicPlayer!.allowsPickingMultipleItems = false
        self.present(self.musicPlayer!, animated: true, completion: nil)
    }
    
    @IBAction func dropDownBtnClicked(_ sender: Any) {
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 10)
    }
    
    
    @IBAction func languageAction(sender : Any){
        
        let viewApps = AppStoryboard.Shared.instance.instantiateViewController(withIdentifier: "AppsFeedViewController") as! AppsFeedViewController
        
        
        self.sheetController = SheetViewController(controller: viewApps, sizes: [.fixed(450)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
//
        
//        if viewLanguage == nil {
//            self.viewLanguage = Bundle.main.loadNibNamed("LanguagePopUpVC", owner: self, options: nil)?.first as? LanguagePopUpVC
//        }
//
//        viewLanguage.frame = self.view.frame
//        viewLanguage.resetHandler()
//        viewLanguage.parentView = self
//        let window = UIApplication.shared.keyWindow
//        window?.addSubview(self.viewLanguage)
//        self.viewLanguage.center = self.view.center
    }
    
    func resetAllActivities() {
        FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
    }
    
    @objc func handleDeletePostNotofication(_ notification: Notification) {
        if let postId = notification.object as? Int {
            self.deletePost(postID: postId, currentIndex: nil)
        }
    }    
}


extension FeedViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let fileName = "myImageToUpload.jpg"
            FileBasedManager.shared.saveFileTemporarily(fileObj: pickedImage, name: fileName)
            self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType: "image", selectLang: false, videoUrl: "", imgUrl:FileBasedManager.shared.getSavedImagePath(name: fileName), isPosting: false)
            
            picker.dismiss(animated: true, completion: nil)
        }else if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String,
                 let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if SharedManager.shared.isVideoPickerFromHeader {
                let thumbImage:UIImage = SharedManager.shared.videoSnapshot(filePathLocal: url)!
                let dict:[String:Any] = ["path":url.path, "storedImage":thumbImage]
                let feedObj:FeedVideoModel = self.feedCustomHeaderView.feedModel.getVideoObj(dict: dict)
                FeedCallBManager.shared.videoClipArray.insert(feedObj, at: 0)
                self.feedCustomHeaderView.videoClipArray = FeedCallBManager.shared.videoClipArray
                self.feedCustomHeaderView.videoCollectionView.reloadData()
            }else {
                let thumbImage:UIImage = SharedManager.shared.videoSnapshot(filePathLocal: url)!
                self.viewLanguageModel.feedArray = self.viewModel.feedArray
                FileBasedManager.shared.encodeVideo(videoURL: url) { (newUrl) in
                    DispatchQueue.main.async {
                        self.viewLanguageModel.handlingUploadFeedView(currentIndex: self.currentIndex, fileType:"video", selectLang: true, videoUrl: newUrl!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadFile(filePath:String, fileType:String, langID:String = "", identifier:String = "", bodyString:String = ""){
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        let feedObj = self.viewModel.feedArray[self.currentIndex.row]
        var parameters = ["action": "comment",
                          "token": SharedManager.shared.userToken(),
                          "body": bodyString,
                          "post_id":String(feedObj.postID!),
                          "identifier":identifier,
                          "fileType":fileType, "fileUrl":filePath]
        if langID != "" {
            if fileType == "audio" {
                parameters["recording_language_id"] = langID
                parameters["file_language_id"] = langID
                
            }else {
                parameters["file_language_id"] = langID
            }
        }
        self.callingServiceToUpload(parameters: parameters, action: "comment")
        
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(feedObj.postID!)
        
        var dic = [String : Any]()
        dic["group_id"] = String(feedObj.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_comment_NOTIFICATION"
        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
    }
    
    func callingServiceToUpload(parameters:[String:String], action:String)  {
        RequestManager.fetchDataMultipart(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if (action == "comment") {
                    if res is String {
                        // self.commentServiceCallbackHandler?(res as! String)
                    }else {
                        self.viewLanguageModel.handlingCommentCallback(currentIndex: self.currentIndex, res: res)
                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
                    }
                }
            }
        }, param:parameters, fileUrl: "")
    }
    
    //    func resetUIElement(){
    //        self.headerDropdownView.isHidden = true
    //        self.feedCustomHeaderView.videoSelectionView.isHidden = true
    //    }
    
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
    //                FeedCallBManager.shared.showAudioRecorder(cell:self.feedTableView.cellForRow(at: self.currentIndex)!)
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
    //            if indexObj.isType == PostDataTy1pe.Image && indexObj.assetMain != nil {
    //                arrayAsset.append(indexObj.assetMain)
    //            }
    //        }
    //        viewController.selectedAssets = arrayAsset
    //        self.present(viewController, animated: true) {
    //        }
    //    }
    
}

//extension FeedViewController: MakeDropDownDataSourceProtocol{
//extension FeedViewController{
//    func getDataToDropDown(cell: UITableViewCell, indexPos: Int, makeDropDownIdentifier: String) {
//        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
//            let customCell = cell as! DropDownTableViewCell
//            customCell.countryNameLabel.text = self.lanaguageModelArray[indexPos].languageName
//        }
//    }
//
//    func numberOfRows(makeDropDownIdentifier: String) -> Int {
//        return self.lanaguageModelArray.count
//    }

//    func selectItemInDropDown(indexPos: Int, makeDropDownIdentifier: String) {
//        self.selectedLangModel = self.lanaguageModelArray[indexPos]
//        let languageName = self.lanaguageModelArray[indexPos].languageName
//        self.dropDownBtn.setTitle(" "+languageName, for: .normal)
//        self.dropDown.hideDropDown()
//    }

//    func setUpDropDown(){
//        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
//        dropDown.cellReusableIdentifier = "dropDownCell"
//        dropDown.makeDropDownDataSourceProtocol = self
//        var frm = CGRect(x: 0, y: 0, width: 0, height: 0)
//        if UIDevice.current.hasNotch {
//            frm = CGRect(x: self.dropDownBtn.frame.origin.x, y: 15 + self.langView.frame.origin.y + self.dropDownBtn.frame.size.height, width: self.dropDownBtn.frame.size.width, height: self.dropDownBtn.frame.size.height)
//        } else {
//            frm = CGRect(x: self.dropDownBtn.frame.origin.x, y: -10 + self.langView.frame.origin.y + self.dropDownBtn.frame.size.height, width: self.dropDownBtn.frame.size.width, height: self.dropDownBtn.frame.size.height)
//        }
//        dropDown.setUpDropDown(viewPositionReference: (frm), offset: 0)
//        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
//        dropDown.setRowHeight(height: self.dropDownRowHeight)
//        self.view.addSubview(dropDown)
//
////        self.viewLanguageModel.langugageHandlerDetectedAndAutoTranslation = { [weak self] (langugageID, isAuto) in
////            self?.selectedLangModel = self?.lanaguageModelArray[(langugageID-1)]
////            self?.dropDownBtn.setTitle(" "+(self?.selectedLangModel?.languageName)!, for: .normal)
////            self!.switchBtn!.setOn(false, animated: false)
////            if isAuto == 1 {
////                self!.switchBtn!.setOn(true, animated: false)
////            }
////        }
//    }

//    func languageHandler()  {
//        if let langID = SharedManager.shared.userBasicInfo["language_id"] as? Int   {
//            let isAuto = SharedManager.shared.userBasicInfo["auto_translate"] as! Int
//            if self.lanaguageModelArray.count > 0 {
//                self.selectedLangModel = self.lanaguageModelArray[(langID-1)]
//                self.dropDownBtn.setTitle(" "+(self.selectedLangModel?.languageName)!, for: .normal)
//                self.switchBtn!.setOn(false, animated: false)
//                if isAuto == 1 {
//                    self.switchBtn!.setOn(true, animated: false)
//                }
//            }
//        }
//    }

//    func populateLangugaeData(){
//        self.lanaguageModelArray = SharedManager.shared.populateLangData()
//    }
//}

extension FeedViewController:TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                let newObj = PostCollectionViewObject.init()
                self.selectedAssets.append(newObj)
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        newObj.photoUrl = urlString
                        self?.viewLanguageModel.feedArray = self!.viewModel.feedArray
                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
                    }
                }
            }else if indexObj.type == .livePhoto {
                let newObj = PostCollectionViewObject.init()
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        newObj.photoUrl = urlString
                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
                    }
                }
                newObj.isType = PostDataType.Image
                newObj.assetMain = indexObj
                self.selectedAssets.append(newObj)
            }
            else if indexObj.type == .video {
                let newObj = PostCollectionViewObject.init()
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {[weak self] (asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            newObj.videoURL = urlAsset.url
                            let thumbImage:UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self!.viewLanguageModel.feedArray = self!.viewModel.feedArray
                                FileBasedManager.shared.encodeVideo(videoURL: newObj.videoURL as URL) { (newUrl) in
                                    DispatchQueue.main.async {
                                        newObj.videoURL = newUrl
                                        self!.viewLanguageModel.handlingUploadFeedView(currentIndex: self!.currentIndex, fileType:"video", selectLang: true, videoUrl: newObj.videoURL!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
                                    }
                                }
                            }
                        }
                    })
                }
                self.selectedAssets.append(newObj)
            }
        }
    }
    
    @IBAction func notficationAction(sender : UIButton) {
        
//        let feedController = AppStoryboard.Notification.instance.instantiateViewController(withIdentifier: "NotificationPagerController") as! NotificationPagerController
//        self.navigationController?.pushViewController(feedController, animated: true)
        
        // omnia
        let vc = Container.Notification.getNotificationCenterScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedViewController: DismissReportSheetDelegate, FeedsDelegate {
    
    // refresh delete post or hide post
    func deletePost(postID: Int, currentIndex: IndexPath?) {
        LogClass.debugLog("delete post done")
        viewModel.feedArray.removeAll(where: {$0.postID == postID})
        self.feedTableView.reloadData()
    }
    
    func deleteAllPostsFromAuther(autherID: Int, currentIndex: IndexPath?) {
        LogClass.debugLog("delete all posts from auther")
        viewModel.feedArray.removeAll(where: {$0.authorID == autherID})
        self.feedTableView.reloadData()
    }
    
    func commentUpdated(feedUpdatedOBJ: FeedData, currentIndex: IndexPath?) {
       
        if let index = viewModel.feedArray.firstIndex(where: { $0.postID == feedUpdatedOBJ.postID }) {
            viewModel.feedArray[index].commentCount = feedUpdatedOBJ.commentCount
            self.feedTableView.reloadData()
        }
    }
    
    func dismissReportWithMessage(message:String) {
        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: message)
        self.sheetController.closeSheet()
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
            }
        } else if type == "Delete" || type == "Hide"  {
            let feedObj = self.viewModel.feedArray[currentIndex.row]
            if feedObj.comments!.count > 0 {
                var commentCount:Int = 0
                if feedObj.comments!.count > 0 {
                    commentCount = (feedObj.comments?.count)! - 1
                }
                FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
                feedObj.comments?.remove(at: commentCount)
                self.viewModel.feedArray[currentIndex.row] = feedObj
                self.feedTableView.reloadRows(at: [currentIndex], with: .none)
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(currentIndex: currentIndex)
            }
        } else if type == "Delete" || type == "Hide" {
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.feedTableView.visibleCells)
            self.viewModel.feedArray.remove(at: currentIndex.row)
            self.feedTableView.deleteRows(at: [currentIndex], with: .fade)
            self.feedTableView.reloadData()
        } else if type.contains("Hide all") {
            self.handleRefresh()
        } else if type.contains("Block") {
            self.handleRefresh()
            showToast(with: "User blocked successfully".localized(), color: UIColor().hexStringToUIColor(hex: "#03875F"))
        } else if type == "Edit" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let feedObj = self.viewModel.feedArray[currentIndex.row]
                let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
                createPost.modalPresentationStyle = .fullScreen
                let createPostController = createPost.viewControllers.first as! CreatePostViewController
                createPostController.isPostEdit = true
                createPostController.feedObj = feedObj
                SharedManager.shared.createPostSelection  = -1
                self.present(createPost, animated: false, completion: nil)                       }
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
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension FeedViewController:DismissReportDetailSheetDelegate   {
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: message)
        }
    }
}

extension FeedViewController:GifImageSelectionDelegate  {
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

extension FeedViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension FeedViewController : feedCommentDelegate {
    
    func videoProcessingSocketResponse(res:NSArray) {
        if res.count > 0 {
            if let dict = res[0] as? [String:Any] {
                if dict["additional_data"] != nil {
                    if let additionalDict = dict["additional_data"] as? [String:Any] {
                        if let postDict = additionalDict["post"] as? [String:Any] {
                            if let postScope = postDict["post_scope_id"] as? Int {
                                if postScope == 2 {
                                    //           self.feedCustomHeaderView.videoProcessed(videoID: postDict["post_id"] as! Int)
                                }else if postScope == 1{
                                    FeedCallBManager.shared.manageVideoProcessingResponse(feedObj: self.viewModel.feedArray, id: String(postDict["post_id"] as! Int))
                                }
                            }else {
                                FeedCallBManager.shared.manageVideoProcessingResponse(feedObj: self.viewModel.feedArray, id: String(postDict["post_id"] as! Int))
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FeedViewController:MPMediaPickerControllerDelegate  {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)  {
        self.musicPlayer!.dismiss(animated: true, completion: {
            //            SharedManager.shared.showOnWindow()
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

extension FeedViewController: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        let types = ["public.item"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = false
        }
        documentPicker.modalPresentationStyle = .formSheet
        if #available(iOS 13, *) {
            documentPicker.overrideUserInterfaceStyle = .dark
            documentPicker.shouldShowFileExtensions = true
        }
        self.present(documentPicker, animated: true) {
            
        }
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
    
    
    func loadFeed(id : String){
        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token":SharedManager.shared.userToken()]
        
        RequestManagerGen.fetchDataGetNotification(Completion: { (response: Result<(FeedSingleModel), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
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
        
        let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FeedDetailController) as! FeedDetailController
        feedController.feedObj = mainBody
        feedController.feedArray = [mainBody]
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        UIApplication.topViewController()?.navigationController!.pushViewController(feedController, animated: true)
    }
    
    
    
    @IBAction func videoAction(sender : UIButton) {
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
    
    
//        func getUsernfo(){
//    
//            let userToken = SharedManager.shared.userToken()
//            var parameters = ["action": "profile/about","token": userToken]
//            if self.otherUserID.count > 0 {
//                parameters["user_id"] = self.otherUserID
//            }
//            SharedManager.shared.showOnWindow()
//            RequestManager.fetchDataGet(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
//                switch response {
//                case .failure(let error):
//                    if error is String {
//                        SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
//                    }
//                case .success(let res):
//                    if res is Int {
//                        AppDelegate.shared().loadLoginScreen()
//                    }else if res is [String : Any] {
//    
//                            SharedManager.shared.userEditObj = UserProfile.init(fromDictionary: res as! [String : Any])
//    
//                    }
//                    if self.tabBarController?.selectedIndex == 2 {
//                        self.viewModel.selectedTab = selectedUserTab.timeline
//                        self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
//                    }else {
//                        self.viewModel.selectedTab = selectedUserTab.timeline
//                        self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
//                    }
//    
//    
//                    self.otherUserisFriend = self.otherUserObj.is_friend
//                    self.otherUserSearchObj = nil
//                    self.profileTableView.reloadData()
//                }
//            }, param:parameters)
//        }
    //
}


extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
//    class func topViewController() -> UIViewController? {
//        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//        if let navController = keyWindow?.rootViewController as? UINavigationController {
//            return navController.visibleViewController
//        }
//        if let tabbar = keyWindow?.rootViewController as? UITabBarController {
//            return tabbar.selectedViewController
//        }
//        if let presented = keyWindow?.rootViewController?.presentedViewController {
//            return presented
//        }
//        return keyWindow?.rootViewController
//    }
    
//    class func topViewController() -> UIViewController? {
//        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
//            return UIViewController()
//        }
//        
//        var topViewController = keyWindow.rootViewController
//        
//        while let presentedViewController = topViewController?.presentedViewController {
//            topViewController = presentedViewController
//        }
//        
//        if let navController = topViewController as? UINavigationController {
//            return navController.visibleViewController
//        }
//        
//        if let tabBarController = topViewController as? UITabBarController {
//            return tabBarController.selectedViewController
//        }
//        
//        return topViewController
//    }

//    class func topViewController() -> UIViewController? {
//        var currentViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
//
//        while true {
//            if let navigationController = currentViewController as? UINavigationController {
//                currentViewController = navigationController.visibleViewController
//            } else if let tabController = currentViewController as? UITabBarController {
//                currentViewController = tabController.selectedViewController
//            } else if let presented = currentViewController?.presentedViewController {
//                currentViewController = presented
//            } else {
//                break // Exit the loop when there are no more presented view controllers
//            }
//        }
//
//        return currentViewController
//    }
}

// feed popover meun
extension FeedViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension FeedViewController: FeedPopOverMenuDelegate {
    
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
            showAlert(title: "Unable to access the Camera",
                      message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
        case .authorized ,.notDetermined:
            let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "GoLiveController") as! GoLiveController
            self.present(goLive, animated: true, completion: nil)
        }
    }
}

protocol FeedPopOverMenuDelegate: AnyObject {
    func openPostTapped()
    func openStoryTapped()
    func openReelTapped()
    func openLiveTapped()
}
