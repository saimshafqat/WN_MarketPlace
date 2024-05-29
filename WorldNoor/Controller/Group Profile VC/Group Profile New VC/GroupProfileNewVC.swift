//
//  GroupProfileNewVC.swift
//  WorldNoor
//
//  Created by apple on 9/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import TLPhotoPicker



class GroupProfileNewVC: UIViewController {
    
    var chatObj = Chat()
    var arrayFriends = [Member]()
    let val = 10 + 5.0
    var filePath = ""
    var isAdmin = false
    
    @IBOutlet var tblviewGroup : UITableView!
    
    @IBOutlet var lblGroupName : UILabel!
    @IBOutlet var lblGroupContactNumber : UILabel!
    @IBOutlet var imgViewGroup : UIImageView!
    
    @IBOutlet var viewEdit : UIView!
    @IBOutlet var viewImageEdit : UIView!
    
    var updateGroupName : UpdateGroupNameVC!
    
    
    var isGroupMute = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGroupName = (self.GetView(nameVC: "UpdateGroupNameVC", nameSB:"VideoClipStoryBoard") as! UpdateGroupNameVC)
        tblviewGroup.registerCustomCells([
            "GroupProfileNewHEaderCell" ,
            "GroupProfileNewOptionCell" ,
            "GroupProfileAddCell"
        ])

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isAdmin = false
        self.viewEdit.isHidden = true
        self.viewImageEdit.isHidden = true
        SocketSharedManager.sharedSocket.delegateGroup = self
        if self.chatObj.is_mute.count > 0 {
            if self.chatObj.is_mute == "0" {
                isGroupMute = false
            }else {
                isGroupMute = true
            }
        }
        for indexObj in self.chatObj.arrayAdmin_ids {
            if indexObj == SharedManager.shared.userObj!.data.id! {
                self.isAdmin = true
                self.viewEdit.isHidden = false
                self.viewImageEdit.isHidden = false
            }
        }
        
        self.arrayFriends.removeAll()
        self.arrayFriends = chatObj.toMember?.allObjects as? [Member] ?? []
        self.title = chatObj.name
        self.lblGroupName.text = self.title
        
//        let urlString = URL.init(string: self.chatObj.group_image)
//        self.imgViewGroup.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        self.imgViewGroup.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        self.imgViewGroup.loadImageWithPH(urlMain:self.chatObj.group_image)
        
        self.view.labelRotateCell(viewMain: self.imgViewGroup)
        self.lblGroupContactNumber.text = String(self.arrayFriends.count) + " " + "Members".localized()
        self.tblviewGroup.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}

extension GroupProfileNewVC : SocketDelegateForGroup{
    
    func didSocketGroupThemeUpdate(data: [String : Any]) {
        LogClass.debugLog("didSocketGroupThemeUpdate ==>")
        LogClass.debugLog(data)
    }
    func didSocketGroupUpdate(data: [String : Any]) {
        
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.chatObj.conversation_id {
            
            let newName = self.ReturnValueCheck(value: data["new_group_name"] as Any)
            let newImage = self.ReturnValueCheck(value: data["new_group_image"] as Any)
            
            if newName.count > 0 {
                self.chatObj.name = newName
                self.lblGroupName.text = newName
                self.title = newName
            }else {
                self.chatObj.group_image = newImage
//                let urlString = URL.init(string: newImage)
//                self.imgViewGroup.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
                
                self.imgViewGroup.loadImageWithPH(urlMain:newImage)
                
                self.view.labelRotateCell(viewMain: self.imgViewGroup)
            }
            
        }
        
        
    }
    func didSocketRemoveContactGroup(data: [String : Any]){
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.chatObj.conversation_id {
            
            let userLeft = self.ReturnValueCheck(value: data["user_who_left"] as Any)
            
            if userLeft.count > 0 {
                for indexFriend in 0..<self.arrayFriends.count {
                    if self.arrayFriends[indexFriend].id == userLeft {
                        self.arrayFriends.remove(at: indexFriend)
                        break
                    }
                }
            }
        }
        
        self.tblviewGroup.reloadData()
        
    }
    
    
    
    func didSocketContactGroup(data: [String : Any])
    {
        
        if self.ReturnValueCheck(value: data["conversation_id"] as Any) == self.chatObj.conversation_id {
            
            
            if let arrayUSer = data["members"] as? [[String : Any]] {
                for indexObj in arrayUSer {
                    
                    var isFound = false
                    
                    for indexFriend in self.arrayFriends {
                        if self.ReturnValueCheck(value: indexObj["id"] as Any) == indexFriend.id{
                            isFound = true
                            break
                        }
                    }
                    
                    if !isFound {
                        chatObj.addToToMember(ChatDBManager().getMemberSet(arrayMember: [ConversationMemberModel.init(fromDictionary: indexObj)]))
                        self.arrayFriends = chatObj.toMember?.allObjects as? [Member] ?? []
                        CoreDbManager.shared.saveContext()
                    }
                }
                
                self.tblviewGroup.reloadData()
            }
        }
    }
    
}
extension GroupProfileNewVC : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFriends.count + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < 2 {
//            let cellOption = tableView.dequeueReusableCell(withIdentifier: "GroupProfileNewOptionCell", for: indexPath) as! GroupProfileNewOptionCell
            
            guard let cellOption = tableView.dequeueReusableCell(withIdentifier: "GroupProfileNewOptionCell", for: indexPath) as? GroupProfileNewOptionCell else {
               return UITableViewCell()
            }
            
            if indexPath.row == 0 {
                cellOption.switchMain.isHidden = true
                cellOption.lblOption.text = "Leave & Delete Group".localized()
                cellOption.imgViewMain.image = UIImage.init(named: "DeleteChat")
            }else {
                cellOption.switchMain.isHidden = false
                cellOption.lblOption.text = "Mute Notifications".localized()
                cellOption.imgViewMain.image = UIImage.init(named: "Mute-Notifications")
            }
            
            
            cellOption.switchMain.isOn = self.isGroupMute
            cellOption.switchMain.addTarget(self, action: #selector(self.changeSwitch), for: .valueChanged)
            cellOption.selectionStyle = .none
            return cellOption
        }else if indexPath.row == 2 {
//            let cellOption = tableView.dequeueReusableCell(withIdentifier: "GroupProfileAddCell", for: indexPath) as! GroupProfileAddCell
            
            guard let cellOption = tableView.dequeueReusableCell(withIdentifier: "GroupProfileAddCell", for: indexPath) as? GroupProfileAddCell else {
               return UITableViewCell()
            }
            cellOption.viewAdd.isHidden = true
            if isAdmin {
                cellOption.viewAdd.isHidden = false
            }
            
            
            cellOption.btnAdd.addTarget(self, action: #selector(self.AddMoreContact), for: .touchUpInside)
            cellOption.selectionStyle = .none
            return cellOption
            
        }
        
        
//        let cellAdmin = tableView.dequeueReusableCell(withIdentifier: "GroupProfileNewHEaderCell", for: indexPath) as! GroupProfileNewHEaderCell
        
        guard let cellAdmin = tableView.dequeueReusableCell(withIdentifier: "GroupProfileNewHEaderCell", for: indexPath) as? GroupProfileNewHEaderCell else {
           return UITableViewCell()
        }
        
        
        let index = indexPath.row - 3
        cellAdmin.lblUserName.text = (self.arrayFriends[index].firstName ?? "") + " " + (self.arrayFriends[index].lastname ?? "")
        cellAdmin.lblUserStatus.text = self.arrayFriends[index].username
//        let urlString = URL.init(string: self.arrayFriends[index].profile_image)
//        cellAdmin.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cellAdmin.imgViewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        cellAdmin.imgViewUser.loadImageWithPH(urlMain:self.arrayFriends[index].profile_image ?? "")
        self.view.labelRotateCell(viewMain: cellAdmin.imgViewUser)
        
        cellAdmin.viewAdmin.isHidden = true
        cellAdmin.viewRemove.isHidden = true
        if isAdmin {
            cellAdmin.viewRemove.isHidden = false
        }
        
        if self.arrayFriends[index].is_admin == "1"
        {
            cellAdmin.viewAdmin.isHidden = false
            cellAdmin.viewRemove.isHidden = true
        }
        
        cellAdmin.btnRemove.tag = indexPath.row
        cellAdmin.btnRemove.addTarget(self, action: #selector(self.removeUserFromGroup), for: .touchUpInside)
        cellAdmin.selectionStyle = .none
        return cellAdmin
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isAdmin {
            if indexPath.row == 0 {
                
                let dict:NSDictionary = ["conversation_id":self.chatObj.conversation_id,"member_id":SharedManager.shared.userObj!.data.id!,"action":"leave_group_as_member"]
//                SharedManager.shared.showOnWindow()
                Loader.startLoading()
                SocketSharedManager.sharedSocket.removeUserFromGroupText(dict: dict) { (returnValue) in
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: NewChatListVC.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }else {
            if indexPath.row == 0 {
                AddContactForAdmin()
            }
            
            
        }
    }
    
    @objc func changeSwitch(switchMain : UISwitch){
        var switchValue = 0
        
        if switchMain.isOn {
            switchValue = 1
        }
        
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
//        let parameters = [
//            "action": "conversation/" + self.chatObj.conversation_id + "/mute-unmute-notifications" ,
//            "token": SharedManager.shared.userToken(),
//            "serviceType": "Node",
//            "mute": switchValue] as [String : Any]
        
        let parameters = [
            "action": "conversation/mute-unmute-notifications/" + self.chatObj.conversation_id,
            "token": SharedManager.shared.userToken(),
            "convo_id" : self.chatObj.conversation_id,
            "serviceType": "Node",
            "muteNotificationType" : "mute_msg",
            "muteNotificationTime" : Date().customString(format:"YYYY-MM-dd HH:mm:ss"),
            "mute": switchValue] as [String : Any]
        
        
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(_):
                if self.chatObj.is_mute == "1" {
                    self.chatObj.is_mute = "0"
                }else {
                    self.chatObj.is_mute = "1"
                }
                CoreDbManager.shared.saveContext()
            }
        }, param:parameters)
    }
    
    @objc func AddMoreContact(){
        let viewGroup = self.GetView(nameVC: "GroupContactsVC", nameSB: "Notification") as! GroupContactsVC
        viewGroup.isOpenfromGroupDetail = .Contact
        viewGroup.chatObj = self.chatObj
        self.navigationController?.pushViewController(viewGroup, animated: true)
    }
    
    @objc func AddContactForAdmin(){
        
        if self.arrayFriends.count == 1 {
            self.removeAdminFromGroup()
            return
        }
        let viewGroup = self.GetView(nameVC: "GroupContactsVC", nameSB: "Notification") as! GroupContactsVC
        viewGroup.isOpenfromGroupDetail = .Admin
        viewGroup.chatObj = self.chatObj
        self.navigationController?.pushViewController(viewGroup, animated: true)
    }
    
    
    func removeAdminFromGroup(){
        let alert = UIAlertController(title: "Remove Users".localized(), message: "Are you sure to leave this group?".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default , handler:{ (UIAlertAction)in
            
            let dict:NSDictionary = [
                "conversation_id":self.chatObj.conversation_id,
                "member_id": SharedManager.shared.userObj?.data.id as Any,
                "action":"leave_group_as_admin"
            ]
            
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            SocketSharedManager.sharedSocket.makeNewAdminForGroup(dict: dict) { (returnValue) in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: NewChatListVC.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel , handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    
    @objc func removeUserFromGroup(sender : UIButton){
        let index = sender.tag - 3
        
        
        let alert = UIAlertController(title: "Remove Users".localized(), message: "Are you sure to remove this contact from group?".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default , handler:{ (UIAlertAction)in
            
            let dict:NSDictionary = ["conversation_id":self.chatObj.conversation_id,"member_id": self.arrayFriends[index].id,"action":"remove_someone_as_admin"]
            
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            SocketSharedManager.sharedSocket.removeUserFromGroupText(dict: dict) { (returnValue) in
                
                let membersArr = self.chatObj.toMember?.allObjects as? [Member] ?? []
                for member in membersArr {
                    if member.id == self.arrayFriends[index].id {
                        self.chatObj.removeFromToMember(member)
                        break
                    }
                 }
                CoreDbManager.shared.saveContext()
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                self.arrayFriends.remove(at: index)
                self.tblviewGroup.reloadData()
                self.lblGroupContactNumber.text = String(self.arrayFriends.count) + " " +  "Members".localized()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel , handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    
    @IBAction func updateGroupName(sender : UIButton){
        self.updateGroupName.lblShow = "Group Name".localized()
        self.updateGroupName.textShow = "Enter Group Name".localized()
        self.updateGroupName.textinTF = self.lblGroupName.text!
        (self.updateGroupName as UpdateGroupNameVC).delegate = self as DelegateReturnData
        self.updateGroupName.convsersationID = self.chatObj.conversation_id
        
        UIApplication.shared.keyWindow!.addSubview((self.updateGroupName as UpdateGroupNameVC).view)
    }
    
    @IBAction func updateGorupImage(sender : UIButton){
        self.openPhotoPicker(maxValue: 1)
    }
    
    
    func openPhotoPicker(maxValue : Int = 10){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxValue
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        
        self.present(viewController, animated: true) {
//            viewController.albumPopView.show(viewController.albumPopView.isHidden, duration: 0.1)
        }
    }
    
    func uploadFile(){
        

        let parameters = ["action": "update-group-chat-image"  ,
                          "token": SharedManager.shared.userToken(),
                          "serviceType": "Node",
                          "conversation_id" :self.chatObj.conversation_id,
                          "fileType":"image", "fileUrl":self.filePath] as [String : Any]
        
        let newTime = SharedManager.shared.getCurrentDateString()
        self.callingServiceToUpload(parameters: parameters, newTime: newTime , fileType:"image")
        
    }
    
    func callingServiceToUpload(parameters:[String:Any] , newTime: String, fileType:String)  {

        RequestManager.fetchDataMultiparts(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                
                
                if let mainResult = res as? [String : Any] {
                    if let mainData = mainResult["data"] as? [String : Any] {
                        
                        if let mainURL = mainData["group_image"] as? String {
                            
                            let dictMain:NSDictionary = [ "new_group_image": mainURL , "conversation_id" : self.chatObj.conversation_id]
                            
                            SocketSharedManager.sharedSocket.updateGroupConversation(dict: dictMain as NSDictionary) { (pData) in
                            }
                        }
                    }
                }
            }
        }, param:parameters, fileUrl: "")
    }
}


extension GroupProfileNewVC : DelegateReturnData {
    func delegateReturnFunction(dataMain: Any) {
        self.lblGroupName.text = (dataMain as! String)
        self.title = self.lblGroupName.text
    }
}

extension GroupProfileNewVC : TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                
                let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                self.imgViewGroup.image = imageChoose
                
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        self!.filePath = urlString!.path
                        self!.uploadFile()
                    }
                }
            }
        }
    }
    
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        
    }
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
    
    func getImageFromAsset(asset: PHAsset) -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func getSelectedItem(asset:TLPHAsset)->UIImage {
        if asset.type == .video {
            
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset.phAsset!, targetSize: CGSize(width: 138, height: 138), contentMode: .aspectFit, options: option,  resultHandler: {(result, info)->Void in
                
                thumbnail = result!
                
            })
            return thumbnail
            
        }
        if let image = asset.fullResolutionImage {
            return image
        }
        return UIImage()
    }
}
