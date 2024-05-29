//
//  FriendNotificationVC.swift
//  WorldNoor
//
//  Created by apple on 4/30/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FriendNotificationVC: UIViewController {
    
    var arrayNotificaiton = [FirendRequestModel]()
    
    @IBOutlet var tbleViewNotification : UITableView!
    @IBOutlet var lblText : UILabel!
    @IBOutlet var lblButton : UILabel!
    
    var pageNumber = 1
    var isAPiCall = false
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayNotificaiton = []
        self.tbleViewNotification.register(UINib.init(nibName: "FriendNotificationCell", bundle: nil), forCellReuseIdentifier: "FriendNotificationCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
           refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tbleViewNotification.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        
        
        
        self.isAPiCall = false
        self.arrayNotificaiton.removeAll()
        self.tbleViewNotification.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            pageNumber = 1
            self.getNotification()
            refreshControl.endRefreshing()
        }
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Friend Requests".localized()
        self.lblText.text = "To know who can send you friend requests, check ".localized()
        self.lblButton.text = "Privacy Settings".localized()
        self.isAPiCall = false
        self.arrayNotificaiton.removeAll()
        self.tbleViewNotification.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            pageNumber = 1
            self.getNotification()
        }
    }
    
    
    
    @IBAction func showPrivacyAction(sender : UIButton){
        let settingVC = self.GetView(nameVC: "PrivacySettingVC", nameSB:"Notification" ) as! PrivacySettingVC
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func getNotification() {
        if self.isAPiCall {
           return
        }
        self.isAPiCall = true
        let parameters = [
            "action": "notifications/friend-requests",
            "page" : String(self.pageNumber) ,
            "token": SharedManager.shared.userToken()
        ]
        RequestManager.fetchDataGet(Completion: { (response) in
//            self.arrayNotificaiton.removeAll()
            self.pageNumber = self.pageNumber + 1
            switch response {
            case .failure(let error):
                self.isAPiCall = false
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                LogClass.debugLog("res ===> 2233")
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    if let other_notifications = newRes["contact_notifications"] as? [[String : Any]] {
                        if other_notifications.count > 6 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                                self.isAPiCall = false
                            }
                        }
                        for indexNotification in other_notifications{
                            let newObj = FirendRequestModel.init(fromDictionary: indexNotification)                            
                            if newObj.type == "new_friend_request" {
                                self.arrayNotificaiton.append(newObj)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tbleViewNotification.reloadData()
                    }
                }
            }
        }, param: parameters)
    }
}


extension FriendNotificationVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayNotificaiton.count == 0 && !self.isAPiCall{
         return 5
        }
        return self.arrayNotificaiton.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellOTher = tableView.dequeueReusableCell(withIdentifier: "FriendNotificationCell", for: indexPath) as? FriendNotificationCell else {
           return UITableViewCell()
        }
        cellOTher.stopShimmer()
        if self.arrayNotificaiton.count == 0 {
            cellOTher.startShimmer()
            cellOTher.selectionStyle = .none
            return cellOTher
        }
        if self.arrayNotificaiton.count > indexPath.row {
            cellOTher.lblUserCity.text = self.arrayNotificaiton[indexPath.row].sender_email
            cellOTher.lblUserName.text = self.arrayNotificaiton[indexPath.row].sender_firstname + " " + self.arrayNotificaiton[indexPath.row].sender_lastname

            
            cellOTher.imgViewUser.loadImageWithPH(urlMain:self.arrayNotificaiton[indexPath.row].sender_Image)
            
            self.view.labelRotateCell(viewMain: cellOTher.imgViewUser)
            
            cellOTher.btnAccept?.tag = indexPath.row
            cellOTher.btnReject?.tag = indexPath.row
            cellOTher.btnShowProfile?.tag = indexPath.row
            cellOTher.btnAccept?.addTarget(self, action: #selector(self.acceptAction), for: .touchUpInside)
            cellOTher.btnReject?.addTarget(self, action: #selector(self.rejecttAction), for: .touchUpInside)
            cellOTher.btnShowProfile?.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
            
            cellOTher.selectionStyle = .none
            
            print("indexPath.row ===>")
            print(indexPath.row)
            print(self.arrayNotificaiton.count - 1)
            print(self.isAPiCall)
        }
    
        return cellOTher
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("indexPath.row ===> One")
        print(indexPath.row)
        print("indexPath.row ===> Two")
        
        if indexPath.row == self.arrayNotificaiton.count - 1 {
            self.getNotification()
        }

    }
    
    @objc func showProfile(sender : UIButton){
        if self.arrayNotificaiton.count > sender.tag {
            let vcProfile = self.GetView(nameVC: "ProfileViewController", nameSB: "PostStoryboard") as! ProfileViewController
            vcProfile.otherUserID = self.arrayNotificaiton[sender.tag].sender_id
            vcProfile.otherUserisFriend = "0"
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
        }
    }
    
    @objc func acceptAction(sender : UIButton){
//        SharedManager.shared.showOnWindow()
        if self.arrayNotificaiton.count > sender.tag {
            Loader.startLoading()
            let parameters = ["action": "user/accept_friend_request","token": SharedManager.shared.userToken(), "user_id" : self.arrayNotificaiton[sender.tag].sender_id]
            
            RequestManager.fetchDataPost(Completion: { (response) in
    //            SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        self.arrayNotificaiton.remove(at: sender.tag)
                        self.tbleViewNotification.reloadData()
                    }
                }
            }, param: parameters)
        }
        
    }
    
    @objc func rejecttAction(sender : UIButton){
        
//        SharedManager.shared.showOnWindow()
        if self.arrayNotificaiton.count > sender.tag {
            Loader.startLoading()
            let parameters = ["action": "user/reject_friend_request","token": SharedManager.shared.userToken() , "user_id" : self.arrayNotificaiton[sender.tag].sender_id]
            
            RequestManager.fetchDataPost(Completion: { (response) in
    //            SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    }
                    
                    self.arrayNotificaiton.remove(at: sender.tag)
                    self.tbleViewNotification.reloadData()
                }
            }, param: parameters)
            
        }
        
    }
}


class FriendNotificationCell : UITableViewCell {
    @IBOutlet var imgViewUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblUserCity : UILabel!
    
    @IBOutlet var btnAccept : UIButton?
    @IBOutlet var btnReject : UIButton?
    
    @IBOutlet var btnShowProfile : UIButton?
    
    @IBOutlet var viewShimmerImage : ShimmerView!
    @IBOutlet var viewShimmerName : ShimmerView!
    @IBOutlet var viewShimmerDescription : ShimmerView!
    @IBOutlet var viewShimmerButton : ShimmerView!
    
    
    
    func startShimmer(){
        self.viewShimmerImage.startAnimating()
        self.viewShimmerName.startAnimating()
        self.viewShimmerDescription.startAnimating()
        self.viewShimmerButton.startAnimating()
    }
    
    func stopShimmer(){
        self.viewShimmerImage.stopAnimating()
        self.viewShimmerName.stopAnimating()
        self.viewShimmerDescription.stopAnimating()
        self.viewShimmerButton.stopAnimating()
    }
}
