//
//  ContactsList.swift
//  kalam
//
//  Created by mac on 24/10/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation

struct ContactsList{
    
    var id : Int!
    var kalamNumber : String!
    var name : String!
    var number : String!
    var profileImage : String!
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        id = dictionary["id"] as? Int
        kalamNumber = dictionary["kalam_number"] as? String
        name = dictionary["name"] as? String
        number = dictionary["number"] as? String
        profileImage = dictionary["profile_image"] as? String
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if id != nil{
            dictionary["id"] = id
        }
        if kalamNumber != nil{
            dictionary["kalam_number"] = kalamNumber
        }
        if name != nil{
            dictionary["name"] = name
        }
        if number != nil{
            dictionary["number"] = number
        }
        if profileImage != nil{
            dictionary["profile_image"] = profileImage
        }
        return dictionary
    }
    
}
