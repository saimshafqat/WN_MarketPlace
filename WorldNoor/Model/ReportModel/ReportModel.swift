//
//  ReportModel.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class ReportModel:NSObject {
    var name = ""
    var id = ""
    var slug = ""
    var isSelected:Bool = false
    
    override init() {
        
    }
    
    init(dict:[String:Any]){
        super.init()
        self.name = self.ReturnValueCheck(value: dict["name"] as Any)
        self.id = self.ReturnValueCheck(value: dict["id"] as Any)
        self.slug = self.ReturnValueCheck(value: dict["slug"] as Any)
    }
    
    func manageReportArray(array:[[String:Any]])->[ReportModel]{
        var reportModelArray:[ReportModel] = [ReportModel]()
        for dic in array {
            let report = ReportModel.init(dict: dic)
            reportModelArray.append(report)
        }
        return reportModelArray
    }
    
    func ReturnValueCheck(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
}
