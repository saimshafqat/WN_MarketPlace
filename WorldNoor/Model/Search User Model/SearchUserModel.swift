
//
//  SearchUserModel.swift
//  WorldNoor
//
//  Created by apple on 4/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class SearchUserModel : ResponseModel {
    
    var  already_sent_friend_req = ""
    var author_name = ""
    var city = ""
    var country_name = ""
    var is_my_friend = ""
    var profile_image = ""
    var state_name = ""
    var user_id = ""
    var username = ""
    var conversation_id = ""
    var can_i_send_fr = ""
    var has_sent_req = ""
    
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.already_sent_friend_req = self.ReturnValueCheck(value: dictionary["already_sent_friend_req"] as Any)
        self.can_i_send_fr = self.ReturnValueCheck(value: dictionary["can_i_send_fr"] as Any)
        self.has_sent_req = self.ReturnValueCheck(value: dictionary["has_sent_req"] as Any)
        self.author_name = self.ReturnValueCheck(value: dictionary["author_name"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.country_name = self.ReturnValueCheck(value: dictionary["country_name"] as Any)
        self.is_my_friend = self.ReturnValueCheck(value: dictionary["is_my_friend"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.state_name = self.ReturnValueCheck(value: dictionary["state_name"] as Any)
        self.user_id = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.conversation_id = self.ReturnValueCheck(value: dictionary["conversation_id"] as Any)
        
    }
    
}

