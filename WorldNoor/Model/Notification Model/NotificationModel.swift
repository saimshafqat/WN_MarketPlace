//
//  NotificationModel.swift
//  WorldNoor
//
//  Created by apple on 4/30/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NotificationModel : ResponseModel {
    
    var notificationID = ""
    var type = ""
    var userID = ""
    var senderID = ""
    
    var isRead = ""
    
    var text = ""
    var context = ""
    var dataID = ""    // for page id or group id or post id or user profile or reel id to navigate
    var createdAt = ""
    
    var sender = NotificationSenderModel()
    var additionalData: [String: Any] = [:]
    var reaction = ""
    
    //-----used in old code ??
    var notificationDate = ""
    var dateMain : Date!
    var group_id = ""
    
    
    init(fromDictionary dictionary: [String:Any]) {
        
        super.init()
        
        self.notificationID = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.type = self.ReturnValueCheck(value: dictionary["type"] as Any)
        self.userID = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        self.senderID = self.ReturnValueCheck(value: dictionary["sender_id"] as Any)
        
        self.isRead = self.ReturnValueCheck(value: dictionary["is_read"] as Any)
        
        self.text = self.ReturnValueCheck(value: dictionary["text"] as Any)
        self.context = self.ReturnValueCheck(value: dictionary["context"] as Any)
        self.dataID = self.ReturnValueCheck(value: dictionary["data_id"] as Any)
        self.createdAt = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        
        // sender object
        if let obj = dictionary["sender"] as? [String : Any] {
            self.sender = NotificationSenderModel.init(fromDictionary: obj)
        }
        
        self.formatteNotificationDate()
        
        if let obj2 = dictionary["additional_data"] as? [String : Any] {
            
            if let reaction = obj2["reaction"] as? String  {
                self.reaction = reaction
                
            } else { // here mean nested object
                
                let newDict: [[String : Any]] = obj2.compactMap { key, value in
                    return value as? [String : Any]
                }
                
                let reactionList = newDict.compactMap( { $0["reaction"] })
                self.reaction = (reactionList.first) as? String ?? ""
            }
        }
    }
    
    var notificationFormattedDate: String = ""
    
    func formatteNotificationDate() {
        
        // "created_at": "2023-08-10 09:33:48"
        var formattedDate = ""
        
        self.createdAt = self.createdAt.utcToLocal(inputformat: "yyyy-MM-dd HH:mm:ss")!
        let dateMain = self.createdAt.returnDateString(inputformat: "yyyy-MM-dd HH:mm:ss")
        let timeDif = Date().findDifferecnce(recent: Date(), previous: dateMain)
        
        if timeDif.month! > 0 {
            formattedDate = String(timeDif.week!) + "w"
            
            //String(timeDif.month!) + "M" //" month(s) ago".localized()
        } else if timeDif.day! > 0 {
            formattedDate = String(timeDif.day!) + "d"  //" day(s) ago".localized()
        } else if timeDif.hour! > 0 {
            formattedDate = String(timeDif.hour!) + "h"  //" hour(s) ago".localized()
        } else if timeDif.minute! > 0 {
            formattedDate = String(timeDif.minute!) + "m"  //" minute(s) ago".localized()
        } else {
            formattedDate = String(timeDif.second!) + "s"  //" second(s) ago".localized()
        }
        
        self.notificationFormattedDate = formattedDate
    }
}
