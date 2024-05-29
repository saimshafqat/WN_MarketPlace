//
//  NotificationDataModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 07/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class SuggestedFriendModel : ResponseModel {
    
    var friendID = ""
    var profileImage = ""
    var firstname = ""
    var lastname = ""
    var username = ""
    var mutualFriendsList = [FriendSuggestionFriends]()
    var mutualFriendsCount = ""
    
    var isFriendRequestSent = false
            
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.friendID = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.profileImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.mutualFriendsCount = self.ReturnValueCheck(value: dictionary["mutualFriendsCount"] as Any)
        
        self.mutualFriendsList.removeAll()

        if let indexArray = dictionary["mutualFriends"] as? [[String : Any]] {
            for objMain in indexArray {
                self.mutualFriendsList.append(FriendSuggestionFriends.init(fromDictionary: objMain))
            }
        }
    }
}
