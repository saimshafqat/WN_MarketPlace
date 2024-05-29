//
//  FriendSuggestionModel.swift
//  WorldNoor
//
//  Created by apple on 1/27/23.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class FriendSuggestionModel : ResponseModel {
    
    var firstname = ""
    var id = ""
    var lastname = ""
    var profile_image = ""
    var username = ""
    var already_sent_friend_req = ""
    var arrayMutual = [FriendSuggestionFriends]()
    var mutualFriendsCount = ""
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.mutualFriendsCount = self.ReturnValueCheck(value: dictionary["mutualFriendsCount"] as Any)
        
        self.arrayMutual.removeAll()
        
        if let indexArray = dictionary["mutualFriends"] as? [[String : Any]] {
            for objMain in indexArray {
                self.arrayMutual.append(FriendSuggestionFriends.init(fromDictionary: objMain))
            }
        }
    }
}



class FriendSuggestionFriends : ResponseModel {
    
    var profile_image = ""

    init(fromDictionary dictionary: [String: Any]){
        super.init()
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
    }
}
