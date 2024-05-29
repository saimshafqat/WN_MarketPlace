//
//  ChatProfileVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 03/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

class ChatProfileVC: UIViewController {
    
    @IBOutlet weak var profHeaderView: ProfileHeaderView!
    @IBOutlet weak var tableView: UITableView!
    var profArray:[[String]]?
    var imageArray:[[String]]?
    var headerArray:[String]?
    var chatConversationObj:Chat?
    var sheetController = SheetViewController()
    let vcTheme = ChatThemeColourVC.instantiate(fromAppStoryboard: .Shared)
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile".localized()
        
        self.updateProfileArray()
        imageArray = [["textformat"], ["magnifyingglass", "pin.fill","minus.circle.fill"], ["xmark.bin.circle.fill", "minus.circle.fill", "exclamationmark.bubble.fill","minus.circle.fill"]]
        headerArray = ["Customization".localized(), "More actions".localized(), "Privacy and support".localized()]
        profHeaderView.manageData(obj: chatConversationObj ?? nil)
        if self.chatConversationObj!.is_mute == "0" {
            self.profHeaderView.muteLbl.text = "Mute"
            self.profHeaderView.muteImageView.image = UIImage.init(systemName: "bell.fill")
        }else {
            self.profHeaderView.muteLbl.text = "Unmute"
            self.profHeaderView.muteImageView.image = UIImage.init(systemName: "bell.slash.fill")
        }
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.rotateViewForLanguage()
        self.profHeaderView.rotateViewForLanguage()
        
        profHeaderView.profileHandler = { [weak self] in
            guard let self = self else { return }
            guard let obj = self.chatConversationObj else { return }
            let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            vcProfile.otherUserID = obj.member_id
            vcProfile.otherUserisFriend = "1"
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
        }
        
        profHeaderView.muteHandler = { [weak self] in
            
            guard let self = self else { return }
            guard let convId = self.chatConversationObj?.conversation_id else { return }
            
            var switchValue = 1
            if self.chatConversationObj?.is_mute == "1" {
                switchValue = 0
            }
            
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let parameters = [
                "action": "conversation/mute-unmute-notifications/" + convId,
                "token": SharedManager.shared.userToken(),
                "convo_id" : convId,
                "serviceType": "Node",
                "muteNotificationType" : "mute_msg",
                "muteNotificationTime" : Date().customString(format:"YYYY-MM-dd HH:mm:ss"),
                "mute": switchValue] as [String : Any]
            
            
            RequestManager.fetchDataPost(Completion: { response in
                switch response {
                case .failure(_):
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                case .success(let res):
                    LogClass.debugLog(res)
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    if self.chatConversationObj?.is_mute == "1" {
                        self.profHeaderView.muteLbl.text = "Mute"
                        self.chatConversationObj?.is_mute = "0"
                        self.profHeaderView.muteImageView.image = UIImage.init(systemName: "bell.fill")
                    }else {
                        self.chatConversationObj?.is_mute = "1"
                        self.profHeaderView.muteLbl.text = "Unmute"
                        self.profHeaderView.muteImageView.image = UIImage.init(systemName: "bell.slash.fill")
                    }
                    CoreDbManager.shared.saveContext()
                }
            }, param:parameters)
        }
        
        profHeaderView.messageHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateProfileArray() {
        
        profArray = [["Nicknames".localized()],
                     ["Search in conversation".localized(),
                      "View pinned messages".localized(),
                      "Change theme".localized()],
                     ["Delete chat".localized(),
                      self.chatConversationObj?.is_blocked == "0" ? "Block".localized() : "Unblock".localized(),
                      "Something's wrong".localized(),
                      "Ignore this conversation".localized()]]
        
        tableView.reloadData()
    }
}

extension ChatProfileVC : UITableViewDelegate , UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return profArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profArray![section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = headerArray?[section]
        label.rotateViewForLanguage()
        label.rotateForTextAligment()
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profileCell = tableView.dequeueReusableCell(withIdentifier: "ChatProfileTVCell", for: indexPath) as? ChatProfileTVCell else {
            return UITableViewCell()
        }
        profileCell.titleLbl.text = profArray?[indexPath.section][indexPath.row] ?? ""
        profileCell.imgView.image = UIImage(systemName: imageArray?[indexPath.section][indexPath.row] ?? "")
        
        profileCell.titleLbl.rotateViewForLanguage()
        profileCell.titleLbl.rotateForTextAligment()
        profileCell.imgView.rotateViewForLanguage()
        
        return profileCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //dismiss search coontroller if its presented already
        
        if let presentedViewController = presentedViewController as? UISearchController {
            presentedViewController.dismiss(animated: true)
        }
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let vc = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: "NickNamesVC") as! NickNamesVC
                vc.chatConversationObj = chatConversationObj
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                present(searchController, animated: true, completion: nil)
            case 1:
                let vc = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: PinnedVC.className) as! PinnedVC
                vc.conversatonObj = self.chatConversationObj!
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                vcTheme.delegateTheme = self
                vcTheme.chatConversationObj = self.chatConversationObj
                self.view.addSubview(vcTheme.view)
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                guard self.chatConversationObj != nil else { return }
                SharedManager.shared.ShowAlertWithCompletaion(title: "Delete chat".localized(), message:"Are you sure you want to delete this chat?".localized(), isError: false,DismissButton:"Cancel".localized() ,AcceptButton: "Yes".localized()) { status in
                    if status {
                        self.deleteConversation(IdMain: self.chatConversationObj?.conversation_id ?? "")
                    }
                }
            case 1:
                
                guard let obj = self.chatConversationObj else { return }
                if(obj.is_blocked == "0")
                {
                    self.blockUser(otherUserID: obj.member_id)
                }
                else {
                    self.unBlockUser(otherUserID: obj.member_id)
                }
            case 2:
                guard let obj = self.chatConversationObj else { return }
                self.showReportProfile(otherUserID: obj.username)
            default:
                SharedManager.shared.ShowAlertWithCompletaion(title: "Ignore this conversation?".localized(),message:"You won't be notified when User's name messages you directly, and the conversation will move to Spam. We won't tell User's name that the messages have been ignored.".localized(), isError: false,DismissButton:"Cancel".localized() ,AcceptButton: "Yes".localized()) { status in
                    if status {
                        self.markConversation()
                    }
                }
                break
            }
        default:
            break
        }
    }
    
    func markConversation(){
        var dic = [String:Any]()
        dic["conversation_id"] = self.chatConversationObj?.conversation_id
        dic["member_id"] = chatConversationObj?.member_id
        dic["me_id"] = SharedManager.shared.userObj?.data.id?.description
        
        SocketSharedManager.sharedSocket.markConversationSpam(dictionary: dic) { returnValue in
            if let dataDict = returnValue as? [[String : Any]] {
                if dataDict.count > 0 {
                    if let status =  dataDict[0]["status"] as? String {
                        if status == "ignored" {
                            self.chatConversationObj?.isSpam = "1"
                        }
                        else if status == "unignored" {
                            self.chatConversationObj?.isSpam = "0"
                        }
                        CoreDbManager.shared.saveContext()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
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
    
    func blockUser(otherUserID : String){
        
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":otherUserID]
        
        LogClass.debugLog("parameters ===>")
        LogClass.debugLog(parameters)
        SharedManager.shared.showOnWindow()
        RequestManager.fetchDataPost(Completion: { response in
            SharedManager.shared.hideLoadingHubFromKeyWindow()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                }else {
                    SharedManager.shared.showAlert(message: "User blocked successfully" , view: self)
                    self.chatConversationObj?.is_blocked = "1"
                    self.updateProfileArray()
                }
            }
            
        }, param:parameters)
    }
    
    func unBlockUser(otherUserID : String){
        
        let parameters = ["action": "user/unblock_user", "token": SharedManager.shared.userToken(), "user_id":otherUserID]
        
        LogClass.debugLog("parameters ===>")
        LogClass.debugLog(parameters)
        SharedManager.shared.showOnWindow()
        RequestManager.fetchDataPost(Completion: { response in
            SharedManager.shared.hideLoadingHubFromKeyWindow()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                    self.chatConversationObj?.is_blocked = "0"
                    self.updateProfileArray()
                }else {
                    SharedManager.shared.showAlert(message: "User unblocked successfully" , view: self)
                    self.chatConversationObj?.is_blocked = "0"
                    self.updateProfileArray()
                }
            }
            
        }, param:parameters)
    }
}

extension ChatProfileVC : DismissReportDetailSheetDelegate {
    
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}

extension ChatProfileVC {
    func deleteConversation(IdMain : String){
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }, param:parameters)
    }
}

extension ChatProfileVC : ChatThemeDelegate {
    func chooseOption(chatOption : String){
        
        self.chatConversationObj?.theme_color = chatOption
        CoreDbManager.shared.saveContext()
    }
}

extension ChatProfileVC:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            let vc = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: ChatSearchVC.className) as! ChatSearchVC
            vc.conversatonObj = self.chatConversationObj!
            vc.searchText = searchTerm
            self.navigationController?.pushViewController(vc, animated: true)
        }
        searchBar.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}

