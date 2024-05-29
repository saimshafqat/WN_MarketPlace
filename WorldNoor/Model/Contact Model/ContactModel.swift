//
//  ContactModel.swift
//  WorldNoor
//
//  Created by apple on 1/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation


class ContactModel : ResponseModel {
    
    var id = ""
    var firstname = ""
    var lastname = ""
    var latest_conversation_id = ""
    var profile_image = ""
    var username = ""
    
    var contactGroup = [ContactModelGroup]()
    
    
    override init() {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        LogClass.debugLog("<=====   dictionary ====>")
        LogClass.debugLog(dictionary)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.latest_conversation_id = self.ReturnValueCheck(value: dictionary["latest_conversation_id"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        
        
        self.contactGroup.removeAll()
        let groupArray =  dictionary["contact_groups_list"] as! [[String : Any]]
        for indexObj in groupArray {
            self.contactGroup.append(ContactModelGroup.init(fromDictionary: indexObj))
        }
        
    }
}


class ContactModelGroup : ResponseModel {
    
    var id = ""
    var title = ""
    
    override init() {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
    }
}

