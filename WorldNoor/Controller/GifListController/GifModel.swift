//
//  GifModel.swift
//  WorldNoor
//
//  Created by Raza najam on 3/15/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GifModel:NSObject {
    
    var id = ""
    var url = ""
    var isSelected: Bool = false
    
    override init() {
    }
    
    init(dict: [String: Any]) {
        super.init()
        self.id = self.ReturnValueCheck(value: dict["id"] as Any)
        self.url = self.ReturnValueCheck(value: dict["gif_path"] as Any)
    }
    
    func manageReportArray(array: [[String:Any]]) -> [GifModel] {
        var reportModelArray: [GifModel] = [GifModel]()
        for dic in array {
            let report = GifModel.init(dict: dic)
            reportModelArray.append(report)
        }
        return reportModelArray
    }
    
    func ReturnValueCheck(value : Any) -> String {
        
        if let MainValue = value as? Int {
            return String(MainValue)
        } else  if let MainValue = value as? String {
            return MainValue
        } else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
}
