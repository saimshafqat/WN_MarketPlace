//
//  KidsInfoModel.swift
//  WorldNoor
//
//  Created by apple on 8/30/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class KidsInfoModel : ResponseModel{
    
    var about_me = ""
    var api_token = ""
    var city = ""
    var city_id = ""
    var country_code = ""
    var country_id = ""
    var cover_image = ""
    var dob = ""
    var email = ""
    var firstname = ""
    var email_verified_at = ""
//    var firstname = ""
    var fr_accepted_notifications_count = ""
    var gender = ""
    var id = ""
    var is_online = ""
    var language_id = ""
    var lastname = ""
    var mobile_banner_flag = ""
    var parent_id = ""
    var phone = ""
    var postal_code_id = ""
    var profile_image = ""
    var state_id = ""
    var status_id = ""
    var ui_language_id = ""
    var username = ""
    var website = ""
    
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.about_me = self.ReturnValueCheck(value: dictionary["about_me"] as Any)
        self.api_token = self.ReturnValueCheck(value: dictionary["api_token"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.city_id = self.ReturnValueCheck(value: dictionary["city_id"] as Any)
        self.country_code = self.ReturnValueCheck(value: dictionary["country_code"] as Any)
        self.country_id = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        self.cover_image = self.ReturnValueCheck(value: dictionary["cover_image"] as Any)
        self.dob = self.ReturnValueCheck(value: dictionary["dob"] as Any)
        self.email = self.ReturnValueCheck(value: dictionary["email"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.email_verified_at = self.ReturnValueCheck(value: dictionary["email_verified_at"] as Any)
//        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.fr_accepted_notifications_count = self.ReturnValueCheck(value: dictionary["fr_accepted_notifications_count"] as Any)
        self.gender = self.ReturnValueCheck(value: dictionary["gender"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.is_online = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.language_id = self.ReturnValueCheck(value: dictionary["language_id"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.mobile_banner_flag = self.ReturnValueCheck(value: dictionary["mobile_banner_flag"] as Any)
        self.parent_id = self.ReturnValueCheck(value: dictionary["parent_id"] as Any)
        self.phone = self.ReturnValueCheck(value: dictionary["phone"] as Any)
        self.postal_code_id = self.ReturnValueCheck(value: dictionary["postal_code_id"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.state_id = self.ReturnValueCheck(value: dictionary["state_id"] as Any)
        self.status_id = self.ReturnValueCheck(value: dictionary["status_id"] as Any)
        self.ui_language_id = self.ReturnValueCheck(value: dictionary["ui_language_id"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.website = self.ReturnValueCheck(value: dictionary["website"] as Any)
        
    }

}


