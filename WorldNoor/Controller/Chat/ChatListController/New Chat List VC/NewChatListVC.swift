//
//  NewChatListVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 31/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets
import CoreData
import Alamofire

class NewChatListVC : UIViewController {
    
    @IBOutlet var OnlineUserCollection : UICollectionView!
    @IBOutlet var tblViewChat : UITableView!
    
    @IBOutlet var segmentcontrol : BetterSegmentedControl!
    @IBOutlet var lblNoOnlineUser : UILabel!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var noConversation : UILabel!

    var sheetController = SheetViewController()
    var tbleArray:[Chat] = []
    var tempArray:[Chat] = []
    
    var arrayOnlineUser:[FriendChatModel] = []
    var searchActive = false
    var isAPICall = false
    var isLoadMore = true
    var pageCount = 1
    let cdCoreManager = ChatDBManager()
    let adPlacement = 10
    var isShowMarketplace = false
    var marketplaceCount = 0
    var marketplaceIcon = ""
    var marketplaceTitle = ""
    var marketplaceLastUpdated = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketSharedManager.sharedSocket.receiveChatMessage()
        SocketSharedManager.sharedSocket.deleteChatMessage()
        self.OnlineUserCollection.register(UINib.init(nibName: "OnlineUserCell", bundle: nil), forCellWithReuseIdentifier: "OnlineUserCell")
        self.tblViewChat.estimatedRowHeight = 100
        self.tblViewChat.rowHeight = UITableView.automaticDimension
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.tblViewChat.addGestureRecognizer(longPressRecognizer)
        self.tblViewChat.register(UINib.init(nibName: "ChatAdCell", bundle: nil), forCellReuseIdentifier: "ChatAdCell")
        
//        self.callRequestForSellingItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if arrayOnlineUser.isEmpty {
            self.getAllFriend()
        }
        self.tbleArray.removeAll()
        self.fetchFromLocalDB()
        self.setUpUI()
        self.tblViewChat.rotateViewForLanguage()
        self.pageCount = 1
        callingGetGroupService(isloading: true)
        SocketSharedManager.sharedSocket.commentDelegate = self
        SocketSharedManager.sharedSocket.userValueDelegate = self
    }
    
    func setUpUI(){
        self.navigationItem.title = "Chats".localized()
        self.searchBar.placeholder = "Search".localized()
        self.searchBar.backgroundColor = .clear
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.layer.borderWidth = 1
        self.searchBar.layer.borderColor = UIColor.clear.cgColor
        self.searchBar.delegate = self
        self.manageNavigation()
        
        segmentcontrol.segments = LabelSegment.segments(withTitles: ["Inbox".localized(), "Community".localized()],
                                                        normalTextColor: UIColor(red: 0.48, green: 0.48, blue: 0.51, alpha: 1.00))
    }
    
    func fetchFromLocalDB() {
        self.tbleArray = self.cdCoreManager.fetchAllChatFromDB()
        noConversation.isHidden = true
        if self.tbleArray.count == 0 {
            noConversation.isHidden = false
        }
        self.tempArray = self.tbleArray
        self.tblViewChat.reloadData()
        self.getHintsFromTextField(sender: searchBar)
    }
    
    func getAllFriend() {
        let parameters = ["action": "user/friends","token": SharedManager.shared.userToken() , "is_online" : "1"]
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                self.arrayOnlineUser.removeAll()
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                LogClass.debugLog("res ==>")
                LogClass.debugLog(res)
                self.arrayOnlineUser.removeAll()
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if let newRes = res as? [[String:Any]]
                {
                    for indexFriend in newRes{
                        
                        let friendObjMain = FriendChatModel.init(fromDictionary: indexFriend)
                        self.arrayOnlineUser.append(friendObjMain)
                    }
                }
                self.OnlineUserCollection.reloadData()
            }
        }, param: parameters)
    }
    
    func callRequestForSellingItem() {
        let baseURL = "https://marketplace.worldnoor.com/api/sellingItems"
        let headers: HTTPHeaders = [
            "token": SharedManager.shared.userToken()
        ]
        let params = ["categoryPage": 1, "is_mobile": true] as [String : Any]
        Alamofire.request(baseURL, method: .post, parameters: params, headers: headers).responseJSON { response in
            guard response.error == nil else {
                return
            }
            switch response.result {
            case .success(let result):
                printLog(result)
                AESDataDecryptor.decryptAESData(encryptedHexString: result as? String ?? .emptyString) { responseString in
                    LogClass.debugLog(responseString)
                    
                    if let jsonData = responseString?.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let categoryResult = try decoder.decode(MarketPlaceForYouDataResponse.self, from: jsonData)
                            LogClass.debugLog(categoryResult)
                            
                            if categoryResult.data.returnResp.user.id > 0 {
                                SharedManager.shared.mpUserObj = categoryResult.data.returnResp.user
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    } else {
                        print("Failed to convert JSON string to Data.")
                    }
                }
            case .failure(let error):
                printLog(error.localizedDescription)
            }
        }
    }
    
    func manageNavigation() {
        
        let viewNavigation = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 50))
        viewNavigation.backgroundColor = .clear
        
        let viewLeftBtn = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        viewLeftBtn.backgroundColor = .clear
        
        
        let imgLeft = UIImageView.init(frame: CGRect.init(x: 10, y: 10, width: 25, height: 25))
        imgLeft.image = UIImage(named: "settingsBlack")
        
        let buttonLeft = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        buttonLeft.backgroundColor = .clear
        buttonLeft.setBackgroundImage(UIImage(named: ""), for: .normal)
        buttonLeft.addTarget(self, action: #selector(self.chatSettingsClicked), for: .touchUpInside)
        viewLeftBtn.addSubview(imgLeft)
        viewLeftBtn.addSubview(buttonLeft)
        
        let viewRightBtn = UIView.init(frame: CGRect.init(x: 41, y: 0, width: 40, height: 40))
        viewRightBtn.backgroundColor = .clear
        
        let imgRight = UIImageView.init(frame: CGRect.init(x: 41, y: 0, width: 40, height: 40))
        imgRight.image = UIImage(named: "CreateNew")
        
        let buttonRight = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        buttonRight.backgroundColor = .clear
        buttonRight.setBackgroundImage(UIImage(named: ""), for: .normal)
        buttonRight.addTarget(self, action: #selector(self.addContactClicked), for: .touchUpInside)
        viewLeftBtn.addSubview(imgRight)
        viewRightBtn.addSubview(buttonRight)
        
        
        viewNavigation.addSubview(viewLeftBtn)
        viewNavigation.addSubview(viewRightBtn)
        let navigationView = UIBarButtonItem(customView: viewNavigation)
        self.navigationItem.rightBarButtonItems  = [navigationView]
    }
    
    @objc func addContactClicked(){
        
        let contactViewController = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "ContactListViewController") as! ContactListViewController
        contactViewController.groupID = "-1"
        self.navigationController?.pushViewController(contactViewController, animated: false)
    }
    
    @objc func chatSettingsClicked(){
        let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatSettingsVC") as! ChatSettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func callingGetGroupService(isloading : Bool = false) {
        let userToken = SharedManager.shared.userToken()
        
        // For Marketplace
//        var parameters = ["action": "conversations_list", "token":userToken, "serviceType":"Node", "per_page" : "10"] as [String : Any]
        var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node", "per_page" : "10"] as [String : Any]
        parameters["page"] = String(pageCount)
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                LogClass.debugLog(res)
                LogClass.debugLog("success ===> callingGetGroupService")
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    if (res as! String).contains("specific conversation") != nil {

                    }else {
                        SharedManager.shared.showAlert(message: res as! String, view: self)
                    }
                    
                }else {
                    
                    let newArray = res as! [AnyObject]
                    var someObj = [ConversationModel]()
                    for indexObj in newArray {
                        
                        // For Marketplace
//                        let postType = SharedManager.shared.ReturnValueAsString(value: indexObj["post_type"] as Any)
//                        if(postType == "marketplace")
//                        {
//                            self.isShowMarketplace = true
//                            let userID = SharedManager.shared.ReturnValueAsInt(value: indexObj["id"] as Any)
//                            SharedManager.shared.mpUserObjId = userID
//                            
//                            self.marketplaceIcon = SharedManager.shared.ReturnValueAsString(value: indexObj["icon"] as Any)
//                            self.marketplaceTitle = SharedManager.shared.ReturnValueAsString(value: indexObj["name"] as Any)
//                            self.marketplaceLastUpdated = SharedManager.shared.ReturnValueAsString(value: indexObj["last_updated"] as Any)
//                            self.marketplaceCount = SharedManager.shared.ReturnValueAsInt(value: indexObj["count"] as Any)
//                            continue
//                        }
                        
                        someObj.append(ConversationModel.init(fromDictionary: indexObj as! [String : Any]))
                    }
                    if newArray.count == 0 {
                        self.isLoadMore = false
                    }
                    self.cdCoreManager.saveChatData(chatData: someObj)
                    self.fetchFromLocalDB()
                    
                }
            }
        }, param:parameters)
    }
    
    
    func isFeedReachEnd(index:Int){
        if isLoadMore {
            let feedCurrentCount = self.tbleArray.count
            if index == feedCurrentCount-1 {
                self.pageCount = self.pageCount + 1
                self.loadNextPage()
            }
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
    
    func loadNextPage() {
        DispatchQueue.global(qos: .background).async {
            
            let userToken = SharedManager.shared.userToken()
            var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node", "per_page" : "10"]
            parameters["page"] = String(self.pageCount)
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)               
                case .success(let res):
                    LogClass.debugLog(res)
                    LogClass.debugLog("success ===> callingGetGroupService")
                    if res is Int {
                        LogClass.debugLog("success ===> 1")
                        AppDelegate.shared().loadLoginScreen()
                    }else if res is String {
                        LogClass.debugLog("success ===> 2")
                        if (res as! String).contains("specific conversation") != nil {
                        } else {
                            SharedManager.shared.showAlert(message: res as! String, view: self)
                        }
                    }else {
                        let newArray = res as! [AnyObject]
                        var someObj = [ConversationModel]()
                        for indexObj in newArray {
                            someObj.append(ConversationModel.init(fromDictionary: indexObj as! [String : Any]))
                        }
                        if newArray.count == 0 {
                            self.isLoadMore = false
                        }
                        self.cdCoreManager.saveChatData(chatData: someObj)
                        self.fetchFromLocalDB()
                    }
                }
            }, param:parameters)
        }
    }
}

extension NewChatListVC : SocketOnlineUser {
    
    func userValueChange(data: [Any] , isOnline:Bool) {
        
        var arrayIndexPath = [IndexPath]()
        var arrayIndex = 0
        var indexRow = 0
        LogClass.debugLog("data ===>")
        LogClass.debugLog(data)
        if isOnline {
            for obj in data {
                let friendObjMain = FriendChatModel.init(fromDictionary: obj as! [String : Any])
                let indexObj = self.arrayOnlineUser.firstIndex(where: {$0.id == friendObjMain.id})
                
                if indexObj == nil {
                    self.arrayOnlineUser.insert(friendObjMain, at: 0)
                    arrayIndexPath.append(IndexPath.init(row: indexRow, section: 0))
                    indexRow = indexRow + 1
                }
            }
            
            self.OnlineUserCollection.reloadData()
            self.getAllFriend()
        }else {
            for indexObj in data {
                let friendObjMain = FriendChatModel.init(fromDictionary: indexObj as! [String : Any])
                
                let indexObj = self.arrayOnlineUser.firstIndex(where: {$0.id == friendObjMain.id})
                if indexObj != nil {
                    arrayIndex = indexObj!
                    arrayIndexPath.append(IndexPath.init(row: indexObj!, section: 0))
                }
            }
            
            if self.arrayOnlineUser.count > 0
            {
                self.arrayOnlineUser.remove(at:arrayIndex)
            }
            
            self.OnlineUserCollection.reloadData()
        }
    }
}

extension NewChatListVC:feedCommentDelegate{
    func chatMessageReceived(res: NSArray) {
        for dict in res {
            if let chatmodel = dict as? [String : Any] {
                let objChat = UserChatModel.init(fromDictionary: chatmodel)
                let identifierString = objChat.identifierString
                let messageID = objChat.message_id
                if(DBMessageManager.checkMessageExists(identifierString: identifierString, messageID: messageID))
                {
                    DBMessageManager.updateMessage(identifierString: identifierString, chatData: objChat, messageID: messageID)
                    fetchFromLocalDB()
                }else {
                    if let chatObj = cdCoreManager.getChatFromDb(conversationID: objChat.conversation_id) {
                        chatObj.last_updated = objChat.messageTime
                        chatObj.latest_message = objChat.body
                        chatObj.latest_message_time = objChat.messageTime
                        chatObj.is_unread = "1"
                        chatObj.unread_messages_count = String((Int(chatObj.unread_messages_count) ?? 0) + 1)
                        DBMessageManager.saveMessageData(messageArr: [objChat], chatListObj: chatObj)
                        CoreDbManager.shared.saveContext()
                        fetchFromLocalDB()
                    }
                    else {
                        self.callingGetGroupService()
                    }
                }
            }
        }
    }
}

extension NewChatListVC:UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tbleArray = tempArray
        self.tblViewChat.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(self.getHintsFromTextField(sender:)),
            object: searchBar)
        self.perform(
            #selector(self.getHintsFromTextField(sender:)),
            with: searchBar,
            afterDelay: 0.5)
        
        return true
    }
    
    @objc func getHintsFromTextField(sender: UISearchBar) {
        guard let text = searchBar.text else {return}
        if text.isEmpty {
            searchActive = false
            self.tbleArray = tempArray
            self.tblViewChat.reloadData()
            return
        }
        searchActive = true
        let filteredArray = self.tempArray.filter { chat in
            let displayName = chat.nickname.isEmpty == false ? chat.nickname : chat.name
            return displayName.lowercased().contains(text.lowercased())
        }
        self.tbleArray.removeAll()
        self.tbleArray = filteredArray
        self.tblViewChat.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        if text.isEmpty {
            searchActive = false
            self.tbleArray = tempArray
            self.tblViewChat.reloadData()
        }
    }
}
