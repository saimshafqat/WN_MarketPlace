//
//  SearchMoreUsersVC.swift
//  WorldNoor
//
//  Created by apple on 11/1/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class SearchMoreUsersVC : UIViewController {
    
    
    var searchString = ""
    var screenTitle: String = .emptyString
    @IBOutlet var tblViewUser : UITableView!
    
    
    var isAPICall = false
    var arrayUsers = [SearchUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblViewUser.register(UINib.init(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: "SearchUserCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = screenTitle
        self.apiCall()
    }
    
    func isFeedReachEnd(indexPath:IndexPath){
        
        if !isAPICall{
            let feedCurrentCount = self.arrayUsers.count
            if indexPath.row == feedCurrentCount-1 {
                self.apiCall()
            }
        }
    }
    
    func apiCall() {
        self.isAPICall = true
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = ["action": "search/users","token": SharedManager.shared.userToken() , "query" : self.searchString , "per_page" : "20"]
        if self.arrayUsers.count > 0 {
            let lastindex = self.arrayUsers.count - 1
            let postObj = self.arrayUsers[lastindex] as SearchUserModel
            parameters["starting_point_id"] = postObj.user_id
        }
        
        // LogClass.debugLog(parameters)
        RequestManager.fetchDataGet(Completion: { (response) in
            self.isAPICall = false
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            
            case .failure(let error):
                self.isAPICall = false
SwiftMessages.apiServiceError(error: error)            case .success(let res):

                self.isAPICall = false
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if let newRes = res as? [[String:Any]]
                {
                    for indexContact in newRes{
                        self.arrayUsers.append(SearchUserModel.init(fromDictionary: indexContact))
                    }
                }else if res is String{
                    self.isAPICall = true
                }
                self.tblViewUser.reloadData()
            }
        }, param: parameters)
    }
    
}


extension SearchMoreUsersVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellUSer = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as? SearchUserCell else {
            return UITableViewCell()
        }
        
        
//        let urlString = URL(string:self.arrayUsers[indexPath.row].profile_image)
//        cellUSer.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cellUSer.imgViewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        cellUSer.imgViewUser.loadImageWithPH(urlMain:self.arrayUsers[indexPath.row].profile_image)
        
        self.view.labelRotateCell(viewMain: cellUSer.imgViewUser)
        let city = self.arrayUsers[indexPath.row].city
        let state = self.arrayUsers[indexPath.row].state_name
        cellUSer.lblUserAddress.text = (city != "" && state != "") ? (city + ", " + state) : (city != "") ? city : state
        cellUSer.lblUserName.text = self.arrayUsers[indexPath.row].author_name
        if self.arrayUsers[indexPath.row].is_my_friend == "1" {
            cellUSer.lblStatus.text = "Send Message".localized()
            cellUSer.viewStatus.backgroundColor = UIColor.init(red: 41/255, green: 47/255, blue: 75/255, alpha: 1.0)
        }else {
            cellUSer.lblStatus.text = "Connect".localized()
            cellUSer.viewStatus.backgroundColor = UIColor.init(red: 253/255, green: 136/255, blue: 36/255, alpha: 1.0)
        }
        
        
        cellUSer.viewStatus.isHidden = true
        if self.arrayUsers[indexPath.row].can_i_send_fr.count > 0 {
            if self.arrayUsers[indexPath.row].can_i_send_fr == "1" {
                cellUSer.viewStatus.isHidden = false
            }
        }
        
        cellUSer.btnConnect.tag = indexPath.row
        cellUSer.btnConnect.addTarget(self, action: #selector(self.connectAction), for: .touchUpInside)
        
        self.isFeedReachEnd(indexPath: indexPath)
        
        cellUSer.selectionStyle = .none
        return cellUSer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vcProfile = self.GetView(nameVC: "ProfileViewController", nameSB: "PostStoryboard") as! ProfileViewController
        vcProfile.otherUserID = self.arrayUsers[indexPath.row].user_id
        vcProfile.otherUserisFriend = self.arrayUsers[indexPath.row].is_my_friend
        vcProfile.otherUserSearchObj = self.arrayUsers[indexPath.row]
        vcProfile.isNavPushAllow = true
        self.navigationController?.pushViewController(vcProfile, animated: true)
    }
    
    @objc func connectAction(sender : UIButton){
        if self.arrayUsers[sender.tag].is_my_friend == "1" {
            
            let moc = CoreDbManager.shared.persistentContainer.viewContext
            let objModel = Chat(context: moc)
            objModel.profile_image = self.arrayUsers[sender.tag].profile_image
            objModel.member_id = self.arrayUsers[sender.tag].user_id
            objModel.name = self.arrayUsers[sender.tag].username
            objModel.latest_conversation_id = self.arrayUsers[sender.tag].conversation_id
            objModel.conversation_id = self.arrayUsers[sender.tag].conversation_id
            objModel.conversation_type = "single"
            
            // Waseem shah issue
            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
            contactGroup.conversatonObj = objModel
            self.navigationController?.pushViewController(contactGroup, animated: true)
            
            
        }else {
            if self.arrayUsers[sender.tag].already_sent_friend_req == "1" {
//                SharedManager.shared.showAlert(message: "Friend request already sent.".localized(), view: self)
                
                SharedManager.shared.ShowAlertWithCompletaion(message: "Your Request is Pending. Do you want to cancel it?".localized(), isError: false,DismissButton: "OK".localized(),AcceptButton: "Cancel Request".localized()) { status in
                    print("status ===>")
                    print(status)
                    if status {
                        
                    }else {
                        
                    }
                }
                return
            }
            
            Loader.startLoading()
            let parameters = ["action": "user/send_friend_request","token": SharedManager.shared.userToken() , "user_id" : self.arrayUsers[sender.tag].user_id]

            RequestManager.fetchDataPost(Completion: { (response) in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)   
                case .success(let res):

                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if let newRes = res as? [String:Any] {
                        self.arrayUsers[sender.tag].already_sent_friend_req = "1"
                        SharedManager.shared.showAlert(message: "Friend Request Sent".localized(), view: self)
                    } else if let newRes = res as? String {
                                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: newRes)
                    }
                }
            }, param: parameters)
        }
    }
    
    
    
}
