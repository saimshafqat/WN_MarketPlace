//
//  ArchivedChatsVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

class ArchivedChatsVC: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var viewEmpty : UIView!
    var isLoadMore = true
    var pageCount = 1
    var tbleArray:[Chat] = []
    var contactArray:[Chat] = []
    var sheetController = SheetViewController()
    var cdCoreManager = ChatDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Archived Chats".localized()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.contactArray.count == 0 {
            self.contactArray.removeAll()
            self.pageCount = 1
            self.loadNextPage()
            
        }
        fetchArchivedConversation()
        isLoadMore = true
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.rotateViewForLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fetchArchivedConversation(){
        self.tbleArray = self.cdCoreManager.fetchAllChatFromDB(convType: .archive)
        self.tableView.reloadData()
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                self.openSheet(indexPath: indexPath)
            }
        }
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
    
    func loadNextPage() {
        DispatchQueue.global(qos: .background).async {
            let userToken = SharedManager.shared.userToken()
            var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node"  , "per_page" : "10", "is_archive":"1"]
            parameters["page"] = String(self.pageCount)
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error) 
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    }else if res is String {
                        if (res as! String).contains("specific conversation") != nil {
                            self.viewEmpty.isHidden = true
                            if self.tbleArray.count == 0 {
                                self.viewEmpty.isHidden = false
                            }
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
                        self.cdCoreManager.saveChatData(chatData: someObj)
                        self.fetchArchivedConversation()
                        
                        self.viewEmpty.isHidden = true
                        if self.tbleArray.count == 0 {
                            self.viewEmpty.isHidden = false
                        }
                        self.tableView.reloadData()
                    }
                }
            }, param:parameters)
        }
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
    
    func openSheet(indexPath : IndexPath){
        let pagerController = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "ChatLongPressSettingVC") as! ChatLongPressSettingVC
        pagerController.userObj = self.tbleArray[indexPath.row]
        pagerController.indexPath = indexPath
        pagerController.chatDelegat = self
        pagerController.isArchiveScreen = true
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(300), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tableView.reloadData()
                    }
                }
            }
        }, param:parameters)
    }
}

extension ArchivedChatsVC : UITableViewDelegate , UITableViewDataSource  {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict = self.tbleArray[indexPath.row]
        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
        contactGroup.conversatonObj = dict
        self.navigationController?.pushViewController(contactGroup, animated: true)
    }
}

extension ArchivedChatsVC : ChatSettingDelegate {
    func settingOptionsChoose(chatSetting : ChatSettingModel , indexPath : IndexPath){
        
        self.sheetController.dismissVC {
            
        }
        
        switch chatSetting.id {
        case .Profile:
            let btnMain = UIButton.init()
            btnMain.tag = indexPath.row
            self.openProfile(sender: btnMain)
            
        case .Delete:
            let btnMain = UIButton.init()
            btnMain.tag = indexPath.row
            self.deleteConversation(IdMain: self.tbleArray[indexPath.row].conversation_id , rowIndex: indexPath)
            
        case .MarkRead:
            var dic = [String:String]()
            dic["conversation_id"] = self.tbleArray[indexPath.row].conversation_id
            dic["is_unread"] = "false"
            SocketSharedManager.sharedSocket.markConversationUnread(dictionary: dic)
            
        case .Unarchive:
            var dic = [String:Any]()
            dic["conversation_id"] = self.tbleArray[indexPath.row].conversation_id
            dic["is_archive"] = 1
            
            SocketSharedManager.sharedSocket.markConversationArchive(dictionary: dic) { returnValue in
                
                if let dataDict = returnValue as? [[String : Any]] {
                    if dataDict.count > 0 {
                        if let statusCode =  dataDict[0]["status"] as? Int {
                            if statusCode == 1 {
                                let chatObj = self.tbleArray[indexPath.row]
                                chatObj.isArchive = "0"
                                CoreDbManager.shared.saveContext()
                                self.tbleArray.remove(at: indexPath.row)
                                self.tableView.beginUpdates()
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                self.tableView.endUpdates()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        default:
            LogClass.debugLog("Default ===>")
        }
    }
}
