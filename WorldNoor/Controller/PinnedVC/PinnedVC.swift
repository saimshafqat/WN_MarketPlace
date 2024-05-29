//
//  PinnedVC.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class PinnedVC: UIViewController {
    var userToken = ""
    var chatModelArray = [Message]()
    var editchatModelObj:Message?
    var isAPICall = false
    var isTranslationOn = true
    var isLoadMore = true
    var conversatonObj = Chat()
    var startingPoint = ""
    var currentOffset : CGPoint!
    var scroolToIndex = 0
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var cstTbleTop: NSLayoutConstraint!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var btnMoveBottom: UIButton!
    @IBOutlet var btnBottomView: UIView!
    
    //MARK: - Ovveride
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.registerCustomCells([
            "SenderChatCell",
            "ReceiverChatCell"
        ])

        self.title = "Pinned Messages".localized()
        self.userToken = SharedManager.shared.userToken()
        self.chatTableView.estimatedRowHeight = 300
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.keyboardDismissMode = .interactive
        self.chatTableView.isEditing = false
        self.manageCallBackHandler()
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
        let parameters:NSDictionary = ["action": "messenger/chat/pinnedMessages", "token":userToken, "serviceType":"Node", "conversation_id":self.conversatonObj.conversation_id, "pinned_by":SharedManager.shared.getUserID()]
        self.callingService(parameters: parameters as! [String : Any])
        
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
    
    func callingService(parameters:[String:Any]) {
        
        if self.chatModelArray.isEmpty {
            Loader.startLoading()
        }
        
        RequestManager.fetchDataPost(Completion: { response in
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
                        }
                    } else {
                        var count = 0
                        var languageChange = "en"
                        if let languageID = SharedManager.shared.userBasicInfo["language_id"] as? Int {
                            languageChange = FeedCallBManager.shared.getLanguageCode(languageID: String(languageID))
                        }
                        if let mainDict = res as? [[String : Any]] {
                            count = mainDict.count
                            if self.startingPoint.count == 0 {
                                var tempUserObj = [UserChatModel]()
                                for indexObj in mainDict {
                                    let userObj = UserChatModel.init(fromDictionary: indexObj)
                                    tempUserObj.append(userObj)
                                }
                                DBMessageManager.saveMessageData(messageArr: tempUserObj, chatListObj: self.conversatonObj)
                                self.updateChatObject()
                            } else {
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
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatModelArray.count-1, section: 0), at: .bottom, animated: false)
                                
                            } else {
                                self.chatTableView.scrollToRow(at: IndexPath(row: self.scroolToIndex, section: 0), at: .top, animated: false)
                            }
                        }
                        if self.chatModelArray.count > 0 {
                            self.startingPoint = self.chatModelArray.first!.id
                        }
                        if self.chatModelArray.count > 0 {
                            if self.chatModelArray.count > 0 {
                                let endpoint = self.chatModelArray[self.chatModelArray.count - 1].id
                                if endpoint != "" {
                                    if Int(endpoint) != nil {
                                        SocketSharedManager.sharedSocket.markmessageSeen(valueMain: Int(endpoint)! )
                                    }
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
        chatModelArray.removeAll()
        conversatonObj = ChatDBManager().getChatFromDb(conversationID: self.conversatonObj.conversation_id) ?? Chat()
        if(conversatonObj.toMessage?.allObjects.count ?? 0 > 0) {
            let pinnedMessages = conversatonObj.toMessage?.filtered(using: NSPredicate(format: "is_pinned == %@", "1")) as? Set<Message>
            if pinnedMessages?.count ?? 0 > 0 {
                chatModelArray = pinnedMessages!.sorted(by: {$0.id < $1.id})
                chatTableView.reloadData()
            }else {
                chatModelArray.removeAll()
                chatTableView.reloadData()
            }
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

extension PinnedVC : UIScrollViewDelegate {
    
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

extension PinnedVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModelArray.count
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
}

extension PinnedVC : DelegateTapCell {
    func delegatRowValueChange(indexPath: IndexPath, selectecion: Bool) {
        
    }
    
    func delegatRowSelectedValueChange(indexPath: IndexPath) {
        
    }
    
    func delegateOpenforImage(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforImage(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func delegateTapCellActionforCopy(chatObj: Message, indexRow: IndexPath){
        
    }
    
    func delegateTapCellAction(chatObj: Message, indexRow: IndexPath) {
        self.unPinSheet(indexObj: indexRow)
    }
    
    func unPinSheet(indexObj:IndexPath) {
        let alert = UIAlertController(title: "Unpin this message".localized(),
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        let meAction = UIAlertAction(title: "Unpin".localized(), style: .default, handler: {_ in
            let parameters = ["conversation_id":self.conversatonObj.conversation_id, "pinned_by":SharedManager.shared.getUserID(), "message_id":self.chatModelArray[indexObj.row].id] as [String : Any]
            SocketSharedManager.sharedSocket.pinMessage(dict: parameters)
            self.chatModelArray[indexObj.row].is_pinned = "0"
            self.chatModelArray[indexObj.row].pinnedBy = ""
            CoreDbManager.shared.saveContext()
            self.updateChatObject()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
        })
        alert.addAction(meAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {})
    }
    
}
