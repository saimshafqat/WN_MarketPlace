//
//  CitySearchModel.swift
//
//
//  Created by apple on .
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
    

class CityGoogleSearchModel : ResponseModel {
  var formatted_address = ""
    var icon = ""
    var id = ""
    var name = ""
    var place_id = ""
    var reference = ""
    var placeLat = ""
    var placeLng = ""

    init(fromDictionary dictionary: [String:Any]){
           super.init()

        self.formatted_address = self.ReturnValueCheck(value: dictionary["formatted_address"] as Any)
        self.icon = self.ReturnValueCheck(value: dictionary["icon"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.place_id = self.ReturnValueCheck(value: dictionary["place_id"] as Any)
        self.reference = self.ReturnValueCheck(value: dictionary["reference"] as Any)


        if let geometry = dictionary["geometry"] as? [String : Any] {
            if let location = geometry["location"] as? [String : Any] {
                self.placeLat = self.ReturnValueCheck(value: location["lat"]!)
                self.placeLng = self.ReturnValueCheck(value: location["lng"]!)
            }
        }

    }
}
