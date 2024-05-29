//
//  GroupValue.swift
//  WorldNoor
//
//  Created by Raza najam on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupValueData: Codable {
    var groupValue: GroupValue?
    
    enum CodingKeys: String, CodingKey {
        case groupValue = "data"
    }
}

class GroupValue : NSObject, Codable {
    
    var groupID : String = ""
    var slug : String = ""
    var name : String = ""
    var title : String = ""
    var groupName:String = ""
    var groupImage : String = ""
    var groupDesc: String = ""
    var totalMember:String = ""
    var totalFollow:String = ""
    var profilePicture:String = ""
    var totalLikes:String = ""
    var totalReviews:String = ""
    var rating:String = ""
    var reviewRating: String = .emptyString
    var positiveReviews:String = ""
    var negativeReviews:String = ""
    var recommendationReviews:String = ""
    var category_id : String = ""
    var member_request : String = ""
    var category : String = ""
    var cover_photo_path: String = ""
    
    var categories = [String]()
    var categoriesStr = ""
    var isMember:Bool = false
    var isAdmin:Bool = false
    var isFollow:Bool = false
    var isLike:Bool = false
    var privacy = false
    var visibility = false
    var is_reviewd = false
    var is_follower : Bool = false
    var groupMembers = [GroupMembers]()
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
    init(fromDictionary dict: [String:Any]){
        
        super.init()
        self.member_request = self.ReturnValueAsString(value: dict["member_request"] as Any)
        self.category = self.ReturnValueAsString(value: dict["category"] as Any)
        self.slug = self.ReturnValueAsString(value: dict["url_slug"] as Any)
        
        self.visibility = self.ReturnValueAsBool(value: dict["visibility"] as Any)
        self.isAdmin = self.ReturnValueAsBool(value: dict["is_admin"] as Any)
        self.privacy = self.ReturnValueAsBool(value: dict["privacy"] as Any)
        self.is_follower = self.ReturnValueAsBool(value: dict["is_follower"] as Any)
        self.groupName = self.ReturnValueAsString(value: dict["title"] as Any)
        self.category_id = self.ReturnValueAsString(value: dict["category_id"] as Any)
        self.groupImage = self.ReturnValueAsString(value: dict["cover_file_path"] as Any)
        self.cover_photo_path = self.ReturnValueAsString(value: dict["cover_photo_path"] as Any)
        self.groupID = self.ReturnValueAsString(value: dict["id"] as Any)
        self.profilePicture = self.ReturnValueAsString(value: dict["profile_picture_path"] as Any)
        self.totalLikes = self.ReturnValueAsString(value: dict["likes"] as Any)
        self.groupDesc = self.ReturnValueAsString(value: dict["description"] as Any)
        self.totalReviews = self.ReturnValueAsString(value: dict["totalReviews"] as Any)
        self.isMember = false
        self.isAdmin = false
        self.isLike = self.ReturnValueAsBool(value: dict["isLiked"] as Any)
        self.is_reviewd = self.ReturnValueAsBool(value: dict["is_reviewd"] as Any)
        self.rating = self.ReturnValueAsString(value: dict["rating"] as Any)
        self.reviewRating = self.ReturnValueAsString(value: dict["reviewRating"] as Any)
        self.negativeReviews = self.ReturnValueAsString(value: dict["negativeReviews"] as Any)
        self.positiveReviews = self.ReturnValueAsString(value: dict["positiveReviews"] as Any)
        self.recommendationReviews = self.ReturnValueAsString(value: dict["recommendationReviews"] as Any)
        self.totalMember = "0"
        
        self.isMember = self.ReturnValueAsBool(value: dict["has_liked"] as Any)
        self.isFollow = self.ReturnValueAsBool(value: dict["has_followed"] as Any)
        self.isAdmin = self.ReturnValueAsBool(value: dict["is_admin"] as Any)
        self.totalFollow = self.ReturnValueAsString(value: dict["total_follows"] as Any)
        self.totalMember = self.ReturnValueAsString(value: dict["total_members"] as Any)
        self.totalLikes = self.ReturnValueAsString(value: dict["total_likes"] as Any)
        self.isLike = self.ReturnValueAsBool(value: dict["has_liked"] as Any)
        
        
        self.groupMembers.removeAll()
        if let arrayMembers = dict["members"] as? [[String : AnyObject]] {
            for indexObj in arrayMembers {
                self.groupMembers.append(GroupMembers.init(fromDictionary: indexObj))
            }
        }
        
        if let catArray = dict["categories"] as? [String] {
            for indx in catArray {
                self.categories.append(indx)
                if self.categoriesStr.count > 0 {
                    self.categoriesStr = self.categoriesStr + "," + indx
                } else {
                    self.categoriesStr = indx
                }
            }
        }
    }
    
    init(fromDictionaryGroup dict: [String:Any]){
        
        super.init()
        self.slug = self.ReturnValueAsString(value: dict["url_slug"] as Any)
        self.category = self.ReturnValueAsString(value: dict["category"] as Any)
        self.member_request = self.ReturnValueAsString(value: dict["member_request"] as Any)
        self.groupName = self.ReturnValueAsString(value: dict["name"] as Any)
        self.groupImage = self.ReturnValueAsString(value: dict["cover_photo_path"] as Any)
        self.groupID = self.ReturnValueAsString(value: dict["id"] as Any)
        self.profilePicture = self.ReturnValueAsString(value: dict["cover_photo_path"] as Any)
        self.totalLikes = self.ReturnValueAsString(value: dict["total_likes"]  as Any)
        self.groupDesc = self.ReturnValueAsString(value: dict["description"] as Any)
        self.isMember = self.ReturnValueAsBool(value: dict["is_member"] as Any)
        self.isAdmin = self.ReturnValueAsBool(value: dict["is_admin"] as Any)
        self.isLike = self.ReturnValueAsBool(value: dict["has_liked"] as Any)
        self.visibility = self.ReturnValueAsBool(value: dict["visibility"] as Any)
        
        self.privacy = self.ReturnValueAsBool(value: dict["privacy"] as Any)
        self.totalMember = self.ReturnValueAsString(value: dict["members"] as Any)
        
        self.groupMembers.removeAll()
        if let arrayMembers = dict["members"] as? [[String : AnyObject]] {
            for indexObj in arrayMembers {
                self.groupMembers.append(GroupMembers.init(fromDictionary: indexObj))
            }
        }
        
        if let catArray = dict["categories"] as? [String] {
            for indx in catArray {
                self.categories.append(indx)
                if self.categoriesStr.count > 0 {
                    self.categoriesStr = self.categoriesStr + "," + indx
                }else {
                    self.categoriesStr = indx
                }
                
            }
        }
    }
    
    
    func manageGroupData(dict:NSDictionary) {
        self.slug = self.ReturnValueAsString(value: dict["url_slug"] as Any)
        self.category = self.ReturnValueAsString(value: dict["category"] as Any)
        self.member_request = self.ReturnValueAsString(value: dict["member_request"] as Any)
        self.groupName = dict["name"] as! String
        self.groupImage = dict["cover_photo_path"] as! String
        self.groupID = self.ReturnValueAsString(value: dict.value(forKey: "id") as Any)
        self.profilePicture = self.ReturnValueAsString(value: dict.value(forKey: "profile_picture_path") as Any)
        self.totalLikes = self.ReturnValueAsString(value: dict.value(forKey: "total_likes") as Any)
        self.groupDesc = self.ReturnValueAsString(value: dict.value(forKey: "description") as Any)
        self.isMember = self.ReturnValueAsBool(value: dict.value(forKey: "is_member") as Any)
        self.isAdmin = self.ReturnValueAsBool(value: dict.value(forKey: "is_admin") as Any)
        self.isLike = self.ReturnValueAsBool(value: dict.value(forKey: "has_liked") as Any)
        self.visibility = self.ReturnValueAsBool(value: dict.value(forKey: "visibility") as Any)
        self.privacy = self.ReturnValueAsBool(value: dict.value(forKey: "privacy") as Any)
        self.totalMember = self.ReturnValueAsString(value: dict.value(forKey: "total_members") as Any)
        self.rating = self.ReturnValueAsString(value: dict["rating"] as Any)
        self.negativeReviews = self.ReturnValueAsString(value: dict["negativeReviews"] as Any)
        self.positiveReviews = self.ReturnValueAsString(value: dict["positiveReviews"] as Any)
        self.recommendationReviews = self.ReturnValueAsString(value: dict["recommendationReviews"] as Any)
        self.totalReviews = self.ReturnValueAsString(value: dict["totalReviews"] as Any)
        
        self.groupMembers.removeAll()
        if let arrayMembers = dict["members"] as? [[String : AnyObject]] {
            for indexObj in arrayMembers {
                self.groupMembers.append(GroupMembers.init(fromDictionary: indexObj))
            }
        }
        
        if let catArray = dict["categories"] as? [String] {
            for indx in catArray {
                self.categories.append(indx)
                if self.categoriesStr.count > 0 {
                    self.categoriesStr = self.categoriesStr + "," + indx
                }else {
                    self.categoriesStr = indx
                }
                
            }
        }
        
        self.totalFollow = self.ReturnValueAsString(value: dict.value(forKey: "total_follows") as Any)
        self.totalMember = self.ReturnValueAsString(value: dict.value(forKey: "total_members") as Any)
    }
    
    func managePageData(dict:NSDictionary)  {
        self.slug = self.ReturnValueAsString(value: dict["url_slug"] as Any)
        self.category = self.ReturnValueAsString(value: dict["category"] as Any)
        self.member_request = self.ReturnValueAsString(value: dict["member_request"] as Any)
        self.name = dict["title"] as! String
        self.profilePicture = self.ReturnValueAsString(value: dict.value(forKey: "profile_picture_path") as Any)
        
        self.groupImage = dict["cover_file_path"] as! String
        self.groupID = self.ReturnValueAsString(value: dict.value(forKey: "id") as Any)
        self.groupDesc = self.ReturnValueAsString(value: dict.value(forKey: "description") as Any)
        self.isMember = self.ReturnValueAsBool(value: dict.value(forKey: "has_liked") as Any)
        self.isFollow = self.ReturnValueAsBool(value: dict.value(forKey: "has_followed") as Any)
        self.isAdmin = self.ReturnValueAsBool(value: dict.value(forKey: "is_admin") as Any)
        self.totalFollow = self.ReturnValueAsString(value: dict.value(forKey: "total_follows") as Any)
        self.totalMember = self.ReturnValueAsString(value: dict.value(forKey: "total_members") as Any)
        self.totalLikes = self.ReturnValueAsString(value: dict.value(forKey: "total_likes") as Any)
        self.isLike = self.ReturnValueAsBool(value: dict.value(forKey: "has_liked") as Any)
        
        if let catArray = dict["categories"] as? [String] {
            for indx in catArray {
                self.categories.append(indx)
                if self.categoriesStr.count > 0 {
                    self.categoriesStr = self.categoriesStr + "," + indx
                }else {
                    self.categoriesStr = indx
                }
                
            }
        }
        self.rating = self.ReturnValueAsString(value: dict["rating"] as Any)
        self.reviewRating = self.ReturnValueAsString(value: dict["reviewRating"] as Any)
        self.negativeReviews = self.ReturnValueAsString(value: dict["negativeReviews"] as Any)
        self.positiveReviews = self.ReturnValueAsString(value: dict["positiveReviews"] as Any)
        self.recommendationReviews = self.ReturnValueAsString(value: dict["recommendationReviews"] as Any)
        self.totalReviews = self.ReturnValueAsString(value: dict["totalReviews"] as Any)
    }
    
    func manageImageData(dict:NSDictionary)  {
        self.title = dict["title"] as! String
        self.groupImage = dict["file_path"] as! String
        self.name = dict["author_name"] as! String
        self.slug = self.ReturnValueAsString(value: dict["url_slug"] as Any)
    }
    
    func ReturnValueAsString(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
    
    func ReturnValueAsBool(value : Any) -> Bool{
        if let MainValue = value as? Int {
            if MainValue == 1 {
                return true
            }
        }else  if let MainValue = value as? String {
            if MainValue == "1" {
                return true
            }
        }
        return false
    }
}



class GroupMembers : ResponseModel {
    var firstname : String = ""
    var is_admin : String = ""
    var is_follower : String = ""
    var is_member : String = ""
    var lastname : String = ""
    var profile_image : String = ""
    var role_id : String = ""
    var user_id : String = ""
    var idMain : String = ""
    
    override init() {
        super.init()
    }
    
    

    
    init(fromDictionary dict: [String:Any]){
        
        super.init()
        
        self.firstname = self.ReturnValueCheck(value: dict["firstname"] as Any)
        self.is_admin = self.ReturnValueCheck(value: dict["is_admin"] as Any)
        self.idMain = self.ReturnValueCheck(value: dict["id"] as Any)
        self.is_follower = self.ReturnValueCheck(value: dict["is_follower"] as Any)
        self.is_member = self.ReturnValueCheck(value: dict["is_member"] as Any)
        self.lastname = self.ReturnValueCheck(value: dict["lastname"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dict["profile_image"] as Any)
        self.role_id = self.ReturnValueCheck(value: dict["role_id"] as Any)
        self.user_id = self.ReturnValueCheck(value: dict["user_id"] as Any)
        
        
    }
}
