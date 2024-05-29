//
//  MPChatVC.swift
//  WorldNoor
//
//  Created by Awais on 25/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
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
import Alamofire

class MPChatVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DelegateRefresh {
    let keyboardObserver = CommonKeyboardObserver()
    var userToken = ""
    var chatModelArray = [MPMessage]()
    var editchatModelObj:MPMessage?
    var isReply:Bool = false
    var isSelectionEnable = false
    var isAPICall = false
    var isTranslationOn = true
    var isLoadMore = true
    var isDeletedOther = false
    var isBlock = false
    var selectedRows = [String]()
    var conversatonObj = MPChat()
    var dateObj : Date!
    var startingPoint = ""
    var currentOffset : CGPoint!
    var imageMain = UIImage.init()
    var calldictionary:[String:Any]  = [:]
    var sheetController = SheetViewController()
    var topBar = UIView()
    let topBarbutton = UIButton()
    var scrollToIndex = 0
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
            "SenderMPChatCell",
            "ReceiverMPChatCell",
            "MPChatHeaderCell",
            "MPChatOfferCell"
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangeNotification),name: NSNotification.Name(Const.KLangChangeNotif),object: nil)
        MPSocketSharedManager.sharedSocket.chatDelegate = self
        self.userToken = SharedManager.shared.userToken()
        self.chatTableView.estimatedRowHeight = 300
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.keyboardDismissMode = .interactive
        self.noConversation.isHidden = true
        self.manageKeyboard()
        self.manageTextView()
        self.manageCallBackHandler()
        
        self.chatModelArray.removeAll()
        self.chatTableView.reloadData()
        
        self.delegateRefresh()
        updateChatObject()
        scrollToBottom(isAnimated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.viewCameraOptions.isHidden = true
//        SocketSharedManager.sharedSocket.commentDelegate = self
        self.chatTableView.keyboardDismissMode = .onDrag
        
        let autoTranslation = self.ReturnValueCheck(value: SharedManager.shared.userBasicInfo["auto_translate"] as Any)
        if  autoTranslation.count == 0 || autoTranslation == "1" {
            self.isTranslationOn = true
        }else if autoTranslation == "0" {
            self.isTranslationOn = false
        }
//        SocketSharedManager.sharedSocket.delegateGroup = self
        self.viewPreviewSlider.setThumbImage(UIImage(named: "NewThumb"), for: .normal)
        self.chatTableView.allowsSelection = true
        self.chatTableView.allowsMultipleSelectionDuringEditing = true
        
        self.reloadVisibleCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
//        SharedManager.shared.colourBG = UIColor.init(red: (57/255), green: (130/255), blue: (247/255), alpha: 1.0)
//        if self.conversatonObj.theme_color.count > 0 {
//            SharedManager.shared.colourBG = UIColor.init().hexStringToUIColor(hex: self.conversatonObj.theme_color.replacingOccurrences(of: "#", with: ""))
//        }
        
        
        self.commentTextView.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 15.0)
        self.commentHeightContraint.constant = 45
        
        self.viewBlockUser.isHidden = true
        
        self.viewGifOptions.isHidden = true
//        self.navigationController?.addTitle(self, title: self.conversatonObj.conversationName, selector: #selector(self.showProfile))
        self.navigationController?.addChatTitle(to: self, title: self.conversatonObj.conversationName, userImage: self.conversatonObj.groupImage, selector: #selector(self.showProfile))
        self.userImgView.loadImageWithPH(urlMain:SharedManager.shared.userEditObj.profileImage)
        self.view.labelRotateCell(viewMain: self.userImgView)
        
        self.isBlock = false
//        if  self.conversatonObj.is_blocked == "1" {
//            self.isBlock = true
//            self.viewBlockUser.isHidden = false
//            self.blocknLeaveLbl.text = "You Blocked this user. So, you can't message or call in this chat.".localized()
//        }
        if self.conversatonObj.isGroupLeave {
            self.viewBlockUser.isHidden = false
            self.isBlock = true
            self.blocknLeaveLbl.text = "You left this group. You can\'t message, call or video chat in this group.".localized()
        }
        
        self.navigationItem.rightBarButtonItems = []
    }
    
    func reloadVisibleCells() {
        guard let indexPathsForVisibleRows = self.chatTableView.indexPathsForVisibleRows else {
            return
        }
        
        // Reload only the visible cells
        self.chatTableView.reloadRows(at: indexPathsForVisibleRows, with: .none)
    }
    
    func addCallButtonswithCross(){
        let crossbtn = UIBarButtonItem(image: UIImage(named: "ic_cross"), style: .done, target: self, action: #selector(self.crossEdit))
        
        self.navigationItem.rightBarButtonItems = [crossbtn]
    }
    
    @objc func crossEdit(){
        self.selectedRows.removeAll()
        self.navigationItem.rightBarButtonItems = []
        self.isSelectionEnable = false
        self.viewSelection.isHidden = true
        self.chatTableView.reloadData()
    }

    @objc func languageChangeNotification(){
        
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
        self.callRequestForMessages()
    }
    
    
    @objc func showProfile(){
        if self.conversatonObj.isGroupLeave {
            return
        }
        
        self.crossEdit()
        
        let vc = MPChatProfileVC.instantiate(fromAppStoryboard: .Chat)
        vc.chatConversationObj = self.conversatonObj
        self.navigationController?.pushViewController(vc, animated: true)
        
//        if self.conversatonObj.conversation_type == "group" {
//
//            let viewMain = self.GetView(nameVC: "GroupProfileNewVC", nameSB: "Notification") as! GroupProfileNewVC
//            viewMain.chatObj = self.conversatonObj
//            self.navigationController?.pushViewController(viewMain, animated: true)
//        }else {
//
//            let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatProfileVC") as! ChatProfileVC
//            vc.chatConversationObj = self.conversatonObj
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func callRequestForMessages() {
        
        if(conversatonObj.toMessage?.allObjects.count ?? 0 == 0) {
            self.noConversation.isHidden = false
            self.noConversation.text = "Loading .....".localized()
        }
        
//        let baseURL = "https://marketplace.worldnoor.com/api/get_messages/\(self.conversatonObj.conversationId)"
//        let headers: HTTPHeaders = [
//            "token": SharedManager.shared.marketplaceUserToken()
//        ]
        
        var params : [String: Any] = [:]
        
        if self.startingPoint.count > 0 {
            params["starting_point_id"] = startingPoint
        }

        self.isAPICall = false
        
        MPRequestManager.shared.request(endpoint: "get_messages/\(self.conversatonObj.conversationId)", method: .post, params: params) { response in
            
            self.isAPICall = true
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        let messagesResult = try decoder.decode(MPMessageResponse.self, from: jsonData)
                        
                        let filteredResult = messagesResult.data.filter { message in
                            !((message.messageLabel == "buyer_detail" && message.senderId == SharedManager.shared.getMPUserID()) ||
                            (message.messageLabel == "quick_response" && message.senderId == SharedManager.shared.getMPUserID()))
                        }

                        if self.startingPoint.count == 0 {
                            MPMessageDBManager.saveMessageData(messageArr: filteredResult, chatListObj: self.conversatonObj)
                                self.updateChatObject()
                        }else {
                            if messagesResult.data.count == 0 {
                                self.isLoadMore = false
                                return
                            }else {
                                MPMessageDBManager.saveMessageData(messageArr: filteredResult, chatListObj: self.conversatonObj)
                                self.updateChatObject()
                            }
                        }
                        
                        self.scrollToIndex = self.chatModelArray.count - 1
                        self.chatTableView.reloadData()
                        if self.chatModelArray.count > 4 {
                            if self.startingPoint.count == 0 {
                                self.btnBottomView.isHidden = true
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count-1, section: 0), at: .bottom, animated: false)

                            }else {
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.scrollToIndex, section: 0), at: .top, animated: false)
                            }
                        }
                        if self.chatModelArray.count > 0 {
                            self.startingPoint = self.chatModelArray.first!.id
                            
                            let endpoint = self.chatModelArray[self.chatModelArray.count - 1].id
                            if endpoint != "" {
//                                    if Int(endpoint) != nil {
//                                        SocketSharedManager.sharedSocket.markmessageSeen(valueMain: Int(endpoint)! )
//                                    }
                            }
                        }
                        self.chatTableView.invalidateIntrinsicContentSize()
                        
                        self.chatTableView.reloadData()
                        LogClass.debugLog(messagesResult)
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
        
//        Alamofire.request(baseURL, method: .post, parameters: params, headers: headers).responseJSON { response in
//            self.noConversation.text = "No conversation".localized()
//            guard response.error == nil else {
//                return
//            }
//            switch response.result {
//            case .success(let result):
//                self.isAPICall = true
//                LogClass.debugLog(result)
//                AESDataDecryptor.decryptAESData(
//                    encryptedHexString: result as? String ?? .emptyString
//                ) { responseString in
//                    LogClass.debugLog(responseString)
//                    // Convert the JSON string to Data
//                    if let jsonData = responseString?.data(using: .utf8) {
//                        do {
//                            let decoder = JSONDecoder()
//                            let messagesResult = try decoder.decode(MPMessageResponse.self, from: jsonData)
//                            
//                            let filteredResult = messagesResult.data.filter { message in
//                                !((message.messageLabel == "buyer_detail" && message.senderId == SharedManager.shared.getMPUserID()) ||
//                                (message.messageLabel == "quick_response" && message.senderId == SharedManager.shared.getMPUserID()))
//                            }
//
//                            if self.startingPoint.count == 0 {
//                                MPMessageDBManager.saveMessageData(messageArr: filteredResult, chatListObj: self.conversatonObj)
//                                    self.updateChatObject()
//                            }else {
//                                if messagesResult.data.count == 0 {
//                                    self.isLoadMore = false
//                                    return
//                                }else {
//                                    MPMessageDBManager.saveMessageData(messageArr: filteredResult, chatListObj: self.conversatonObj)
//                                    self.updateChatObject()
//                                }
//                            }
//                            
//                            self.scrollToIndex = self.chatModelArray.count - 1
//                            self.chatTableView.reloadData()
//                            if self.chatModelArray.count > 4 {
//                                if self.startingPoint.count == 0 {
//                                    self.btnBottomView.isHidden = true
//                                    self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count-1, section: 0), at: .bottom, animated: false)
//
//                                }else {
//                                    self.chatTableView.scrollToRow(at: IndexPath(row: self.scrollToIndex, section: 0), at: .top, animated: false)
//                                }
//                            }
//                            if self.chatModelArray.count > 0 {
//                                self.startingPoint = self.chatModelArray.first!.id
//                                
//                                let endpoint = self.chatModelArray[self.chatModelArray.count - 1].id
//                                if endpoint != "" {
////                                    if Int(endpoint) != nil {
////                                        SocketSharedManager.sharedSocket.markmessageSeen(valueMain: Int(endpoint)! )
////                                    }
//                                }
//                            }
//                            self.chatTableView.invalidateIntrinsicContentSize()
//                            
//                            self.chatTableView.reloadData()
//                            LogClass.debugLog(messagesResult)
//                        } catch {
//                            LogClass.debugLog("Error decoding JSON: \(error)")
//                        }
//                    } else {
//                        LogClass.debugLog("Failed to convert JSON string to Data.")
//                    }
//                }
//            case .failure(let error):
//                LogClass.debugLog(error.localizedDescription)
//            }
//        }
    }
    
    func updateChatObject() {
        noConversation.isHidden = true
        chatModelArray.removeAll()
        conversatonObj = MPChatDBManager().getChatFromDb(conversationID: self.conversatonObj.conversationId) ?? MPChat()
        if let messages = conversatonObj.toMessage?.allObjects as? [MPMessage], !messages.isEmpty {
            // Sort messages by ID
            let sortedMessages = messages.sorted { Int($0.id) ?? 0 < Int($1.id) ?? 0 }

            var currentDay = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM. dd, yyyy"

            for indexObj in sortedMessages {
                let messageDateTime = indexObj.createdAt.customDateFormat(time: indexObj.createdAt, format: Const.dateFormat1)
                if let messageDate = dateFormatter.date(from: messageDateTime) {
                    let day = dateFormatter.string(from: messageDate)
                    indexObj.isShowMessageTime = (day != currentDay) ? "1" : "0"
                    currentDay = day
                }
                
                let repliedToMessageId = indexObj.repliedToMessageId
                if !repliedToMessageId.isEmpty, indexObj.replyTo == nil {
                    if let replyToMessage = sortedMessages.first(where: { $0.id == repliedToMessageId }) {
                        indexObj.replyTo = replyToMessage
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
        
        if self.conversatonObj.conversationId.count > 0 {
            return false
        }
        return true
    }
    
    func createConversation(){
        
//        let memberID:[String] = [self.conversatonObj.member_id ]
//        let parameters:NSDictionary = ["action": "conversation/create", "token":userToken, "serviceType":"Node", "conversation_type":"single","member_ids": memberID]
//        self.callingService(parameters: parameters as! [String : Any])
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
                    
                    if editObj.messageLabel == FeedType.image.rawValue {
                        self.copyimageSend(fileType: editObj.messageLabel, URLImage: url, URLVideo:"")
                    }else if editObj.messageLabel == FeedType.video.rawValue {
                        self.copyimageSend(fileType: editObj.messageLabel, URLImage: thumbnailUrl, URLVideo: url )
                    }else if editObj.messageLabel == FeedType.file.rawValue {
                        self.copyimageSend(fileType: editObj.messageLabel, URLImage: url, URLVideo:"")
                    }else if editObj.messageLabel == FeedType.post.rawValue {
                        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
//                        self.uploadAudioOnSockt(text: myComment, audio_msg_url:editObj.audio_file, identiferString: idString)
                        DispatchQueue.main.async {
                            let moc = CoreDbManager.shared.persistentContainer.viewContext
                            let chatObj = MPMessage(context: moc)
                            chatObj.messageLabel = FeedType.post.rawValue
                            chatObj.senderId = String(SharedManager.shared.getMPUserID())
                            chatObj.identifier = String(Int(Date().timeIntervalSince1970))
                            
                            chatObj.createdAt = SharedManager.shared.getUTCDateTimeString()

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
            let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
            var newObjectInner = [String : Any]()
            newObjectInner["message_id"] = editObj.id
            newObjectInner["content"] = myComment
            newObjectInner["mode"] = "edit"
            
            let dict:[String: Any] = [
                "message":editObj.content,
                "files":[] as [Any],
                "message_type": editObj.messageLabel,
                "conversation_id":self.conversatonObj.conversationId,
                "edit_message" : newObjectInner
            ]
            
            for IndexObj in self.chatModelArray {
                if IndexObj.id == editObj.id {
                    IndexObj.content = myComment
//                    IndexObj.original_body = myComment
                    break
                }
            }
            self.viewReply.isHidden = true
            MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
            self.manageTextView()
            self.editchatModelObj = nil
            self.chatTableView.reloadData()
            self.textViewDidChange(self.commentTextView)
        }
    }
    
    func replyChatText(){
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            
            let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
            let dict:[String: Any] = [
                "message":myComment,
                "conversation_id":self.conversatonObj.conversationId,
                "identifier":String(Int(Date().timeIntervalSince1970)),
                "files":[] as [Any],
                "replied_to_message_id" : editObj.id,
                "sender_id": SharedManager.shared.getMPUserID()
            ]
            
            self.addNewMessage(dict: dict)
            self.viewReply.isHidden = true
            MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
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
            newTimeP = String(Int(Date().timeIntervalSince1970))
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        var indexRow : MPMessage!
        
        for indexObj in self.chatModelArray {
            if indexObj.createdAt == newTime {
                indexRow = indexObj
                break
            }
        }
        
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getMPUserID(), "uploads":urlSendArray, "conversation_id":self.conversatonObj.conversationId, "identifierString":newTimeP, "message_files":[], "audio_file":"", "replied_to_message_id" : indexRow.repliedToMessageId]
        
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
            let chatObj = MPMessage(context: moc)
            let msgCOFile = MPMessageFile(context: moc)
            
            if fileType == "video" {
                chatObj.messageLabel = FeedType.video.rawValue
            }else if fileType == "attachment" {
                chatObj.messageLabel = FeedType.file.rawValue
            }else {
                chatObj.messageLabel = FeedType.image.rawValue
            }
            
            chatObj.senderId = String(SharedManager.shared.getMPUserID())
            chatObj.content = self.commentTextView.text
            
            chatObj.createdAt = SharedManager.shared.getUTCDateTimeString()
            chatObj.identifier = newTime
            
            var messageFile = MPMessageFileModel()
            
            if fileType == "attachment" {
                messageFile.type = FeedType.file.rawValue
                messageFile.url = URLImage
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"attachment" , thumbnailURL: "")
                }
                
            }else if fileType == "video" {
                messageFile.type = FeedType.video.rawValue
                messageFile.thumbnailUrl = URLImage
                messageFile.url = URLVideo
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLVideo ,newTime: newTime , fileType:"video" , thumbnailURL: URLImage)
                }
            }else {
                messageFile.type = FeedType.image.rawValue
                messageFile.url = URLImage
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"image" , thumbnailURL: "")
                }
            }
            
            chatObj.addToToMessageFile(MPMessageDBManager.mapMessageFile(messageFileObj: msgCOFile, messageFile: messageFile))
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
                
                var dict : [String : Any] = [
                    "message":myComment,
                    "conversation_id":self.conversatonObj.conversationId,
                    "identifier":String(Int(Date().timeIntervalSince1970)),
                    "files":[] as [Any],
                    "message_type" : FeedType.post.rawValue,
                    "sender_id": SharedManager.shared.getMPUserID()
                ]
                
                if self.isReply {
                    if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                        dict["replied_to_message_id"] = editObj.id
                    }
                }
                self.addNewMessage(dict: dict)
                self.viewReply.isHidden = true
                MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
                self.manageTextView()
                self.textViewDidChange(self.commentTextView)
                self.editchatModelObj = nil
            }
        }
    }
    
    func uploadAudioOnSockt(text : String ,audio_msg_url : String , identiferString : String , replied_to_message_id : String = ""){
        let dict:NSDictionary = ["body":text,"author_id":SharedManager.shared.getMPUserID(), "audio_msg_url":audio_msg_url, "uploads":[], "conversation_id":self.conversatonObj.conversationId, "identifierString":identiferString, "message_files":[], "audio_file":"", "replied_to_message_id" : replied_to_message_id]
        self.viewReply.isHidden = true
        LogClass.debugLog("uploadAudioOnSockt ===>")
        LogClass.debugLog(dict)
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
    }
    
    func scrollToBottom(isAnimated: Bool = true) {
        self.newMsgCounter = 0
        self.counterLbl.text = ""
        self.btnBottomView.isHidden = true
        
        if !chatModelArray.isEmpty {
            let lastIndexPath = IndexPath(row: self.chatModelArray.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: isAnimated)

//            let endpoint = self.chatModelArray.last?.id ?? ""
//            if let endpointID = Int(endpoint) {
//                SocketSharedManager.sharedSocket.markmessageSeen(valueMain: endpointID)
//            }
        }
    }

    
    @IBAction func bottomBtnClicked(_ sender:UIButton) {
        self.scrollToBottom()
        
    }
    
    func viewTranscript(fileID : String){
        
    }
    
    func addNewMessage(dict:[String: Any])   {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        var objects = MPMessage(context: moc)
        
        LogClass.debugLog("addNewMessage ===>")
        LogClass.debugLog(dict)
        var objChat = MPMessageModel.init()
        objChat.content = SharedManager.shared.ReturnValueAsString(value: dict["message"] as Any)
        objChat.senderId = SharedManager.shared.ReturnValueAsInt(value: dict["sender_id"] as Any)
        objChat.conversationId = SharedManager.shared.ReturnValueAsInt(value: dict["conversation_id"] as Any)
        objChat.identifier = SharedManager.shared.ReturnValueAsString(value: dict["identifier"] as Any)
        objChat.id = SharedManager.shared.ReturnValueAsInt(value: dict["identifier"] as Any)
        objChat.messageLabel = SharedManager.shared.ReturnValueAsString(value: dict["message_type"] as Any)
        
        objChat.createdAt = SharedManager.shared.getUTCDateTimeString()
        objects = MPMessageDBManager.mapMessageObj(msgObj: objects, msgModelObj: objChat)
        objects.toChat = self.conversatonObj
        if dict["replied_to_message_id"] != nil {
            if let IDString = (dict["replied_to_message_id"] as? String)  {
                for indexObj in self.chatModelArray {
                    if indexObj.id == IDString {
                        objects.replyTo = indexObj
                        objects.repliedToMessageId = indexObj.id
                        break
                    }
                }
            }
        }
        
        if let files = dict["files"] as? [[String: Any]] {
            var messageFiles : [MPMessageFileModel] = []
            for fileObj in files {
                var fileObjModal = MPMessageFileModel()
                fileObjModal.length = SharedManager.shared.ReturnValueAsString(value: fileObj["length"] as Any)
                fileObjModal.name = SharedManager.shared.ReturnValueAsString(value: fileObj["name"] as Any)
                fileObjModal.size = SharedManager.shared.ReturnValueAsString(value: fileObj["size"] as Any)
                fileObjModal.thumbnailUrl = SharedManager.shared.ReturnValueAsString(value: fileObj["thumbnail_url"] as Any)
                fileObjModal.type = SharedManager.shared.ReturnValueAsString(value: fileObj["type"] as Any)
                fileObjModal.url = SharedManager.shared.ReturnValueAsString(value: fileObj["url"] as Any)
                
                messageFiles.append(fileObjModal)
            }
            
            objChat.files = messageFiles
        }
        
        CoreDbManager.shared.saveContext()
        self.updateChatObject()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
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
    
//    func manageResponseOfChat(result:[PostCollectionViewObject]){
//        let myChatArray = ChatManager.shared.manageChatData(postObj: result)
//        for dict in myChatArray {
//            self.addNewMessage(dict: dict as! NSDictionary)
//        }
//    }
    
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

extension MPChatVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewGifOptions.isHidden = true
        self.viewCameraOptions.isHidden = true
        if scrollView.contentOffset.y <= 20  && isAPICall {
            currentOffset = self.chatTableView.contentOffset;
            if self.chatModelArray.count > 0 {
                if self.isLoadMore {
                    self.callRequestForMessages()
                }
            }
        }
    }
}

extension MPChatVC:UITableViewDelegate, UITableViewDataSource {
    
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
        
        switch dict.messageLabel.lowercased() {
        case "header":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatHeaderCell", for: indexPath) as? MPChatHeaderCell {
                cell.configureHeaderCell(dict: dict)
                return cell
            }
        case "notification":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatHeaderCell", for: indexPath) as? MPChatHeaderCell {
                cell.configureNotificationCell(dict: dict)
                return cell
            }

        case "offer_sent":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatOfferCell", for: indexPath) as? MPChatOfferCell {
                cell.configureReceiverOfferCell(dict: dict)
                return cell
            }
        case "offer_received":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatOfferCell", for: indexPath) as? MPChatOfferCell {
                cell.configureReceiverOfferCell(dict: dict, isShowActions: false)
                return cell
            }
        case "offer_accepted":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatOfferCell", for: indexPath) as? MPChatOfferCell {
                cell.configureSenderOfferCell(dict: dict)
                return cell
            }
        default:
            var authorID = -1
            
            if dict.senderId.count > 0 {
                authorID = Int(dict.senderId)!
            }
            
            var isReceiverCell = false
            if(dict.messageLabel == "buyer_detail" || dict.messageLabel == "quick_response")
            {
                isReceiverCell = true
            }
            
            if(authorID == SharedManager.shared.getMPUserID() && !isReceiverCell){
                return self.SenderMPChatCell(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return self.ReceiverMPChatCell(tableView: tableView, cellForRowAt: indexPath)
            }
        }
        
        return UITableViewCell()
        
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
}

extension MPChatVC : OptionsPopoverDelegate {
    
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
                if objMain.messageLabel == FeedType.image.rawValue {
//                    if Int(objMain.senderId) == SharedManager.shared.getUserID() {
//                        self.popOverController.reloadDataforImageMessage(isMine: true, showUnpin: objMain.is_pinned == "1")
//                    }else {
//                        self.popOverController.reloadDataforImageMessage(showUnpin: objMain.is_pinned == "1")
//                    }
                }else if objMain.messageLabel != FeedType.post.rawValue {
//                    if Int(objMain.senderId) == SharedManager.shared.getUserID() {
//                        self.popOverController.reloadDataforMediaMessage(isMine: true, showUnpin: objMain.is_pinned == "1")
//                    }else {
//                        self.popOverController.reloadDataforMediaMessage(showUnpin: objMain.is_pinned == "1")
//                    }
                    
                }else if Int(objMain.senderId) == SharedManager.shared.getMPUserID() {
//                    self.popOverController.reloadDatawithOwnMessage(showUnpin: objMain.is_pinned == "1")
                }else {
//                    self.popOverController.reloadDatawithOwnMessage(showUnpin: objMain.is_pinned == "1")
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
                if objMain.messageLabel != FeedType.post.rawValue {
                    if Int(objMain.senderId) == SharedManager.shared.getMPUserID() {
                        self.popOverController.reloadDataforMediaMessage(isMine: true)
                    }else {
                        self.popOverController.reloadDataforMediaMessage()
                    }
                }else if Int(objMain.senderId) == SharedManager.shared.getMPUserID() {
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
        var idDelete = [String]()
        var isShowError = -1
        for indexObj in indexArray {
            if (Int(self.chatModelArray[indexObj.row].senderId)! == SharedManager.shared.getMPUserID()){
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
            let dict = ["conversation_id":conversatonObj.conversationId , "multiple" : true , "ids":idDelete.joined(separator: ",")] as [String : Any]
            self.alertDel(paramStr: dict, indexArray: indexArray)
        }else if isShowError == 1 {
            self.isDeletedOther = true
            let dict = ["conversation_id":conversatonObj.conversationId , "multiple" : true , "ids":idDelete.joined(separator: ",")] as [String : Any]
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
                param["type"] = "delete_for_everyone"
                MPSocketSharedManager.sharedSocket.emitDeleteChatText(dict: param)
                self.delRow(indexArray: indexArray)
            })
            alert.addAction(allAction)
        }
        
        let meAction = UIAlertAction(title: "Delete for me".localized(), style: .default, handler: {_ in
            param["type"] = "delete_for_me"
            MPSocketSharedManager.sharedSocket.emitDeleteChatText(dict: param)
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

extension MPChatVC : DelegateTapMPChatCell {
    
    func delegateOpenforImage(chatObj: MPMessage, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforImage(chatObj: MPMessage, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforCopy(chatObj: MPMessage, indexRow: IndexPath){
        
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
    
    
    func delegateTapCellAction(chatObj: MPMessage, indexRow: IndexPath) {
        if self.isBlock {
            return
        }
        
        if let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatSelectionController") as? ChatSelectionController
        {
            vc.postType = chatObj.messageLabel
            vc.isMine = Int(chatObj.senderId) == SharedManager.shared.getMPUserID()
            vc.isPinned = chatObj.isPinned == "1"
            vc.isShowCopy = chatObj.content.count > 0
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
    
    func selectedChatAction(itemId: Int, messageObj: MPMessage, indexRow: IndexPath) {
        
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
    
    func editChatMessage(messageObj: MPMessage){
        if (Int(messageObj.senderId)! == SharedManager.shared.getMPUserID()){
            self.editchatModelObj = messageObj
            if let editObj = editchatModelObj, editObj.id.count > 0 {
                self.commentTextView.becomeFirstResponder()
                self.commentTextView.text = editObj.content
                self.commentTextView.textColor = UIColor.black
            }
        }else {
            DispatchQueue.main.async {
                SharedManager.shared.showAlert(message: "You can edit only your messages.".localized(), view: self)
            }
        }
    }
    
    func replyChatMessage(messageObj: MPMessage){
        if self.isBlock {
            return
        }
        
        self.editchatModelObj = messageObj
        
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            self.isReply = true
            self.viewReply.isHidden = false
            if Int(editObj.senderId) == SharedManager.shared.getMPUserID() {
                self.replylblUserName.text = "You".localized()
            }else {
                self.replylblUserName.text = editObj.receiverId
            }
            
            self.replyimgViewBG.isHidden = true
            self.replylbl.text = editObj.content
            
            if editObj.messageLabel == FeedType.post.rawValue {
                self.replylbl.text = editObj.content
            }else if editObj.messageLabel == FeedType.image.rawValue {
                self.replyimgViewBG.isHidden = false
                
                self.replyimgViewM.loadImageWithPH(urlMain:editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MPMessageFile).url : "")
                
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
                self.replylbl.text = "Photo".localized()
            }else if editObj.messageLabel == FeedType.video.rawValue {
                self.replyimgViewBG.isHidden = false
                
                self.replyimgViewM.loadImageWithPH(urlMain:editObj.toMessageFile?.count ?? 0 > 0 ? (editObj.toMessageFile?.first as! MPMessageFile).thumbnailUrl : "")
                
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
                self.replylbl.text = "Video".localized()
            }else if editObj.messageLabel == FeedType.file.rawValue {
                
                var messageArray = [MPMessageFile]()
                if editObj.toMessageFile?.count ?? 0 > 0 {
                    messageArray = editObj.toMessageFile?.allObjects as! [MPMessageFile]
                }
                if messageArray.count == 1  {
                    let dictMain = messageArray[0]
                    self.replylbl.text = dictMain.name
//                    let urlMain = URL.init(string: dictMain.url)
//                    self.replylbl.text = urlMain?.lastPathComponent
                }
            }else if editObj.messageLabel == FeedType.audio.rawValue {
                self.replylbl.text = "Audio".localized()
                self.replyimgViewBG.isHidden = false
                self.replyimgViewM.image = UIImage(named: "chat_microphone")
                self.view.labelRotateCell(viewMain: self.replyimgViewM)
            }
        }
        
    }
    
    func forwardChatMessage(messageObj: MPMessage){
        
        self.crossEdit()
        
        let vc = MPForwardMessageContactVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegateRefresh = self
        vc.sendingMessageArray = [messageObj]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pinChatMessage(objIndex: Int){
        
        if (self.chatModelArray[objIndex].isPinned == "1")
        {
            self.chatModelArray[objIndex].isPinned = "0"
            self.chatModelArray[objIndex].pinnedBy = ""
        }
        else {
            self.chatModelArray[objIndex].isPinned = "1"
            self.chatModelArray[objIndex].pinnedBy = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getMPUserID())
        }
        CoreDbManager.shared.saveContext()
        let parameters = ["conversation_id":self.conversatonObj.conversationId, "message_id":self.chatModelArray[objIndex].id] as [String : Any]
        MPSocketSharedManager.sharedSocket.pinMessage(dict: parameters)

        self.chatTableView.reloadRows(at: [IndexPath.init(row: objIndex, section: 0)], with: .automatic)
    }
    
    func copyChatMessage(messageObj: MPMessage){
        UIPasteboard.general.string = messageObj.content
    }
    
    func shareChatMessage(messageObj: MPMessage){
        
        self.editchatModelObj = messageObj
        
        if let editObj = editchatModelObj, editObj.id.count > 0 {
            let url = (editObj.toMessageFile?.first as? MPMessageFile)?.url ?? nil
            
            if editObj.messageLabel == FeedType.post.rawValue {
                showShareActivity(msg: editObj.content, image: nil, data: nil, url: nil, anyObject: nil, sourceRect: nil)
            } else {
                showShareActivity(msg: editObj.content, image: nil, data: nil, url:url , anyObject: nil, sourceRect: nil)
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
        
        var newArray = [MPMessage]()
        for indexObj in 0..<self.selectedRows.count {
            let objIndex = self.chatModelArray.firstIndex(where: { $0.id == self.selectedRows[indexObj]})
            newArray.append(self.chatModelArray[objIndex ?? 0])
        }
        
        let vc = MPForwardMessageContactVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegateRefresh = self
        vc.sendingMessageArray = newArray
        self.navigationController?.pushViewController(vc, animated: true)
        
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
            let dict = ["conversation_id":editObj.conversationId , "message_id":editObj.id] as [String:Any]
            MPSocketSharedManager.sharedSocket.emitDeleteChatText(dict: dict)
        }
    }
    
    func scrollToReplyMessage(messageObj: MPMessage){
        
        if let replyIndex = self.chatModelArray.firstIndex(where: { $0.id == messageObj.repliedToMessageId})
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
extension MPChatVC:UITextViewDelegate   {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let paste = UIPasteboard.general.string, text == paste {
            if UIPasteboard.general.string != nil{
                textView.text = UIPasteboard.general.string
                return false
            }
        }else if text.contains(UIPasteboard.general.string ?? "") {
            if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                textView.text = editObj.content
                var messageArray = [MPMessageFile]()
                if editObj.toMessageFile?.count ?? 0 > 0 {
                    messageArray = editObj.toMessageFile?.allObjects as! [MPMessageFile]
                }
                if  messageArray.count > 0 {
                    self.viewPreview.isHidden = false
                    self.viewVideoPreview.isHidden = true
                    self.imgViewPreview.isHidden = false
                    self.viewPreviewAudio.isHidden = true
                    if messageArray[0].type == FeedType.image.rawValue {
                        self.imgViewPreview.loadImageWithPH(urlMain:messageArray[0].url)
                        self.view.labelRotateCell(viewMain: self.imgViewPreview)
                    }else if messageArray[0].type == FeedType.video.rawValue {
                        self.viewVideoPreview.isHidden = false
                        self.imgViewPreview.loadImageWithPH(urlMain:messageArray[0].thumbnailUrl)
                        self.view.labelRotateCell(viewMain: self.imgViewPreview)
                    }else if messageArray[0].type == FeedType.file.rawValue {
                        
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
                    }else if messageArray[0].type == FeedType.post.rawValue {
                        
                        self.viewPreviewAudio.isHidden = false
                        self.imgViewPreview.isHidden = true
                    }
                }
            }
//            else {
//                if let editObj = self.editchatModelObj, editObj.id.count > 0 {
//
//                    if editObj.messageLabel == FeedType.post.rawValue {
//                        if editObj.audio_file.count > 0 {
//                            self.viewPreview.isHidden = false
//                            self.viewPreviewAudio.isHidden = false
//                            self.imgViewPreview.isHidden = true
//                        }
//                    }
//                }
//            }
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

extension MPChatVC: MPChatDelegate {
    
    func chatMessageReceived(res: NSArray) {
        var indexPathsToReload: [IndexPath] = []
        
        for dict in res {
            if let response = dict as? [String: Any],
               let data = response["data"] as? [[String: Any]] {
                for chatModelData in data {
                    let conversationID = SharedManager.shared.ReturnValueAsString(value: chatModelData["conversation_id"] as Any)
                    guard conversationID == conversatonObj.conversationId else {
                        continue
                    }

                    let messageModel = MPMessageModel(fromDictionary: chatModelData)
                    let identifierString = SharedManager.shared.ReturnValueAsString(value: messageModel.identifier as Any)
                    let messageID = SharedManager.shared.ReturnValueAsString(value: messageModel.id as Any)
                    
                    var isExist = false
                    if MPMessageDBManager.checkMessageExists(identifierString: identifierString, messageID: messageID) {
                        MPMessageDBManager.updateMessage(identifierString: identifierString, chatData: messageModel, messageID: messageID)
                        
                        if let index = chatModelArray.firstIndex(where: { $0.identifier == identifierString }) {
                            if let updatedMessage = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
                                chatModelArray[index] = updatedMessage
                                indexPathsToReload.append(IndexPath(row: index, section: 0))
                                isExist = true
                            }
                        }
                    } else {
                        MPMessageDBManager.saveMessageData(messageArr: [messageModel], chatListObj: self.conversatonObj)
                        if let newMessage = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
                            
                            let repliedToMessageId = newMessage.repliedToMessageId
                            if !repliedToMessageId.isEmpty, newMessage.replyTo == nil {
                                if let replyToMessage = chatModelArray.first(where: { $0.id == repliedToMessageId }) {
                                    newMessage.replyTo = replyToMessage
                                }
                            }
                            
                            let indexPath = IndexPath(row: chatModelArray.count, section: 0)
                            chatModelArray.append(newMessage)
                            chatTableView.insertRows(at: [indexPath], with: .automatic)
                        }
                    }

//                    if !btnBottomView.isHidden {
//                        self.newMsgCounter = isExist ? self.newMsgCounter : self.newMsgCounter + 1
//                        self.counterLbl.text = "" //self.newMsgCounter > 0 ? "+" + String(self.newMsgCounter) : ""
//                    } else {
//                        self.newMsgCounter = 0
//                        self.counterLbl.text = ""
//                    }
                }
            }
        }
        
        if(indexPathsToReload.count > 0)
        {
            chatTableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
        
        if btnBottomView.isHidden {
            scrollToBottom()
        }
    }

    func updateChatMessageReceived(res: NSArray) {
        var indexPathsToReload: [IndexPath] = []
        
        for dict in res {
            if let chatModelData = dict as? [String: Any] {
                let conversationID = SharedManager.shared.ReturnValueAsString(value: chatModelData["conversation_id"] as Any)
                guard conversationID == conversatonObj.conversationId else {
                    continue
                }
                
                let messageModel = MPMessageModel(fromDictionary: chatModelData)
                let identifierString = SharedManager.shared.ReturnValueAsString(value: messageModel.identifier as Any)
                let messageID = SharedManager.shared.ReturnValueAsString(value: messageModel.id as Any)
                
                var isExist = false
                if MPMessageDBManager.checkMessageExists(identifierString: identifierString, messageID: messageID) {
                    MPMessageDBManager.updateMessage(identifierString: identifierString, chatData: messageModel, messageID: messageID)
                    
                    if let index = chatModelArray.firstIndex(where: { $0.identifier == identifierString }) {
                        if let updatedMessage = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
                            chatModelArray[index] = updatedMessage
                            indexPathsToReload.append(IndexPath(row: index, section: 0))
                            isExist = true
                        }
                    }
                } else {
                    MPMessageDBManager.saveMessageData(messageArr: [messageModel], chatListObj: self.conversatonObj)
                    if let newMessage = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
                        
                        let repliedToMessageId = newMessage.repliedToMessageId
                        if !repliedToMessageId.isEmpty, newMessage.replyTo == nil {
                            if let replyToMessage = chatModelArray.first(where: { $0.id == repliedToMessageId }) {
                                newMessage.replyTo = replyToMessage
                            }
                        }
                        
                        let indexPath = IndexPath(row: chatModelArray.count, section: 0)
                        chatModelArray.append(newMessage)
                        chatTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                }
                
//                if !btnBottomView.isHidden {
//                    self.newMsgCounter = isExist ? self.newMsgCounter : self.newMsgCounter + 1
//                    self.counterLbl.text = "" //self.newMsgCounter > 0 ? "+" + String(self.newMsgCounter) : ""
//                } else {
//                    self.newMsgCounter = 0
//                    self.counterLbl.text = ""
//                }
            }
        }

        if(indexPathsToReload.count > 0) {
            chatTableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
        
        if btnBottomView.isHidden {
            scrollToBottom()
        }
    }
    
    func updateChatMessage() {
        self.updateChatObject()
    }
    
//    func feedCommentReceivedFromSocket(res: NSDictionary) {  // For Delete Message
//        if isDeletedOther {
//            return
//        }
//
//        if self.conversatonObj.conversationId == self.ReturnValueCheck(value: res["conversation_id"] as Any) {
//
//            var index = -1
//            for  indexObj in 0..<self.chatModelArray.count {
//                if self.chatModelArray[indexObj].id == self.ReturnValueCheck(value: res["message_id"] as Any) {
//                    index = indexObj
//                    break
//                }
//            }
//
//            if index != -1 {
//                self.chatModelArray.remove(at: index)
//
//                self.chatTableView.beginUpdates()
//                self.chatTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
//                self.chatTableView.endUpdates()
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self.selectedRows.removeAll()
//                    self.isSelectionEnable = false
//
//
//                    self.chatTableView.reloadData()
//                }
//            }
//        }
//    }
    
    func chatMessageDelete(res: NSArray){
        
        for dict in res {
            if let response = dict as? [String : Any], let dataArr = response["data"] as? [[String: Any]] {
                for data in dataArr {
                    let messageId = SharedManager.shared.ReturnValueAsString(value: data["message_id"] as Any)
                    if let index = chatModelArray.firstIndex(where: { $0.id == messageId }) {
                        self.chatModelArray.remove(at: index)
                        self.chatTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
                    }
                }
                
                //                if self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any) == self.conversatonObj.conversationId {
                //
                //                    for indexObj in 0..<self.chatModelArray.count {
                //
                //                        if self.chatModelArray[indexObj].id == self.ReturnValueCheck(value: data["message_id"] as Any) {
                //
                //                            self.chatModelArray.remove(at: indexObj)
                //                            self.chatTableView.deleteRows(at: [IndexPath.init(row: indexObj, section: 0)], with: .automatic)
                //                            break
                //                        }
                //                    }
                //                }
            }
        }
    }
    
    func pinnedMessageDelegate(res: NSDictionary) {
        
        if let chatmodel = res as? [String : Any] {
            
            if self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any) == self.conversatonObj.conversationId && self.ReturnValueCheck(value: chatmodel["sender_id"] as Any) == String(SharedManager.shared.getMPUserID()) {
                
                let pinnedBy = SharedManager.shared.ReturnValueAsString(value: chatmodel["pinned_by"] as Any)
                let messageID = SharedManager.shared.ReturnValueAsString(value: chatmodel["id"] as Any)
                
                if let index = chatModelArray.firstIndex(where: { $0.id == messageID }) {
                    
                    self.chatModelArray[index].isPinned = !pinnedBy.isEmpty ? "1" : "0"
                    self.chatModelArray[index].pinnedBy = pinnedBy
                    
                    self.chatTableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                }
            }
        }
    }
    
    func reactMessageDelegate(res: NSDictionary) {
        
        if let chatmodel = res as? [String : Any] {
            
            if self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any) == self.conversatonObj.conversationId
            {
                let userID = SharedManager.shared.ReturnValueAsString(value: chatmodel["reacted_by"] as Any)
                let messageID = SharedManager.shared.ReturnValueAsString(value: chatmodel["message_id"] as Any)
                let reactionName = SharedManager.shared.ReturnValueAsString(value: chatmodel["reaction"] as Any)
                let userName = SharedManager.shared.ReturnValueAsString(value: chatmodel["firstname"] as Any) + " " + SharedManager.shared.ReturnValueAsString(value: chatmodel["lastname"] as Any)
                let profileImage = SharedManager.shared.ReturnValueAsString(value: chatmodel["profile_image"] as Any)
                MPReactionDBManager.reactionHandling(action: "", selectedReaction: reactionName, messageID: messageID, userID: userID, name: userName, profileImage: profileImage)
                
                if let index = chatModelArray.firstIndex(where: { $0.id == messageID }) {
                    
                    if let updatedMessage = MPMessageDBManager.getMessageFromDb(messageID: messageID) {
                        chatModelArray[index] = updatedMessage
                        
                        self.chatTableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
    }
}


extension MPChatVC {
    
    func videoSave(urlMain : URL){
        
        let asset = AVURLAsset(url: urlMain, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        var cgImage : CGImage
        
        cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        
        
        DispatchQueue.main.async {
            
            var newData = [String : Any]()
            newData["Image"] = UIImage.init(cgImage: cgImage)
            newData["ImageURL"] = ""
            newData["Type"] = FeedType.video.rawValue
            newData["URL"] = urlMain.path
            
            
            self.videoObj["Image"] = UIImage.init(cgImage: cgImage)
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


extension MPChatVC : TLPhotosPickerViewControllerDelegate {
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
        
        let idStr = String(Int(Date().timeIntervalSince1970))
        
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let messageObj = MPMessage(context: moc)
        messageObj.uploadingStatus = "uploading"
        
        let msgCOFile = MPMessageFile(context: moc)
        
        if fileType == "video" {
            messageObj.messageLabel = FeedType.video.rawValue
        }else if fileType == "attachment" {
            messageObj.messageLabel = FeedType.file.rawValue
        }else if fileType == "audio" {
            messageObj.messageLabel = FeedType.audio.rawValue
        }else {
            messageObj.messageLabel = FeedType.image.rawValue
        }
        
        messageObj.senderId = String(SharedManager.shared.getMPUserID())
        messageObj.createdAt = SharedManager.shared.getUTCDateTimeString()
        messageObj.identifier = idStr
        messageObj.id = idStr
        
        if let editObj = self.editchatModelObj, editObj.id.count > 0 {
            messageObj.repliedToMessageId = editObj.id
            messageObj.replyTo = editObj
        }
        
        var chatUploadModal = MPChatUploadModal()
        chatUploadModal.fileType = fileType
        chatUploadModal.fileName = filePath.components(separatedBy: "/").last ?? ""
        chatUploadModal.filePath = URL(string: filePath)
        chatUploadModal.mimeType = filePath.mimeType()
        
        var messageFile = MPMessageFileModel()
        
        if fileType == "attachment" {
            messageFile.type = FeedType.file.rawValue
            messageFile.thumbnailUrl = nil
            messageFile.url = filePath
            
        } else if fileType == "audio" {
            messageFile.type = FeedType.audio.rawValue
            messageFile.thumbnailUrl = nil
            messageFile.url = filePath
            
        } else if fileType == "video" {
            messageFile.type = FeedType.video.rawValue
            let fileName = SharedManager.shared.getIdentifierForMessage() + ".jpg"
            SharedManager.shared.saveImage(image: imageMAin, fileName: fileName)
            messageFile.thumbnailUrl = fileName
            messageFile.url = filePath
            
            chatUploadModal.thumbnailPath = SharedManager.shared.getPathFromDocumentDirectory(fileName: fileName)
            chatUploadModal.thumbnailMimeType = fileName.mimeType()
            chatUploadModal.thumbnailName = fileName
        } else {
            let fileName = SharedManager.shared.getIdentifierForMessage() + ".jpg"
            SharedManager.shared.saveImage(image: imageMAin, fileName: fileName)
            messageFile.type = FeedType.image.rawValue
            messageFile.url = filePath
            messageFile.thumbnailUrl = fileName
            
            chatUploadModal.filePath = SharedManager.shared.getPathFromDocumentDirectory(fileName: fileName)
            chatUploadModal.mimeType = fileName.mimeType()
            chatUploadModal.fileName = fileName
        }
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        messageObj.content = myComment
        messageObj.toChat = self.conversatonObj
        messageObj.addToToMessageFile(MPMessageDBManager.mapMessageFile(messageFileObj: msgCOFile, messageFile: messageFile, isSaveLocal: true))
        if self.isReply {
            for indexObj in self.chatModelArray {
                if let editObj = self.editchatModelObj, editObj.id.count > 0 {
                    if indexObj.id == editObj.id {
                        messageObj.replyTo = indexObj
                        messageObj.repliedToMessageId = indexObj.id
                        break
                    }
                }
            }
        }
        
        CoreDbManager.shared.saveContext()
        _ = MPMessageDBManager.checkMessageExists(identifierString: messageObj.identifier, messageID: "")
        let chatUploading = MPChatUploadManager.init()
        chatUploading.chatID = self.conversatonObj.conversationId
        chatUploading.identifier = idStr
        chatUploading.chatUploadModal = chatUploadModal
        chatUploading.callingServiceToUploadOnS3()
        SharedManager.shared.mpChatUploadingDict[messageObj.identifier] = chatUploading
        
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
        
        var indexRow : MPMessage!
        for indexObj in self.chatModelArray {
            if indexObj.createdAt == newTime {
                indexRow = indexObj
                break
            }
        }
        
        if indexRow.replyTo != nil {
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
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getMPUserID(), "uploads":urlSendArray, "conversation_id":self.conversatonObj.conversationId, "identifierString":newTimeP, "message_files":[], "audio_file":"" ]
        //        "replied_to_message_id" : "1019635"]
        self.viewReply.isHidden = true
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        self.editchatModelObj = nil
        self.manageTextView()
        
        self.viewReply.isHidden = true
        self.selectedRows.removeAll()
        self.isSelectionEnable = false
    }
    
    func UploadGifOnSocket(mainURL : String){
        
        var filesDict = [String: Any]()
        filesDict["name"] = nil
        filesDict["original_url"] = mainURL
        filesDict["thumbnail_url"] = nil
        filesDict["size"] = nil
        filesDict["type"] = "Image/gif"
        filesDict["length"] = nil
        
        let myComment = ChatManager.shared.validateTextMessage(comment: self.commentTextView.text)
        
        let dict:[String: Any] = [
            "message" : myComment,
            "files":[filesDict],
            "conversation_id":self.conversatonObj.conversationId,
            "identifier":String(Int(Date().timeIntervalSince1970)),
            "message_type" : PostType.image.rawValue,
            "sender_id": SharedManager.shared.getMPUserID()
        ]
        self.viewReply.isHidden = true
        self.addNewMessage(dict: dict)
        
        MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
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

extension MPChatVC  {
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
    
    @IBAction func attachFileAction(sender : UIButton){
        self.didPressDocumentShare()
        
    }
}

extension MPChatVC : GifImageSelectionDelegate {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        if gifDict.count > 0 {
            for (_, gifObj) in gifDict {
                let newTime = SharedManager.shared.getCurrentDateString()
                self.UploadGifOnSocket(mainURL: gifObj.url)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.viewCameraOptions.isHidden = true
        self.viewGifOptions.isHidden = true
    }
}



extension MPChatVC: UIDocumentPickerDelegate {
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

extension MPChatVC {
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

extension MPChatVC : SocketDelegateForGroup   {
    
    func didSocketGroupThemeUpdate(data: [String : Any]) {
        LogClass.debugLog("didSocketGroupThemeUpdate ==>")
        LogClass.debugLog(data)
        self.updateChatObject()
    }
    
    func didSocketRemoveContactGroup(data: [String : Any])  {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversationId {
            let userLeft = self.ReturnValueCheck(value: data["user_who_left"] as Any)
            if userLeft ==  String(SharedManager.shared.getMPUserID()) {
                self.ShowAlertWithPop(message: "Admin remove you from this group.".localized())
            }else if userLeft.count > 0 {
                let userID = SharedManager.shared.ReturnValueAsString(value: userLeft)
                if userID != "" {
                    if let member = MPChatDBManager.getChatMember(id: userLeft) {
                        self.conversatonObj.removeFromToMember(member)
                        CoreDbManager.shared.saveContext()
                    }
                }
            }
        }
    }
    
    func didSocketGroupUpdate(data: [String : Any]) {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversationId {
            let newName = self.ReturnValueCheck(value: data["new_group_name"] as Any)
            let newImage = self.ReturnValueCheck(value: data["new_group_image"] as Any)
            if newName.count > 0 {
                self.conversatonObj.conversationName = newName
                self.navigationController?.addTitle(self, title: newName, selector: #selector(self.showProfile))
            }else {
                self.conversatonObj.groupImage = newImage
            }
        }
    }
    
    func didSocketContactGroup(data: [String : Any]) {
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.conversatonObj.conversationId {
            if let arrayUSer = data["members"] as? [[String : Any]] {
                for _ in arrayUSer {
                    
                }
            }
        }
    }
}

extension MPChatVC : DelegateChatPreview  {
    
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


extension MPChatVC:MPReactionSenderDelegate {

    func showReactionListDelegate(messageID:String, messageObj:MPMessage) {
        if let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "MPReactionViewController") as? MPReactionViewController {
            vc.message_id = messageID
            vc.message = messageObj
            self.sheetController = SheetViewController(controller: vc, sizes: [.fixed(480)])
            self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self.present(self.sheetController, animated: true, completion: nil)
        }
    }
    
    func reactionTapped(indexP: IndexPath, messageObj: MPMessage) {
        let userID = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getMPUserID())
        let userName = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getFullName())
        let userProfileImage = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getProfileImage())
        let param = ["conversation_id":self.conversatonObj.conversationId, "message_id":messageObj.id, "reacted_by":SharedManager.shared.getMPUserID(), "reaction":SharedManager.shared.arrayChatGif[indexP.row]] as [String : Any]
        MPReactionDBManager.reactionHandling(action: "add_reaction", selectedReaction: param["reaction"] as! String, messageID: messageObj.id, userID: userID, name: userName, profileImage: userProfileImage)
        MPSocketSharedManager.sharedSocket.addReaction(dictionary: param)
        self.updateChatObject()
    }
    
}

extension MPChatVC
{
    func SenderMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let sendCell = tableView.dequeueReusableCell(withIdentifier: "SenderMPChatCell", for: indexPath) as! SenderMPChatCell
        sendCell.loadData(dict: dict, index: indexPath)
        sendCell.delegateTap = self
        sendCell.reactionDelegate = self
        
        sendCell.viewSelected.isHidden = true
        sendCell.viewUnSelectedTick.isHidden = true
        if self.isSelectionEnable {
            sendCell.viewSelected.isHidden = false
            sendCell.viewUnSelectedTick.isHidden = false
            sendCell.viewSelectedTick.isHidden = true
            if self.selectedRows.contains(dict.id) {
                sendCell.viewSelectedTick.isHidden = false
            }
        }
        
        sendCell.selectionStyle = .none
        
        sendCell.onSwipeToReply = {
            self.replyChatMessage(messageObj: dict)
        }
        
        sendCell.onScrollToReplyMessage = {
            self.scrollToReplyMessage(messageObj: dict)
        }
        
        return sendCell
    }
}

//MARK:  Recive Cells
extension MPChatVC
{
    func ReceiverMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let receiveCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverMPChatCell", for: indexPath) as! ReceiverMPChatCell
        receiveCell.loadData(dict: dict, index: indexPath)
        receiveCell.delegateTap = self
        receiveCell.reactionDelegate = self
        
        receiveCell.viewSelected.isHidden = true
        receiveCell.viewUnSelectedTick.isHidden = true
        if self.isSelectionEnable {
            receiveCell.viewSelected.isHidden = false
            receiveCell.viewUnSelectedTick.isHidden = false
            receiveCell.viewSelectedTick.isHidden = true
            if self.selectedRows.contains(dict.id) {
                receiveCell.viewSelectedTick.isHidden = false
            }
        }
        
        receiveCell.selectionStyle = .none
        
        receiveCell.onSwipeToReply = {
            self.replyChatMessage(messageObj: dict)
        }
        
        receiveCell.onScrollToReplyMessage = {
            self.scrollToReplyMessage(messageObj: dict)
        }
        
        return receiveCell
    }
}


