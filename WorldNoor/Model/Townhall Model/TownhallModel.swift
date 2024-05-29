//
//  Townhall Model.swift
//  WorldNoor
//
//  Created by apple on 1/24/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation

class TownhallModel : ResponseModel {

    var area = ""
    var city = ""
    var country_name = ""
    var county = ""
    var designation = ""
    var designation_id = ""
    var designation_level = ""
    var elected_in = ""
    var email = ""
    var id = ""
    var page_cover_image = ""
    var page_description = ""
    var page_follower_counts = ""
    var page_id = ""
    var page_like_count = ""
    var page_profile_image = ""
    var page_title = ""
    var phone = ""
    var state = ""
    var state_id = ""
    var url_slug = ""
    var user_city = ""
    var user_state = ""
    var username = ""
    
    override init() {
    }
        
    init(fromDictionary dictionary: [String:Any]){
        super.init()
           
        self.area = self.ReturnValueCheck(value: dictionary["area"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.country_name = self.ReturnValueCheck(value: dictionary["country_name"] as Any)
        self.county = self.ReturnValueCheck(value: dictionary["county"] as Any)
        self.designation = self.ReturnValueCheck(value: dictionary["designation"] as Any)
        self.designation_id = self.ReturnValueCheck(value: dictionary["designation_id"] as Any)
        self.designation_level = self.ReturnValueCheck(value: dictionary["designation_level"] as Any)
        self.elected_in = self.ReturnValueCheck(value: dictionary["elected_in"] as Any)
        self.email = self.ReturnValueCheck(value: dictionary["email"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.page_cover_image = self.ReturnValueCheck(value: dictionary["page_cover_image"] as Any)
        self.page_description = self.ReturnValueCheck(value: dictionary["page_description"] as Any)
        self.page_follower_counts = self.ReturnValueCheck(value: dictionary["page_follower_counts"] as Any)
        self.page_id = self.ReturnValueCheck(value: dictionary["page_id"] as Any)
        self.page_like_count = self.ReturnValueCheck(value: dictionary["page_like_count"] as Any)
        self.page_profile_image = self.ReturnValueCheck(value: dictionary["page_profile_image"] as Any)
        self.page_title = self.ReturnValueCheck(value: dictionary["page_title"] as Any)
        self.phone = self.ReturnValueCheck(value: dictionary["phone"] as Any)
        self.state = self.ReturnValueCheck(value: dictionary["state"] as Any)
        self.state_id = self.ReturnValueCheck(value: dictionary["state_id"] as Any)
        self.url_slug = self.ReturnValueCheck(value: dictionary["url_slug"] as Any)
        self.user_city = self.ReturnValueCheck(value: dictionary["user_city"] as Any)
        self.user_state = self.ReturnValueCheck(value: dictionary["user_state"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
    }
}
