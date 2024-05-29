//
//  GenericNotification.swift
//  WorldNoor
//
//  Created by Raza najam on 9/11/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GenericNotification: NSObject {
    static let shared = GenericNotification()
    var notificationCounter = 0
    
    override init() {
        super.init()
//        self.callingNotificationCountService()
    }
    
    func manageGenericNotification(arr:[Any]){
        if arr.count > 0 {
            if let dict = arr[0] as? [String:Any] {
                if let idDict = dict["to_id"] as? [String:Any] {
                    let userID = String(SharedManager.shared.getUserID())
                    if let isMyNotif =  idDict[userID] as? Bool {
                        if isMyNotif {
                            self.notificationCounter = self.notificationCounter + 1
//                            FeedCallBManager.shared.notificationBadgeHandler?()
                            FeedPostBaseViewModel.shared.notificationBadgeHandler?()
                        }
                    }
                }
            }
        }
    }
    
    func resetNotificationCounter(){
        self.notificationCounter = 0
    }
    
    func callingNotificationCountService() {
        
        let parameters = ["action": "app/init",
                          "token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { (response) in
            LogClass.debugLog(response)
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                LogClass.debugLog(res)
                if let dict = res as? [String: Any] {
                    if let counter = dict["all_unseen_notifications_count"] as? Int {
                        self.notificationCounter = counter
                        FeedPostBaseViewModel.shared.notificationBadgeHandler?()
                    }
                }
            }
        }, param: parameters)
    }

}
