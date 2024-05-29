//
//  FriendChatModel.swift
//  WorldNoor
//
//  Created by apple on 5/15/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class FriendChatModel :ResponseModel {
    
    
    var email = ""
    var firstname = ""
    var lastname = ""
    var name = ""
    var latest_coversation_id = ""

    var phone = ""
    var profile_image = ""
    var username = ""
    var isSelect = false
    var id = ""
    var is_online = ""
    
    override init() {
        super.init()
    }
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        let latestConversationID = self.ReturnValueCheck(value: dictionary["latest_coversation_id"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.email = self.ReturnValueCheck(value: dictionary["email"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.latest_coversation_id = self.ReturnValueCheck(value: dictionary["latest_conversation_id"] as Any)

        if self.latest_coversation_id == "" {
            if latestConversationID != "" {
                self.latest_coversation_id = latestConversationID
            }
        }
        self.phone = self.ReturnValueCheck(value: dictionary["phone"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.is_online = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.name = self.firstname + " " + self.lastname
    }
}
