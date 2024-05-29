//
//  UserProfile.swift
//  WorldNoor
//
//  Created by apple on 1/13/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation

//class PageGroupModel: ResponseModel {
//    var category: String = .emptyString
//    var categoryId: String = .emptyString
//    var colorCode: String? = .emptyString
//    var coverPhotoPath: String = .emptyString
//    var createdAt: String = .emptyString
//    var summaryDescription: String = .emptyString
//    var id: String = .emptyString
//    var isAdmin: String = .emptyString
//    var isFollower: String = .emptyString
//    var isMember: String = .emptyString
//    var memberRequest: String = .emptyString
//    var name: String = .emptyString
//    var privacy: String = .emptyString
//    var searchSuggestionType: String = .emptyString
//    var totalMembers: String = .emptyString
//    var urlSlug: String = .emptyString
//    var visibility: String = .emptyString
//    init(fromDictionary dictionary: [String:Any]) {
//        super.init()
//        self.category = self.ReturnValueCheck(value: dictionary["category"] as Any)
//        self.categoryId = self.ReturnValueCheck(value: dictionary["categoryId"] as Any)
//        self.colorCode = self.ReturnValueCheck(value: dictionary["colorCode"] as Any)
//        self.coverPhotoPath = self.ReturnValueCheck(value: dictionary["coverPhotoPath"] as Any)
//        self.createdAt = self.ReturnValueCheck(value: dictionary["createdAt"] as Any)
//        self.summaryDescription = self.ReturnValueCheck(value: dictionary["description"] as Any)
//        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
//        self.isAdmin = self.ReturnValueCheck(value: dictionary["isAdmin"] as Any)
//        self.isFollower = self.ReturnValueCheck(value: dictionary["isFollower"] as Any)
//        self.isMember = self.ReturnValueCheck(value: dictionary["isMember"] as Any)
//        self.memberRequest = self.ReturnValueCheck(value: dictionary["memberRequest"] as Any)
//        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
//        self.privacy = self.ReturnValueCheck(value: dictionary["privacy"] as Any)
//        self.searchSuggestionType = self.ReturnValueCheck(value: dictionary["searchSuggestionType"] as Any)
//        self.totalMembers = self.ReturnValueCheck(value: dictionary["totalMembers"] as Any)
//        self.urlSlug = self.ReturnValueCheck(value: dictionary["urlSlug"] as Any)
//        self.visibility = self.ReturnValueCheck(value: dictionary["visibility"] as Any)
//    }
//}



class LikePageModel: ResponseModel {
    
    var name: String = .emptyString
    var pageId: String = .emptyString
    var profile: String? = .emptyString
    var slug: String = .emptyString
    var title: String = .emptyString
    var userId: String = .emptyString

    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.pageId = self.ReturnValueCheck(value: dictionary["page_id"] as Any)
        self.profile = self.ReturnValueCheck(value: dictionary["profile"] as Any)
        self.slug = self.ReturnValueCheck(value: dictionary["slug"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
        self.userId = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
    }
}

class UserProfile : ResponseModel {
    
    var aboutme = ""
    var isGoogleAccount = ""
    var isProfileCompleted = ""
    var address = ""
    var city = ""
    var country = ""
    var coverImage = ""
    var dob = ""
    var email = ""
    var firstname = ""
    var gender = ""
    var genderPronounc = ""
    var lastname = ""
    var phone = ""
    var otp_id = ""
    var countryCode = ""
    var profileImage = ""
    var state = ""
    var institutes = [UserInstitutes]()
    var places = [UserPlaces]()
    var workExperiences = [UserWorkExperiences]()
    var websiteArray = [WebsiteModel]()
    var InterestArray = [InterestModel]()
    var languayeArray = [LanguageModel]()
    var relationshipArray = [RelationshipModel]()
    var familyRelationshipArray = [RelationshipModel]()
    var userLifeEventsArray = [UserLifeEventsModel]()
    var gameArray = [LikePageModel]()
    var movieArray = [LikePageModel]()
    var sportArray = [LikePageModel]()
    var tvShowArray = [LikePageModel]()
    var bookArray = [LikePageModel]()
    var musicArray = [LikePageModel]()
    var athleteArray = [LikePageModel]()
    var groupArray = [GroupValue]()

    var is_blocked_by_me = ""
    var dob_privacy = ""
    var can_i_send_fr = ""
    var phone_privacy = ""
    var id = ""
    var is_friend = ""
    var has_sent_req = ""
    var pronoun = ""
    var custom_gender = ""
    var currency: UserCurrency? = nil
    var username = ""
    
    override init() {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()

        self.custom_gender = self.ReturnValueCheck(value: dictionary["custom_gender"] as Any)
        self.pronoun = self.ReturnValueCheck(value: dictionary["pronoun"] as Any)
        self.aboutme = self.ReturnValueCheck(value: dictionary["about_me"] as Any)
        self.isGoogleAccount = self.ReturnValueCheck(value: dictionary["is_google_account"] as Any)
        self.isProfileCompleted = self.ReturnValueCheck(value: dictionary["is_profile_completed"] as Any)
        self.is_blocked_by_me = self.ReturnValueCheck(value: dictionary["is_blocked_by_me"] as Any)
        self.otp_id = self.ReturnValueCheck(value: dictionary["otp_id"] as Any)
        self.has_sent_req = self.ReturnValueCheck(value: dictionary["has_sent_req"] as Any)
        self.is_friend = self.ReturnValueCheck(value: dictionary["is_friend"] as Any)
        self.address = self.ReturnValueCheck(value: dictionary["address"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.country = self.ReturnValueCheck(value: dictionary["country"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.coverImage = self.ReturnValueCheck(value: dictionary["cover_image"] as Any)
        self.dob = self.ReturnValueCheck(value: dictionary["dob"] as Any)
        self.email = self.ReturnValueCheck(value: dictionary["email"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.gender = self.ReturnValueCheck(value: dictionary["gender"] as Any)
        self.genderPronounc = self.ReturnValueCheck(value: dictionary["pronoun"] as Any)
        
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.phone = self.ReturnValueCheck(value: dictionary["phone"] as Any)
        self.profileImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.state = self.ReturnValueCheck(value: dictionary["state"] as Any)
        self.countryCode = self.ReturnValueCheck(value: dictionary["country_code"] as Any)
        self.can_i_send_fr = self.ReturnValueCheck(value: dictionary["can_i_send_fr"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        
        self.currency = UserCurrency(fromDictionary: dictionary["currency"] as? [String: Any] ?? [:])
        
        self.institutes.removeAll()
        let institutesArray =  dictionary["institutes"] as! [[String : Any]]
        for indexObj in institutesArray {
            self.institutes.append(UserInstitutes.init(fromDictionary: indexObj))
        }
        self.places.removeAll()
        let placessArray =  dictionary["places"] as! [[String : Any]]
        for indexObj in placessArray {
            self.places.append(UserPlaces.init(fromDictionary: indexObj))
        }
        
        self.workExperiences.removeAll()
        let workArray =  dictionary["work_experiences"] as! [[String : Any]]
        for indexObj in workArray {
            self.workExperiences.append(UserWorkExperiences.init(fromDictionary: indexObj))
        }
        
        self.InterestArray.removeAll()
        let InterestArrayLocal =  dictionary["intersets"] as! [[String : Any]]
        for indexObj in InterestArrayLocal {
            self.InterestArray.append(InterestModel.init(fromDictionary: indexObj))
        }
        // language array
        self.languayeArray.removeAll()
        let languageArrayLocal = dictionary["languages"] as? [[String: Any]] ?? []
        for indexObj in languageArrayLocal {
            self.languayeArray.append(LanguageModel.init(fromDictionary: indexObj))
        }
        // relationship
        self.relationshipArray.removeAll()
        let relationshipArrayLocal = dictionary["relationships"] as? [[String: Any]] ?? []
        for indexObj in relationshipArrayLocal {
            self.relationshipArray.append(RelationshipModel.init(fromDictionary: indexObj))
        }
        // family relationship
        self.familyRelationshipArray.removeAll()
        let familyRelationshipArrayLocal = dictionary["family_relationships"] as? [[String: Any]] ?? []
        for indexObj in familyRelationshipArrayLocal {
            self.familyRelationshipArray.append(RelationshipModel.init(fromDictionary: indexObj))
        }
        // website
        self.websiteArray.removeAll()
        let websiteArrayLocal = dictionary["websites"] as? [[String: Any]] ?? []
        for indexObj in websiteArrayLocal {
            self.websiteArray.append(WebsiteModel(fromDictionary: indexObj))
        }
        
        // user life events
        self.userLifeEventsArray.removeAll()
        let userLifeEvents = dictionary["userLifeEvents"] as? [[String: Any]] ?? []
        for indexObj in userLifeEvents {
            self.userLifeEventsArray.append(UserLifeEventsModel(fromDictionary: indexObj))
        }
        
        let likePages = dictionary["liked_pages"] as? [String: Any] ?? [:]
        // Games
        gameArray.removeAll()
        let gamesList = likePages["game"] as? [[String: Any]] ?? []
        for indexObj in gamesList {
            gameArray.append(LikePageModel(fromDictionary: indexObj))
        }

        // Movie
        movieArray.removeAll()
        let movieList = likePages["movie"] as? [[String: Any]] ?? []
        for indexObj in movieList {
            movieArray.append(LikePageModel(fromDictionary: indexObj))
        }

        // Sports
        sportArray.removeAll()
        let sportsList = likePages["sport"] as? [[String: Any]] ?? []
        for indexObj in sportsList {
            sportArray.append(LikePageModel(fromDictionary: indexObj))
        }

        // Tv
        tvShowArray.removeAll()
        let tvShowsList = likePages["tv"] as? [[String: Any]] ?? []
        for indexObj in tvShowsList {
            tvShowArray.append(LikePageModel(fromDictionary: indexObj))
        }
        
        // Book
        bookArray.removeAll()
        let bookList = likePages["book"] as? [[String: Any]] ?? []
        for indexObj in bookList {
            bookArray.append(LikePageModel(fromDictionary: indexObj))
        }
        
        // athlete
        athleteArray.removeAll()
        let athleteList = likePages["athlete"] as? [[String: Any]] ?? []
        for indexObj in athleteList {
            athleteArray.append(LikePageModel(fromDictionary: indexObj))
        }
        
        // music
        musicArray.removeAll()
        let musicList = likePages["music"] as? [[String: Any]] ?? []
        for indexObj in musicList {
            musicArray.append(LikePageModel(fromDictionary: indexObj))
        }

        // group
        groupArray.removeAll()
        let groupList = dictionary["joined_groups"] as? [[String: Any]] ?? []
        for indexObj in groupList {
            groupArray.append(GroupValue(fromDictionaryGroup: indexObj))
        }

        if let settingsObj = dictionary["settings"] as? [String : Any] {
            self.dob_privacy = self.ReturnValueCheck(value: settingsObj["dob_privacy"] as Any)
            self.phone_privacy = self.ReturnValueCheck(value: settingsObj["phone_privacy"] as Any)
        }

        if self.gender.count == 0 {
            self.gender = self.pronoun + "(" + self.custom_gender + ")"
        }
    }
}

class UserCurrency: ResponseModel {
    var id: String = ""
    var name: String = ""
    var symbol: String = ""
    var isSelected: Bool?
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.symbol = self.ReturnValueCheck(value: dictionary["symbol"] as Any)
    }
}

class UserPlaces : ResponseModel {
    var  address = ""
    var  place = ""
    var  id = ""
    var  country_id = ""
    var  city = ""
    var  state = ""
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
         self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.address = self.ReturnValueCheck(value: dictionary["address"] as Any)
        self.country_id = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.place = self.ReturnValueCheck(value: dictionary["place"] as Any)
        self.state = self.ReturnValueCheck(value: dictionary["state"] as Any)
    }
}

class UserWorkExperiences : ResponseModel {
    var  address = ""
    var  company = ""
    var  employment_status = ""
    var  end_date = ""
    var  start_date = ""
    var  title = ""
    var  id = ""
    var  descriptionExp = ""
    var  city = ""
    var  country_id = ""
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.address = self.ReturnValueCheck(value: dictionary["address"] as Any)
        self.company = self.ReturnValueCheck(value: dictionary["company"] as Any)
        self.employment_status = self.ReturnValueCheck(value: dictionary["employment_status"] as Any)
        self.end_date = self.ReturnValueCheck(value: dictionary["end_date"] as Any)
        self.start_date = self.ReturnValueCheck(value: dictionary["start_date"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
        self.descriptionExp = self.ReturnValueCheck(value: dictionary["description"] as Any)
        self.city = self.ReturnValueCheck(value: dictionary["city"] as Any)
        self.country_id = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        if end_date.count == 0 {
            end_date = Date().toFormat("YYYY-MM-dd")
        }
    }
}

class UserInstitutes : ResponseModel {
    
    var  address = ""
    var  city_name = ""
    var  country_id = ""
    var  degree_title = ""
    var  graduation_date = ""
    var  name = ""
    var  id = ""
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.address = self.ReturnValueCheck(value: dictionary["address"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.city_name = self.ReturnValueCheck(value: dictionary["city_name"] as Any)
        self.degree_title = self.ReturnValueCheck(value: dictionary["degree_title"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.country_id = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        self.graduation_date = self.ReturnValueCheck(value: dictionary["graduation_date"] as Any)
    }
}

class ResponseModel: NSObject {
    
    func ReturnValueCheck(value : Any) -> String {
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

