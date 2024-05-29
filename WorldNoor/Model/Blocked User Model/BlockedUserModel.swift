//
//  BlockedUserModel.swift
//  WorldNoor
//
//  Created by apple on 4/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class BlockedUserModel : ResponseModel {
    
    var firstname = ""
    var id = ""
    var lastname = ""
    var profile_image = ""
    var user_id = "" // Underscore REmove
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.user_id = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
    }
}
