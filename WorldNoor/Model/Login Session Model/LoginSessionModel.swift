//
//  LoginSessionModel.swift
//  WorldNoor
//
//  Created by apple on 4/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class LoginSessionModel : ResponseModel {
  var created_at = ""
    var device_ip = ""
    var device_user_agent = ""
    var id = ""
    var token = ""
    
    init(fromDictionary dictionary: [String:Any]){
           super.init()

        self.created_at = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        self.device_ip = self.ReturnValueCheck(value: dictionary["device_ip"] as Any)
        self.device_user_agent = self.ReturnValueCheck(value: dictionary["device_user_agent"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.token = self.ReturnValueCheck(value: dictionary["token"] as Any)
    }
}
