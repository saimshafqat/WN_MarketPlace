//
//  GroupInviteUsersVC.swift
//  WorldNoor
//
//  Created by apple on 11/20/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class GroupInviteUsersVC : UIViewController {
    
    @IBOutlet var tbleViewGroup : UITableView!
    var arrayFriends = [FriendChatModel]()
    
    var arraySelected = [Int]()
    var chatObj = ConversationModel.init()
    
    var groupObj:GroupValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewGroup.register(UINib.init(nibName: "GroupContactSelection", bundle: nil), forCellReuseIdentifier: "GroupContactSelection")
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(self.saveAction), lblText: "Save".localized(), widthValue: 50.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tbleViewGroup.rotateViewForLanguage()
        
        self.title = "Choose Contacts".localized()
        self.getAllFriend()
    }
    
    @objc func saveAction(){
        
        if self.arraySelected.count == 0 {
            SharedManager.shared.showAlert(message: "Choose atleast one user to add in group.".localized(), view: self)
            return
        }
        self.addUserToGroup()
    }
    
    func addUserToGroup() {
        
        var newArray = [String]()
        for indexObj in self.arraySelected {
            newArray.append(self.arrayFriends[indexObj].email)
        }
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters : [String : Any] = ["action": "group/members/invite",
                                           "token": SharedManager.shared.userToken(),
                                           "group_id" : groupObj!.groupID,
                                           "emails" : newArray
        ]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                self.tbleViewGroup.reloadData()
            }
        }, param: parameters)
    }
    
    
    func getAllFriend() {
        
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
                        
                        for indexObj in self.chatObj.arrayMembers {
                            
                            if friendObjMain.id == indexObj.id {
                                isAlreadyAdded = false
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

extension GroupInviteUsersVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactSelection", for: indexPath) as? GroupContactSelection else {
            return UITableViewCell()
        }
        
        
        cell.lblUserName.text = self.arrayFriends[indexPath.row].name
        cell.lblUserEmail.text = self.arrayFriends[indexPath.row].email
        
//        let urlString = URL.init(string: self.arrayFriends[indexPath.row].profile_image)
//        cell.imgviewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cell.imgviewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
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
        if self.arraySelected.contains(indexPath.row) {
            self.arraySelected.remove(at: self.arraySelected.firstIndex(of: indexPath.row)!)
            self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
        }else {
            self.arraySelected.append(indexPath.row)
            self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}
