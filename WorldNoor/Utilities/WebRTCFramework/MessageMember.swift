//
//  MessageMember.swift
//  kalam
//
//  Created by mac on 23/04/2020.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation

struct MessageMember {

    var firstname : String!
    var hideProfilePicture : Int!
    var id : Int!
    var lastname : String!
    var profileImage : String!
    var showRemoteView = false
    var sessionId : String!



    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        firstname = dictionary["firstname"] as? String
        hideProfilePicture = dictionary["hide_profile_picture"] as? Int
        id = dictionary["id"] as? Int
        lastname = dictionary["lastname"] as? String
        profileImage = dictionary["profile_image"] as? String
showRemoteView = dictionary["showRemoteView"] as? Bool ?? false
        sessionId = dictionary["sessionId"] as? String

    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if firstname != nil{
            dictionary["firstname"] = firstname
        }
        if hideProfilePicture != nil{
            dictionary["hide_profile_picture"] = hideProfilePicture
        }
        if id != nil{
            dictionary["id"] = id
        }
        if lastname != nil{
            dictionary["lastname"] = lastname
        }
        if profileImage != nil{
            dictionary["profile_image"] = profileImage
        }
if showRemoteView != nil{
    dictionary["showRemoteView"] = showRemoteView
}
        if sessionId != nil{
            dictionary["sessionId"] = sessionId
        }

        return dictionary
    }

}
