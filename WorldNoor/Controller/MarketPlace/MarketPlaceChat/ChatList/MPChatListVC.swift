//
//  MPChatListVC.swift
//  WorldNoor
//
//  Created by Awais on 12/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets
import Alamofire

class MPChatListVC: UIViewController {

    @IBOutlet var tblViewChat : UITableView!
    @IBOutlet var noConversation : UILabel!

    var sheetController = SheetViewController()
    var tbleArray:[MPChat] = []
    
    var isAPICall = false
    var isLoadMore = true
    var pageCount = 1
    var totalPages = 1
    let cdCoreManager = MPChatDBManager()
    let adPlacement = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MPSocketSharedManager.sharedSocket.delegate = self
        if MPSocketSharedManager.sharedSocket.manager == nil && MPSocketSharedManager.sharedSocket.manager?.status != .connected && MPSocketSharedManager.sharedSocket.manager?.status != .connecting{
            MPSocketSharedManager.sharedSocket.establishConnection()
            LogClass.debugLog("========MP SOCKET WAS NOT CONNECTED============")
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.tblViewChat.addGestureRecognizer(longPressRecognizer)
        self.tblViewChat.register(UINib.init(nibName: "ChatAdCell", bundle: nil), forCellReuseIdentifier: "ChatAdCell")
        self.tblViewChat.register(UINib.init(nibName: "MPChatListCell", bundle: nil), forCellReuseIdentifier: "MPChatListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tbleArray.removeAll()
        self.fetchFromLocalDB()
        self.setUpUI()
        self.tblViewChat.rotateViewForLanguage()
        self.pageCount = 1
        callRequestForConversation()
        SocketSharedManager.sharedSocket.commentDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setUpUI(){
        self.navigationItem.title = "Marketplace inbox".localized()
    }
    
    func fetchFromLocalDB() {
        self.tbleArray = self.cdCoreManager.fetchAllChatFromDB()
        noConversation.isHidden = true
        if self.tbleArray.count == 0 {
            noConversation.isHidden = false
        }
        self.tblViewChat.reloadData()
    }
    
    func callRequestForConversation() {
        
        MPRequestManager.shared.request(endpoint: "conversations?page=\(pageCount)&perPage=10") { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        let conversationResult = try decoder.decode(MPConversationResponse.self, from: jsonData)
                        self.totalPages = conversationResult.data.totalPages
                        
                        if conversationResult.data.conversations.count == 0 {
                            self.isLoadMore = false
                        }
                        
                        self.cdCoreManager.saveChatData(chatData: conversationResult.data.conversations)
                        self.fetchFromLocalDB()
                        
                        LogClass.debugLog(conversationResult)
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
        
//        let baseURL = "https://marketplace.worldnoor.com/api/conversations?page=\(pageCount)&perPage=10"
//        let headers: HTTPHeaders = [
//            "token": SharedManager.shared.marketplaceUserToken()
//        ]
//
//        Alamofire.request(baseURL, method: .get, headers: headers).responseJSON { response in
//            guard response.error == nil else {
//                return
//            }
//            switch response.result {
//            case .success(let result):
//                LogClass.debugLog(result)
//                AESDataDecryptor.decryptAESData(
//                    encryptedHexString: result as? String ?? .emptyString
//                ) { responseString in
//                    LogClass.debugLog(responseString)
//                    if let jsonData = responseString?.data(using: .utf8) {
//                        do {
//                            let decoder = JSONDecoder()
//                            let conversationResult = try decoder.decode(MPConversationResponse.self, from: jsonData)
//                            self.totalPages = conversationResult.data.totalPages
//                            
//                            if conversationResult.data.conversations.count == 0 {
//                                self.isLoadMore = false
//                            }
//                            
//                            self.cdCoreManager.saveChatData(chatData: conversationResult.data.conversations)
//                            self.fetchFromLocalDB()
//                            
//                            LogClass.debugLog(conversationResult)
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
    
    func isFeedReachEnd(index:Int){
        let feedCurrentCount = self.tbleArray.count
        if index == feedCurrentCount-1 && self.pageCount < self.totalPages {
            self.pageCount = self.pageCount + 1
            self.callRequestForConversation()
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tblViewChat)
            if let indexPath = self.tblViewChat.indexPathForRow(at: touchPoint) {
                self.openSheet(indexPath: indexPath)
            }
        }
    }
}

extension MPChatListVC:feedCommentDelegate{
    func chatMessageReceived(res: NSArray) {
//        for dict in res {
//            if let chatmodel = dict as? [String : Any] {
//                let objChat = UserChatModel.init(fromDictionary: chatmodel)
//                let identifierString = objChat.identifierString
//                let messageID = objChat.message_id
//                if(DBMessageManager.checkMessageExists(identifierString: identifierString, messageID: messageID))
//                {
//                    DBMessageManager.updateMessage(identifierString: identifierString, chatData: objChat, messageID: messageID)
//                    fetchFromLocalDB()
//                }else {
//                    if let chatObj = cdCoreManager.getChatFromDb(conversationID: objChat.conversation_id) {
//                        chatObj.last_updated = objChat.messageTime
//                        chatObj.latest_message = objChat.body
//                        chatObj.latest_message_time = objChat.messageTime
//                        chatObj.is_unread = "1"
//                        chatObj.unread_messages_count = String((Int(chatObj.unread_messages_count) ?? 0) + 1)
//                        DBMessageManager.saveMessageData(messageArr: [objChat], chatListObj: chatObj)
//                        CoreDbManager.shared.saveContext()
//                        fetchFromLocalDB()
//                    }
//                    else {
//                        self.callRequestForConversation()
//                    }
//                }
//            }
//        }
    }
}

extension MPChatListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let adsCount = Int(self.tbleArray.count/adPlacement)
        return (self.tbleArray.count + adsCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > 0 && indexPath.row % adPlacement == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatAdCell", for: indexPath) as? ChatAdCell {
                
                DispatchQueue.main.async {
                    cell.bannerView.rootViewController = self
                }
                
                cell.reloadData(parentview: self,indexMain: indexPath)
                
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MPChatListCell", for: indexPath) as! MPChatListCell
            
            let chatIndex = indexPath.row - (indexPath.row / adPlacement)
            
            let dict = self.tbleArray[chatIndex]
            cell.configureCell(dict: dict)
            cell.btnUserProfile.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
            cell.btnUserProfile.tag = chatIndex

            self.isFeedReachEnd(index: chatIndex)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func openProfile(sender : UIButton){
        
        let chatDict = self.tbleArray[sender.tag]
        
//        let viewMain = self.GetView(nameVC: "GroupProfileNewVC", nameSB: "Notification") as! GroupProfileNewVC
//        viewMain.chatObj = chatDict
//        self.navigationController?.pushViewController(viewMain, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row > 0 && indexPath.row % adPlacement == 0 {
            //ad cell
            return
        }
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        let dict = self.tbleArray[chatIndex]
        
        var dic = [String:String]()
        dic["id"] = dict.conversationId
        dic["is_read"] = "1"
        self.tbleArray[chatIndex].isRead = true
        MPSocketSharedManager.sharedSocket.markConversationReadUnRead(dictionary: dic)
        
        let chatVC = MPChatVC.instantiate(fromAppStoryboard: .Chat)
        chatVC.conversatonObj = dict
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func deleteConversation(convId: String, rowIndex: Int){
        
        var dic = [String:Any]()
        dic["id"] = convId

        MPSocketSharedManager.sharedSocket.deleteConversation(dictionary: dic) { returnValue in
            if let dataDict = returnValue as? [[String : Any]] {
                if dataDict.count > 0 {
                    if let statusCode =  dataDict[0]["status"] as? Int {
                        if statusCode == 200 {
                            MPChatDBManager.deleteChatObj(chat_id: convId)
                            self.tbleArray.remove(at: rowIndex)
                            
                            let indexPath = IndexPath(row: rowIndex, section: 0)
                            self.tblViewChat.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    func leaveGroup(convId: String, rowIndex: Int){
        
        var dic = [String:Any]()
        dic["conversation_id"] = convId

        MPSocketSharedManager.sharedSocket.leaveGroup(dictionary: dic) { returnValue in
            if let dataDict = returnValue as? [[String : Any]] {
                if dataDict.count > 0 {
                    if let statusCode =  dataDict[0]["status"] as? Int {
                        if statusCode == 200 {
                            self.tbleArray[rowIndex].isGroupLeave = true
                        }
                    }
                }
            }
        }
    }

    func openSheet(indexPath : IndexPath){
        let pagerController = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "MPChatActionVC") as! MPChatActionVC
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        pagerController.chatObj = self.tbleArray[chatIndex]
        pagerController.indexPath = indexPath
        pagerController.chatActionDelegate = self
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(300), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
}

extension MPChatListVC : MPChatActionDelegate {
    
    func chatActionChoose(action: MPChatActionModel, indexPath: IndexPath) {
        self.sheetController.dismissVC {
            
        }
        
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        
        switch action.id {
        case .Mutenotification , .UnMutenotification:
            var switchValue = 1
            if self.tbleArray[chatIndex].mutedAt.count > 0 {
                switchValue = 0
            }
            
            var dic = [String:Any]()
            dic["id"] = self.tbleArray[chatIndex].conversationId
            dic["is_mute"] = switchValue
            dic["muted_till"] = 0

            MPSocketSharedManager.sharedSocket.markConversationMuteUnMute(dictionary: dic) { returnValue in
                if let dataDict = returnValue as? [[String : Any]] {
                    if dataDict.count > 0 {
                        if let statusCode =  dataDict[0]["status"] as? Int {
                            if statusCode == 200 {
                                self.tbleArray[chatIndex].mutedAt = switchValue == 1 ? "1" : ""
                                
                                let indexPath = IndexPath(row: chatIndex, section: 0)
                                self.tblViewChat.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
            }

        case .Profile:
            let btnMain = UIButton.init()
            btnMain.tag = chatIndex
            self.openProfile(sender: btnMain)

        case .Delete:
            let alert = UIAlertController(title: "Delete chat".localized(),
                                          message: "Are you sure you want to delete this chat?".localized(),
                                          preferredStyle: UIAlertController.Style.alert)

            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: {_ in
                let btnMain = UIButton.init()
                btnMain.tag = chatIndex
                self.deleteConversation(convId: self.tbleArray[chatIndex].conversationId, rowIndex: chatIndex)
            })

            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
            })

            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: {})

        case .MarkRead, .MarkasRead:

            var dic = [String:String]()
            dic["id"] = self.tbleArray[chatIndex].conversationId

            if self.tbleArray[chatIndex].isRead == false {
                dic["is_read"] = "1"
                self.tbleArray[chatIndex].isRead = true
            }else {
                dic["is_read"] = "0"
                self.tbleArray[chatIndex].isRead = false
            }

            let indexPath = IndexPath(row: chatIndex, section: 0)
            self.tblViewChat.reloadRows(at: [indexPath], with: .automatic)
            MPSocketSharedManager.sharedSocket.markConversationReadUnRead(dictionary: dic)
        case .Archive:
            var dic = [String:Any]()
            dic["conversation_id"] = self.tbleArray[chatIndex].conversationId
            dic["is_archive"] = 0

            MPSocketSharedManager.sharedSocket.markConversationArchive(dictionary: dic) { returnValue in
                if let dataDict = returnValue as? [[String : Any]] {
                    if dataDict.count > 0 {
                        if let statusCode =  dataDict[0]["status"] as? Int {
                            if statusCode == 200 {
                                self.tbleArray[chatIndex].isArchive = true
                                CoreDbManager.shared.saveContext()
                                self.tbleArray.remove(at: chatIndex)
                                let indexPath = IndexPath(row: chatIndex, section: 0)
                                self.tblViewChat.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
            }
            
        case .Leave:
            let alert = UIAlertController(title: "Leave Group".localized(),
                                          message: "Are you sure to leave this group?".localized(),
                                          preferredStyle: UIAlertController.Style.alert)

            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: {_ in
                let btnMain = UIButton.init()
                btnMain.tag = chatIndex
                self.leaveGroup(convId: self.tbleArray[chatIndex].conversationId, rowIndex: chatIndex)
            })

            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
            })

            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: {})
            
        default:
            LogClass.debugLog("Default ===>")
        }
    }
    
    func blockUser(chatObj:MPChat){
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":chatObj.conversationId]
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
//                    chatObj.has_blocked_me = "true"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                } else {
//                    chatObj.has_blocked_me = "true"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                }
            }
        }, param:parameters)
    }
    
    func showReportProfile(otherUserID : String){
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.isPost = ReportType.User
        reportDetail.delegate = self
        
        let otherUserObj = UserProfile.init()
        otherUserObj.username = otherUserID
        reportDetail.userObj = otherUserObj
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension MPChatListVC : DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        
    }
}

extension MPChatListVC: MPSocketDelegate {
    func didSocketConnected(data: [Any]) {
        LogClass.debugLog("MP didSocketConnected ===>")
        LogClass.debugLog(data)
        
    }
    
    func didSocketDisConnected(data: [Any]) {
        LogClass.debugLog("MP didSocketDisConnected ===>")
        LogClass.debugLog(data)
    }
    
    func didReceiveCallstatusAck(data: [String : Any]) {
        LogClass.debugLog("MP didReceiveCallstatusAck ===>")
        LogClass.debugLog(data)
    }
    
}
