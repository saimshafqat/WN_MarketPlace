//
//  AppsNotificationModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 08/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class AppsNotificationModel : ResponseModel {
    
    var app = ""
    var poshID = ""
    var title = ""
    var type = ""
    var key = ""
    var count = ""
            
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.app = self.ReturnValueCheck(value: dictionary["app"] as Any)
        self.poshID = self.ReturnValueCheck(value: dictionary["posh_id"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
        self.type = self.ReturnValueCheck(value: dictionary["type"] as Any)
        self.key = self.ReturnValueCheck(value: dictionary["key"] as Any)
        self.count = self.ReturnValueCheck(value: dictionary["count"] as Any)
    }
}

// apu response
//"app":"kalamtime",
//     "posh_id":"bfeedebb-cb44-4ef2-8d0d-2d1d1e514cad",
//     "title":"13 New Messages",
//     "type":"messages",
//     "key":"message_count",
//     "count":"13",
//     "source":{
//
//     },
//     "timestamp":1702007667144,
//     "links":{
//        "web":"https://kalamtime.com/staging/#/poshauth/?wntoken=3c9762ecf32b982221df9629465420cea16f78764f9f0d90a9fbb1f9d43ca1adbde593bffd5f7729c3d202aee5689c289388d6c8f91bae80db8dbc25&poshid=bfeedebb-cb44-4ef2-8d0d-2d1d1e514cad",
//        "android":"",
//        "ios":""
//     }
