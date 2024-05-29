//
//  NotificationProfileModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 02/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class NotificationProfileModel : ResponseModel {
    
    var reaction = ""
    
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.reaction = self.ReturnValueCheck(value: dictionary["reaction"] as Any)
    }
}
