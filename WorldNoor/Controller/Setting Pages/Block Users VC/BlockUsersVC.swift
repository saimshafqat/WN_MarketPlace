//
//  BlockUsersVC.swift
//  WorldNoor
//
//  Created by apple on 4/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class BlockUsersVC: UIViewController {
    
    var arrayBlockedUser = [BlockedUserModel]()
    
    @IBOutlet var tbleViewBlockedUser : UITableView!
    
    @IBOutlet var viewEmpty : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tbleViewBlockedUser.register(UINib.init(nibName: "BlockedUserCell", bundle: nil), forCellReuseIdentifier: "BlockedUserCell")
        self.title = "Block Users".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewEmpty.isHidden = true
        self.arrayBlockedUser.removeAll()
        self.getAllBlockUser()
    }
    
    
    func getAllBlockUser(){
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
                    
                    for indexObj in newRes {
                        self.arrayBlockedUser.append(BlockedUserModel.init(fromDictionary: indexObj))
                    }
                }
                self.viewEmpty.isHidden = false
                if self.arrayBlockedUser.count > 0 {
                    self.viewEmpty.isHidden = true
                }
                self.tbleViewBlockedUser.reloadData()
            }
        }, param: parameters)
    }
}

extension BlockUsersVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayBlockedUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cellBlocked  = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath) as? BlockedUserCell else {
           return UITableViewCell()
        }
        
        
        cellBlocked.lblUserName.text = self.arrayBlockedUser[indexPath.row].firstname + " " + self.arrayBlockedUser[indexPath.row].lastname
//        cellBlocked.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cellBlocked.imgViewUser.sd_setImage(with: URL.init(string: self.arrayBlockedUser[indexPath.row].profile_image), placeholderImage: UIImage(named: "placeholder.png"))
        
        cellBlocked.imgViewUser.loadImageWithPH(urlMain:self.arrayBlockedUser[indexPath.row].profile_image)
        
        
        self.view.labelRotateCell(viewMain: cellBlocked.imgViewUser)
        cellBlocked.btnUnblock.tag = indexPath.row
        cellBlocked.btnUnblock.addTarget(self, action: #selector(self.UnBlockUser), for: .touchUpInside)
        cellBlocked.selectionStyle = .none
        return cellBlocked
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LogClass.debugLog("didSelectRowAt ===>")
        let userID = String(self.arrayBlockedUser[indexPath.row].user_id)
        let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        vcProfile.otherUserID = userID
        vcProfile.otherUserisFriend = "1"
        vcProfile.isNavPushAllow = true
        UIApplication.topViewController()!.navigationController?.pushViewController(vcProfile, animated: true)
    }
    
    @objc func UnBlockUser(sender : UIButton){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/unblock_user",
                          "token": SharedManager.shared.userToken(),
                          "user_id":self.arrayBlockedUser[sender.tag].user_id]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? String {
                    SharedManager.shared.ShowsuccessAlert(message: newRes) { status in
                        
                        self.arrayBlockedUser.removeAll()
                        self.getAllBlockUser()
                    }
                } else {
                    self.arrayBlockedUser.remove(at: sender.tag)
                }
                self.tbleViewBlockedUser.reloadData()
            }
        }, param: parameters)
    }
}

class BlockedUserCell : UITableViewCell {
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var btnUnblock: UIButton!
}
