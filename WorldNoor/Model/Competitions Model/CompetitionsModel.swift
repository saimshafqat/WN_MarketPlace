//
//  CompetitionsModel.swift
//  WorldNoor
//
//  Created by apple on 12/28/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class CompetitionsModel : ResponseModel{
    
    var banner = ""
    var descriptionModel = ""
    var from_date = ""
    var happening = ""
    var has_joined = ""
    var id = ""
    var name = ""
    var now = ""
    var short_description = ""
    var to_date = ""
    var prizesArray = [PrizesModel]()
    
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.banner = self.ReturnValueCheck(value: dictionary["banner"] as Any)
        self.descriptionModel = self.ReturnValueCheck(value: dictionary["description"] as Any)
        self.from_date = self.ReturnValueCheck(value: dictionary["from_date"] as Any)
        self.happening = self.ReturnValueCheck(value: dictionary["happening"] as Any)
        self.has_joined = self.ReturnValueCheck(value: dictionary["has_joined"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.now = self.ReturnValueCheck(value: dictionary["now"] as Any)
        self.short_description = self.ReturnValueCheck(value: dictionary["short_description"] as Any)
        self.to_date = self.ReturnValueCheck(value: dictionary["to_date"] as Any)
        
        
        if let newPrize = dictionary["prizes"] as? [[String : Any]] {
            for indexPrize in newPrize {
                self.prizesArray.append(PrizesModel.init(fromDictionary: indexPrize))
            }
        }
        
        
    }

}



class PrizesModel : ReportModel {
    
    var Id = ""
    var image = ""
    var position = ""
    var title = ""

    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.Id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.image = self.ReturnValueCheck(value: dictionary["image"] as Any)
        self.position = self.ReturnValueCheck(value: dictionary["position"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
        
    }
}


class PointsModel : ReportModel {
    
    var Id = ""
    var activity_name = ""
    var activity_Description = ""
    var points = ""

    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.Id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.activity_name = self.ReturnValueCheck(value: dictionary["activity_name"] as Any)
        self.points = self.ReturnValueCheck(value: dictionary["points"] as Any)
        
    }
}


class LBUSerModel : ReportModel {
    
    var nameModel = ""
    var rank = ""
    var score = ""
    var userCity = ""
    var userCountry = ""
    var userImage = ""
    var userID = ""

    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.nameModel = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.rank = self.ReturnValueCheck(value: dictionary["rank"] as Any)
        self.score = self.ReturnValueCheck(value: dictionary["score"] as Any)
        self.userCity = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.userCountry = self.ReturnValueCheck(value: dictionary["country"] as Any)
        self.userImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.userID = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        
        
    }
}
