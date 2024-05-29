//
//  MessageRequestVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class MessageRequestVC: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet weak var toggleBtn1:UIButton!{
        didSet {
            toggleBtn1.roundButton()
        }
    }
    
    @IBOutlet weak var toggleBtnSpam:UIButton!{
        didSet {
            toggleBtnSpam.roundButton()
        }
    }
    
    @IBOutlet weak var lblText:UILabel!
    
    var selectedBtnTag = 0
    var startingPoint = ""
    var isAPICall = false
    var starting_point_id = ""
    var friendSuggestion:[FriendSuggestionModel] = [FriendSuggestionModel]()
    var spamArr:[Chat] = []
    var isLoadMore = true
    var pageCount = 1
    var cdCoreManager = ChatDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Message requests".localized()
        self.tableView.register(UINib.init(nibName: "ArchivedChatTVCell", bundle: nil), forCellReuseIdentifier: "ArchivedChatTVCell")
        self.tableView.register(UINib.init(nibName: "MessageRequestTVCell", bundle: nil), forCellReuseIdentifier: "MessageRequestTVCell")
        
        getSuggestedFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        if selectedBtnTag == 1 {
            fetchSpamConversation()
        }
        
        self.tableView.rotateViewForLanguage()
        self.lblText.rotateForTextAligment()
        self.lblText.rotateViewForLanguage()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fetchSpamConversation(){
        self.spamArr = self.cdCoreManager.fetchAllChatFromDB(convType: .spam)
        self.tableView.reloadData()
    }
    
    func paggingAPICall(indexPathMain : IndexPath){
        
        if !self.isAPICall {
            if indexPathMain.row == self.friendSuggestion.count - 1 {
                self.getSuggestedFriends()
            }
        }
    }
    
    func getSuggestedFriends(){
        
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "get-suggested-friends","token": userToken]
        if self.starting_point_id.count > 0 {
            parameters["starting_point_id"] = self.starting_point_id
        }
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            LogClass.debugLog("response ===>")
            LogClass.debugLog(parameters)
            LogClass.debugLog(response)
            switch response {
            case .failure(let error):
                if error is String {

                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let resArray = res as? [[String : Any]] {
                    for indexObj in resArray {
                        self.friendSuggestion.append(FriendSuggestionModel.init(fromDictionary: indexObj))
                    }
                }
            }
            
            if self.friendSuggestion.count > 0 {
                self.starting_point_id = self.friendSuggestion.last!.id
            }
            self.tableView.reloadData()
        }, param:parameters)
    }
    
    func isSpamReachEnd(indexPath:IndexPath){
        if isLoadMore {
            let spamCurrentCount = self.spamArr.count
            if indexPath.row == spamCurrentCount-1 {
                self.pageCount = self.pageCount + 1
                self.loadSpamNextPage()
            }
        }
    }
    
    func loadSpamNextPage() {
        
        DispatchQueue.global(qos: .background).async {
            let userToken = SharedManager.shared.userToken()
            var parameters = ["action": "conversations", "token":userToken, "serviceType":"Node"  , "per_page" : "10", "is_ignored":"1"]
            parameters["page"] = String(self.pageCount)
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                LogClass.debugLog("response ===>")
                LogClass.debugLog(parameters)
                LogClass.debugLog(response)
                
                
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)   
                case .success(let res):
                    LogClass.debugLog(res)
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        if (res as! String).contains("specific conversation") != nil {
                            self.isLoadMore = false
                        }else {
                            SharedManager.shared.showAlert(message: res as! String, view: self)
                        }
                    } else {
                        let newArray = res as! [AnyObject]
                        var someObj = [ConversationModel]()
                        for indexObj in newArray {
                            someObj.append(ConversationModel.init(fromDictionary: indexObj as! [String : Any]))
                        }
                        if newArray.count == 0 {
                            self.isLoadMore = false
                        }
                        self.cdCoreManager.saveChatData(chatData: someObj)
                        self.fetchSpamConversation()
                        
                        self.tableView.reloadData()
                    }
                }
            }, param:parameters)
        }
    }
    
    @IBAction func toggleBtn(_ sender:UIButton) {
        toggleBtn1.backgroundColor = .clear
        toggleBtnSpam.backgroundColor = .clear
        selectedBtnTag = sender.tag
        (sender.tag == 1) ? (toggleBtnSpam.backgroundColor = .SettingBtnBgColor) : (toggleBtn1.backgroundColor = .SettingBtnBgColor)
        self.tableView.reloadData()
        
        if selectedBtnTag == 1 {
            if self.spamArr.count == 0 {
                self.fetchSpamConversation()
                self.pageCount = 1
                self.loadSpamNextPage()
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func openChat(sender : UIButton){
        Loader.startLoading()
        let parameters = ["action": "user/send_friend_request","token": SharedManager.shared.userToken() , "user_id" : self.friendSuggestion[sender.tag].id]
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    self.friendSuggestion.remove(at: sender.tag)
                    SharedManager.shared.showAlert(message: "Friend Request Sent".localized(), view: self)
                    self.tableView.reloadData()
                } else if let newRes = res as? String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: newRes)
                }
            }
        }, param: parameters)
        
    }
    
    @objc func removeRequest(sender : UIButton){
        
        let friend = friendSuggestion[sender.tag]
        
        let parameters = ["action": "notifications/remove-suggestion",
                          "token": SharedManager.shared.userToken(),
                          "remove_id": friend.id]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            
            switch response {
            case .failure(let error): break
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    self.friendSuggestion.remove(at: sender.tag)
                }
                self.tableView.reloadData()
            }
            self.showToast(with: "User successfully removed.".localized())
        }, param: parameters)
    }
    
}

extension MessageRequestVC : UITableViewDelegate , UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedBtnTag == 0 {
            return self.friendSuggestion.count
        }
        return self.spamArr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedBtnTag == 0 {
            paggingAPICall(indexPathMain: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedBtnTag == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageRequestTVCell", for: indexPath) as? MessageRequestTVCell else {
                return UITableViewCell()
            }
            
            let friendSuggestion = self.friendSuggestion[indexPath.row]
            
            cell.manageViewData(friendSuggestion: friendSuggestion)
            
            cell.nameLabel.rotateViewForLanguage()
            cell.nameLabel.rotateForTextAligment()
            cell.messageButton.rotateViewForLanguage()
            cell.removeButton.rotateViewForLanguage()
            
            cell.removeButton.tag = indexPath.row
            cell.removeButton.addTarget(self, action: #selector(self.removeRequest), for: .touchUpInside)
            
            cell.messageButton.tag = indexPath.row
            cell.messageButton.addTarget(self, action: #selector(self.openChat), for: .touchUpInside)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArchivedChatTVCell", for: indexPath) as? ArchivedChatTVCell else {
                return UITableViewCell()
            }
            
            let spamUser = spamArr[indexPath.row]
            
            cell.manageViewData(conversation: spamUser)
            
            cell.titleLbl.rotateViewForLanguage()
            cell.titleLbl.rotateForTextAligment()
            cell.descriptionLbl.rotateViewForLanguage()
            cell.descriptionLbl.rotateForTextAligment()
            
            cell.selectionStyle = .none
            
            self.isSpamReachEnd(indexPath: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedBtnTag == 0 {
            let friendSuggestion = self.friendSuggestion[indexPath.row]
            let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            vcProfile.otherUserID = friendSuggestion.id
            vcProfile.otherUserisFriend = "0"
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
        } else {
            let dict = self.spamArr[indexPath.row]
            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
            contactGroup.conversatonObj = dict
            self.navigationController?.pushViewController(contactGroup, animated: true)
        }
    }
}
