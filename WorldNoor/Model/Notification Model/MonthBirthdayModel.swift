//
//  MonthBirthdayModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class MonthBirthdayModel : ResponseModel {
    
    var monthNumber = ""
    var birthdaysList = [FriendBirthdayModel]()
            
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.monthNumber = self.ReturnValueCheck(value: dictionary["month"] as Any)
        
        self.birthdaysList.removeAll()

        if let indexArray = dictionary["birthdays"] as? [[String : Any]] {
            for objMain in indexArray {
                self.birthdaysList.append(FriendBirthdayModel.init(fromDictionary: objMain))
            }
        }
    }
}
