//
//  WebsiteModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 20/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class WebsiteModel: ResponseModel {
    var id = ""
    var link = ""
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.link = self.ReturnValueCheck(value: dictionary["link"] as Any)
    }
}
