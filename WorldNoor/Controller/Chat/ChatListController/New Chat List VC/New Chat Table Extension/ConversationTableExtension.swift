//
//  ConversationTableExtension.swift
//  WorldNoor
//
//  Created by Waseem Shah on 31/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

extension NewChatListVC : UITableViewDelegate , UITableViewDataSource {
    
    // For Marketplace
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        guard isShowMarketplace else { return nil }
//        
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
//        headerView.backgroundColor = .clear
//        
//        let imageMainView = UIView(frame: CGRect(x: 10, y: 8, width: 50, height: 50))
//        imageMainView.backgroundColor = .clear
//        imageMainView.layer.borderWidth = 1
//        imageMainView.layer.masksToBounds = true
//        imageMainView.layer.borderColor = UIColor.lightGray.cgColor
//        imageMainView.layer.cornerRadius = 8
//        imageMainView.clipsToBounds = true
//        headerView.addSubview(imageMainView)
//        
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.frame = CGRect(x: 8, y: 8, width: 34, height: 34)
//        imageView.tintColor = .black
//        imageMainView.addSubview(imageView)
//        
//        imageView.loadImageWithPH(urlMain: self.marketplaceIcon)
//        
//        let titleLabel = UILabel(frame: CGRect(x: 65, y: 8, width: headerView.frame.width - 100, height: 30))
//        titleLabel.text = self.marketplaceTitle
//        titleLabel.textColor = .black
//        titleLabel.backgroundColor = .clear
//        titleLabel.textAlignment = .left
//        headerView.addSubview(titleLabel)
//        
//        titleLabel.dynamicHeadlineSemiBold17()
//        
//        let subtitleLabel = UILabel(frame: CGRect(x: 65, y: 35, width: headerView.frame.width - 100, height: 20))
//        subtitleLabel.textColor = UIColor().hexStringToUIColor(hex: "#797979")
//        subtitleLabel.backgroundColor = .clear
//        subtitleLabel.textAlignment = .left
//        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
//        headerView.addSubview(subtitleLabel)
//        
//        let timeStr = self.marketplaceLastUpdated.customDateFormat(time: self.marketplaceLastUpdated, format:Const.dateFormat1)
//        subtitleLabel.text = self.marketplaceCount > 0 ?
//        "\(self.marketplaceCount) " +
//        (self.marketplaceCount == 1 ? "new message".localized() : "new messages".localized()) + "  \(timeStr)" :
//        timeStr
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
//        headerView.addGestureRecognizer(tapGesture)
//        
//        return headerView
//    }
//    
//    @objc func headerTapped() {
//        let vc = MPChatListVC.instantiate(fromAppStoryboard: .Chat)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return isShowMarketplace ? 70 : 0.0001
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as! MyContactCell
            
            let chatIndex = indexPath.row - (indexPath.row / adPlacement)
            
            let dict = self.tbleArray[chatIndex]
            cell.manageContactList( dict: dict)
            cell.btnUserProfile.addTarget(self, action: #selector(self.openProfile), for: .touchUpInside)
            cell.btnUserProfile.tag = chatIndex
            cell.lblMessageCount.text = dict.unread_messages_count
            
            cell.imgViewMute.isHidden = true
            
            if dict.is_mute.count > 0 {
                if dict.is_mute == "1" {
                    cell.imgViewMute.isHidden = false
                }
            }
            if !searchActive {
                self.isFeedReachEnd(index: chatIndex)
            }
            cell.selectionStyle = .none
            return cell
        }
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
        
        if indexPath.row > 0 && indexPath.row % adPlacement == 0 {
            //ad cell
            return
        }
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        let dict = self.tbleArray[chatIndex]
        
        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
        
        contactGroup.conversatonObj = dict
        self.navigationController?.pushViewController(contactGroup, animated: true)
    }
    
    func deleteConversation(IdMain : String , rowIndex : Int){
        
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
                    self.tbleArray.remove(at: rowIndex)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tblViewChat.reloadData()
                    }
                }
            }
        }, param:parameters)
    }
    
    func openSheet(indexPath : IndexPath){
        let pagerController = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "ChatLongPressSettingVC") as! ChatLongPressSettingVC
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        pagerController.userObj = self.tbleArray[chatIndex]
        pagerController.indexPath = indexPath
        pagerController.chatDelegat = self
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(300), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
}

extension NewChatListVC : ChatSettingDelegate {
    
    func settingOptionsChoose(chatSetting : ChatSettingModel , indexPath : IndexPath){
        self.sheetController.dismissVC {
            
        }
        let chatIndex = indexPath.row - (indexPath.row / adPlacement)
        
        switch chatSetting.id {
        case .Mutenotification , .UnMutenotification:
            var switchValue = 1
            if self.tbleArray[chatIndex].is_mute == "1" {
                switchValue = 0
            }
            
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let parameters = [
                "action": "conversation/mute-unmute-notifications/" + self.tbleArray[chatIndex].conversation_id,
                "token": SharedManager.shared.userToken(),
                "convo_id" : self.tbleArray[chatIndex].conversation_id,
                "serviceType": "Node",
                "muteNotificationType" : "mute_msg",
                "muteNotificationTime" : Date().customString(format:"YYYY-MM-dd HH:mm:ss"),
                "mute": switchValue] as [String : Any]
            
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    LogClass.debugLog(res)
                    if self.tbleArray[chatIndex].is_mute == "1" {
                        self.tbleArray[chatIndex].is_mute = "0"
                    } else {
                        self.tbleArray[chatIndex].is_mute = "1"
                    }
                    
                    self.tblViewChat.reloadData()
                }
            }, param:parameters)
            
        case .Profile:
            let btnMain = UIButton.init()
            btnMain.tag = chatIndex
            self.openProfile(sender: btnMain)
            
        case .Wrong:
            
            self.showReportProfile(otherUserID: self.tbleArray[chatIndex].username)
        case .Delete:
            let alert = UIAlertController(title: "Delete chat".localized(),
                                          message: "Are you sure you want to delete this chat?".localized(),
                                          preferredStyle: UIAlertController.Style.alert)
            
            let yesAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: {_ in
                let btnMain = UIButton.init()
                btnMain.tag = chatIndex
                self.deleteConversation(IdMain: self.tbleArray[chatIndex].conversation_id, rowIndex: chatIndex)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {_ in
            })
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: {})
            
        case .MarkRead , .MarkasRead:
            
            var dic = [String:String]()
            dic["conversation_id"] = self.tbleArray[chatIndex].conversation_id
            
            if self.tbleArray[chatIndex].is_unread == "1" {
                dic["is_unread"] = "0"
                self.tbleArray[chatIndex].is_unread = "0"
            }else {
                dic["is_unread"] = "1"
                self.tbleArray[chatIndex].is_unread = "1"
            }
            
            self.tblViewChat.reloadData()
            SocketSharedManager.sharedSocket.markConversationUnread(dictionary: dic)
        case .Archive:
            var dic = [String:Any]()
            dic["conversation_id"] = self.tbleArray[chatIndex].conversation_id
            dic["is_archive"] = 0
            
            SocketSharedManager.sharedSocket.markConversationArchive(dictionary: dic) { returnValue in
                if let dataDict = returnValue as? [[String : Any]] {
                    if dataDict.count > 0 {
                        if let statusCode =  dataDict[0]["status"] as? Int {
                            if statusCode == 1 {
                                self.tbleArray.remove(at: chatIndex)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.tblViewChat.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            
        case .Block:
            self.blockUser(chatObj: self.tbleArray[chatIndex])
        case .Unblock:
            self.unBlockUser(chatObj: self.tbleArray[chatIndex])
        default:
            LogClass.debugLog("Default ===>")
        }
    }
    
    func blockUser(chatObj:Chat){
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":chatObj.member_id]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    chatObj.is_blocked = "1"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                } else {
                    chatObj.is_blocked = "1"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                    SharedManager.shared.showAlert(message: "User blocked successfully" , view: self)
                }
            }
        }, param:parameters)
    }
    
    func unBlockUser(chatObj:Chat){
        let parameters = ["action": "user/unblock_user", "token": SharedManager.shared.userToken(), "user_id":chatObj.member_id]
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    chatObj.is_blocked = "0"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                    SharedManager.shared.showAlert(message: res as! String , view: self)
                } else {
                    chatObj.is_blocked = "0"
                    CoreDbManager.shared.saveContext()
                    self.fetchFromLocalDB()
                    SharedManager.shared.showAlert(message: "User unblocked successfully" , view: self)
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

extension NewChatListVC : DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        
    }
}
