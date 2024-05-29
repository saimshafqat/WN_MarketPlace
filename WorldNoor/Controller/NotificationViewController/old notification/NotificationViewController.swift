//
//  NotificationViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    var arrayNotificaiton = [NotificationModel]()
    
    @IBOutlet var tbleViewNotification : UITableView!
    @IBOutlet var lblEmpty : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewNotification.register(UINib.init(nibName: "NotificationOtherCell", bundle: nil), forCellReuseIdentifier: "NotificationOtherCell")
        
        self.getNotification()
        self.lblEmpty.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Notification".localized()
    }
    
    
    func getNotification(){
        let parameters = ["action": "notifications/get_all","token": SharedManager.shared.userToken(), "device" : "ios"]
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                LogClass.debugLog("res ===>")
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let newRes = res as? [String:Any]
                {
                    if let other_notifications = newRes["other_notifications"] as? [[String : Any]]
                    {
                        for indexNotification in other_notifications{
                            self.arrayNotificaiton.append(NotificationModel.init(fromDictionary: indexNotification))
                        }
                    }
                    
                    for indexObj in self.arrayNotificaiton {
                        indexObj.dateMain = indexObj.createdAt.returnDateString(inputformat: "yyyy-MM-dd HH:mm:ss")
                        
                        let timeDif = Date().findDifferecnce(recent: Date(), previous: indexObj.dateMain)
                        
                        if timeDif.month! > 0 {
                            indexObj.notificationDate = String(timeDif.month!) + " month(s) ago".localized()
                        }else if timeDif.day! > 0 {
                            indexObj.notificationDate = String(timeDif.day!) + " day(s) ago".localized()
                        }else if timeDif.hour! > 0 {
                            indexObj.notificationDate = String(timeDif.hour!) + " hour(s) ago".localized()
                        }else if timeDif.minute! > 0 {
                            indexObj.notificationDate = String(timeDif.minute!) + " minute(s) ago".localized()
                        }
                        
                    }
                    self.arrayNotificaiton = self.arrayNotificaiton.sorted(by: { $0.dateMain.compare($1.dateMain) == .orderedDescending })
                    self.lblEmpty.isHidden = false
                    self.tbleViewNotification.isHidden = true
                    if self.arrayNotificaiton.count > 0 {
                        self.lblEmpty.isHidden = true
                        self.tbleViewNotification.isHidden = false
                    }
                    self.tbleViewNotification.reloadData()
                }
            }
        }, param: parameters)
    }
    
    func getMoreNotification() {
        self.arrayNotificaiton.removeAll()
        Loader.startLoading()
        let parameters = [
            "action": "generic_notifications",
            "serviceType": "Node",
            "token": SharedManager.shared.userToken(),
            "is_mobile" : "1"
        ]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    if let other_notifications = newRes["notifications"] as? [[String : Any]]
                    {
                        for indexNotification in other_notifications{
                            self.arrayNotificaiton.append(NotificationModel.init(fromDictionary: indexNotification))
                        }
                        
                        for indexObj in self.arrayNotificaiton {
                            
                            indexObj.createdAt = indexObj.createdAt.utcToLocal(inputformat: "yyyy-MM-dd HH:mm:ss")!
                            indexObj.dateMain = indexObj.createdAt.returnDateString(inputformat: "yyyy-MM-dd HH:mm:ss")
                            
                            let timeDif = Date().findDifferecnce(recent: Date(), previous: indexObj.dateMain)
                            
                            if timeDif.month! > 0 {
                                indexObj.notificationDate = String(timeDif.month!) + " month(s) ago".localized()
                            }else if timeDif.day! > 0 {
                                indexObj.notificationDate = String(timeDif.day!) + " day(s) ago".localized()
                            }else if timeDif.hour! > 0 {
                                indexObj.notificationDate = String(timeDif.hour!) + " hour(s) ago".localized()
                            }else if timeDif.minute! > 0 {
                                indexObj.notificationDate = String(timeDif.minute!) + " minute(s) ago".localized()
                            }else  {
                                indexObj.notificationDate = String(timeDif.second!) + " second(s) ago".localized()
                            }
                        }
                    }
                    
                    
                    self.arrayNotificaiton = self.arrayNotificaiton.sorted(by: { $0.dateMain.compare($1.dateMain) == .orderedDescending })
                    
                    self.getNotification()
                    
                    self.tbleViewNotification.reloadData()
                }
            }
        }, param: parameters)
    }
    
}


extension NotificationViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayNotificaiton.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cellOTher = tableView.dequeueReusableCell(withIdentifier: "NotificationOtherCell", for: indexPath) as! NotificationOtherCell
        
        
        guard let cellOTher = tableView.dequeueReusableCell(withIdentifier: "NotificationOtherCell", for: indexPath) as? NotificationOtherCell else {
            return UITableViewCell()
        }
        
        cellOTher.lblTime.text = self.arrayNotificaiton[indexPath.row].notificationDate
        cellOTher.lblHeading.text = self.arrayNotificaiton[indexPath.row].text
        cellOTher.selectionStyle = .none
        return cellOTher
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arrayNotificaiton[indexPath.row].type == "group-user_invited" || self.arrayNotificaiton[indexPath.row].type == "group-user_joined" {
            
//            let groupViewC = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewGroupDetailVC") as! NewGroupDetailVC
            let groupViewC = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupPostController1") as! GroupPostController1
            let groupValue =  GroupValue()
            
            groupValue.groupID = self.arrayNotificaiton[indexPath.row].group_id
            groupViewC.groupObj = groupValue
            self.navigationController?.pushViewController(groupViewC, animated: true)
            
        } else if "message-processed_successfully" != self.arrayNotificaiton[indexPath.row].type {
            self.loadFeed(id: self.arrayNotificaiton[indexPath.row].group_id)
        }
    }
    
    func loadFeed(id : String) {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token": SharedManager.shared.userToken()]
        
        RequestManagerGen.fetchDataGetNotification(Completion: { (response: Result<(FeedSingleModel), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
                
            case .failure(let error):
                
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    } else {
                        self.ShowAlert(message: "No post found".localized())
                    }
                } else {
                    self.ShowAlert(message: "No post found".localized())
                }
            case .success(let res):
                self.pushNewView(mainBody: res.data!.post!)
            }
        }, param:parameters)
    }
    
    
    func pushNewView(mainBody : FeedData){
    
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        feedController.feedObj = mainBody
        feedController.feedArray = [mainBody]
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
//        UIApplication.topViewController()!.present(feedController, animated: true)
        
        UIApplication.topViewController()!.navigationController?.pushViewController(feedController, animated: true)
        
//        let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FeedNewDetailController") as! FeedNewDetailController
//        feedController.feedObj = mainBody
//        feedController.feedArray = [mainBody]
//        feedController.indexPath = IndexPath.init(row: 0, section: 0)
//        UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
//        UIApplication.topViewController()!.present(feedController, animated: true)
        
    }
}



class NotificationOtherCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblTime : UILabel!
}
