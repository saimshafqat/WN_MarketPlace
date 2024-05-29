//
//  ContactsData.swift
//  kalam
//
//  Created by mac on 24/10/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation

struct ContactsData {
    
    var contactsList : [ContactsList]!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        contactsList = [ContactsList]()
        if let contactsListArray = dictionary["contacts_list"] as? [[String:Any]]{
            for dic in contactsListArray{
                let value = ContactsList(fromDictionary: dic)
                contactsList.append(value)
            }
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if contactsList != nil{
            var dictionaryElements = [[String:Any]]()
            for contactsListElement in contactsList {
                dictionaryElements.append(contactsListElement.toDictionary())
            }
            dictionary["contacts_list"] = dictionaryElements
        }
        return dictionary
    }
    
}
