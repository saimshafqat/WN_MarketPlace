//
//  PrivacyModel.swift
//  WorldNoor
//
//  Created by apple on 9/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class PrivacyModel :ResponseModel {
    
    
    var FuturePostValue = "Public"
    var FriendRequestValue = "Everyone"
    var FriendListValue = "Public"
    var EmailAddressValue = "Public"
    var PhoneNumberValue = "Public"
    
    var FuturePostSettingValue = "public"
    var FriendRequestSettingValue = "everyone"
    var FriendListSettingValue = "public"
    var EmailAddressSettingValue = "public"
    var PhoneNumberSettingValue = "public"
    

    init(fromDictionary dictionary: [[String:Any]]){
        
        super.init()
        
        
        for indexObj in dictionary {
            if let typeValue = indexObj["setting_type"] as? String {
                switch typeValue {
                case "future_posts":
                    if let settingValue = indexObj["setting_value"] as? String {
                        self.FuturePostSettingValue = settingValue
                        self.FuturePostValue = settingValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
                    }
                    
                case "friends_list":
                    if let settingValue = indexObj["setting_value"] as? String {
//                        self.FriendListValue = settingValue
                        self.FriendListSettingValue = settingValue
                        self.FriendListValue = settingValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)

                    }
                case "search_from_email":
                    if let settingValue = indexObj["setting_value"] as? String {
//                        self.EmailAddressValue = settingValue
                        self.EmailAddressSettingValue = settingValue
                        self.EmailAddressValue = settingValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)

                    }
                case "search_from_phone":
                    if let settingValue = indexObj["setting_value"] as? String {
//                        self.PhoneNumberValue = settingValue
                        self.PhoneNumberSettingValue = settingValue
                        self.PhoneNumberValue = settingValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)

                    }
                case "friend_requests":
                    if let settingValue = indexObj["setting_value"] as? String {
//                        self.FriendRequestValue = settingValue
                        self.FriendRequestSettingValue = settingValue
                        self.FriendRequestValue = settingValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
                    }
                default:
                    LogClass.debugLog("No Value Found")
                }
            }
        }
    }
    
    override init() {
        super.init()
    }
}
