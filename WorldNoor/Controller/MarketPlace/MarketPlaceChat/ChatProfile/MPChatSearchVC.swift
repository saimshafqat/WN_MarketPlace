//
//  MPChatSearchVC.swift
//  WorldNoor
//
//  Created by Awais on 24/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatSearchVC: UIViewController {
    var userToken = ""
    var chatModelArray = [MPMessage]()
    var editchatModelObj:MPMessage?
    var isSelectionEnable = false
    var isAPICall = false
    var isTranslationOn = true
    var isLoadMore = true
    var selectedRows = [String]()
    var conversatonObj = MPChat()
    var startingPoint = ""
    var currentOffset : CGPoint!
    var scroolToIndex = 0
    var videoObj = [String : Any]()
    var searchText = ""
    
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
        self.title = self.conversatonObj.conversationName
        self.userToken = SharedManager.shared.userToken()
        self.chatTableView.estimatedRowHeight = 300
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.keyboardDismissMode = .interactive
        self.chatTableView.isEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDataFromDB()
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
    
    func delegateRefresh(){
        
        self.chatModelArray.removeAll()
        startingPoint = ""
        self.isLoadMore = true
        self.chatTableView.reloadData()
    }
    
    func fetchDataFromDB() {
        chatModelArray.removeAll()
        conversatonObj = MPChatDBManager().getChatSearchFromDb(conversationID: self.conversatonObj.conversationId, searchStr: searchText) ?? MPChat()
        if(conversatonObj.toMessage?.allObjects.count ?? 0 > 0) {
            let messages = conversatonObj.toMessage?.filtered(using: NSPredicate(format: "content CONTAINS[c] %@", searchText)) as? Set<MPMessage>
            if messages?.count ?? 0 > 0 {
                chatModelArray = messages!.sorted(by: {$0.id < $1.id})
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

extension MPChatSearchVC : UIScrollViewDelegate {
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

extension MPChatSearchVC: UITableViewDelegate, UITableViewDataSource {
    
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

//MARK:  Send Cells
extension MPChatSearchVC
{
    func SenderMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let sendCell = tableView.dequeueReusableCell(withIdentifier: "SenderMPChatCell", for: indexPath) as! SenderMPChatCell
        sendCell.loadData(dict: dict, index: indexPath)
        sendCell.isPinned = true
        
        sendCell.viewSelected.isHidden = true
        sendCell.viewUnSelectedTick.isHidden = true
        
        sendCell.selectionStyle = .none
        
        return sendCell
    }
}

//MARK:  Recive Cells
extension MPChatSearchVC
{
    func ReceiverMPChatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict = self.chatModelArray[indexPath.row]
        
        let receiveCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverMPChatCell", for: indexPath) as! ReceiverMPChatCell
        receiveCell.loadData(dict: dict, index: indexPath)
        receiveCell.isPinned = true
        
        receiveCell.viewSelected.isHidden = true
        receiveCell.viewUnSelectedTick.isHidden = true
        
        receiveCell.selectionStyle = .none
        return receiveCell
    }
}
