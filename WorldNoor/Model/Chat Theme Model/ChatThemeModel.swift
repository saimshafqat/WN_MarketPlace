//
//  .swift
//  WorldNoor
//
//  Created by Waseem Shah on 30/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ChatThemeModel : ResponseModel {
    
    var color_code = ""
    var color_id = ""
  
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        self.color_code = self.ReturnValueCheck(value: dictionary["color_code"] as Any)
        self.color_id = self.ReturnValueCheck(value: dictionary["color_id"] as Any)
    }
}
