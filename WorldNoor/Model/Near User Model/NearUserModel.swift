//
//  NearUserModel.swift
//  WorldNoor
//
//  Created by apple on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NearUserModel : ResponseModel {
    
    var about_me = ""
    var already_sent_friend_req = ""
    var api_token = ""
    var author_name = ""
    var city  = ""
    var country_id = ""
    var country_name = ""
    var cover_image = ""
    var created_at = ""
    var distance_in_km = ""
    var dob  = ""
    var email  = ""
    var email_verified_at = ""
    var firstname  = ""
    var fr_accepted_notifications_count = ""
    var gender  = ""
    var id  = ""
    var is_my_friend = ""
    var is_online = ""
    var language_id = ""
    var lastname  = ""
    var lat  = ""
    var location_id = ""
    var longitude  = ""
    var password  = ""
    var phone  = ""
    var profile_image = ""
    var remember_token = ""
    var state_id = ""
    var status_id = ""
    var user_id = ""
    var username  = ""
    var can_i_send_fr  = ""
    var friend_status = ""
    
    var interests = [UserInterestModel]()
    
    init(fromDictionary dictionary: [String:Any]) {

        super.init()
        self.friend_status = self.ReturnValueCheck(value: dictionary["friend_status"] as Any)
        self.about_me = self.ReturnValueCheck(value: dictionary["about_me"] as Any)
        self.already_sent_friend_req = self.ReturnValueCheck(value: dictionary["already_sent_friend_req"] as Any)
        
        self.can_i_send_fr = self.ReturnValueCheck(value: dictionary["can_i_send_fr"] as Any)
        self.api_token = self.ReturnValueCheck(value: dictionary["api_token"] as Any)
        self.author_name = self.ReturnValueCheck(value: dictionary["author_name"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.country_id = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        self.country_name = self.ReturnValueCheck(value: dictionary["country_name"] as Any)
        self.cover_image = self.ReturnValueCheck(value: dictionary["cover_image"] as Any)
        self.created_at = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        self.distance_in_km = self.ReturnValueCheck(value: dictionary["distance_in_km"] as Any)
        self.dob = self.ReturnValueCheck(value: dictionary["dob"] as Any)
        self.email = self.ReturnValueCheck(value: dictionary["email"] as Any)
        self.email_verified_at = self.ReturnValueCheck(value: dictionary["email_verified_at"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.fr_accepted_notifications_count = self.ReturnValueCheck(value: dictionary["fr_accepted_notifications_count"] as Any)
        self.gender = self.ReturnValueCheck(value: dictionary["gender"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.is_my_friend = self.ReturnValueCheck(value: dictionary["is_my_friend"] as Any)
        self.is_online = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.language_id = self.ReturnValueCheck(value: dictionary["language_id"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.lat = self.ReturnValueCheck(value: dictionary["lat"] as Any)
        self.location_id = self.ReturnValueCheck(value: dictionary["location_id"] as Any)
        self.longitude = self.ReturnValueCheck(value: dictionary["longitude"] as Any)
        self.password = self.ReturnValueCheck(value: dictionary["password"] as Any)
        self.phone = self.ReturnValueCheck(value: dictionary["phone"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.remember_token = self.ReturnValueCheck(value: dictionary["remember_token"] as Any)
        self.state_id = self.ReturnValueCheck(value: dictionary["state_id"] as Any)
        self.user_id = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        
        
        self.interests.removeAll()
        if let indexArray = dictionary["interests"] as? [[String : Any]] {
            for objMain in indexArray {
                self.interests.append(UserInterestModel.init(fromDictionary: objMain))
            }
        }
    }
}


class UserInterestModel : ResponseModel {
    
    var id  = ""
    var name = ""
    var slug  = ""
    
    init(fromDictionary dictionary: [String:Any]) {

        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.slug = self.ReturnValueCheck(value: dictionary["slug"] as Any)
    }
}
