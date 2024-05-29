//
//  InterestModel.swift
//  WorldNoor
//
//  Created by apple on 1/22/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation


class InterestModel : ResponseModel {

    var id = ""
    var name = ""

    override init() {
          
    }
        
    init(fromDictionary dictionary: [String:Any]){
        super.init()
           
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
    }

}
