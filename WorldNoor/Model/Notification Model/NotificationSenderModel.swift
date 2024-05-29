//
//  NotificationSenderModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 18/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class NotificationSenderModel : ResponseModel {
    
    var firstName = ""
    var lastName = ""
    var profileImage = ""
    var profileImageThumbnail = "" // like profile image but small size
            
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        // sender object
        self.firstName = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastName = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.profileImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.profileImageThumbnail = self.ReturnValueCheck(value: dictionary["profile_image_thumbnail"] as Any)
    }
}
