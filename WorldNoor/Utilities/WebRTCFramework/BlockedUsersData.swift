//
//  BlockedUsersData.swift
//  kalam
//
//  Created by mac on 21/07/2020.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation

struct BlockedUsersData{

    var blockId : Int!
    var country : String!
    var countryCode : Int!
    var hideProfilePicture : Int!
    var name : String!
    var nickname : String!
    var phone : String!
    var profileImage : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        blockId = dictionary["block_id"] as? Int
        country = dictionary["country"] as? String
        countryCode = dictionary["country_code"] as? Int
        hideProfilePicture = dictionary["hide_profile_picture"] as? Int
        name = dictionary["name"] as? String
        nickname = dictionary["nickname"] as? String
        phone = dictionary["phone"] as? String
        profileImage = dictionary["profile_image"] as? String
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if nickname != nil{
            dictionary["nickname"] = nickname
        }
        if blockId != nil{
            dictionary["block_id"] = blockId
        }
        if country != nil{
            dictionary["country"] = country
        }
        if countryCode != nil{
            dictionary["country_code"] = countryCode
        }
        if hideProfilePicture != nil{
            dictionary["hide_profile_picture"] = hideProfilePicture
        }
        if name != nil{
            dictionary["name"] = name
        }
        if phone != nil{
            dictionary["phone"] = phone
        }
        if profileImage != nil{
            dictionary["profile_image"] = profileImage
        }
        return dictionary
    }

}
