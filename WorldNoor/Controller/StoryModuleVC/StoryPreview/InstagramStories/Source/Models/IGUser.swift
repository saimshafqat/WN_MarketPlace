//
//  IGUser.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation

public class IGUser: NSObject {
    public var internalIdentifier = ""
    public var name: String = ""
    public var picture: String = ""
    
    public static func manageUserData(id: String, userName : String , pic : String)->IGUser {
        let userObj = IGUser.init()
        userObj.internalIdentifier = id
        userObj.name = userName ?? ""
        userObj.picture = pic ?? ""
        return userObj
    }
}
