//
//  FirendRequestModel.swift
//  WorldNoor
//
//  Created by apple on 5/2/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class FirendRequestModel :ResponseModel {
    
    var additional_data = ""
    var context = ""
    var created_at = ""
    var data_id = ""
    var id = ""
    var is_read = ""
    var is_seen = ""
    
    var sender_id = ""
    var sender_Image = ""
    var sender_email = ""
    var sender_firstname = ""
    var sender_lastname = ""
    
    var text = ""
    var type = ""
    var user_id = ""
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.additional_data = self.ReturnValueCheck(value: dictionary["additional_data"] as Any)
        self.context = self.ReturnValueCheck(value: dictionary["context"] as Any)
        self.created_at = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        self.data_id = self.ReturnValueCheck(value: dictionary["data_id"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.is_read = self.ReturnValueCheck(value: dictionary["is_read"] as Any)
        self.is_seen = self.ReturnValueCheck(value: dictionary["is_seen"] as Any)
        self.text = self.ReturnValueCheck(value: dictionary["text"] as Any)
        self.type = self.ReturnValueCheck(value: dictionary["type"] as Any)
        self.user_id = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        
        self.sender_id = self.ReturnValueCheck(value: dictionary["sender_id"] as Any)
        
        
        if let senderObj = dictionary["sender"] as? [String : AnyObject] {
            self.sender_Image = self.ReturnValueCheck(value: senderObj["profile_image_thumbnail"] as Any)
            self.sender_email = self.ReturnValueCheck(value: senderObj["email"] as Any)
            self.sender_firstname = self.ReturnValueCheck(value: senderObj["firstname"] as Any)
            self.sender_lastname = self.ReturnValueCheck(value: senderObj["lastname"] as Any)
        }
        
    }
}

