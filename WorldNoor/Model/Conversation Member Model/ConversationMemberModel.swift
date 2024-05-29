//
//  ConversationMemberModel.swift
//  WorldNoor
//
//  Created by apple on 9/22/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ConversationMemberModel :ResponseModel {
    
    
    var firstname = ""
    var id = ""
    var is_admin = ""
    var is_online = ""
    var lastname = ""
    var profile_image = ""
    var username = ""
    var nickname = ""
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.is_admin = self.ReturnValueCheck(value: dictionary["is_admin"] as Any)
        self.is_online = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.nickname = self.ReturnValueCheck(value: dictionary["nickname"] as Any)
    }
}
