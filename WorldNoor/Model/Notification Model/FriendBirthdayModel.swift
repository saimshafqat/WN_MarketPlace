//
//  FriendBirthdayModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 12/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class FriendBirthdayModel : ResponseModel {
    
    var friendID = ""
    var firstName = ""
    var lastName = ""
    var userName = ""
    var profileImage = ""
    var dateOfBirth = ""
    var age = ""
    var formattedDate = ""
            
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.friendID = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.firstName = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastName = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.userName = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.profileImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.dateOfBirth = self.ReturnValueCheck(value: dictionary["dob"] as Any)
        self.age = self.ReturnValueCheck(value: dictionary["user_age"] as Any)
        self.formattedDate = self.ReturnValueCheck(value: dictionary["formatted_date"] as Any)
    }
}
