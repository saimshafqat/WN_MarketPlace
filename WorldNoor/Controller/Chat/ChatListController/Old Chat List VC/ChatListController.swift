
//
//  ChatListController.swift
//  WorldNoor
//
//  Created by Raza najam on 12/17/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class ChatListController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var viewNoPost: UIView!

    var contactArray:[Chat] = []
    var tbleArray:[Chat] = []
    var isAPICall = false
    var isLoadMore = true
    var pageCount = 1
    var cdChatList:ChatDBManager = ChatDBManager()
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat".localized()
        self.navigationItem.title = Const.ContactViewTitle.localized()
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangeNotification),name: NSNotification.Name(Const.KLangChangeNotif),object: nil)
        SocketSharedManager.sharedSocket.receiveChatMessage()
        SocketSharedManager.sharedSocket.deleteChatMessage()
        self.manageUI()
        self.chatTableView.estimatedRowHeight = 100
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        chatTableView.addSubview(self.refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshingManually()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tbleArray.removeAll()
            self.contactArray.removeAll()
            self.isLoadMore = true
            self.pageCount = 1
            self.callingGetGroupService(isloading: false)
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func languageChangeNotification(){
        self.isLoadMore = true
        self.pageCount = 1
        self.callingGetGroupService(isloading: true)
    }
    
    func manageUI(){
        let newButton = UIBarButtonItem(title: "New".localized(), style: .plain, target: self, action: #selector(self.addContactClicked))
        let settingButton = UIBarButtonItem(image: UIImage(named: "MoreSettings"), style: .plain, target: self, action: #selector(self.chatSettingsClicked))
        self.navigationItem.rightBarButtonItems  = [newButton, settingButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        self.viewNoPost.isHidden = true
        super.viewWillAppear(animated)
        self.chatTableView.keyboardDismissMode = .onDrag
        if self.contactArray.count == 0 {
            self.tbleArray.removeAll()
            self.contactArray.removeAll()
            self.pageCount = 1
            self.callingGetGroupService(isloading: true)
        }
        
        self.chatTableView.rotateViewForLanguage()
        SocketSharedManager.sharedSocket.delegateGroup = self
        SocketSharedManager.sharedSocket.commentDelegate = self
        isLoadMore = true
    }
    
    func fetchFromLocalDB() {
        
        
    }
    
    func loadNextPage() {
        DispatchQueue.global(qos: .background).async {
         
            let userToken = SharedManager.shared.userToken()
            var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node"  , "per_page" : "10"]
            parameters["page"] = String(self.pageCount)
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
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

                        }else {
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
                        // Manage Saving in coredata...
                        self.contactArray = self.cdChatList.fetchAllChatFromDB()
                        self.tbleArray = self.cdChatList.fetchAllChatFromDB()
                        self.chatTableView.reloadData()
                    }
                }
            }, param:parameters)
        }
    }
    
    func callingGetGroupService(isloading : Bool = false) {
        
        if isloading {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }

        self.viewNoPost.isHidden = true
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node"  , "per_page" : "10"]
        parameters["page"] = String(pageCount)
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog("error ===> callingGetGroupService")
                LogClass.debugLog(error)
SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                LogClass.debugLog(res)
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    if (res as! String).contains("specific conversation") != nil {
                        self.viewNoPost.isHidden = false
                    }else {
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
                     self.contactArray = self.cdChatList.fetchAllChatFromDB()
                     self.tbleArray = self.contactArray
                    
                    if self.tbleArray.count == 0{
                        self.viewNoPost.isHidden = false
                    }else {
                        self.viewNoPost.isHidden = true
                    }
                    self.chatTableView.reloadData()
                }
            }
        }, param:parameters)
    }

    func isFeedReachEnd(indexPath:IndexPath){

        if isLoadMore {
            let feedCurrentCount = self.tbleArray.count
            if indexPath.row == feedCurrentCount-1 {
                self.pageCount = self.pageCount + 1
                self.loadNextPage()
            }

        }
    }
    
    @objc func addContactClicked(){
        let contactViewController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.ContactViewIdentifier) as! ContactViewController
        contactViewController.groupID = "-1"
        self.navigationController?.pushViewController(contactViewController, animated: false)
    }
    
    @objc func chatSettingsClicked(){
        let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "ChatSettingsVC") as! ChatSettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatListController:UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.deleteConversation(IdMain: self.tbleArray[indexPath.row].conversation_id , rowIndex: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tbleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            let dict = self.tbleArray[indexPath.row]
            cell.manageContactList( dict: dict)
            cell.btnUserProfile.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
            cell.btnUserProfile.tag = indexPath.row
            cell.lblMessageCount.text = dict.unread_messages_count
            cell.viewMessageCount.isHidden = false
            if cell.lblMessageCount.text!.count > 0 {
                if Int(cell.lblMessageCount.text!)! < 1 {
                    cell.lblMessageCount.text = ""
                    cell.viewMessageCount.isHidden = true
                }
            }
            cell.imgViewMute.isHidden = true
            
            if dict.is_mute.count > 0 {
                if dict.is_mute == "1" {
                    cell.imgViewMute.isHidden = false
                }
            }
            
            self.isFeedReachEnd(indexPath: indexPath)
            return cell
        }
        
        self.isFeedReachEnd(indexPath: indexPath)
        return UITableViewCell()
    }
    
    @objc func openProfile(sender : UIButton){
        let chatDict = self.tbleArray[sender.tag]
        if  chatDict.conversation_type == "group" {
            let viewMain = self.GetView(nameVC: "GroupProfileNewVC", nameSB: "Notification") as! GroupProfileNewVC
            viewMain.chatObj = chatDict
            self.navigationController?.pushViewController(viewMain, animated: true)
        }else {
            let emptyDict = [String : Any]()
            let userObj = SearchUserModel.init(fromDictionary: emptyDict)
            userObj.author_name = chatDict.name 
            userObj.conversation_id = chatDict.conversation_id 
            userObj.profile_image = chatDict.profile_image
            userObj.user_id = chatDict.member_id 
            userObj.username = chatDict.name 
            let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            vcProfile.otherUserID = chatDict.member_id
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dict = self.tbleArray[indexPath.row]
        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
        contactGroup.conversatonObj = dict
        self.navigationController?.pushViewController(contactGroup, animated: true)

    }
    
    func deleteConversation(IdMain : String , rowIndex : IndexPath){
        let userToken = SharedManager.shared.userToken()
        let urlMain = "conversation/local/delete/" + IdMain
        let parameters = ["action":urlMain , "token":userToken, "serviceType":"Node" ] as [String : Any]
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    ChatDBManager.deleteChatObj(chat_id: IdMain)
                    self.tbleArray.remove(at: rowIndex.row)
                    self.chatTableView.beginUpdates()
                    self.chatTableView.deleteRows(at: [rowIndex], with: .automatic)
                    self.chatTableView.endUpdates()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.chatTableView.reloadData()
                    }
                }
            }
        }, param:parameters)
    }
}

extension ChatListController : SocketDelegateForGroup{
    func didSocketGroupThemeUpdate(data: [String : Any]) {
        LogClass.debugLog("didSocketGroupThemeUpdate ==>")
        LogClass.debugLog(data)
    }
    func didSocketRemoveContactGroup(data: [String : Any]){
        
        let userID = SharedManager.shared.getUserID()
        for indexObj in 0..<self.tbleArray.count {
            if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.tbleArray[indexObj].conversation_id {
                let userLeft = self.ReturnValueCheck(value: data["user_who_left"] as Any)
                
                if String(userID) == self.ReturnValueCheck(value: data["user_who_left"] as Any) {
                    self.tbleArray.remove(at: indexObj)
                }
            }
        }
        
        self.chatTableView.reloadData()
        
    }
    
    func didSocketGroupUpdate(data: [String : Any]) {
        for indexObj in 0..<self.contactArray.count {
            if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.contactArray[indexObj].conversation_id {
                
                let newName = self.ReturnValueCheck(value: data["new_group_name"] as Any)
                let newImage = self.ReturnValueCheck(value: data["new_group_image"] as Any)
                
                if newName.count > 0 {
                    self.contactArray[indexObj].name =  newName
                }else {
                    self.contactArray[indexObj].group_image = newImage
                }
            }
        }
        
        for indexObj in 0..<self.tbleArray.count {
            if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.tbleArray[indexObj].conversation_id {
                
                let newName = self.ReturnValueCheck(value: data["new_group_name"] as Any)
                let newImage = self.ReturnValueCheck(value: data["new_group_image"] as Any)
                
                if newName.count > 0 {
                    self.tbleArray[indexObj].name =  newName
                }else {
                    self.tbleArray[indexObj].group_image =  newImage
                }
            }
        }
        self.chatTableView.reloadData()
    }
    
    func didSocketContactGroup(data: [String : Any]) {
        
        for var indexObj in 0..<self.contactArray.count {
            if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.contactArray[indexObj].conversation_id {
                if let arrayUSer = data["members"] as? [[String : Any]] {
                    for indexUser in arrayUSer {
                        var isFound = false
                        
                        let test = self.contactArray[indexObj].toMember
                    }
                }
            }else {
                self.callingGetGroupService(conversationID: self.ReturnValueCheck(value: data["conversation_id"] as Any))
            }
        }
        
        for var indexObj in 0..<self.tbleArray.count {
            if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.tbleArray[indexObj].conversation_id {
                if let arrayUSer = data["members"] as? [[String : Any]] {
                    for indexUser in arrayUSer {

                    }
                }
            }
        }
        
        self.chatTableView.reloadData()
    }
    
    func callingGetGroupService(conversationID : String) {
        
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversations?fetch_one=1", "token":userToken, "serviceType":"Node", "convo_id":conversationID ]
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):

SwiftMessages.apiServiceError(error: error)
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    
                    let newArray = res as! [AnyObject]
                    self.chatTableView.reloadData()
                }
            }
        }, param:parameters)
    }
}

extension ChatListController   : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tbleArray = self.contactArray.filter{
            ($0.name).range(of: searchText,
                            options: .caseInsensitive,
                            range: nil,
                            locale: nil) != nil
        }
        if searchText.count == 0 {
            self.tbleArray = self.contactArray
        }
        self.chatTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ChatListController:feedCommentDelegate    {
    func chatMessageDelete(res: NSArray) {

    }
    
    func feedCommentReceivedFromSocket(res: NSDictionary) {
        
    }
    
    func chatMessageReceived(res: NSArray) {
        var indexMain = -1
        
        for dict in res {
            if let chatmodel = dict as? [String : Any] {
                let commingMessageConversationID = self.ReturnValueCheck(value: chatmodel["conversation_id"] as Any)
                for var indexObj in 0..<self.contactArray.count {
                    let conversationID = self.contactArray[indexObj].conversation_id
                    if conversationID == commingMessageConversationID {
                        indexMain = indexObj
                        self.contactArray[indexObj].latest_message = self.ReturnValueCheck(value: chatmodel["body"] as Any)
                        break
                    }
                }
            }
        }
        
        if indexMain != -1 {
            let itemAt = self.contactArray.remove(at: indexMain)
            self.contactArray.insert(itemAt, at: 0)
            self.tbleArray.removeAll()
            for indexObj in self.contactArray {
                self.tbleArray.append(indexObj)
            }
            self.chatTableView.reloadData()
        }
    }
}

extension UIViewController {
    func ReturnValueCheck(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
}

extension Dictionary where Key:NSObject, Value:AnyObject {
    mutating func addSomething(forKey key:Key, value: Value) {
        self[key] = value
    }
}

