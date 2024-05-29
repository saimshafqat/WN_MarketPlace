//
//  ChatBlockVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 13/09/2023.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ChatBlockVC: UIViewController {
    
    var arrayBlockedUser = [BlockedUserModel]()
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var viewEmpty : UIView!
    @IBOutlet var tblHeaderView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blocked accounts".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.manageUI()
        self.viewEmpty.isHidden = true
        self.arrayBlockedUser.removeAll()
        self.getAllBlockUser()
    }
    
    func manageUI(){
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.plus"), style: .plain, target: self, action: #selector(self.addContactBtn))
        addBtn.tintColor = .black
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    @objc func addContactBtn(){
        let contactVC = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: ChatContactVC.className) as! ChatContactVC
        contactVC.groupID = "-1"
        contactVC.titleStr = "Block an account"
        self.pushFromBottom(contactVC)
    }
        
    func getAllBlockUser() {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/blocked_users","token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else  if let newRes = res as? [[String:Any]] {
                    // Iterate through the new response data
                    for indexObj in newRes {
                        // Initialize a new blocked user model from the current data
                        let newUser = BlockedUserModel.init(fromDictionary: indexObj)
                        // Check if the user is already in the array
                        if !self.arrayBlockedUser.contains(where: { $0.id == newUser.id }) {
                            // If not, append the new user to the array
                            self.arrayBlockedUser.append(newUser)
                        } else {
                            LogClass.debugLog("User \(newUser.id) is already in the blocked list.")
                        }
                    }
                }
                // perform on main thread
                DispatchQueue.main.async {
                    self.viewEmpty.isHidden = false
                    self.tblHeaderView.isHidden = true
                    if self.arrayBlockedUser.count > 0 {
                        self.viewEmpty.isHidden = true
                        self.tblHeaderView.isHidden = false
                    }
                    self.tableView.reloadData()
                }
            }
        }, param: parameters)
    }
}

extension ChatBlockVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayBlockedUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellBlocked  = tableView.dequeueReusableCell(withIdentifier: ChatBlockCell.className, for: indexPath) as! ChatBlockCell
        cellBlocked.lblUserName.text = self.arrayBlockedUser[indexPath.row].firstname + " " + self.arrayBlockedUser[indexPath.row].lastname
        cellBlocked.imgViewUser.loadImageWithPH(urlMain:self.arrayBlockedUser[indexPath.row].profile_image)
        self.view.labelRotateCell(viewMain: cellBlocked.imgViewUser)
        cellBlocked.btnUnblock.tag = indexPath.row
        cellBlocked.btnUnblock.addTarget(self, action: #selector(self.UnBlockUser), for: .touchUpInside)
        cellBlocked.selectionStyle = .none
        return cellBlocked
    }
    
    @objc func UnBlockUser(sender : UIButton) {
        Loader.startLoading()
        let parameters = ["action": "user/unblock_user","token": SharedManager.shared.userToken() , "user_id":self.arrayBlockedUser[sender.tag].user_id]
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? String {
                    SharedManager.shared.ShowsuccessAlert(title: Const.AppName.localized(), message: newRes) { status in
                        self.arrayBlockedUser.removeAll()
                        self.getAllBlockUser()
                    }
                } else {
                    self.arrayBlockedUser.remove(at: sender.tag)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, param: parameters)
    }
}
