//
//  MPPinnedVC.swift
//  WorldNoor
//
//  Created by Awais on 24/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire

class MPPinnedVC: UIViewController {
    var userToken = ""
    var chatModelArray = [MPMessage]()
    var editchatModelObj:MPMessage?
    var isAPICall = false
    var isTranslationOn = true
    var isLoadMore = true
    var conversatonObj = MPChat()
    var startingPoint = ""
    var currentOffset : CGPoint!
    var scrollToIndex = 0
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var cstTbleTop: NSLayoutConstraint!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var btnMoveBottom: UIButton!
    @IBOutlet var btnBottomView: UIView!
    @IBOutlet var noConversation : UILabel!
    
    //MARK: - Ovveride
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTableView.registerCustomCells([
            "SenderMPChatCell",
            "ReceiverMPChatCell",
            "MPChatHeaderCell",
            "MPChatOfferCell"
        ])

        self.title = "Pinned Messages".localized()
        self.userToken = SharedManager.shared.userToken()
        self.chatTableView.estimatedRowHeight = 300
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.keyboardDismissMode = .interactive
        self.chatTableView.isEditing = false
        self.manageCallBackHandler()
        self.callRequestForMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateChatObject()
        scrollToBottom()
        self.tabBarController?.tabBar.isHidden = true
        let autoTranslation = self.ReturnValueCheck(value: SharedManager.shared.userBasicInfo["auto_translate"] as Any)
        if  autoTranslation.count == 0 || autoTranslation == "1" {
            self.isTranslationOn = true
        }else if autoTranslation == "0" {
            self.isTranslationOn = false
        }
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
        
        var params : [String: Any] = ["is_pinned":true]
        
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
        if let messages = conversatonObj.toMessage?.filtered(using: NSPredicate(format: "isPinned == %@", "1")) as? Set<MPMessage>, !messages.isEmpty {
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
            chatModelArray.removeAll()
            chatTableView.reloadData()
        }
    }
    
    func scrollToBottom() {
        self.counterLbl.text = ""
        self.btnBottomView.isHidden = true
        if chatModelArray.count > 0{
            DispatchQueue.main.async {
                let lastIndexPath = IndexPath(row: self.chatModelArray.count-1, section: 0)
                self.chatTableView.scrollToRow(at: lastIndexPath,
                                               at: UITableView.ScrollPosition.bottom,
                                               animated: true)
            }
        }
    }
    
    @IBAction func bottomBtnClicked(_ sender:UIButton) {
        self.scrollToBottom()
    }
}

extension MPPinnedVC : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 20  && isAPICall {
            currentOffset = self.chatTableView.contentOffset;
        }
        
        if let lastIndex = chatTableView.indexPathsForVisibleRows?.last  {
            if (self.chatModelArray.count) - 1 >= lastIndex.row + 1 {
                btnBottomView.isHidden = false
                self.view.bringSubviewToFront(btnMoveBottom)
            } else {
                btnBottomView.isHidden = true
                self.counterLbl.text = ""
            }
            
        }
    }
}

extension MPPinnedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModelArray.count
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
}

extension MPPinnedVC : DelegateTapMPChatCell {
    func delegatRowValueChange(indexPath: IndexPath, selectecion: Bool) {
        
    }
    
    func delegatRowSelectedValueChange(indexPath: IndexPath) {
        
    }
    
    func delegateOpenforImage(chatObj: MPMessage, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforImage(chatObj: MPMessage, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforCopy(chatObj: MPMessage, indexRow: IndexPath){
        
    }
    
    func delegateTapCellAction(chatObj: MPMessage, indexRow: IndexPath) {
        self.unPinSheet(indexObj: indexRow)
    }
    
    func unPinSheet(indexObj:IndexPath) {
        let alert = UIAlertController(title: "Unpin this message".localized(),
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        let meAction = UIAlertAction(title: "Unpin".localized(), style: .default, handler: {_ in
            
            self.chatModelArray[indexObj.row].isPinned = "0"
            self.chatModelArray[indexObj.row].pinnedBy = ""
            
            CoreDbManager.shared.saveContext()
            let parameters = ["conversation_id":self.conversatonObj.conversationId, "message_id":self.chatModelArray[indexObj.row].id] as [String : Any]
            MPSocketSharedManager.sharedSocket.pinMessage(dict: parameters)
            
            self.updateChatObject()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
        })
        alert.addAction(meAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {})
    }
}

//MARK:  Send Cells
extension MPPinnedVC
{
    func SenderMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let sendCell = tableView.dequeueReusableCell(withIdentifier: "SenderMPChatCell", for: indexPath) as! SenderMPChatCell
        sendCell.loadData(dict: dict, index: indexPath)
        sendCell.isPinned = true
        sendCell.delegateTap = self
        
        sendCell.viewSelected.isHidden = true
        sendCell.viewUnSelectedTick.isHidden = true
        
        sendCell.selectionStyle = .none
        
        return sendCell
    }
}

//MARK:  Recive Cells
extension MPPinnedVC
{
    func ReceiverMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let receiveCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverMPChatCell", for: indexPath) as! ReceiverMPChatCell
        receiveCell.loadData(dict: dict, index: indexPath)
        receiveCell.isPinned = true
        receiveCell.delegateTap = self
        
        receiveCell.viewSelected.isHidden = true
        receiveCell.viewUnSelectedTick.isHidden = true
        
        receiveCell.selectionStyle = .none
        return receiveCell
    }
}
