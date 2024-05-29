//
//  ConversationModel.swift
//  WorldNoor
//
//  Created by apple on 9/22/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ConversationModel :ResponseModel {
    
    var author_id = ""
    var conversation_id = ""
    var conversation_type = ""
    var group_image = ""
    var has_blocked_me = ""
    var is_mute = ""
    var latest_message = ""
    var latest_message_language_id = ""
    var latest_message_time = ""
    var last_updated = ""
    var profile_image = ""
    var is_online = ""
    var member_id = ""
    var latest_conversation_id = ""
    var unread_messages_count = ""
    var is_unread = ""
    
    var arrayMembers = [ConversationMemberModel]()
    var arrayAdmin_ids = [Int]()
    var name = ""
    var isArchive = "0"
    var isSpam = "0"
    var theme_color = ""
    var is_leave = "0"
    var username = ""
    var is_blocked = "0"

    var dictMain = [String:Any]()
    
    override init() {
        super.init()
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.dictMain = dictionary
        self.latest_conversation_id = self.ReturnValueCheck(value: dictionary["latest_conversation_id"] as Any)
        self.member_id = self.ReturnValueCheck(value: dictionary["member_id"] as Any)
        self.is_online = self.ReturnValueCheck(value: dictionary["is_online"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.latest_message_time = self.ReturnValueCheck(value: dictionary["latest_message_time"] as Any)
        self.author_id = self.ReturnValueCheck(value: dictionary["author_id"] as Any)
        self.conversation_id = self.ReturnValueCheck(value: dictionary["conversation_id"] as Any)
        self.conversation_type = self.ReturnValueCheck(value: dictionary["conversation_type"] as Any)
        self.group_image = self.ReturnValueCheck(value: dictionary["group_image"] as Any)
        self.has_blocked_me = self.ReturnValueCheck(value: dictionary["has_blocked_me"] as Any)
        self.is_mute = self.ReturnValueCheck(value: dictionary["is_mute"] as Any)
        self.latest_message = self.ReturnValueCheck(value: dictionary["latest_message"] as Any)
        self.unread_messages_count = self.ReturnValueCheck(value: dictionary["unread_messages_count"] as Any)
        self.latest_message_language_id = self.ReturnValueCheck(value: dictionary["latest_message_language_id"] as Any)
        self.last_updated = self.ReturnValueCheck(value: dictionary["last_updated"] as Any)
        self.is_unread = self.ReturnValueCheck(value: dictionary["is_unread"] as Any)
        self.theme_color = self.ReturnValueCheck(value: dictionary["color_code"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.isArchive = self.ReturnValueCheck(value: dictionary["is_archive"] as Any)
        if self.isArchive == "" {
            self.isArchive = "0"
        }
        self.isSpam = self.ReturnValueCheck(value: dictionary["is_ignored"] as Any)
        if self.isSpam == "" {
            self.isSpam = "0"
        }
        self.is_leave = self.ReturnValueCheck(value: dictionary["is_leave"] as Any)
        if self.is_leave == "" {
            self.is_leave = "0"
        }
        self.is_blocked = self.ReturnValueCheck(value: dictionary["is_blocked"] as Any)
        if self.is_blocked == "" {
            self.is_blocked = "0"
        }
        self.arrayAdmin_ids.removeAll()
        
        if let adminArray = dictionary["admin_ids"] as? [Int]{
            for indexObj in adminArray{
                self.arrayAdmin_ids.append(indexObj)
            }
        }
        
        self.arrayMembers.removeAll()
        
        if let memberArray = dictionary["members"] as? [[String : Any]]{
            for indexObj in memberArray{
                self.arrayMembers.append(ConversationMemberModel.init(fromDictionary: indexObj))
            }
        }
        
        if self.latest_message == "" {
            if let lastMessage = dictionary["lastMessage"] as? [String: Any],
               let messageFiles = lastMessage["message_files"] as? [[String: Any]],
               let firstFile = messageFiles.first,
               let postType = firstFile["post_type"] as? String {
                
                self.latest_message = postType
            }
        }
    }
    
    func convertintoDict() -> [String : Any]{
        
        return self.dictMain
    }
}

