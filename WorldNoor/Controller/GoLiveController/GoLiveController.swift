//
//  GoLiveController.swift
//  WorldNoor
//
//  Created by Raza najam on 6/5/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import LFLiveKit
import FittedSheets

class GoLiveController: UIViewController, LFLiveSessionDelegate {
    var sessionString = ""
    var appearingAnimations = ["fade in", "fade in left", "fade in right", "zoom in"]
    var disappearingAnimations = ["fade out", "fade out left", "fade out right", "zoom out"]
    var countDownFrom: Double = 3
    var appearingAnimation = CountdownView.Animation.fadeIn
    var disappearingAnimation = CountdownView.Animation.fadeOut
    var spin = true
    var autohide = true
    var sheetController = SheetViewController()
    var selectedLangID = ""
    var selectedLangName = ""
    var selectedPrivacyString = "friends"
    var selectedPrivacyIDs:[Int:String] = [:]
    var isFirstAppearance = true
    var stayLiveTimer: Timer?

    var livePostObj : FeedData?
    
    
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stopLiveButton: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var langTxtLbl: UILabel!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        session.delegate = self
        session.preView = self.view
        self.requestAccessForVideo()
        self.requestAccessForAudio()
        self.containerView.backgroundColor = UIColor.clear
        containerView.addSubview(stateLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(beautyButton)
        containerView.addSubview(cameraButton)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for:.touchUpInside)
        muteButton.addTarget(self, action: #selector(didTappedMuteButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
        self.manageUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stayLiveTimer?.invalidate()
        self.stayLiveTimer = nil
    }
    
    func manageUI(){
        selectedLangID = SharedManager.shared.getCurrentLanguageID()
        selectedLangName = SharedManager.shared.getLanguageName(id: selectedLangID)
        self.langTxtLbl.text = String(format: "Your Language is".localized() + " %@", selectedLangName)
        privacyBtn.layer.shadowColor = UIColor.black.cgColor
        privacyBtn.layer.shadowRadius = 1.0
        privacyBtn.layer.shadowOpacity = 1.0
        privacyBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
        privacyBtn.layer.masksToBounds = false
    }
    
    //MARK: AccessAuth
    func requestAccessForVideo() -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        switch status  {
        // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if(granted){
                    DispatchQueue.main.async {
                        self.session.running = true
                        self.startLiveButton.isHidden = false
                        self.languageView.isHidden = false
                        self.privacyView.isHidden = false
                    }
                }
            })
            break;
        // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            session.running = true;
            self.startLiveButton.isHidden = false
            self.languageView.isHidden = false
            self.privacyView.isHidden = false
            break;
        // 用户明确地拒绝授权，或者相机设备无法访问
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
    
    //MARK: - Callbacks
    
    // 回调
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {

    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {

        switch state {
        case LFLiveState.ready:
            stateLabel.text = "Ready".localized()
            break;
        case LFLiveState.pending:
            stateLabel.text = "Pending".localized()
            break;
        case LFLiveState.start:
            stateLabel.text = "Live".localized()
            if isFirstAppearance {
                self.bottomView.isHidden = false
                self.startLiveButton.isHidden = true
                self.languageView.isHidden = true
                self.privacyBtn.isEnabled = false
                self.closeButton.isHidden = true
                self.callingUploadThumbService()
                isFirstAppearance = false
                
                self.didTapStartCounterButton()
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
            }
            break;
        case LFLiveState.error:
            stateLabel.text = "Error".localized()
            self.stayLiveTimer?.invalidate()
            self.stayLiveTimer = nil
            break;
        case LFLiveState.stop:
            stateLabel.text = "Stop".localized()
            self.stayLiveTimer?.invalidate()
            self.stayLiveTimer = nil
            break;
        default:
            stateLabel.text = "Connecting...".localized()
            break;
        }
    }
    
    //MARK: - Events
    @IBAction func changeLanguageBtnClicked(_ sender: Any) {
        let langController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "LanguageSelectionController") as! LanguageSelectionController
        langController.delegate = self
        self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(500)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func didTappedStartLiveButton(_ button: UIButton) -> Void {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        if SocketSharedManager.sharedSocket.socket.status == .connected {
            SocketSharedManager.sharedSocket.goLiveSession()
            SocketSharedManager.sharedSocket.commentDelegate = self
            self.startLiveButton.isEnabled = false
        }else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.didTappedStartLiveButton(UIButton.init())
            }
        }
    }
    
    func startLiveSession(sessionID:String) {
        let stream = LFLiveStreamInfo()
        stream.url = String(format: "%@%@", AppConfigurations().BaseUrlLiveStreaming, sessionID)
        self.sessionString = sessionID
        session.startLive(stream)
//        self.didTapStartCounterButton()
    }
    
    @IBAction func managePrivacyOption(){
        let langController = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "PrivacyOptionController") as! PrivacyOptionController
        langController.delegate = self
        langController.isAppearFrom = "GoLive"
        self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(600)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func didTappedStopButton(_ button: UIButton) -> Void {
        session.stopLive()
        self.showOptions()
    }
    
    @objc func didTappedBeautyButton(_ button: UIButton) -> Void {
        session.beautyFace = !session.beautyFace;
        beautyButton.isSelected = !session.beautyFace
    }
    
    @IBAction func didTappedMuteButton(_ button: UIButton) -> Void {
        session.muted = !session.muted;
        muteButton.isSelected = !muteButton.isSelected
    }
    
    @objc func didTappedCameraButton(_ button: UIButton) -> Void {
        let devicePositon = session.captureDevicePosition;
        session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back;
    }
    
    @objc func didTappedCloseButton(_ button: UIButton) -> Void  {
        session.stopLive()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Getters and Setters
    
    //  默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏
    var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.medium)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low2)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session?.reconnectInterval = 1
        session?.reconnectCount = 100
        return session!
    }()
    
    // 状态Label
    var stateLabel: UILabel = {
        let stateLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 80, height: 40))
        stateLabel.text = "GoLive".localized()
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        stateLabel.layer.shadowColor = UIColor.black.cgColor
        stateLabel.layer.shadowRadius = 1.0
        stateLabel.layer.shadowOpacity = 1.0
        stateLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        stateLabel.layer.masksToBounds = false
        return stateLabel
    }()
    
    // 关闭按钮
    var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 10 - 44, y: 20, width: 50, height: 50))
        closeButton.setImage(UIImage(named: "close_preview"), for: UIControl.State())
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowRadius = 1.0
        closeButton.layer.shadowOpacity = 1.0
        closeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        closeButton.layer.masksToBounds = false
        return closeButton
    }()
    
    // 摄像头
    var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 2, y: 20, width: 50, height: 50))
        cameraButton.setImage(UIImage(named: "camra_preview"), for: UIControl.State())
        cameraButton.layer.shadowColor = UIColor.black.cgColor
        cameraButton.layer.shadowRadius = 1.0
        cameraButton.layer.shadowOpacity = 1.0
        cameraButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        cameraButton.layer.masksToBounds = false
        return cameraButton
    }()
    
    // 摄像头
    var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 3, y: 20, width: 50, height: 50))
        beautyButton.setImage(UIImage(named: "camra_beauty"), for: UIControl.State.selected)
        beautyButton.setImage(UIImage(named: "camra_beauty_close"), for: UIControl.State())
        beautyButton.layer.shadowColor = UIColor.black.cgColor
        beautyButton.layer.shadowRadius = 1.0
        beautyButton.layer.shadowOpacity = 1.0
        beautyButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        beautyButton.layer.masksToBounds = false
        return beautyButton
    }()
    
    //MARK: -OTHER LOGIC
    func showOptions(){
        
        var dictMain = [String : Any]()
        var langObj = LanguageObj.init(valueDict: dictMain)
        langObj.languageName = self.selectedLangName
        langObj.codeID = Int(self.selectedLangID)
        
//        var feedObj = FeedData.init(valueDict:dictMain )
        
        if self.livePostObj != nil {
            self.livePostObj!.language = langObj
            self.livePostObj!.privacyType = self.selectedPrivacyString
            self.livePostObj!.liveStreamID = self.sessionString
        }
        
        
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        reportController.delegate = self
        reportController.reportType = "Live"
        reportController.feedObj = self.livePostObj
        self.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
//        self.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
}

extension GoLiveController : feedCommentDelegate {
    
    func goLiveSessionSocketResponse(res:NSArray) {
        if res.count > 0 {
            if let sessionID = res[0] as? String {
                if sessionID  != "NO ACK" || sessionID != "" {
                    self.startLiveSession(sessionID: sessionID)
                }else {
                    self.showSocketFailureMessage()
                }
            }else {
                self.showSocketFailureMessage()
            }
        }else {
            self.showSocketFailureMessage()
        }
    }
    
    func showSocketFailureMessage(){
        SharedManager.shared.showAlert(message: "Could not connect, please try later.".localized(), view: self)
        self.startLiveButton.isEnabled = true
    }
    
    func getThumbWithPostObj()->[PostCollectionViewObject] {
        let thumb = session.currentImage
        var newAssets = [PostCollectionViewObject]()
        let createPostObj = PostCollectionViewObject.init()
        createPostObj.isType = PostDataType.Image
        createPostObj.imageMain = thumb
        newAssets.append(createPostObj)
        return newAssets        
    }
    
    func callingUploadThumbService()
    {
        let userToken = SharedManager.shared.userObj!.data.token
        let parameters = ["action": "upload","api_token": userToken, "multiple_uploads":"true","type":"create_post","serviceType":"Media"]
        CreateRequestManager.uploadMultipartRequest( params: parameters as! [String : String],fileObjectArray: self.getThumbWithPostObj(),success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
            if let dict = respDict["meta"] as? NSDictionary {
                let meta = dict
                let code = meta["code"] as! Int
                
                if code == ResponseKey.successResp.rawValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() ) {
                        self.managePostCreateService(resp: respDict["data"] as! NSArray)
                    }
                }
            }
        },failure: {(error) -> Void in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
        }, showProgress: false)
    }
    
    func managePostCreateService(resp:NSArray,isFileExist:Bool = false)  {
        let userToken = SharedManager.shared.userObj!.data.token
        var createPostObj = PostCollectionViewObject.init()
        var postObj:[PostCollectionViewObject] = [PostCollectionViewObject]()
        postObj = createPostObj.getPostData(respArray: resp)
        if postObj.count > 0 {
            createPostObj = postObj[0]
            postObj.removeAll()
        }
        var parameters = ["action": "post/create","token": userToken, "body":"", "live_stream_session_id":self.sessionString, "live_stream_thumbnail_url":createPostObj.hashString, "privacy_option":self.selectedPrivacyString]
        if self.selectedPrivacyIDs.count > 0 {
            var counter = 0
            for (_,v) in self.selectedPrivacyIDs {
                let key = String(format: "contact_group_ids[%i]", counter)
                parameters[key] = v
                counter = counter + 1
            }
        }
        
        CreateRequestManager.uploadMultipartCreateRequests( params: parameters as! [String : String],fileObjectArray: postObj,success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue {
                
                if let dataDict = respDict["data"] as? NSDictionary {
                    if let postID = dataDict["post_id"] as? Int {
                        
                        
                        if let dataMain = respDict["data"] as? [String : AnyObject] {
                            if let stringMain = dataMain["post_id"] as? Int {
                                self.loadFeed(id: String(stringMain))
                            }
                        }
                        
                        
                        let metaDict = ["post_id":String(postID)]
                        let notifDict = ["type":"live_stream_NOTIFICATION", "group_id":String(SharedManager.shared.getUserID()), "meta":metaDict] as [String : Any]
                        SocketSharedManager.sharedSocket.emitLiveStreamNotificationAction(dict: notifDict)
                        self.manageStayLiveStreaming()
                        self.stayLiveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.manageStayLiveStreaming), userInfo: nil, repeats: true)
                    }
                }
            }
            
            
            
        },failure: {(error) -> Void in

        }, isShowProgress: isFileExist)
    }
    
    func loadFeed(id : String){
                
        // For live notificaiton
        var dic:[String:Any] = ["group_id":id]
        dic["type"] = "live_stream_NOTIFICATION"
        SocketSharedManager.sharedSocket.livenotification(dictionary: dic)
        
        
        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token":SharedManager.shared.userToken()]
        
        RequestManagerGen.fetchDataGetNotification(Completion: { (response: Result<(FeedSingleModel), Error>) in
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

                self.livePostObj = res.data!.post!
//                SharedManager.shared.postCreateTop = res.data!.post!
//                SharedManager.shared.isNewPostExist = true
//                self.dismiss(animated: true, completion: nil)
//                self.viewModel.selectedAssets.removeAll()
//                self.postCollectionView.reloadData()
//                self.bottomCollectionView.reloadData()
            }
        }, param:parameters)
    }
    
    @objc func manageStayLiveStreaming()  {
        if  stateLabel.text == "Live" {
            SocketSharedManager.sharedSocket.emitLiveStreamingStayLive(dict: ["session_id":self.sessionString])
        }
    }
}

extension GoLiveController {
    func didTapStartCounterButton() {
     
        CountdownView.shared.dismissStyle = .byButton
        CountdownView.show(countdownFrom: countDownFrom, spin: spin, animation: appearingAnimation, autoHide: autohide,
                           completion: nil)
        if !autohide {
            delay(countDownFrom, closure: {
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                CountdownView.hide(animation: self.disappearingAnimation, options: (duration: 1, delay: 0.2),
                                   completion: nil)
            })
            
            
        }
    }
    
    internal func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

extension GoLiveController:DismissReportSheetDelegate {
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply: Bool) {
        
    }
    
    func dismissReportWithMessage(message: String) {
        self.sheetController.closeSheet()
        
        var parameters = ["stream_id":self.sessionString, "language_id":selectedLangID, "should_store_stream":"no"]
        if message == "Save" {
            SharedManager.shared.isNewPostExist = true
            parameters["should_store_stream"] = "yes"
        }
        if SocketSharedManager.sharedSocket.socket.status == .connected {
            SocketSharedManager.sharedSocket.emitSaveLiveStream(dict: parameters as NSDictionary)
        }else {
            SharedManager.shared.showAlert(message: "Please wait for the connection to establish.".localized(), view: self)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismissController()
        }
    }
    
    func callingService(parameters:[String:String]) {

        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):

                break
            }
        }, param:parameters)
    }
    
    func dismissController()  {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GoLiveController:LanguageSelectionDelegate {
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        
    }
    
    func lanaguageSelected(langObj: LanguageModel) {
        self.sheetController.closeSheet()
        selectedLangID = langObj.languageID
        selectedLangName = langObj.languageName
        self.langTxtLbl.text = String(format: "Your Language is".localized() + " %@", selectedLangName)
    }
}

extension GoLiveController:PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String) {
        self.sheetController.closeSheet()
        self.selectedPrivacyString = keyPair
        self.privacyBtn.setTitle(type, for: .normal)
    }
    
    
    func privacyOptionCategorySelected(type:String, catID:[Int:String]) {
        self.sheetController.closeSheet()
        if type.count > 0 {
            self.privacyBtn.setTitle("Contact Groups".localized(), for: .normal)
            self.selectedPrivacyString = type
            self.selectedPrivacyIDs = catID
        }
    }
}
