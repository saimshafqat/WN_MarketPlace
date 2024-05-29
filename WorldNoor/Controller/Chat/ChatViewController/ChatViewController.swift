//
//  ChatViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import CommonKeyboard
import AVKit
import AVFoundation
import Photos
import TLPhotoPicker
import SKPhotoBrowser
import FittedSheets
import WebRTC
import CoreData

class ChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DelegateRefresh {
    let keyboardObserver = CommonKeyboardObserver()
    var userToken = ""
    var chatModelArray = [Message]()
    var editchatModelObj:Message?
    var chatDict = Dictionary<String, [Message]>()
    var isReply:Bool = false
    var isSelectionEnable = false
    var isAPICall = false
    var isTranslationOn = true
    var isLoadMore = true
    var isDeletedOther = false
    var isBlock = false
    var selectedRows = [String]()
    var conversatonObj = Chat()
    var dateObj : Date!
    var startingPoint = ""
    var currentOffset : CGPoint!
    var imageMain = UIImage.init()
    var calldictionary:[String:Any]  = [:]
    var sheetController = SheetViewController()
    var topBar = UIView()
    let topBarbutton = UIButton()
    var scroolToIndex = 0
    var newMsgCounter = 0
    var videoObj = [String : Any]()
    var reactToID = ""
    var viewReaction:ReactionChatView? = ReactionChatView.loadNib()
    
    @IBOutlet var viewPreview : UIView!
    @IBOutlet var viewVideoPreview : UIView!
    @IBOutlet var imgViewPreview : UIImageView!
    @IBOutlet var viewPreviewAudio : UIView!
    @IBOutlet var viewPreviewSlider : UISlider!
    @IBOutlet var viewBlockUser : UIView! {
        didSet {
            viewBlockUser.addShadowToView()
            viewBlockUser.isHidden = true
        }
    }
    @IBOutlet weak var blocknLeaveLbl: UILabel!
    @IBOutlet weak var replylblUserName: UILabel!
    @IBOutlet var viewCameraOptions: UIView!
    @IBOutlet var viewGifOptions: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var replyimgViewBG: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var cstTbleTop: NSLayoutConstraint!
    @IBOutlet weak var commentEditViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cstViewChatPreview: NSLayoutConstraint!
    @IBOutlet weak var commentHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var replyimgViewM: UIImageView!
    @IBOutlet weak var viewReply: UIView!
    @IBOutlet weak var replylbl: UILabel!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var btnMoveBottom: UIButton!
    @IBOutlet var btnBottomView: UIView!
    @IBOutlet var messageRequestView: UIView!
    @IBOutlet var noConversation : UILabel!
    
    lazy var popOverController: OptionsPopover = {
        if var controller = self.GetView(nameVC: "OptionsPopover", nameSB: "Notification") as? OptionsPopover {
            controller.delegate = self
            return controller
        }else {
            return OptionsPopover.init()
        }
    }()
    
    
    lazy var chatPreviewController: ChatPreviewVC = {
        if var controller = self.GetView(nameVC: "ChatPreviewVC", nameSB: "Notification") as? ChatPreviewVC {
            controller.delegateChat = self
            return controller
        }else {
            return ChatPreviewVC.init()
        }
    }()
    
    
    @IBOutlet weak var viewSelection: UIView!{
        didSet {
            //            viewSelection.addShadowToView()
            viewSelection.isHidden = true
        }
    }
    @IBOutlet weak var viewVideo: UIView!{
        didSet {
            viewVideo.addShadowToView()
            viewVideo.isHidden = true
        }
    }
    
    //MARK: - Overide
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.registerCustomCells([
            "SenderChatCell",
            "ReceiverChatCell"
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangeNotification),name: NSNotification.Name(Const.KLangChangeNotif),object: nil)
        SocketSharedManager.sharedSocket.commentDelegate = self
        self.userToken = SharedManager.shared.userToken()
        self.chatTableView.estimatedRowHeight = 300
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.keyboardDismissMode = .interactive
        self.noConversation.isHidden = true
        self.manageKeyboard()
        self.manageTextView()
        self.manageCallBackHandler()
        checkCallStatus()
        
        self.chatModelArray.removeAll()
        self.chatTableView.reloadData()
        
        self.delegateRefresh()
        updateChatObject()
        scrollToBottom(isAnimated: false)
        
        if self.conversatonObj.conversation_type == "group" {
            checkCallStatus()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.viewCameraOptions.isHidden = true
        SocketSharedManager.sharedSocket.commentDelegate = self
        self.chatTableView.keyboardDismissMode = .onDrag
        
        let autoTranslation = self.ReturnValueCheck(value: SharedManager.shared.userBasicInfo["auto_translate"] as Any)
        if  autoTranslation.count == 0 || autoTranslation == "1" {
            self.isTranslationOn = true
        }else if autoTranslation == "0" {
            self.isTranslationOn = false
        }
        SocketSharedManager.sharedSocket.delegateGroup = self
        self.viewPreviewSlider.setThumbImage(UIImage(named: "NewThumb"), for: .normal)
        self.chatTableView.allowsSelection = true
        self.chatTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        SharedManager.shared.colourBG = UIColor.init(red: 0.0705882, green: 0.498039, blue: 0.647059, alpha: 1.0)
        if self.conversatonObj.theme_color.count > 0 {
            SharedManager.shared.colourBG = UIColor.init().hexStringToUIColor(hex: self.conversatonObj.theme_color.replacingOccurrences(of: "#", with: ""))
        }
        
        
        self.commentTextView.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 15.0)
        self.commentHeightContraint.constant = 45
        
        self.viewBlockUser.isHidden = true
        
        //  let dict:NSDictionary = [ "u" : self.conversatonObj.member_id]
        //  SocketSharedManager.sharedSocket.checkUserIsBlocked(dict:dict) { (mainData) in
        //      if self.ReturnValueCheck(value: (mainData?.first as! [String : Any])["b"] as Any) == "1" {
        //          self.viewBlockUser.isHidden = false
        //          self.blocknLeaveLbl.text = "You Blocked this user. So, you can't message or call in this chat.".localized()
        //      }
        //  }
        
        self.viewGifOptions.isHidden = true
        title = self.conversatonObj.nickname.count > 0 ? self.conversatonObj.nickname : self.conversatonObj.name
        self.navigationController?.addTitle(self, title: self.conversatonObj.nickname.count > 0 ? self.conversatonObj.nickname : self.conversatonObj.name , selector: #selector(self.showProfile))
        self.userImgView.loadImageWithPH(urlMain:SharedManager.shared.userEditObj.profileImage)
        self.view.labelRotateCell(viewMain: self.userImgView)
        
        self.isBlock = false
        
        if self.conversatonObj.is_blocked == "1" {
            self.isBlock = true
            self.viewBlockUser.isHidden = false
            self.blocknLeaveLbl.text = "You Blocked this user. So, you can't message or call in this chat.".localized()
        }
        
        if self.conversatonObj.is_leave == "1" {
            self.viewBlockUser.isHidden = false
            self.isBlock = true
            self.blocknLeaveLbl.text = "You left this group. You can\'t message, call or video chat in this group.".localized()
        }
        
        if self.conversatonObj.conversation_id.count > 0 && !self.isBlock {
            addCallButtons()
        } else {
            self.navigationItem.rightBarButtonItems = []
        }
    }
    
    func addCallButtonswithCross(){
        let audiobtn = UIBarButtonItem(image: UIImage(named: "chat_Call"), style: .done, target: self, action: #selector(self.makeCallAudio)) //old  ChatCallLine
        let videobtn = UIBarButtonItem(image: UIImage(named: "chat_video_call"), style: .done, target: self, action: #selector(self.makeCallVideo)) //old  VideoCallLine
        let crossbtn = UIBarButtonItem(image: UIImage(named: "ic_cross"), style: .done, target: self, action: #selector(self.crossEdit))
        
        self.navigationItem.rightBarButtonItems = [crossbtn, videobtn, audiobtn]
        NotificationCenter.default.addObserver(self, selector: #selector(callStatusChanged), name: NSNotification.Name(rawValue: "CallStatus"), object: nil)
    }
    
    func addCallButtons(){
        
        if self.isBlock { return }
        
        let audiobtn = UIBarButtonItem(image: UIImage(named: "chat_Call"), style: .done, target: self, action: #selector(self.makeCallAudio))//old  ChatCallLine
        let videobtn = UIBarButtonItem(image: UIImage(named: "chat_video_call"), style: .done, target: self, action: #selector(self.makeCallVideo))//old  VideoCallLine
        self.navigationItem.rightBarButtonItems = [videobtn,audiobtn]
        NotificationCenter.default.addObserver(self, selector: #selector(callStatusChanged), name: NSNotification.Name(rawValue: "CallStatus"), object: nil)
        
    }
    //ACK for emiter
    func didReceiveCallstatusAck(data: [String : Any]) {
        
        guard let started = data["started"] as? Bool else {
            return
        }
        if(started){
            addCustomTopBar(isShown: true)
            calldictionary = data
        }else{
            addCustomTopBar(isShown: false)
        }
    }
    
    @objc func callStatusChanged(notification: NSNotification) {
        let data = notification.userInfo as! [String:Any]
        
        let started = data["started"] as! Bool
        if(started){
            if(self.conversatonObj.conversation_id == data["chatId"] as? String){
                addCustomTopBar(isShown: true)
                calldictionary = data
            }
        }else{
            addCustomTopBar(isShown: false)
        }
    }
    
    func addCustomTopBar(isShown: Bool) {
        let v = topBar
        v.backgroundColor = UIColor.themeBlueColor
        if isShown {
            view.addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
            v.heightAnchor.constraint(equalToConstant: 30).isActive = true
            v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
            v.addSubview(topBarbutton)
            topBarbutton.translatesAutoresizingMaskIntoConstraints = false
            topBarbutton.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
            topBarbutton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            topBarbutton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
            topBarbutton.setTitle("Call in progress, Press to join".localized(), for: .normal)
            topBarbutton.backgroundColor = UIColor.themeBlueColor
            topBarbutton.addTarget(self, action: #selector(onClickTopBarButton), for: .touchUpInside)
        } else {
            v.removeFromSuperview()
        }
    }
    
    @objc func onClickTopBarButton() {
        callJoinBtn()
    }
    func callJoinBtn(){
        
        if(RoomClient.sharedInstance.isCallInitiated == true){return}
        
        let isVideo = calldictionary["isVideo"] as! String
        if(isVideo == "1"){
            proceddWithCall(isVideoEnabled: true)
        }else{
            proceddWithCall(isVideoEnabled: false)
        }
    }
    func checkCallStatus() {
        
        if self.conversatonObj.conversation_id.count > 0 {
            SocketSharedManager.sharedSocket.check_call_status(dictionary: ["chatId": self.conversatonObj.conversation_id])
            
        }
    }
    
    @objc func crossEdit(){
        self.selectedRows.removeAll()
        addCallButtons()
        self.isSelectionEnable = false
        self.viewSelection.isHidden = true
        self.chatTableView.reloadData()
    }
    
    @objc func makeCallVideo(){
        PermissionManager.requestVideoCallPermissions { (cameraStatus, microphoneStatus) in
            switch (cameraStatus, microphoneStatus) {
                
            case (.authorized, .authorized):
                LogClass.debugLog("Video call permissions granted")
                self.proceddWithCall(isVideoEnabled: true)
            case (.denied, _), (_, .denied):
                LogClass.debugLog("Video call permissions denied")
                // Handle denial or show an alert
            case (.restricted, _), (_, .restricted):
                LogClass.debugLog("Video call permissions restricted")
                // Handle restricted access or show an alert
            case (.notDetermined, _), (_, .notDetermined):
                LogClass.debugLog("Video call permissions not determined")
                // Handle not determined state, if needed
            case (.authorized, .none):
                LogClass.debugLog("Video call permissions not determined")
                // Handle not determined state, if needed
            }
        }
        
    }
    
    @objc func makeCallAudio(){
        PermissionManager.requestAudioCallPermissions { (microphoneStatus, _) in
            switch microphoneStatus {
            case .authorized:
                LogClass.debugLog("Microphone permission granted for audio call")
                self.proceddWithCall(isVideoEnabled: false)
            case .denied:
                LogClass.debugLog("Microphone permission denied for audio call")
                // Handle denial or show an alert
            case .restricted:
                LogClass.debugLog("Microphone permission restricted for audio call")
                // Handle restricted access or show an alert
            case .notDetermined:
                LogClass.debugLog("Microphone permission not determined for audio call")
                // Handle not determined state, if needed
            }
        }
    }
    
    func proceddWithCall (isVideoEnabled:Bool){
        
        if RoomClient.sharedInstance.isCallConnected == true {
            return
        }
        
        if !Network.isAvailable{
            SharedManager.shared.showAlert(message: "Network Error".localized(), view: self)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if(SocketSharedManager.sharedSocket.manager?.status == .connected){
                debugPrint("socket: alreadyconnected")
                self.makeCall(isVideoEnabled: isVideoEnabled)
            }else{
                var makecall = false
                SocketSharedManager.sharedSocket.socket.on(clientEvent: .connect) { (data, ack) in
                    if(makecall){
                        debugPrint("socket: now connected")
                        self.makeCall(isVideoEnabled: isVideoEnabled)
                        makecall = false
                    }
                }
                debugPrint("socket: not alreadyconnected")
                SocketSharedManager.sharedSocket.socket.connect()
                makecall = true
            }
        }
    }
    func makeCall(isVideoEnabled:Bool){
        
        
        let chatId:String = self.conversatonObj.conversation_id
        let isGroup = self.conversatonObj.conversation_type == "group" ? true : false
        
        if(SocketSharedManager.sharedSocket.manager?.status == .connected){
            var dic = [String:Any]()
            dic["type"] = "startNewCall"
            dic["isVideo"] = isVideoEnabled
            dic["chatId"] = chatId
            dic["receiverId"] = self.conversatonObj.member_id
            LogClass.debugLog("-------------newcall sent----------------")
            LogClass.debugLog(dic)
            SocketSharedManager.sharedSocket.socket?.emitWithAck(dic["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dic)]).timingOut(after: 0) { (data) in
                let dic = data.first as? [String:Any]
                LogClass.debugLog(data)
                let chatId = dic?["chatId"] as! String
                let roomId = dic?["roomId"] as! String
                let newsocket = dic?["newSocket"] as? Int
                if(newsocket == 0){
                    let message = dic?["message"] as! String
                    
                    let alert = SharedManager.shared.showBasicAlertGlobal(message: message)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if let tabController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController {
                            tabController.presentVC(alert) {
                            }
                        }
                    }
                    
                }else{
                    
                    let signalingMessage = Available.init(type: "newcall", connectedUserId: SharedManager.shared.ReturnValueAsString(value: self.conversatonObj.member_id), isAvailable: false, reason: "", name: self.conversatonObj.name ,callId: "",chatId: chatId, photoUrl: self.conversatonObj.profile_image, isVideo: isVideoEnabled, isBusy: false,sessionId: "",socketId: "",callType:isGroup ? "group":"single" ,roomId: roomId)
                    LogClass.debugLog(signalingMessage)
                    ATCallManager.shared.outgoingCall(from: self.conversatonObj.name, connectAfter: 0, isVideo: isVideoEnabled, callobject: signalingMessage)
                    
                    if let vc = AppStoryboard.Call.instance.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController{
                        RoomClient.sharedInstance.isVideoCall = isVideoEnabled
                        RoomClient.sharedInstance.room_id = roomId
                        RoomClient.sharedInstance.chatId = Int(chatId) ?? 0
                        RoomClient.sharedInstance.isIncomingCall = false
                        RoomClient.sharedInstance.connectedUserName = self.conversatonObj.name
                        RoomClient.sharedInstance.connectedUserPhoto = self.conversatonObj.profile_image
                        RoomClient.sharedInstance.screen = vc
                        vc.modalPresentationStyle = .fullScreen
                        if let tabController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController {
                            tabController.presentVC(vc) {
                                //vc.setupUI()
                                if isGroup {
                                    RoomClient.sharedInstance.isGroupCall = true
                                }else{
                                    RoomClient.sharedInstance.isGroupCall = false
                                }
                                RoomClient.sharedInstance.startNoAnswerTimer()
                                RoomClient.sharedInstance.playCallTone()
                            }
                        }
                    }
                }
            }
        }
        
    }
    @objc func languageChangeNotification(){
        self.manageUserChat()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func manageCallBackHandler(){
        ChatCallBackManager.shared.reloadTableAtSpecificIndex = { [weak self] (currentIndex) in
            self?.chatTableView.beginUpdates()
            self?.chatTableView.endUpdates()
        }
    }
    
    func delegateRefresh(){
        
        self.chatModelArray.removeAll()
        startingPoint = ""
        self.isLoadMore = true
        self.chatTableView.reloadData()
        self.manageUserChat()
    }
    
    
    @objc func showProfile(){
        if self.conversatonObj.is_leave == "1" {
            return
        }
        
        self.crossEdit()
        
        if self.conversatonObj.conversation_type == "group" {
            
            let viewMain = self.GetView(nameVC: "GroupProfileNewVC", nameSB: "Notification") as! GroupProfileNewVC
            viewMain.chatObj = self.conversatonObj
            self.navigationController?.pushViewController(viewMain, animated: true)
        }else {
            
            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatProfileVC") as! ChatProfileVC
            vc.chatConversationObj = self.conversatonObj
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func manageUserChat(){
        self.isAPICall = false
        if self.conversatonObj.conversation_id.count > 0 {
            var manageAction =   String(format:"messages/%@", self.conversatonObj.conversation_id )
            if self.startingPoint.count > 0 {
                manageAction = manageAction + "?starting_point_id=" + startingPoint
            }else {
                // self.chatModelArray.removeAll()
            }
            let parameters:NSDictionary = ["action": manageAction, "token":userToken, "serviceType":"Node"]
            self.callingService(parameters: parameters as! [String : Any])
        }else if self.conversatonObj.conversation_id.count > 0 {
            var manageAction =   String(format:"messages/%@", self.conversatonObj.conversation_id )
            if self.startingPoint.count > 0 {
                manageAction = manageAction + "?starting_point_id=" + startingPoint
            }
            let parameters:NSDictionary = ["action": manageAction, "token":userToken, "serviceType":"Node"]
            self.callingService(parameters: parameters as! [String : Any])
        }
    }
    
    func createNewchat(){
        let memberID:[String] = [self.conversatonObj.member_id ]
        let parameters:NSDictionary = ["action": "conversation/create", "token":userToken, "serviceType":"Node", "conversation_type":"single","member_ids": memberID]
        self.callingService(parameters: parameters as! [String : Any])
    }
    
    func manageTextView(){
        self.commentTextView.textColor = UIColor.gray
        self.commentTextView.text = Const.chatTextViewPlaceholder.localized()
    }
    
    func manageKeyboard(){
        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            var bottom = 0.0
            if info.isShowing {
                bottom = Double(-info.visibleHeight)
                if #available(iOS 11, *) {
                    let guide = weakSelf.view.safeAreaInsets
                    bottom = bottom + Double(guide.bottom)
                }
            }
            UIView.animate(info, animations: { [weak self] in
                
                self?.commentEditViewBottomConstraint.constant = CGFloat(bottom)
                if self?.view != nil {
                    self?.view.layoutIfNeeded()
                }
            })
        }
    }
    
    func isCreateConversationNeeded()-> Bool{
        
        if self.conversatonObj.conversation_id.count > 0 {
            return false
        }
        return true
    }
    
    func createConversation(){
        
        let memberID:[String] = [self.conversatonObj.member_id ]
        let parameters:NSDictionary = ["action": "conversation/create", "token":userToken, "serviceType":"Node", "conversation_type":"single","member_ids": memberID]
        self.callingService(parameters: parameters as! [String : Any])
    }
    
    @IBAction func sendCommentBtnClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        if self.viewVideo.isHidden {
            if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                if self.isReply {
                    self.replyChatText()
                }else {
                    self.editandemmitChatText()
                }
            }else {
                self.sendMessage()
            }
        }else if !self.viewVideo.isHidden {
            
            self.viewVideo.isHidden = true
            if self.videoObj["Type"] as! String == FeedType.video.rawValue {
                self.uploadFile(filePath: (self.videoObj["URL"] as! String), fileType: "video" ,imageMAin: (self.videoObj["Image"] as! UIImage))
                self.viewVideo.isHidden = true
            }else if self.videoObj["Type"] as! String == FeedType.audio.rawValue {
                
                let audioUrl = self.videoObj["URL"] as! String
                LogClass.debugLog("audioUrl ===>")
                LogClass.debugLog(audioUrl)
                
                self.uploadFile(filePath: audioUrl, fileType: "audio")
                self.commentTextView.resignFirstResponder()
            } else if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                if self.viewPreview.isHidden {
                    if self.isReply {
                        self.replyChatText()
                    }else {
                        self.editandemmitChatText()
                    }
                }
                else {
                    let url = editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MessageFile).url : ""
                    let thumbnailUrl = editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MessageFile).thumbnail_url : ""
                    
                    if editObj.post_type == FeedType.image.rawValue {
                        self.copyimageSend(fileType: editObj.post_type, URLImage: url, URLVideo:"")
                    }else if editObj.post_type == FeedType.video.rawValue {
                        self.copyimageSend(fileType: editObj.post_type, URLImage: thumbnailUrl, URLVideo: url )
                    }else if editObj.post_type == FeedType.file.rawValue {
                        self.copyimageSend(fileType: editObj.post_type, URLImage: url, URLVideo:"")
                    }else if editObj.post_type == FeedType.post.rawValue {
                        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
                        let idString = SharedManager.shared.getCurrentDateString()
                        self.uploadAudioOnSockt(text: myComment, audio_msg_url:editObj.audio_file, identiferString: idString)
                        DispatchQueue.main.async {
                            let moc = CoreDbManager.shared.persistentContainer.viewContext
                            let chatObj = Message(context: moc)
                            chatObj.post_type = FeedType.post.rawValue
                            chatObj.author_id = String(SharedManager.shared.getUserID())
                            chatObj.identifierString = idString
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            dateFormatter.timeZone = TimeZone(identifier: "UTC")
                            chatObj.messageTime = dateFormatter.string(from: Date())
                            chatObj.audio_file = editObj.audio_file
                            chatObj.audio_msg_url = editObj.audio_file
                            chatObj.audio_translation = editObj.audio_translation
                            self.chatModelArray.append(chatObj)
                            self.chatTableView.reloadData()
                            CoreDbManager.shared.saveContext()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count - 1 , section: 0), at: .bottom, animated: true)
                                self.editchatModelObj = nil
                                self.viewPreview.isHidden = true
                                self.viewPreviewAudio.isHidden = true
                            }
                        }
                    }
                }
            }else {
                self.sendMessage()
            }
            
            self.viewReply.isHidden = true
        }
        
    }
    
    func editandemmitChatText(){
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            var newObject = [String : Any]()
            var newObjectInner = [String : Any]()
            newObjectInner["id"] = editObj.id
            newObject["m"] = newObjectInner
            let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
            let dict:NSDictionary = ["body":myComment,"mode": "edit","author_id":SharedManager.shared.getUserID(), "conversation_id":self.conversatonObj.conversation_id, "message_to_be_edited" : newObject]
            
            for IndexObj in self.chatModelArray {
                if IndexObj.id == editObj.id {
                    IndexObj.body = myComment
                    IndexObj.original_body = myComment
                    break
                }
            }
            self.viewReply.isHidden = true
            SocketSharedManager.sharedSocket.emitChatText(dict: dict)
            self.manageTextView()
            self.editchatModelObj = nil
            self.chatTableView.reloadData()
            self.textViewDidChange(self.commentTextView)
        }
    }
    
    func replyChatText(){
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            
            let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
            let dict:NSDictionary = ["body":myComment,"author_id":SharedManager.shared.getUserID(), "audio_msg_url":"", "uploads":[], "conversation_id":self.conversatonObj.conversation_id, "identifierString":SharedManager.shared.getCurrentDateString(), "message_files":[], "audio_file":"" , "replied_to_message_id" : editObj.id]
            
            self.addNewMessage(dict: dict)
            self.viewReply.isHidden = true
            SocketSharedManager.sharedSocket.emitChatText(dict: dict)
            self.manageTextView()
            self.editchatModelObj = nil
            self.textViewDidChange(self.commentTextView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count - 1 , section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func replyChatAttachText(mainURL : String , newTime : String , fileType:String, thumbnailURL : String ){
        
        var urlSendArray = [[String : Any]]()
        var urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = thumbnailURL
        
        if fileType == "video" {
            urlSend["type"] = "video/mov"
        }else if fileType == "attachment" {
            urlSend["type"] = "attachment"
        }else {
            urlSend["type"] = "image/png"
        }
        
        urlSendArray.append(urlSend)
        
        var newTimeP = newTime
        if newTime.count == 0 {
            newTimeP = SharedManager.shared.getCurrentDateString()
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        var indexRow : Message!
        
        for indexObj in self.chatModelArray {
            if indexObj.identifierString == newTime {
                indexRow = indexObj
                break
            }
        }
        
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":self.conversatonObj.conversation_id, "identifierString":newTimeP, "message_files":[], "audio_file":"", "replied_to_message_id" : indexRow.replied_to_message_id]
        
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
        self.manageTextView()
        self.textViewDidChange(self.commentTextView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count - 1 , section: 0), at: .bottom, animated: true)
        }
    }
    
    func copyimageSend(fileType : String , URLImage : String , URLVideo : String){
        let newTime = String(Int(Date().timeIntervalSince1970))
        
        self.viewPreview.isHidden = true
        self.editchatModelObj = nil
        DispatchQueue.main.async {
            
            let moc = CoreDbManager.shared.persistentContainer.viewContext
            let chatObj = Message(context: moc)
            let msgCOFile = MessageFile(context: moc)
            
            if fileType == "video" {
                chatObj.post_type = FeedType.video.rawValue
            }else if fileType == "attachment" {
                chatObj.post_type = FeedType.file.rawValue
            }else {
                chatObj.post_type = FeedType.image.rawValue
            }
            
            chatObj.author_id = String(SharedManager.shared.getUserID())
            chatObj.body = self.commentTextView.text
            
            chatObj.identifierString = newTime
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            chatObj.messageTime = dateFormatter.string(from: Date())
            
            let messageFile = UserChatMessageFiles.init()
            
            
            if fileType == "attachment" {
                messageFile.post_type = FeedType.file.rawValue
                messageFile.url = URLImage
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"attachment" , thumbnailURL: "")
                }
                
            }else if fileType == "video" {
                messageFile.post_type = FeedType.video.rawValue
                messageFile.thumbnail_url = URLImage
                messageFile.url = URLVideo
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLVideo ,newTime: newTime , fileType:"video" , thumbnailURL: URLImage)
                }
            }else {
                messageFile.post_type = FeedType.image.rawValue
                messageFile.url = URLImage
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"image" , thumbnailURL: "")
                }
            }
            
            chatObj.addToToMessageFile(DBMessageManager.mapMessageFile(messageFileObj: msgCOFile, messageFile: messageFile))
            CoreDbManager.shared.saveContext()
            self.chatModelArray.append(chatObj)
            self.chatTableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count - 1 , section: 0), at: .bottom, animated: true)
            }
        }
    }
    func sendMessage(){
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        if(myComment != "") {
            if isCreateConversationNeeded() {
                self.createConversation()
            }else {
                
                var dict : [String : Any] = ["body":myComment,"author_id":SharedManager.shared.getUserID(), "audio_msg_url":"", "uploads":[], "conversation_id":self.conversatonObj.conversation_id, "identifierString":SharedManager.shared.getCurrentDateString(), "message_files":[], "audio_file":"","post_type" : FeedType.post.rawValue]
                
                if self.isReply {
                    if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                        dict["replied_to_message_id"] = editObj.id
                    }
                }
                self.addNewMessage(dict: dict as NSDictionary)
                self.viewReply.isHidden = true
                SocketSharedManager.sharedSocket.emitChatText(dict: dict as NSDictionary)
                self.manageTextView()
                self.textViewDidChange(self.commentTextView)
                self.editchatModelObj = nil
            }
        }
    }
    
    func uploadAudioOnSockt(text : String ,audio_msg_url : String , identiferString : String , replied_to_message_id : String = ""){
        let dict:NSDictionary = ["body":text,"author_id":SharedManager.shared.getUserID(), "audio_msg_url":audio_msg_url, "uploads":[], "conversation_id":self.conversatonObj.conversation_id, "identifierString":identiferString, "message_files":[], "audio_file":"", "replied_to_message_id" : replied_to_message_id]
        self.viewReply.isHidden = true
        LogClass.debugLog("uploadAudioOnSockt ===>")
        LogClass.debugLog(dict)
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
    }
    
    func callingService(parameters:[String:Any]) {
        
        if(conversatonObj.toMessage?.allObjects.count ?? 0 == 0) {
            self.noConversation.isHidden = false
            self.noConversation.text = "Loading .....".localized()
        }
        
        RequestManager.fetchDataPost(Completion: { response in
            
            self.noConversation.text = "No conversation".localized()
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                
                self.isAPICall = true
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    if (res as! String).contains("No messages available") {
                        LogClass.debugLog("No messages available ===> ")
                        self.isLoadMore = false
                    } else if (res as! String).lowercased().contains("messages") {
                        self.isLoadMore = false
                    } else {
                        SharedManager.shared.showAlert(message: res as! String, view: self)
                    }
                    
                } else {
                    if parameters["action"] as! String == "conversation/create" {
                        if res is NSDictionary {
                            let dict = res as! NSDictionary
                            self.conversatonObj.conversation_id = self.ReturnValueCheck(value: dict["conversation_id"] as Any)
                            self.sendCommentBtnClicked(UIButton())
                            self.addCallButtons()
                        }
                    }else {
                        var count = 0
                        var languageChange = "en"
                        if let languageID = SharedManager.shared.userBasicInfo["language_id"] as? Int {
                            languageChange = FeedCallBManager.shared.getLanguageCode(languageID: String(languageID))
                        }
                        if let mainDict = res as? [[String : Any]]
                        {
                            count = mainDict.count
                            if self.startingPoint.count == 0 {
                                var tempUserObj = [UserChatModel]()
                                for indexObj in mainDict {
                                    let userObj = UserChatModel.init(fromDictionary: indexObj)
                                    tempUserObj.append(userObj)
                                }
                                DBMessageManager.saveMessageData(messageArr: tempUserObj, chatListObj: self.conversatonObj)
                                self.updateChatObject()
                            }else {
                                if mainDict.count == 0 {
                                    self.isLoadMore = false
                                }else {
                                    var tempUserObj = [UserChatModel]()
                                    for indexObj in mainDict {
                                        tempUserObj.append(UserChatModel.init(fromDictionary: indexObj))
                                    }
                                    DBMessageManager.saveMessageData(messageArr: tempUserObj, chatListObj: self.conversatonObj)
                                    self.updateChatObject()
                                }
                            }
                        }
                        
                        self.scroolToIndex = count - 1
                        self.chatTableView.reloadData()
                        if self.chatModelArray.count > 4 {
                            if self.startingPoint.count == 0 {
                                self.btnBottomView.isHidden = true
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count-1, section: 0), at: .bottom, animated: false)
                                
                            }else {
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.scroolToIndex, section: 0), at: .top, animated: false)
                            }
                        }
                        if self.chatModelArray.count > 0 {
                            self.startingPoint = self.chatModelArray.first!.id
                            
                            let endpoint = self.chatModelArray[self.chatModelArray.count - 1].id
                            if endpoint != "" {
                                if Int(endpoint) != nil {
                                    SocketSharedManager.sharedSocket.markmessageSeen(valueMain: Int(endpoint)! )
                                }
                            }
                        }
                        self.chatTableView.invalidateIntrinsicContentSize()
                    }
                }
            }
        }, param:parameters)
    }
    
    func updateChatObject() {
        noConversation.isHidden = true
        chatModelArray.removeAll()
        conversatonObj = ChatDBManager().getChatFromDb(conversationID: self.conversatonObj.conversation_id) ?? Chat()
        if let messages = conversatonObj.toMessage?.allObjects as? [Message], !messages.isEmpty {
            // Sort messages by ID
            let sortedMessages = messages.sorted { Int($0.id) ?? 0 < Int($1.id) ?? 0 }

            var currentDay = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM. dd, yyyy"

            for indexObj in sortedMessages {
                let messageDateTime = indexObj.messageTime.customDateFormat(time: indexObj.messageTime, format: Const.dateFormat1)
                if let messageDate = dateFormatter.date(from: messageDateTime) {
                    let day = dateFormatter.string(from: messageDate)
                    indexObj.isShowMessageTime = (day != currentDay) ? "1" : "0"
                    currentDay = day
                }
                
                let repliedToMessageId = indexObj.replied_to_message_id
                if !repliedToMessageId.isEmpty, indexObj.reply_to == nil {
                    if let replyToMessage = sortedMessages.first(where: { $0.id == repliedToMessageId }) {
                        indexObj.reply_to = replyToMessage
                    }
                }
            }

            chatModelArray = sortedMessages
            chatTableView.reloadData()
        }
        else {
            noConversation.isHidden = false
        }
    }
    
    func scrollToBottom(isAnimated: Bool = true) {
        self.newMsgCounter = 0
        self.counterLbl.text = ""
        self.btnBottomView.isHidden = true
        
        if !chatModelArray.isEmpty {
            let lastIndexPath = IndexPath(row: self.chatModelArray.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: isAnimated)
            
            let endpoint = self.chatModelArray.last?.id ?? ""
            if let endpointID = Int(endpoint) {
                SocketSharedManager.sharedSocket.markmessageSeen(valueMain: endpointID)
            }
        }
    }

    
    @IBAction func bottomBtnClicked(_ sender:UIButton) {
        self.scrollToBottom()
        
    }
    
    func viewTranscript(fileID : String){
        
    }
    
    func dowloadConvertedURL(fileID : String){
        
        let parameters = ["action": "message_files/translate_video","token": SharedManager.shared.userToken() , "file_id" : fileID]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let newRes = res as? [String : Any] {
                    
                    for indexObj in self.chatModelArray {
                        if indexObj.toMessageFile?.count ?? 0 > 0 {
                            if (indexObj.toMessageFile?.first as! MessageFile).id == fileID {
                                (indexObj.toMessageFile?.first as! MessageFile).convertedUrl = newRes["url"] as! String
                                
                                self.VideoPlayWithURL(URLVideo: newRes["url"] as! String)
                            }
                        }
                    }
                }else {
                    for indexObj in self.chatModelArray {
                        if indexObj.toMessageFile?.count ?? 0 > 0 {
                            if (indexObj.toMessageFile?.first as! MessageFile).id == fileID {
                                self.VideoPlayWithURL(URLVideo: (indexObj.toMessageFile?.first as! MessageFile).url)
                            }
                        }
                    }
                }
            }
        }, param: parameters)
    }
    
    
    func addNewMessage(dict:NSDictionary)   {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        var objects = Message(context: moc)
        
        LogClass.debugLog("addNewMessage ===>")
        LogClass.debugLog(dict)
        let objChat = UserChatModel.init(fromDictionary: dict as! [String : Any])
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        objChat.messageTime = dateFormatter.string(from: Date())
        objects = DBMessageManager.mapMessageObj(msgObj: objects, userObj: objChat)
        objects.id = String(Int(Date().timeIntervalSince1970))
        objects.toChat = self.conversatonObj
        if dict["replied_to_message_id"] != nil {
            if let IDString = (dict["replied_to_message_id"] as? String)  {
                for indexObj in self.chatModelArray {
                    if indexObj.id == IDString {
                        objects.reply_to = indexObj
                        objects.replied_to_message_id = indexObj.id
                        break
                    }
                }
            }
        }
        
        if objChat.post_type == PostType.image.rawValue {
            let ObjFile = UserChatMessageFiles.init()
            if let uploadObj = dict["uploads"] as? [[String : AnyObject]] {
                if uploadObj.count > 0 {
                    ObjFile.url =  (uploadObj[0] as? [String : Any])!["url"] as! String
                    ObjFile.post_type = objChat.post_type
                    ObjFile.id = objChat.identifierString
                    objChat.message_files.append(ObjFile)
                }
            }else if let uploadObj = dict["uploads"] as? [Any] {
                
            }
        }
        CoreDbManager.shared.saveContext()
        self.updateChatObject()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.btnBottomView.isHidden = true
            let lastIndexPath = IndexPath(row: self.chatModelArray.count-1, section: 0)
            if self.chatModelArray.count > 4 {
                self.chatTableView.scrollToRow(at: lastIndexPath,
                                               at: UITableView.ScrollPosition.bottom,
                                               animated: true)
            }
        }
    }
    
    @IBAction func attachFile(sender:UIButton)    {
        self.viewCameraOptions.isHidden = true
        self.viewGifOptions.isHidden = false
    }
    
    @IBAction func cameraAction(sender:UIButton)    {
        self.viewGifOptions.isHidden = true
        self.viewCameraOptions.isHidden = false
    }
    
    func openImageCamera(){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes =  ["public.image", "public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            SharedManager.shared.showAlert(message: "Your camera is not accessible. Please check your device settings and then try again.".localized(), view: self)
        }
    }
    
    func openVideoCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openPhotoPicker(maxValue : Int = 1){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxValue
        configure.numberOfColumn = 3
        configure.allowedLivePhotos = false
        viewController.configure = configure
        
        self.present(viewController, animated: true)
    }
    
    func manageResponseOfChat(result:[PostCollectionViewObject]){
        let myChatArray = ChatManager.shared.manageChatData(postObj: result)
        for dict in myChatArray {
            self.addNewMessage(dict: dict as! NSDictionary)
        }
    }
    
    @IBAction func micButtonClicked(sender:UIButton)    {
        let audioRecorder = AppStoryboard.Shared.instance.instantiateViewController(withIdentifier: SharedAudioRecorderVC.className) as! SharedAudioRecorderVC
        
        audioRecorder.getAudioUrl = { audioUrl in
            
            
            var newData = [String : Any]()
            
            let urlMAin = audioUrl.absoluteString
            newData["Image"] = nil
            newData["ImageURL"] = ""
            newData["Type"] = FeedType.audio.rawValue
            newData["URL"] = urlMAin
            
            
            self.videoObj["Image"] = nil
            self.videoObj["ImageURL"] = ""
            self.videoObj["Type"] = FeedType.audio.rawValue
            self.videoObj["URL"] = urlMAin
            self.videoObj["LanguageID"] = SharedManager.shared.getCurrentLanguageID()
            
            
            if self.viewReply.isHidden {
                self.cstViewChatPreview.constant = 0.0
            }else {
                self.cstViewChatPreview.constant = 50.0
            }
            
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
            
            self.addChild(asChildViewController:self.chatPreviewController , selectedView:self.viewVideo )
            self.chatPreviewController.reloadView(mainData: newData)
        }
        
        self.sheetController = SheetViewController(controller: audioRecorder, sizes: [.fixed(280)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
}

extension ChatViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewGifOptions.isHidden = true
        self.viewCameraOptions.isHidden = true
        if scrollView.contentOffset.y <= 20  && isAPICall {
            currentOffset = self.chatTableView.contentOffset;
            if self.chatModelArray.count > 0 {
                if self.isLoadMore {
                    self.manageUserChat()
                }
            }
        }
    }
}

extension ChatViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModelArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let lastVisibleIndexPath = chatTableView.indexPathsForVisibleRows?.last else { return }

        guard let messageCount = self.conversatonObj.toMessage?.count, messageCount > 4 else {
            btnBottomView.isHidden = true
            return
        }

        let lastRow = messageCount
        let threshold = lastRow - 4

        let isNearBottom = lastVisibleIndexPath.row >= threshold

        btnBottomView.isHidden = isNearBottom
        if isNearBottom {
            counterLbl.text = ""
            newMsgCounter = 0
        } else {
            self.view.bringSubviewToFront(btnMoveBottom)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        var authorID = -1
        if dict.author_id.count > 0 {
            authorID = Int(dict.author_id)!
        }
        
        if dict.sender_id.count > 0 {
            authorID = Int(dict.sender_id)!
        }
        
        if(authorID == SharedManager.shared.getUserID()){
            return self.SenderChatCell(tableView: tableView, cellForRowAt: indexPath)
        }else {
            return self.ReceiverChatCell(tableView: tableView, cellForRowAt: indexPath)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isSelectionEnable {
            if (self.selectedRows.contains(self.chatModelArray[indexPath.row].id)) {
                self.selectedRows.remove(at: (selectedRows.firstIndex(of: self.chatModelArray[indexPath.row].id))!)
            }else {
                self.selectedRows.append(self.chatModelArray[indexPath.row].id)
            }
            
            self.delegatRowSelectedValueChange(indexPath: indexPath)
            self.chatTableView.reloadData()
        }
    }
    
    func VideoPlayWithURL(URLVideo : String){
        let videoURL = URL.init(string: URLVideo)
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func attachFileAction(sender : UIButton){
        self.didPressDocumentShare()
        
    }
}

extension ChatViewController : OptionsPopoverDelegate {
    
    func delegatRowSelectedValueChange(indexPath : IndexPath){
        if self.viewSelection.isHidden {
            return
        }
        
        if selectedRows.count > 1 {
            self.popOverController.reloadDatawithMultipleMessage()
        }else {
            if selectedRows.count == 1 && self.chatModelArray.count > 0{
                
                let objIndex = self.chatModelArray.firstIndex(where: { $0.id == self.selectedRows[0]})
                let objMain = self.chatModelArray[objIndex ?? 0]
                if objMain.post_type == FeedType.image.rawValue {
                    if Int(objMain.author_id) == SharedManager.shared.getUserID() {
                        self.popOverController.reloadDataforImageMessage(isMine: true, showUnpin: objMain.is_pinned == "1")
                    }else {
                        self.popOverController.reloadDataforImageMessage(showUnpin: objMain.is_pinned == "1")
                    }
                }else if objMain.post_type != FeedType.post.rawValue {
                    if Int(objMain.author_id) == SharedManager.shared.getUserID() {
                        self.popOverController.reloadDataforMediaMessage(isMine: true, showUnpin: objMain.is_pinned == "1")
                    }else {
                        self.popOverController.reloadDataforMediaMessage(showUnpin: objMain.is_pinned == "1")
                    }
                    
                }else if Int(objMain.author_id) == SharedManager.shared.getUserID() {
                    self.popOverController.reloadDatawithOwnMessage(showUnpin: objMain.is_pinned == "1")
                }else {
                    self.popOverController.reloadDatawithOwnMessage(showUnpin: objMain.is_pinned == "1")
                }
            }else {
                self.popOverController.reloadDatawithDefaultValue()
            }
        }
        
        self.chatTableView.reloadData()
    }
    
    
    func delegatRowValueChange(indexPath : IndexPath , selectecion : Bool){
        if self.viewSelection.isHidden {
            return
        }
        
        if selectedRows.count > 1 {
            self.popOverController.reloadDatawithMultipleMessage()
            
        }else {
            if selectedRows.count == 1 && self.chatModelArray.count > 0{
                
                let objIndex = self.chatModelArray.firstIndex(where: { $0.id == self.selectedRows[0]})
                let objMain = self.chatModelArray[objIndex ?? 0 ]
                if objMain.post_type != FeedType.post.rawValue {
                    if Int(objMain.author_id) == SharedManager.shared.getUserID() {
                        self.popOverController.reloadDataforMediaMessage(isMine: true)
                    }else {
                        self.popOverController.reloadDataforMediaMessage()
                    }
                }else if Int(objMain.author_id) == SharedManager.shared.getUserID() {
                    self.popOverController.reloadDatawithOwnMessage()
                }else {
                    self.popOverController.reloadDatawithOtherUserMessage()
                }
            }else {
                self.popOverController.reloadDatawithDefaultValue()
            }
        }
        
        
    }
    
    func selectedActionAtIndex(actionIndex: Int) {
        
    }
    
    @IBAction func hideReply(sender : UIButton){
        self.viewReply.isHidden = true
        self.isReply = false
        
        self.editchatModelObj = nil
        self.viewVideo.isHidden = true
        self.videoObj = [String : Any]()
    }
    
    func deleteMultipleMessage(indexArray : [IndexPath]){
        var idDelete = [Any]()
        var isShowError = -1
        for indexObj in indexArray {
            if (Int(self.chatModelArray[indexObj.row].author_id)! == SharedManager.shared.getUserID()){
                if self.chatModelArray.count > indexObj.row {
                    if self.chatModelArray[indexObj.row].id != "" {
                        idDelete.append(self.chatModelArray[indexObj.row].id)
                    }
                }
            }else {
                if self.chatModelArray.count > indexObj.row {
                    if self.chatModelArray[indexObj.row].id != "" {
                        idDelete.append(self.chatModelArray[indexObj.row].id)
                    }
                }
                isShowError = 1
            }
        }
        
        self.isDeletedOther = false
        if isShowError == -1 {
            let dict = ["conversation_id":conversatonObj.conversation_id , "delete_multiple" : true , "multiple_delete_message_ids":idDelete] as [String : Any]
            self.alertDel(paramStr: dict, indexArray: indexArray)
        }else if isShowError == 1 {
            self.isDeletedOther = true
            let dict = ["conversation_id":conversatonObj.conversation_id , "delete_multiple" : true , "multiple_delete_message_ids":idDelete] as [String : Any]
            self.alertDel(isMe: false, paramStr: dict, indexArray: indexArray)
        }
    }
    
    func alertDel(isMe:Bool = true, paramStr:[String:Any], indexArray:[IndexPath]) {
        var param = paramStr
        let alert = UIAlertController(title: "Delete chat message.",
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        if isMe {
            let allAction = UIAlertAction(title: "Delete for everyone".localized(), style: .default, handler: {_ in
                param["messageType"] = "delete_for_everyone"
                SocketSharedManager.sharedSocket.emitDeleteChatText(dict: param)
                self.delRow(indexArray: indexArray)
            })
            alert.addAction(allAction)
        }
        
        let meAction = UIAlertAction(title: "Delete for me".localized(), style: .default, handler: {_ in
            param["messageType"] = "delete_for_me"
            SocketSharedManager.sharedSocket.emitDeleteChatText(dict: param)
            self.delRow(indexArray: indexArray)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
        })
        alert.addAction(meAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: {})
        }
    }
    
    func delRow(indexArray:[IndexPath]) {
        
        var arrayNew = [IndexPath]()
        
        for indexObj in indexArray {
            LogClass.debugLog("indexObj.row ===> 112222")
            LogClass.debugLog(indexObj.row)
            LogClass.debugLog(self.chatModelArray.count)
            if (self.chatModelArray.count) > indexObj.row {
                let msgObj = self.chatModelArray[indexObj.row]
                self.conversatonObj.removeFromToMessage(msgObj)
                CoreDbManager.shared.saveContext()
                self.chatModelArray.remove(at: indexObj.row)
                arrayNew.append(indexObj)
            }
        }
        
        self.chatTableView.deleteRows(at: arrayNew, with: .automatic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            self.crossEdit()
            self.selectedRows.removeAll()
            self.isSelectionEnable = false
            self.updateChatObject()
        }
    }
    
}

extension ChatViewController : DelegateTapCell {
    
    func delegateOpenforImage(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforImage(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforCopy(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func addChild(asChildViewController: UIViewController, selectedView: UIView) {
        addChild(asChildViewController)
        selectedView.isHidden = false
        
        selectedView.addSubview(asChildViewController.view)
        asChildViewController.view.frame = selectedView.bounds
        asChildViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        asChildViewController.didMove(toParent: self)
    }
    
    func removeChild(asChildViewController: UIViewController) {
        self.viewSelection.isHidden = true
        asChildViewController.willMove(toParent: nil)
        asChildViewController.view.removeFromSuperview()
        asChildViewController.removeFromParent()
    }
    
    
    func delegateTapCellAction(chatObj: Message, indexRow: IndexPath) {
        if self.isBlock {
            return
        }
        
        if let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatSelectionController") as? ChatSelectionController
        {
            vc.postType = chatObj.post_type
            vc.isMine = Int(chatObj.author_id) == SharedManager.shared.getUserID()
            vc.isPinned = chatObj.is_pinned == "1"
            vc.isShowCopy = chatObj.body.count > 0
            vc.didSelectReaction = { reactionIndex in
                self.reactionTapped(indexP: reactionIndex, messageObj: chatObj)
            }
            
            vc.didSelectOption = { itemId in
                self.selectedChatAction(itemId: itemId, messageObj: chatObj, indexRow: indexRow)
            }
            
            self.sheetController = SheetViewController(controller: vc, sizes: [.fixed(480)])
            self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self.present(self.sheetController, animated: true, completion: nil)
        }
    }
    
    func selectedChatAction(itemId: Int, messageObj: Message, indexRow: IndexPath) {
        
        if self.isBlock {
            return
        }
        
        switch itemId {
        case 1:
            self.editChatMessage(messageObj: messageObj)
        case 2:
            self.replyChatMessage(messageObj: messageObj)
        case 3:
            self.forwardChatMessage(messageObj: messageObj)
        case 4:
            self.deleteMultipleMessage(indexArray: [indexRow])
        case 5:
            self.pinChatMessage(objIndex: indexRow.row)
        case 6:
            self.copyChatMessage(messageObj: messageObj)
        case 7:
            self.shareChatMessage(messageObj: messageObj)
        case 8:
            self.selectMultipleMessages(indexRow: indexRow)
        default:
            break
        }
        
    }
    
    func editChatMessage(messageObj: Message){
        if (Int(messageObj.author_id)! == SharedManager.shared.getUserID()){
            self.editchatModelObj = messageObj
            if let editObj = editchatModelObj, editObj.id.count > 0 {
                self.commentTextView.becomeFirstResponder()
                self.commentTextView.text = editObj.body
                self.commentTextView.textColor = UIColor.black
            }
        }else {
            DispatchQueue.main.async {
                SharedManager.shared.showAlert(message: "You can edit only your messages.".localized(), view: self)
            }
        }
    }
    
    func replyChatMessage(messageObj: Message){
        if self.isBlock {
            return
        }
        
        self.editchatModelObj = messageObj
        
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            self.isReply = true
            self.viewReply.isHidden = false
            if Int(editObj.author_id) == SharedManager.shared.getUserID() {
                self.replylblUserName.text = "You".localized()
            }else {
                self.replylblUserName.text = editObj.full_name
            }
            
            self.replyimgViewBG.isHidden = true
            self.replylbl.text = editObj.body
            
            if editObj.post_type == FeedType.post.rawValue {
                self.replylbl.text = editObj.body
            }else if editObj.post_type == FeedType.image.rawValue {
                self.replyimgViewBG.isHidden = false
                
                self.replyimgViewM.loadImageWithPH(urlMain:editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MessageFile).url : "")
                
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
                self.replylbl.text = "Photo".localized()
            }else if editObj.post_type == FeedType.video.rawValue {
                self.replyimgViewBG.isHidden = false
                
                self.replyimgViewM.loadImageWithPH(urlMain:editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MessageFile).thumbnail_url : "")
                
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
                self.replylbl.text = "Video".localized()
            }else if editObj.post_type == FeedType.file.rawValue {
                
                var messageArray = [MessageFile]()
                if editObj.toMessageFile?.count ?? 0 > 0 {
                    messageArray = editObj.toMessageFile?.allObjects as! [MessageFile]
                }
                if messageArray.count == 1  {
                    let dictMain = messageArray[0]
                    let urlMain = URL.init(string: dictMain.url)
                    self.replylbl.text = urlMain?.lastPathComponent
                }
            }else if editObj.post_type == FeedType.audio.rawValue {
                self.replylbl.text = "Audio".localized()
                self.replyimgViewBG.isHidden = false
                self.replyimgViewM.image = UIImage(named: "chat_microphone")
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
            }
        }
        
    }
    
    func forwardChatMessage(messageObj: Message){
        
        self.crossEdit()
        
        if let viewGroup = self.GetView(nameVC: "ForwardMessageContactVC", nameSB: "Notification") as? ForwardMessageContactVC {
            viewGroup.delegateRefresh = self
            viewGroup.sendingMessageArray = [messageObj]
            self.navigationController?.pushViewController(viewGroup, animated: true)
        }
    }
    
    func pinChatMessage(objIndex: Int){
        
        if (self.chatModelArray[objIndex].is_pinned == "1")
        {
            self.chatModelArray[objIndex].is_pinned = "0"
            self.chatModelArray[objIndex].pinnedBy = ""
        }
        else {
            self.chatModelArray[objIndex].is_pinned = "1"
            self.chatModelArray[objIndex].pinnedBy = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getUserID())
        }
        CoreDbManager.shared.saveContext()
        let parameters = ["conversation_id":self.conversatonObj.conversation_id, "pinned_by":SharedManager.shared.getUserID(), "message_id":self.chatModelArray[objIndex].id] as [String : Any]
        SocketSharedManager.sharedSocket.pinMessage(dict: parameters)
        
        self.chatTableView.reloadData()
    }
    
    func copyChatMessage(messageObj: Message){
        UIPasteboard.general.string = messageObj.body
    }
    
    func shareChatMessage(messageObj: Message){
        
        self.editchatModelObj = messageObj
        
        if let editObj = editchatModelObj, editObj.id.count > 0 {
            let url = (editObj.toMessageFile?.first as? MessageFile)?.url ?? nil
            
            if editObj.post_type == FeedType.post.rawValue {
                showShareActivity(msg: editObj.body, image: nil, data: nil, url: nil, anyObject: nil, sourceRect: nil)
            }else if editObj.post_type == FeedType.image.rawValue {
                showShareActivity(msg: editObj.body, image: nil, data: nil, url:url , anyObject: nil, sourceRect: nil)
            }else if editObj.post_type == FeedType.video.rawValue {
                showShareActivity(msg: editObj.body, image: nil, data: nil, url:url , anyObject: nil, sourceRect: nil)
            }else if editObj.post_type == FeedType.file.rawValue {
                showShareActivity(msg: editObj.body, image: nil, data: nil, url:url , anyObject: nil, sourceRect: nil)
            }else if editObj.post_type == FeedType.audio.rawValue {
                showShareActivity(msg: editObj.body, image: nil, data: nil, url:editObj.audio_msg_url , anyObject: nil, sourceRect: nil)
            }
        }
    }
    
    func selectMultipleMessages(indexRow: IndexPath){
        
        self.isSelectionEnable = true
        
        self.selectedRows.append(self.chatModelArray[indexRow.row].id)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegatRowSelectedValueChange(indexPath: indexRow)
        }
        
        self.addCallButtonswithCross()
        self.delegatRowValueChange(indexPath: indexRow, selectecion: true)
        self.viewSelection.isHidden = false
    }
    
    @IBAction func forwardMultipleMessages(sender : UIButton){
        
        if self.selectedRows.count == 0 {
            SharedManager.shared.showAlert(message: "please select message.".localized(), view: self)
            self.crossEdit()
            return
        }
        
        var newArray = [Message]()
        for indexObj in 0..<self.selectedRows.count {
            let objIndex = self.chatModelArray.firstIndex(where: { $0.id == self.selectedRows[indexObj]})
            newArray.append(self.chatModelArray[objIndex ?? 0])
        }
        if let viewGroup = self.GetView(nameVC: "ForwardMessageContactVC", nameSB: "Notification") as? ForwardMessageContactVC {
            viewGroup.delegateRefresh = self
            viewGroup.sendingMessageArray = newArray
            self.navigationController?.pushViewController(viewGroup, animated: true)
        }
        
        self.crossEdit()
    }
    
    @IBAction func deleteMultipleMessages(sender : UIButton){
        
        if self.selectedRows.count == 0 {
            SharedManager.shared.showAlert(message: "please select message.".localized(), view: self)
            self.crossEdit()
            return
        }
        
        var indexRow = [IndexPath]()
        for indexObj in 0..<self.selectedRows.count {
            let objIndex = self.chatModelArray.firstIndex(where: { $0.id == self.selectedRows[indexObj]})
            indexRow.append(IndexPath.init(row: objIndex ?? 0, section: 0))
        }
        
        self.deleteMultipleMessage(indexArray: indexRow)
    }
    
    func deleteMessage(){
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            let dict = ["conversation_id":editObj.conversation_id , "message_id":editObj.id] as [String:Any]
            SocketSharedManager.sharedSocket.emitDeleteChatText(dict: dict)
        }
    }
    
    func scrollToReplyMessage(messageObj: Message){
        
        if let replyIndex = self.chatModelArray.firstIndex(where: { $0.id == messageObj.replied_to_message_id})
        {
            DispatchQueue.main.async {
                self.chatTableView.scrollToRow(at: IndexPath(row: replyIndex, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @IBAction func previewHide(sender : UIButton){
        self.viewPreview.isHidden = true
        self.editchatModelObj = nil
        self.selectedRows.removeAll()
        self.isSelectionEnable = false
    }
    
    @IBAction func playPreviewHide(sender : UIButton){
        
    }
    
}
extension ChatViewController:UITextViewDelegate   {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let paste = UIPasteboard.general.string, text == paste {
            if UIPasteboard.general.string != nil{
                textView.text = UIPasteboard.general.string
                return false
            }
        }else if text.contains(UIPasteboard.general.string ?? "") {
            if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                textView.text = editObj.body
                var messageArray = [MessageFile]()
                if editObj.toMessageFile?.count ?? 0 > 0 {
                    messageArray = editObj.toMessageFile?.allObjects as! [MessageFile]
                }
                if  messageArray.count > 0 {
                    self.viewPreview.isHidden = false
                    self.viewVideoPreview.isHidden = true
                    self.imgViewPreview.isHidden = false
                    self.viewPreviewAudio.isHidden = true
                    if messageArray[0].post_type == FeedType.image.rawValue {
                        self.imgViewPreview.loadImageWithPH(urlMain:messageArray[0].url)
                        self.view.labelRotateCell(viewMain: self.imgViewPreview)
                    }else if messageArray[0].post_type == FeedType.video.rawValue {
                        self.viewVideoPreview.isHidden = false
                        self.imgViewPreview.loadImageWithPH(urlMain:messageArray[0].thumbnail_url)
                        self.view.labelRotateCell(viewMain: self.imgViewPreview)
                    }else if messageArray[0].post_type == FeedType.file.rawValue {
                        
                        let messagefile = messageArray[0]
                        
                        let urlmain = messagefile.url.components(separatedBy: ".")
                        
                        if urlmain.last == "pdf" {
                            self.imgViewPreview.image = UIImage.init(named: "PDFIcon.png")
                        }else if urlmain.last == "doc" || urlmain.last == "docx"{
                            self.imgViewPreview.image = UIImage.init(named: "WordFile.png")
                        }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
                            self.imgViewPreview.image = UIImage.init(named: "ExcelIcon.png")
                        }else if  urlmain.last == "zip"{
                            self.imgViewPreview.image = UIImage.init(named: "ZipIcon.png")
                        }else if  urlmain.last == "pptx"{
                            self.imgViewPreview.image = UIImage.init(named: "pptIcon.png")
                        }else {
                            self.imgViewPreview.image = UIImage.init(named: "PDFIcon.png")
                        }
                    }else if messageArray[0].post_type == FeedType.post.rawValue {
                        
                        self.viewPreviewAudio.isHidden = false
                        self.imgViewPreview.isHidden = true
                    }
                }
            }else {
                if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                    
                    if editObj.post_type == FeedType.post.rawValue {
                        if editObj.audio_file.count > 0 {
                            self.viewPreview.isHidden = false
                            self.viewPreviewAudio.isHidden = false
                            self.imgViewPreview.isHidden = true
                        }
                    }
                }
            }
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.commentTextView.textColor == UIColor.gray {
            self.commentTextView.text = nil
            self.commentTextView.textColor = UIColor.black
        }
        if self.chatModelArray.count > 4 {
            self.btnBottomView.isHidden = true
            self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count-1, section: 0), at: .bottom, animated: false)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.commentTextView.text = Const.chatTextViewPlaceholder.localized()
            self.commentTextView.textColor = UIColor.gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView){
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < 100 {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightContraint.constant = newFrame.size.height + 15
        }else {
            self.commentTextView.isScrollEnabled = true
        }
        self.commentTextView.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 20.0)
    }
}

extension ChatViewController:feedCommentDelegate    {
    
    func updateChatMessage() {
        self.updateChatObject()
    }
    
    func feedCommentReceivedFromSocket(res: NSDictionary) {  // For Delete Message
        if isDeletedOther {
            return
        }
        
        if self.conversatonObj.conversation_id == self.ReturnValueCheck(value: res["conversation_id"] as Any) {
            
            var index = -1
            for  indexObj in 0..<self.chatModelArray.count {
                if self.chatModelArray[indexObj].id == self.ReturnValueCheck(value: res["message_id"] as Any) {
                    index = indexObj
                    break
                }
            }
            
            if index != -1 {
                self.chatModelArray.remove(at: index)
                
                self.chatTableView.beginUpdates()
                self.chatTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
                self.chatTableView.endUpdates()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.selectedRows.removeAll()
                    self.isSelectionEnable = false
                    
                    
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    
    func chatMessageDelete(res: NSArray){
        
        for dict in res {
            if let chatmodel = dict as? [String : Any] {
                
                if self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any) == self.conversatonObj.conversation_id {
                    
                    for indexObj in 0..<self.chatModelArray.count {
                        
                        if self.chatModelArray[indexObj].id == self.ReturnValueCheck(value: chatmodel["message_id"] as Any) {
                            
                            self.chatModelArray.remove(at: indexObj)
                            self.chatTableView.deleteRows(at: [IndexPath.init(row: indexObj, section: 0)], with: .automatic)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func pinnedMessageDelegate(res: NSDictionary){
        
        if let chatmodel = res as? [String : Any] {
            
            if self.ReturnValueCheck(value: chatmodel["conversationId"] as Any) == self.conversatonObj.conversation_id && self.ReturnValueCheck(value: chatmodel["user_id"] as Any) == String(SharedManager.shared.getUserID()) {
                
                for indexObj in 0..<self.chatModelArray.count {
                    
                    if self.chatModelArray[indexObj].id == self.ReturnValueCheck(value: chatmodel["message_id"] as Any) {
                        
                        if(self.ReturnValueCheck(value: chatmodel["status"] as Any) == "pin") {
                            self.chatModelArray[indexObj].is_pinned = "1"
                            self.chatModelArray[indexObj].pinnedBy = self.ReturnValueCheck(value: chatmodel["user_id"] as Any)
                        }
                        else {
                            self.chatModelArray[indexObj].is_pinned = "0"
                            self.chatModelArray[indexObj].pinnedBy = ""
                        }
                        self.chatTableView.reloadRows(at: [IndexPath.init(row: indexObj, section: 0)], with: .none)
                        break
                    }
                }
            }
        }
    }
    
    func GettingConvertedURLAudio(postfileID : String ,textToSpeech : String , languageCode : String , rowReload : Int){
        
        var fileID = ""
        for indexObj in self.chatModelArray {
            if indexObj.id == postfileID {
                if indexObj.toMessageFile?.count ?? 0 > 0 {
                    fileID = (indexObj.toMessageFile?.first as! MessageFile).id
                }
                
                break
            }
        }
        
        let parameters = ["action": "message_files/translate_audio","token": SharedManager.shared.userToken() , "file_id" : fileID]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let newRes = res as? [String : Any] {
                    
                    for indexObj in self.chatModelArray {
                        
                        if indexObj.id == postfileID {
                            indexObj.audio_translation = newRes["url"] as! String
                            self.chatTableView.reloadRows(at: [IndexPath.init(row: rowReload, section: 0)], with: .none)
                            break
                        }
                    }
                }
            }
        }, param: parameters)
    }
}


extension ChatViewController {
    
    func videoSave(urlMain : URL){
        
        let asset = AVURLAsset(url: urlMain, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        var cgImage : CGImage
        
        cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        
        
        DispatchQueue.main.async {
            
            let img = UIImage.init(cgImage: cgImage)
            var newData = [String : Any]()
            newData["Image"] = img
            newData["ImageURL"] = ""
            newData["Type"] = FeedType.video.rawValue
            newData["URL"] = urlMain.path
            
            
            self.videoObj["Image"] = img
            self.videoObj["ImageURL"] = ""
            self.videoObj["Type"] = FeedType.video.rawValue
            self.videoObj["URL"] = urlMain.absoluteString
            self.videoObj["LanguageID"] = SharedManager.shared.getCurrentLanguageID()
            
            
            if self.viewReply.isHidden {
                self.cstViewChatPreview.constant = 0.0
            }else {
                self.cstViewChatPreview.constant = 50.0
            }
            
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
            self.addChild(asChildViewController:self.chatPreviewController , selectedView:self.viewVideo )
            self.chatPreviewController.reloadView(mainData: newData)
        }
    }
    
    func exportVideo(asset  : TLPHAsset) {
        asset.exportVideoFile(progressBlock: { (progress) in
            
        }) { (url, mimeType) in
            self.videoSave(urlMain : url)
            
        }
    }
}


extension ChatViewController : TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                self.imageMain = self.getImageFromAsset(asset: indexObj.phAsset!)!
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        self!.uploadFile(filePath: urlString!.path, fileType: "image", imageMAin: self!.imageMain)
                    }
                }
                
            }else if indexObj.type == .livePhoto {
                
            }
            else if indexObj.type == .video {
                self.exportVideo(asset: indexObj)
                
            }
        }
    }
    
    func uploadFile(filePath:String, fileType:String , imageMAin : UIImage = UIImage.init()){
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let newTime = dateFormatter.string(from: Date())
        let idStr = String(Int(Date().timeIntervalSince1970))
        
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let messageObj = Message(context: moc)
        messageObj.uploadingStatus = "uploading"
        
        let msgCOFile = MessageFile(context: moc)
        
        if fileType == "video" {
            messageObj.post_type = FeedType.video.rawValue
        }else if fileType == "attachment" {
            messageObj.post_type = FeedType.file.rawValue
        }else if fileType == "audio" {
            messageObj.post_type = FeedType.audio.rawValue
        }else {
            messageObj.post_type = FeedType.image.rawValue
        }
        
        messageObj.author_id = String(SharedManager.shared.getUserID())
        messageObj.identifierString = idStr
        messageObj.id = idStr
        messageObj.messageTime = newTime
        
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            messageObj.replied_to_message_id = editObj.id
            messageObj.addToReply_to(editObj)
        }
        
        var chatUploadModal = ChatUploadModal()
        chatUploadModal.fileType = fileType
        chatUploadModal.fileName = filePath.components(separatedBy: "/").last ?? ""
        chatUploadModal.filePath = URL(string: filePath)
        chatUploadModal.mimeType = filePath.mimeType()
        
        let messageFile = UserChatMessageFiles.init()
        
        if fileType == "attachment" {
            messageFile.post_type = FeedType.file.rawValue
            messageFile.localthumbnailimage = nil
            messageFile.localVideoURL = filePath
            
        } else if fileType == "audio" {
            messageFile.post_type = FeedType.audio.rawValue
            messageFile.localthumbnailimage = nil
            messageFile.localVideoURL = filePath
            messageObj.audio_msg_url = filePath
            
        } else if fileType == "video" {
            messageFile.post_type = FeedType.video.rawValue
            let fileName = SharedManager.shared.getIdentifierForMessage() + ".jpg"
            SharedManager.shared.saveImage(image: imageMAin, fileName: fileName)
            messageFile.localthumbnailimage = fileName
            messageFile.localVideoURL = filePath
            
            chatUploadModal.thumbnailPath = SharedManager.shared.getPathFromDocumentDirectory(fileName: fileName)
            chatUploadModal.thumbnailMimeType = fileName.mimeType()
            chatUploadModal.thumbnailName = fileName
        } else {
            let fileName = SharedManager.shared.getIdentifierForMessage() + ".jpg"
            SharedManager.shared.saveImage(image: imageMAin, fileName: fileName)
            messageFile.post_type = FeedType.image.rawValue
            messageFile.localimage = filePath
            messageFile.localthumbnailimage = fileName
            
            chatUploadModal.filePath = SharedManager.shared.getPathFromDocumentDirectory(fileName: fileName)
            chatUploadModal.mimeType = fileName.mimeType()
            chatUploadModal.fileName = fileName
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        messageObj.body = myComment
        messageObj.toChat = self.conversatonObj
        messageObj.addToToMessageFile(DBMessageManager.mapMessageFile(messageFileObj: msgCOFile, messageFile: messageFile))
        if self.isReply {
            for indexObj in self.chatModelArray {
                if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                    if indexObj.id == editObj.id {
                        messageObj.addToReply_to(indexObj)
                        messageObj.replied_to_message_id = indexObj.id
                        break
                    }
                }
            }
        }
        
        CoreDbManager.shared.saveContext()
        _ = DBMessageManager.checkMessageExists(identifierString: messageObj.identifierString, messageID: "")
        let chatUploading = ChatUploadManager.init()
        chatUploading.chatID = self.conversatonObj.conversation_id
        chatUploading.identifier = idStr
        chatUploading.chatUploadModal = chatUploadModal
        chatUploading.callingServiceToUploadOnS3()
        SharedManager.shared.chatUploadingDict[messageObj.identifierString] = chatUploading
        
        self.updateChatObject()
        self.viewReply.isHidden = true
        self.hideReply(sender: UIButton.init())
        self.commentTextView.resignFirstResponder()
        self.manageTextView()
        DispatchQueue.main.async {
            self.btnBottomView.isHidden = true
            self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count - 1 , section: 0), at: .bottom, animated: true)
        }
    }
    
    func UploadImageOnSocket(mainURL : String , newTime : String , fileType:String, thumbnailURL : String ){
        
        var indexRow : Message!
        for indexObj in self.chatModelArray {
            if indexObj.identifierString == newTime {
                indexRow = indexObj
                break
            }
        }
        
        if indexRow.reply_to != nil {
            self.replyChatAttachText(mainURL: mainURL, newTime: newTime, fileType: fileType, thumbnailURL: thumbnailURL)
        }else {
            self.sendAttachOnSocket(mainURL: mainURL, newTime: newTime, fileType: fileType, thumbnailURL: thumbnailURL)
        }
    }
    
    func sendAttachOnSocket(mainURL : String , newTime : String , fileType:String, thumbnailURL : String ){
        var urlSendArray = [[String : Any]]()
        var urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = thumbnailURL
        
        if fileType == "video" {
            urlSend["type"] = "video/mov"
            urlSend["language_id"] = "1"
        }else if fileType == "attachment" {
            urlSend["type"] = "attachment"
        }else {
            urlSend["type"] = "image/png"
        }
        
        urlSendArray.append(urlSend)
        
        var newTimeP = newTime
        if newTime.count == 0 {
            newTimeP = SharedManager.shared.getCurrentDateString()
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":self.conversatonObj.conversation_id, "identifierString":newTimeP, "message_files":[], "audio_file":"" ]
        //        "replied_to_message_id" : "1019635"]
        self.viewReply.isHidden = true
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
        self.manageTextView()
        
        self.viewReply.isHidden = true
        self.selectedRows.removeAll()
        self.isSelectionEnable = false
    }
    
    func UploadGifOnSocket(mainURL : String , newTime : String  ){
        
        var urlSendArray = [[String : Any]]()
        var  urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = ""
        urlSend["type"] = "Image/gif"
        urlSendArray.append(urlSend)
        
        var newTimeP = newTime
        if newTime.count == 0 {
            newTimeP = SharedManager.shared.getCurrentDateString()
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":self.conversatonObj.conversation_id, "identifierString":newTimeP, "message_files":[], "audio_file":"","post_type" : PostType.image.rawValue]
        self.viewReply.isHidden = true
        self.addNewMessage(dict: dict)
        
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
        
        self.selectedRows.removeAll()
        self.isSelectionEnable = false
    }
    
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
    
    func getImageFromAsset(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func getSelectedItem(asset:TLPHAsset)->UIImage {
        if asset.type == .video {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset.phAsset!, targetSize: CGSize(width: 138, height: 138), contentMode: .aspectFit, options: option,  resultHandler: {(result, info)->Void in
                thumbnail = result!
            })
            return thumbnail
        }
        if let image = asset.fullResolutionImage {
            return image
        }
        return UIImage()
    }
    
    func getSelectedItemVideo(asset:TLPHAsset , sender : Int)  {
        if asset.type == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset.phAsset!, options: options, resultHandler: { [weak self](asset, audioMix, info) in
                
            })
        }
    }
}

extension ChatViewController  {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let imageChoose = info[.editedImage] as? UIImage {
                
                if SharedManager.shared.saveToDocuments(filename: "ChatImage.png" , imageMain: imageChoose) {
                    self.imageMain = imageChoose
                    self.uploadFile(filePath: self.getURLForImage(filename: "ChatImage.png").path, fileType: "image", imageMAin: self.imageMain)
                }
            }else {
                if let videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as? NSURL) {
                    do {
                        let asset = AVURLAsset(url: videoURL as URL , options: nil)
                        let imgGenerator = AVAssetImageGenerator(asset: asset)
                        imgGenerator.appliesPreferredTrackTransform = true
                        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let thumbnail = UIImage(cgImage: cgImage)
                        self.imageMain = thumbnail
                        
                    } catch _ {
                    }
                    self.encodeVideo(videoURL: videoURL as URL) { (newUrl) in
                        DispatchQueue.main.async {
                            self.uploadFile(filePath: videoURL.path!, fileType: "video" ,imageMAin: self.imageMain)
                        }
                    }
                }
            }
        }
    }
    
    func encodeVideo(videoURL: URL,completion : @escaping ((_ newURL : URL?) -> Void))  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        var exportSession : AVAssetExportSession?
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetLowQuality)
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4")?.absoluteString
        _ = URL.init(string: myDocumentPath!)
        
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.mp4")
        self.deleteFile(filePath: filePath!)
        if FileManager.default.fileExists(atPath: myDocumentPath!) {
            do {
                try FileManager.default.removeItem(atPath: myDocumentPath!)
            }
            catch _ {
            }
        }
        
        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession?.status {
            case .failed:
                completion(nil)
            case .cancelled:
                completion(nil)
            case .completed:
                completion(exportSession?.outputURL)
            default:
                break
            }
        })
    }
    
    func deleteFile(filePath: URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    @IBAction func cameraChooseAction(sender : UIButton){
        self.viewCameraOptions.isHidden = true
        self.openPhotoPicker()
    }
    
    @IBAction func galleryChooseAction(sender : UIButton){
        self.viewCameraOptions.isHidden = true
        self.openImageCamera()
    }
    
    @IBAction func gifBrowseChooseAction(sender : UIButton){
        self.viewGifOptions.isHidden = true
        let gifObj = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "GifListController") as! GifListController
        gifObj.delegate = self
        gifObj.isMultiple = false
        gifObj.modalPresentationStyle = .fullScreen
        self.present(gifObj, animated: true, completion: nil)
    }
    
    @IBAction func gifUploadChooseAction(sender : UIButton){
        self.viewGifOptions.isHidden = true
        self.openPhotoPicker()
    }
    
    
    func chatMessageReceived(res: NSArray) {
        for dict in res {
            if let chatmodel = dict as? [String : Any] {
                if self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any) != self.conversatonObj.conversation_id {
                    break
                }
                let objChat = UserChatModel.init(fromDictionary: chatmodel)
                let identifierString = objChat.identifierString
                let messageID = objChat.message_id
                var isExist = false
                if(DBMessageManager.checkMessageExists(identifierString: identifierString, messageID: messageID))
                {
                    DBMessageManager.updateMessage(identifierString: identifierString, chatData: objChat, messageID: messageID)
                    isExist = true
                }else {
                    DBMessageManager.saveMessageData(messageArr: [objChat], chatListObj: self.conversatonObj)
                }
                
//                if !btnBottomView.isHidden {
//                    self.newMsgCounter = isExist ? self.newMsgCounter : self.newMsgCounter + 1
//                    self.counterLbl.text = "" //self.newMsgCounter > 0 ? "+" + String(self.newMsgCounter) : ""
//                }
//                else {
//                    self.newMsgCounter = 0
//                    self.counterLbl.text = ""
//                }
                
                self.updateChatObject()
                if self.btnBottomView.isHidden {
                    scrollToBottom()
                }
            }
        }
    }
}

extension ChatViewController : GifImageSelectionDelegate {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        if gifDict.count > 0 {
            for (_, gifObj) in gifDict {
                let newTime = SharedManager.shared.getCurrentDateString()
                self.UploadGifOnSocket(mainURL: gifObj.url, newTime: newTime)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.viewCameraOptions.isHidden = true
        self.viewGifOptions.isHidden = true
    }
}



extension ChatViewController: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
        //        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
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
        self.present(documentPicker, animated: true) {
            
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}
        self.uploadFile(filePath: url.absoluteString, fileType: "attachment" )
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension ChatViewController {
    func showShareActivity(msg:String?, image:UIImage?,data:NSData?, url:String?,anyObject:AnyObject?, sourceRect:CGRect?){
        var objectsToShare = [Any]()
        
        if let data = data {
            objectsToShare.append(data)
        }
        
        if url != nil {
            if let urlNew = URL.init(string: url!) {
                objectsToShare.append(urlNew)
            }
        }
        
        if let image = image {
            objectsToShare.append(image)
        }
        
        if let msg = msg {
            objectsToShare.append(msg)
        }
        
        if let anyObject = anyObject {
            objectsToShare.append(anyObject)
        }
        
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.excludedActivityTypes = [
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.copyToPasteboard
            ]
            if let sourceRect = sourceRect {
                activityVC.popoverPresentationController?.sourceRect = sourceRect
            }
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}

extension ChatViewController : SocketDelegateForGroup   {
    
    func didSocketGroupThemeUpdate(data: [String : Any]) {
        LogClass.debugLog("didSocketGroupThemeUpdate ==>")
        LogClass.debugLog(data)
        self.updateChatObject()
    }
    
    func didSocketRemoveContactGroup(data: [String : Any])  {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversation_id {
            let userLeft = self.ReturnValueCheck(value: data["user_who_left"] as Any)
            if userLeft ==  String(SharedManager.shared.getUserID()) {
                self.ShowAlertWithPop(message: "Admin remove you from this group.".localized())
            }else if userLeft.count > 0 {
                let userID = SharedManager.shared.ReturnValueAsString(value: userLeft)
                if userID != "" {
                    if let member = ChatDBManager.getChatMember(id: userLeft) {
                        self.conversatonObj.removeFromToMember(member)
                        CoreDbManager.shared.saveContext()
                    }
                }
            }
        }
    }
    
    func didSocketGroupUpdate(data: [String : Any]) {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversation_id {
            let newName = self.ReturnValueCheck(value: data["new_group_name"] as Any)
            let newImage = self.ReturnValueCheck(value: data["new_group_image"] as Any)
            if newName.count > 0 {
                self.conversatonObj.name = newName
                self.navigationController?.addTitle(self, title: newName, selector: #selector(self.showProfile))
            }else {
                self.conversatonObj.group_image = newImage
            }
        }
    }
    
    func didSocketContactGroup(data: [String : Any]) {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversation_id {
            if let arrayUSer = data["members"] as? [[String : Any]] {
                for _ in arrayUSer {
                    
                }
            }
        }
    }
}

extension ChatViewController : DelegateChatPreview  {
    
    func delegateRemoveView(dataMain: [String : Any], isDelete: Bool) {
        if isDelete {
            self.viewVideo.isHidden = true
            self.removeChild(asChildViewController: self.chatPreviewController)
            self.videoObj = [String : Any]()
        }
    }
    
    func delegateChooseLanguage(dataMain: [String : Any]) {
        self.videoObj["LanguageID"] = dataMain["LanguageID"]
    }
}


extension ChatViewController:ReactionSenderDelegate {
    
    func showReactionListDelegate(messageID:String, messageObj:Message) {
        let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ReactionsViewController") as! ReactionsViewController
        vc.message_id = messageID
        vc.message = messageObj
        self.sheetController = SheetViewController(controller: vc, sizes: [.fixed(480)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.present(self.sheetController, animated: true, completion: nil)
    }
    
    func reactionTapped(indexP: IndexPath, messageObj: Message) {
        let userID = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getUserID())
        let userName = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getFullName())
        let userProfileImage = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getProfileImage())
        let param = ["conversation_id":self.conversatonObj.conversation_id, "message_id":messageObj.id, "reacted_by":SharedManager.shared.getUserID(), "reaction":SharedManager.shared.arrayChatGif[indexP.row]] as [String : Any]
        DBReactionManager.reactionHandling(action: "add_reaction", selectedReaction: param["reaction"] as! String, messageID: messageObj.id, userID: userID, name: userName, profileImage: userProfileImage)
        SocketSharedManager.sharedSocket.addReaction(dictionary: param)
        self.updateChatObject()
    }
    
}
