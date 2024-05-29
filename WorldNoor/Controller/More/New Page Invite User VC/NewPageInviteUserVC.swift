//
//  NewPageInviteUserVC.swift
//  WorldNoor
//
//  Created by apple on 12/7/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewPageInviteUserVC : UIViewController {
    
    @IBOutlet var tbleViewGroup : UITableView!
    var arrayFriends = [FriendChatModel]()
    
    var isOpenfromGroupDetail = GroupContactType.New
    
    var arraySelected = [Int]()
    var groupObj:GroupValue!
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewGroup.register(UINib.init(nibName: "GroupContactSelection", bundle: nil), forCellReuseIdentifier: "GroupContactSelection")
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(self.saveAction), lblText: "Invite".localized(), widthValue: 50.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tbleViewGroup.rotateViewForLanguage()
        
            self.title = "Invite Friends".localized()
            self.pageNumber = 1
            self.getAllFriend()
        
    }
    
    @objc func saveAction(){
        self.makeNewAdmin()
    }
    
    func makeNewAdmin(){
        var arrayEmail = [String]()
        for indexObj in arraySelected {
            arrayEmail.append(self.arrayFriends[indexObj].email)
        }
        let dict = [
            "page_id":self.groupObj.groupID,
            "friends_emails": arrayEmail as Any,
            "action":"page/invite/users"
        ]

        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }, param: dict)
    }
 
    func getAllFriend() {
        self.arrayFriends.removeAll()
        Loader.startLoading()
        let parameters = ["action": "user/friends","token": SharedManager.shared.userToken() , "page" : String(self.pageNumber)]
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if let newRes = res as? [[String:Any]]
                {
                    for indexFriend in newRes{
                        
                        let friendObjMain = FriendChatModel.init(fromDictionary: indexFriend)
                        var isAlreadyAdded = true
                        
                        
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

extension NewPageInviteUserVC:UITableViewDelegate, UITableViewDataSource {
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
        
        
        cell.imgviewUser.loadImageWithPH(urlMain: self.arrayFriends[indexPath.row].profile_image )
        
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

