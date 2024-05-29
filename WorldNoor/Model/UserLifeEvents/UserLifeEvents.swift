//
//  UserLifeEvents.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 31/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//


import Foundation

class UserLifeEventsModel: ResponseModel {
    var categoryImage: String = ""
    var categoryId: String = ""
    var creationDate: String = ""
    var eventDescription: String = ""
    var eventName: String = ""
    var eventId: String = ""
    var lifeEventDescription: String = ""
    var lifeEventLocation: String = ""
    var lifeEventTitle: String = ""
    var lifeEventVenue: String = ""
    var lifeEventId: String = ""
    var postId: String = ""
    var privacyStatus: String = ""
    var statusApproval: String = ""
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        self.categoryImage = self.ReturnValueCheck(value: dictionary["categoryImage"] as Any)
        self.categoryId = self.ReturnValueCheck(value: dictionary["category_id"] as Any)
        self.creationDate = self.ReturnValueCheck(value: dictionary["creationDate"] as Any)
        self.eventDescription = self.ReturnValueCheck(value: dictionary["eventDescription"] as Any)
        self.eventName = self.ReturnValueCheck(value: dictionary["eventName"] as Any)
        self.eventId = self.ReturnValueCheck(value: dictionary["event_id"] as Any)
        self.lifeEventDescription = self.ReturnValueCheck(value: dictionary["lifeEventDescription"] as Any)
        self.lifeEventLocation = self.ReturnValueCheck(value: dictionary["lifeEventLocation"] as Any)
        self.lifeEventTitle = self.ReturnValueCheck(value: dictionary["lifeEventTitle"] as Any)
        self.lifeEventVenue = self.ReturnValueCheck(value: dictionary["lifeEventVenue"] as Any)
        self.lifeEventId = self.ReturnValueCheck(value: dictionary["life_event_id"] as Any)
        self.postId = self.ReturnValueCheck(value: dictionary["postId"] as Any)
        self.privacyStatus = self.ReturnValueCheck(value: dictionary["privacy_status"] as Any)
        self.statusApproval = self.ReturnValueCheck(value: dictionary["statusApproval"] as Any)
    }
    
}
