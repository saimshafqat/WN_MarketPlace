//
//  GroupContactsVC.swift
//  WorldNoor
//
//  Created by apple on 5/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupContactsVC: UIViewController {
    
    @IBOutlet var tbleViewGroup : UITableView!
    var arrayFriends = [FriendChatModel]()
    
    var isOpenfromGroupDetail = GroupContactType.New
    
    var arraySelected = [Int]()
    var chatObj = Chat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewGroup.register(UINib.init(nibName: "GroupContactSelection", bundle: nil), forCellReuseIdentifier: "GroupContactSelection")
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(self.saveAction), lblText: "Save".localized(), widthValue: 50.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.tbleViewGroup.rotateViewForLanguage()
        if isOpenfromGroupDetail == .Contact {
            self.title = "Choose Contacts".localized()
            self.getAllFriend()
        }else if isOpenfromGroupDetail == .Admin {
            self.title = "Choose New Admin".localized()
            self.arrayFriends.removeAll()
            let membersArr = self.chatObj.toMember?.allObjects as? [Member] ?? []
            for indexObj in membersArr {
                
                if indexObj.id == self.ReturnValueCheck(value: SharedManager.shared.userObj?.data.id as Any)
                {
                    
                }else {
                    
                    let newModel = FriendChatModel.init()
                    
                    newModel.email = indexObj.username ?? ""
                    newModel.firstname = indexObj.firstName ?? ""
                    newModel.lastname = indexObj.lastname ?? ""
                    newModel.name = indexObj.username ?? ""
                    newModel.latest_coversation_id = ""
                    newModel.phone = ""
                    newModel.profile_image = indexObj.profile_image ?? ""
                    newModel.username = indexObj.username ?? ""
                    newModel.isSelect = false
                    newModel.id = indexObj.id ?? ""
                    self.arrayFriends.append(newModel)
                }
                
            }
            self.tbleViewGroup.reloadData()
        }else {
            self.title = "New Group".localized()
            self.getAllFriend()
        }
    }
    
    @objc func saveAction(){
        
        if isOpenfromGroupDetail == .Contact {
            if self.arraySelected.count == 0 {
                SharedManager.shared.showAlert(message: "Choose atleast one user to add in group.".localized(), view: self)
                
                return
            }
            self.addUserToGroup()
        }else if isOpenfromGroupDetail == .Admin {
            if self.arraySelected.count == 0 {
                SharedManager.shared.showAlert(message: "Choose one user as Admin for group.".localized(), view: self)
            }else {
                self.makeNewAdmin()
            }
        }else {
            self.createNewGroup()
        }
    }
    
    func makeNewAdmin(){
        let dict:NSDictionary = [
            "conversation_id":self.chatObj.conversation_id,
            "member_id": SharedManager.shared.userObj?.data.id as Any,
            "action":"leave_group_as_admin",
            "new_admin_id":self.arrayFriends[self.arraySelected[0]].id
        ]
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        SocketSharedManager.sharedSocket.makeNewAdminForGroup(dict: dict) { (returnValue) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: NewChatListVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
            
        }
        
    }
    
    
    func addUserToGroup(){
        
        
        var newArray = [Int]()
        
        for indexObj in self.arraySelected {
            newArray.append(Int(self.arrayFriends[indexObj].id)!)
        }
        let dict:NSDictionary = [
            "conversation_id":self.chatObj.conversation_id,
            "member_ids": newArray
        ]
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        SocketSharedManager.sharedSocket.addUserstoGroup(dict: dict) { (returnValue) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: NewChatListVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }        
    }
    
    func createNewGroup(){
        var selectedFriends = [FriendChatModel]()
        for selectedUser in self.arrayFriends {
            if selectedUser.isSelect {
                selectedFriends.append(selectedUser)
            }
        }
        let viewMain = self.GetView(nameVC: "GroupChatCreateVC", nameSB: "Notification") as! GroupChatCreateVC
        viewMain.arrayFriends = selectedFriends
        self.navigationController?.pushViewController(viewMain, animated: true)
    }
    
    func getAllFriend(){
        self.arrayFriends.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/friends","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else  if let newRes = res as? [[String:Any]] {
                    for indexFriend in newRes{
                        
                        let friendObjMain = FriendChatModel.init(fromDictionary: indexFriend)
                        var isAlreadyAdded = true
                        
                        if self.isOpenfromGroupDetail == .Contact {
                            let membersArr = self.chatObj.toMember?.allObjects as? [Member] ?? []
                            for indexObj in membersArr {
                                
                                if friendObjMain.id == indexObj.id {
                                    isAlreadyAdded = false
                                }
                            }
                        }
                        if isAlreadyAdded{
                            self.arrayFriends.append(friendObjMain)
                        }
                        
                    }
                }
                self.tbleViewGroup.reloadData()
            }
        }, param: parameters)
    }
}

extension GroupContactsVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactSelection", for: indexPath) as? GroupContactSelection else {
           return UITableViewCell()
        }
        
        
        cell.lblUserName.text = self.arrayFriends[indexPath.row].name
        cell.lblUserEmail.text = self.arrayFriends[indexPath.row].email
        
        cell.lblUserName.dynamicHeadlineSemiBold17()
        cell.lblUserEmail.dynamicCaption1Regular12()
        
        cell.imgviewUser.loadImageWithPH(urlMain:self.arrayFriends[indexPath.row].profile_image)
        
        self.view.labelRotateCell(viewMain: cell.imgviewUser)
        cell.imgviewSelect.isHidden = true
        cell.viewSelect.backgroundColor = UIColor.white
        if self.arrayFriends[indexPath.row].isSelect {
            cell.imgviewSelect.isHidden = false
            cell.viewSelect.backgroundColor = UIColor.init(red: (235/255), green: (235/255), blue: (235/255), alpha: 1.0)
        }
        
        
        cell.imgviewSelect.rotateViewForLanguage()
        cell.lblUserEmail.rotateForTextAligment()
        self.view.labelRotateCell(viewMain: cell.lblUserEmail)
        
        cell.lblUserName.rotateForTextAligment()
        self.view.labelRotateCell(viewMain: cell.lblUserName)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if isOpenfromGroupDetail == .Admin {
            
            if self.arraySelected.contains(indexPath.row) {
                self.arraySelected.remove(at: self.arraySelected.firstIndex(of: indexPath.row)!)
                self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
            }else {
                if self.arraySelected.count == 0 {
                    self.arraySelected.append(indexPath.row)
                    self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
                }else {
                    SharedManager.shared.showAlert(message: "You can select only one user as Admin".localized(), view: self)
                }
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }else if isOpenfromGroupDetail == .Contact {
            if self.arraySelected.contains(indexPath.row) {
                self.arraySelected.remove(at: self.arraySelected.firstIndex(of: indexPath.row)!)
                self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
            }else {
                self.arraySelected.append(indexPath.row)
                self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }else {
            self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

class GroupContactSelection : UITableViewCell {
    @IBOutlet var imgviewUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblUserEmail : UILabel!
    @IBOutlet var viewSelect : UIView!
    @IBOutlet var imgviewSelect : UIImageView!
}

