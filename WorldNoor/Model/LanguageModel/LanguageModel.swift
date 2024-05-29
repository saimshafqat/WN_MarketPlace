//
//  LanguageModel.swift
//  WorldNoor
//
//  Created by Raza najam on 2/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation

class LanguageModel: NSObject , NSCoding{
    var languageName =  ""
    var languageID = ""
    var languageCode = ""
    
    init(name:String, id:String) {
        self.languageName = name
        self.languageID = id
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        self.languageName = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.languageID = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.languageCode = self.ReturnValueCheck(value: dictionary["code"] as Any)
    }
    
    func ReturnValueCheck(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        } else  if let MainValue = value as? String {
            return MainValue
        } else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.languageName, forKey: "languageName")
        aCoder.encode(self.languageID, forKey: "languageID")
        aCoder.encode(self.languageCode, forKey: "languageCode")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(fromDictionary: [String : AnyObject]())
        self.languageName = aDecoder.decodeObject(forKey:"languageName") as? String ?? ""
        self.languageID = aDecoder.decodeObject(forKey:"languageID") as? String ?? ""
        self.languageCode = aDecoder.decodeObject(forKey:"languageCode") as? String ?? ""
    }
}

class RelationshipModel: NSObject , NSCoding {
    var partnerhip_id = ""
    var relationshipCreationDate = ""
    var statusApproval = ""
    var statusDescription = ""
    var statusId = ""
    var privacy_status = ""
    var user: UserRelationshipModel?
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.partnerhip_id = self.ReturnValueCheck(value: dictionary["partnership_id"] as Any)
        self.relationshipCreationDate = self.ReturnValueCheck(value: dictionary["relationshipCreationDate"] as Any)
        self.statusApproval = self.ReturnValueCheck(value: dictionary["statusApproval"] as Any)
        self.statusDescription = self.ReturnValueCheck(value: dictionary["statusDescription"] as Any)
        self.privacy_status = self.ReturnValueCheck(value: dictionary["privacy_status"] as Any)
        self.statusId = self.ReturnValueCheck(value: dictionary["statusId"] as Any)
        if let userDictionary = dictionary["user"] as? [String: Any] {
            self.user = UserRelationshipModel(dictionary: userDictionary)
        }
    }
    
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.partnerhip_id, forKey: "partnership_id")
        aCoder.encode(self.relationshipCreationDate, forKey: "relationshipCreationDate")
        aCoder.encode(self.statusApproval, forKey: "statusApproval")
        aCoder.encode(self.statusDescription, forKey: "statusDescription")
        aCoder.encode(self.statusId, forKey: "statusId")
        aCoder.encode(self.user, forKey: "user")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(fromDictionary: [String : AnyObject]())
        self.partnerhip_id = aDecoder.decodeObject(forKey:"partnership_id") as? String ?? ""
        self.relationshipCreationDate = aDecoder.decodeObject(forKey:"relationshipCreationDate") as? String ?? ""
        self.statusApproval = aDecoder.decodeObject(forKey:"statusApproval") as? String ?? ""
        self.statusDescription = aDecoder.decodeObject(forKey:"statusDescription") as? String ?? ""
        self.statusId = aDecoder.decodeObject(forKey:"statusId") as? String ?? ""
        self.user = aDecoder.decodeObject(forKey:"user") as? UserRelationshipModel
    }
}

class UserRelationshipModel: NSObject, NSCoding {
    var aboutMe: String?
    var apiToken: String?
    var authType: String?
    var bio: String?
    var blockedBy: String?
    var city: String?
    var cityId: String?
    var countryCode: String?
    var countryId: String?
    var countyId: String?
    var coverImage: String?
    var createdAt: String?
    var currency: String?
    var deviceType: String?
    var dob: String?
    var email: String?
    var emailVerifiedAt: String?
    var firstname: String?
    var frAcceptedNotificationsCount: Int?
    var gender: String?
    var googleId: String?
    var hideStatus: String?
    var id: String?
    var isOnline: String?
    var languageId: String?
    var lastname: String?
    var mobileBannerFlag: Int?
    var muteStory: Int?
    var onlineAt: String?
    var otpId: String?
    var parentId: String?
    var phone: String?
    var pin: String?
    var poshId: String?
    var postalCodeId: String?
    var profileImage: String?
    var profileOriginalName: String?
    var pronoun: String?
    var stateId: String?
    var statusId: Int?
    var systemCountry: Int?
    var uiLanguageId: Int?
    var updatedAt: String?
    var username: String?
    var website: String?
    
    init(dictionary: [String: Any]) {
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.createdAt = dictionary["created_at"] as? String
        self.updatedAt = dictionary["updated_at"] as? String
        self.onlineAt = dictionary["online_at"] as? String
        self.username = dictionary["username"] as? String
        self.email = dictionary["email"] as? String
        self.aboutMe = dictionary["about_me"] as? String
        self.apiToken = dictionary["api_token"] as? String
        self.authType = dictionary["auth_type"] as? String
        self.bio = dictionary["bio"] as? String
        self.blockedBy = dictionary["blocked_by"] as? String
        self.city = dictionary["city"] as? String
        self.cityId = dictionary["city_id"] as? String
        self.countryCode = dictionary["country_code"] as? String
        self.countryId = self.ReturnValueCheck(value: dictionary["country_id"] as Any)
        self.countyId = self.ReturnValueCheck(value: dictionary["county_id"] as Any)
        self.currency = dictionary["currency"] as? String
        self.deviceType = dictionary["device_type"] as? String
        self.dob = dictionary["dob"] as? String
        self.emailVerifiedAt = dictionary["email_verified_at"] as? String
        self.firstname = dictionary["firstname"] as? String
        self.frAcceptedNotificationsCount = dictionary["fr_accepted_notifications_count"] as? Int
        self.gender = dictionary["gender"] as? String
        self.googleId = dictionary["google_id"] as? String
        self.hideStatus = self.ReturnValueCheck(value: dictionary["hide_status"] as Any)
        self.isOnline = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.languageId = dictionary["language_id"] as? String
        self.lastname = dictionary["lastname"] as? String
        self.mobileBannerFlag = dictionary["mobile_banner_flag"] as? Int
        self.muteStory = dictionary["mute_story"] as? Int
        self.otpId = dictionary["otp_id"] as? String
        self.parentId = dictionary["parent_id"] as? String
        self.phone = dictionary["phone"] as? String
        self.pin = dictionary["pin"] as? String
        self.poshId = dictionary["posh_id"] as? String
        self.postalCodeId = dictionary["postal_code_id"] as? String
        self.profileOriginalName = dictionary["profile_original_name"] as? String
        self.pronoun = dictionary["pronoun"] as? String
        self.stateId = dictionary["state_id"] as? String
        self.statusId = dictionary["status_id"] as? Int
        self.systemCountry = dictionary["system_country"] as? Int
        self.uiLanguageId = dictionary["ui_language_id"] as? Int
        self.website = dictionary["website"] as? String
        self.coverImage = dictionary["cover_image"] as? String
        self.profileImage = dictionary["profile_image"] as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(aboutMe, forKey: "aboutMe")
        aCoder.encode(apiToken, forKey: "apiToken")
        aCoder.encode(authType, forKey: "authType")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(blockedBy, forKey: "blockedBy")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(cityId, forKey: "cityId")
        aCoder.encode(countryCode, forKey: "countryCode")
        aCoder.encode(countryId, forKey: "countryId")
        aCoder.encode(countyId, forKey: "countyId")
        aCoder.encode(coverImage, forKey: "coverImage")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(currency, forKey: "currency")
        aCoder.encode(deviceType, forKey: "deviceType")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(emailVerifiedAt, forKey: "emailVerifiedAt")
        aCoder.encode(firstname, forKey: "firstname")
        aCoder.encode(frAcceptedNotificationsCount, forKey: "frAcceptedNotificationsCount")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(googleId, forKey: "googleId")
        aCoder.encode(hideStatus, forKey: "hideStatus")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(isOnline, forKey: "isOnline")
        aCoder.encode(languageId, forKey: "languageId")
        aCoder.encode(lastname, forKey: "lastname")
        aCoder.encode(mobileBannerFlag, forKey: "mobileBannerFlag")
        aCoder.encode(muteStory, forKey: "muteStory")
        aCoder.encode(onlineAt, forKey: "onlineAt")
        aCoder.encode(otpId, forKey: "otpId")
        aCoder.encode(parentId, forKey: "parentId")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(pin, forKey: "pin")
        aCoder.encode(poshId, forKey: "poshId")
        aCoder.encode(postalCodeId, forKey: "postalCodeId")
        aCoder.encode(profileImage, forKey: "profileImage")
        aCoder.encode(profileOriginalName, forKey: "profileOriginalName")
        aCoder.encode(pronoun, forKey: "pronoun")
        aCoder.encode(stateId, forKey: "stateId")
        aCoder.encode(statusId, forKey: "statusId")
        aCoder.encode(systemCountry, forKey: "systemCountry")
        aCoder.encode(uiLanguageId, forKey: "uiLanguageId")
        aCoder.encode(updatedAt, forKey: "updatedAt")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(website, forKey: "website")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(dictionary: [String: Any]()) // Assuming this is how your custom init works
        aboutMe = aDecoder.decodeObject(forKey: "aboutMe") as? String
        apiToken = aDecoder.decodeObject(forKey: "apiToken") as? String
        authType = aDecoder.decodeObject(forKey: "authType") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
        blockedBy = aDecoder.decodeObject(forKey: "blockedBy") as? String
        city = aDecoder.decodeObject(forKey: "city") as? String
        cityId = aDecoder.decodeObject(forKey: "cityId") as? String
        countryCode = aDecoder.decodeObject(forKey: "countryCode") as? String
        countryId = aDecoder.decodeObject(forKey: "countryId") as? String
        countyId = aDecoder.decodeObject(forKey: "countyId") as? String
        coverImage = aDecoder.decodeObject(forKey: "coverImage") as? String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        currency = aDecoder.decodeObject(forKey: "currency") as? String
        deviceType = aDecoder.decodeObject(forKey: "deviceType") as? String
        dob = aDecoder.decodeObject(forKey: "dob") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        emailVerifiedAt = aDecoder.decodeObject(forKey: "emailVerifiedAt") as? String
        firstname = aDecoder.decodeObject(forKey: "firstname") as? String
        frAcceptedNotificationsCount = aDecoder.decodeObject(forKey: "frAcceptedNotificationsCount") as? Int
        gender = aDecoder.decodeObject(forKey: "gender") as? String
        googleId = aDecoder.decodeObject(forKey: "googleId") as? String
        hideStatus = aDecoder.decodeObject(forKey: "hideStatus") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        isOnline = aDecoder.decodeObject(forKey: "isOnline") as? String
        languageId = aDecoder.decodeObject(forKey: "languageId") as? String
        lastname = aDecoder.decodeObject(forKey: "lastname") as? String
        mobileBannerFlag = aDecoder.decodeObject(forKey: "mobileBannerFlag") as? Int
        muteStory = aDecoder.decodeObject(forKey: "muteStory") as? Int
        onlineAt = aDecoder.decodeObject(forKey: "onlineAt") as? String
        otpId = aDecoder.decodeObject(forKey: "otpId") as? String
        parentId = aDecoder.decodeObject(forKey: "parentId") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        pin = aDecoder.decodeObject(forKey: "pin") as? String
        poshId = aDecoder.decodeObject(forKey: "poshId") as? String
        postalCodeId = aDecoder.decodeObject(forKey: "postalCodeId") as? String
        profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
        profileOriginalName = aDecoder.decodeObject(forKey: "profileOriginalName") as? String
        pronoun = aDecoder.decodeObject(forKey: "pronoun") as? String
        stateId = aDecoder.decodeObject(forKey: "stateId") as? String
        statusId = aDecoder.decodeObject(forKey: "statusId") as? Int
        systemCountry = aDecoder.decodeObject(forKey: "systemCountry") as? Int
        uiLanguageId = aDecoder.decodeObject(forKey: "uiLanguageId") as? Int
        updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
        username = aDecoder.decodeObject(forKey: "username") as? String
        website = aDecoder.decodeObject(forKey: "website") as? String
    }

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
