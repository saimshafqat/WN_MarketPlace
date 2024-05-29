//
//  UsersListVC.swift
//  WorldNoor
//
//  Created by apple on 11/19/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class UsersListVC : UIViewController {
    
    @IBOutlet var tblViewUSers : UITableView!
    
    var arrayUsers = [GroupMembers]()
    
    var groupObj:GroupValue?
    var isAPICAll = false
    var isFromPage : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblViewUSers.register(UINib.init(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: "SearchUserCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getUsers()
        
    }
    
    func getUsers(){
        if isFromPage == 0 {
            self.showMember()
        }else if isFromPage == 2 {
            self.showLikeMember()
        }else if isFromPage == 1 {
            self.showFollowMember()
        }
    }
}

extension UsersListVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellUSer = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as! SearchUserCell
        
        cellUSer.lblStatus.text = "Remove"
        cellUSer.lblUserAddress.text = ""
        cellUSer.lblUserName.text = self.arrayUsers[indexPath.row].firstname + " " + self.arrayUsers[indexPath.row].lastname
        cellUSer.imgViewUser.loadImageWithPH(urlMain: self.arrayUsers[indexPath.row].profile_image)
        cellUSer.btnConnect.tag = indexPath.row
        cellUSer.btnConnect.addTarget(self, action: #selector(self.removeUser), for: .touchUpInside)
        cellUSer.viewStatus.isHidden = true
        if self.arrayUsers.count - 1 == indexPath.row {
            if !isAPICAll{
                self.getUsers()
            }
            
        }
        cellUSer.selectionStyle = .none
        return cellUSer
    }
    
    @objc func removeUser(sender : UIButton){
        let parameters = [
            "action": "group/members/leave",
            "group_id":self.groupObj!.groupID ,
            "user_id":self.arrayUsers[sender.tag].user_id,
            "token": SharedManager.shared.userToken()
        ]
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {

                    
                } else {
                    if let obj = SharedManager.shared.userEditObj.groupArray.filter({$0.groupID == self.groupObj?.groupID}).first {
                        let profileGroupModel = ProfileGroupPageModel(tabName: "group", item: obj)
                        NotificationCenter.default.post(name: .CategoryLikePages, object: profileGroupModel)
                    }
                }
            }
        }, param:parameters as! [String : String])
    }
    
    
    func showMember(){
        isAPICAll = true
        var parameters = [
            "action": "group/members",
            "group_id":self.groupObj!.groupID ,
            "token": SharedManager.shared.userToken()
        ]
        
        
        if self.arrayUsers.count > 0 {
            parameters["starting_point_id"] = self.arrayUsers.last!.user_id
        }else {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }
        
        
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    self.isAPICAll = false
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isAPICAll = false
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let newData = res as? [[String : Any]]{
                        
                        for indexobj in newData {
                            self.arrayUsers.append(GroupMembers.init(fromDictionary: indexobj))
                        }
                    }
                    self.isAPICAll = false
                    self.tblViewUSers.reloadData()
                }
            }
        }, param:parameters as! [String : String])
    }
    
    func showLikeMember(){
        isAPICAll = true
        var parameters = [
            "action": "page/likes",
            "page_id":self.groupObj!.groupID ,
            "token": SharedManager.shared.userToken()
        ]
        
        
        if self.arrayUsers.count > 0 {
            parameters["starting_point_id"] = self.arrayUsers.last!.idMain
        }else {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }
        
        
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    self.isAPICAll = false
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isAPICAll = false
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let newData = res as? [[String : Any]]{
                        
                        for indexobj in newData {
                            self.arrayUsers.append(GroupMembers.init(fromDictionary: indexobj))
                        }
                    }
                    self.isAPICAll = false
                    self.tblViewUSers.reloadData()
                }
            }
        }, param:parameters as! [String : String])
    }
    
    func showFollowMember(){
        isAPICAll = true
        var parameters = [
            "action": "page/follows",
            "page_id":self.groupObj!.groupID ,
            "token": SharedManager.shared.userToken()
        ]
        
        
        if self.arrayUsers.count > 0 {
            parameters["starting_point_id"] = self.arrayUsers.last!.idMain
        }else {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
        }
        
        
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    self.isAPICAll = false
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isAPICAll = false
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let newData = res as? [[String : Any]]{
                        
                        for indexobj in newData {
                            self.arrayUsers.append(GroupMembers.init(fromDictionary: indexobj))
                        }
                    }
                    self.isAPICAll = false
                    self.tblViewUSers.reloadData()
                }
            }
        }, param:parameters as! [String : String])
    }
}
