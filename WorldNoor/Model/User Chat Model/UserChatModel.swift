//
//  UserChatModel.swift
//  WorldNoor
//
//  Created by apple on 2/12/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class UserChatModel : ResponseModel {
    
    var audio_msg_url = ""
    var author_id = ""
    var auto_translate = ""
    var conversation_id = ""
    var conversation_name = ""
    var conversation_type = ""
    var created_at = ""
    var full_name = ""
    var message_id = ""
    var name = ""
    var id = ""
    var new_message_id = ""
    var original_body = ""
    var body = ""
    var post_type = FeedType.none.rawValue
    var profile_image = ""
    var sender_id = ""
    var speech_to_text = ""
    var identifierString = ""
    var original_speech_to_text = ""
    var messageTime = ""
    var pinnedBy = ""
    
    var audio_file = ""
    var audio_translation = ""
    
    var imageLocal = ""
    var VideoLocal = ""
    
    var replied_to_message_id = ""
    var replied_to = [UserChatModel]()
    
    var isOriginal = false
    var message_files = [UserChatMessageFiles]()
    var userReaction = [UserReaction]()
    var seenBy = ""
    
    override init() {
        super.init()
    }
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.replied_to_message_id = self.ReturnValueCheck(value: dictionary["replied_to_message_id"] as Any)
        
        if let replyData = dictionary["replied_to"] as? [String : Any]
        {
            let objMain = UserChatModel.init(fromDictionary: replyData)
            self.replied_to.append(objMain)
        }
        
        self.audio_file = self.ReturnValueCheck(value: dictionary["audio_file"] as Any)
        self.original_speech_to_text = self.ReturnValueCheck(value: dictionary["original_speech_to_text"] as Any)
        self.audio_msg_url = self.ReturnValueCheck(value: dictionary["audio_msg_url"] as Any)
        self.body = self.ReturnValueCheck(value: dictionary["body"] as Any)
        self.author_id = self.ReturnValueCheck(value: dictionary["author_id"] as Any)
        self.messageTime = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        self.auto_translate = self.ReturnValueCheck(value: dictionary["auto_translate"] as Any)
        self.conversation_id = self.ReturnValueCheck(value: dictionary["conversation_id"] as Any)
        self.conversation_name = self.ReturnValueCheck(value: dictionary["conversation_name"] as Any)
        self.conversation_type = self.ReturnValueCheck(value: dictionary["conversation_type"] as Any)
        self.created_at = self.ReturnValueCheck(value: dictionary["created_at"] as Any)
        self.full_name = self.ReturnValueCheck(value: dictionary["full_name"] as Any)
        self.message_id = self.ReturnValueCheck(value: dictionary["message_id"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.new_message_id = self.ReturnValueCheck(value: dictionary["new_message_id"] as Any)
        self.original_body = self.ReturnValueCheck(value: dictionary["original_body"] as Any)
        self.post_type = self.ReturnValueCheck(value: dictionary["post_type"] as Any)
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.sender_id = self.ReturnValueCheck(value: dictionary["sender_id"] as Any)
        self.speech_to_text = self.ReturnValueCheck(value: dictionary["speech_to_text"] as Any)
        self.identifierString = self.ReturnValueCheck(value: dictionary["identifierString"] as Any)
        self.pinnedBy = self.ReturnValueCheck(value: dictionary["pm_pinned_by"] as Any)
        self.seenBy = self.ReturnValueCheck(value: dictionary["seen_by"] as Any)
        
        if self.identifierString.count == 0 {
            self.identifierString = self.ReturnValueCheck(value: dictionary["local_id"] as Any)
        }
        
        if self.original_body.count > 0 && self.body.count == 0 {
            self.body = self.original_body
        }
        
        if self.original_body.count == 0 {
            self.original_body =  self.body
        }
        self.message_files.removeAll()
        if let arrayMessage = dictionary["message_files"] as? [[String : Any]] {
            for indexObj in arrayMessage {
                self.message_files.append(UserChatMessageFiles.init(fromDictionary: indexObj))
            }
        }
        
        if self.post_type == FeedType.audio.rawValue {
            if self.message_files.count > 0 {
                self.audio_msg_url = self.message_files.first!.url
            }
        }
        
        if name.count == 0 {
            name = self.full_name
        }
        
        if let reactionMessage = dictionary["message_reaction"] as? [[String : Any]] {
            for indexObj in reactionMessage {
                self.userReaction.append(UserReaction.init(fromDictionary: indexObj))
            }
        }
    }
    
    init(fromValue : String){
        super.init()
        self.body = fromValue
        self.post_type = "Date"
        
    }
}

class UserChatMessageFiles : ResponseModel {
    var id = ""
    var post_type = FeedType.none.rawValue
    var url = ""
    var ConvertedUrl = ""
    var size = ""
    var name = ""
    var thumbnail_url = ""
    var localthumbnailimage : String!
    var localimage = ""
    var localVideoURL = ""
    
    override init() {
        super.init()
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.size = self.ReturnValueCheck(value: dictionary["size"] as Any)
        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.post_type = self.ReturnValueCheck(value: dictionary["post_type"] as Any)
        self.url = self.ReturnValueCheck(value: dictionary["url"] as Any)
        self.thumbnail_url = self.ReturnValueCheck(value: dictionary["thumbnail_url"] as Any)
        self.size = self.ReturnValueCheck(value: dictionary["size"] as Any)
    }
}

class UserReaction : ResponseModel {
    var reaction = ""
    var firstname = ""
    var lastname = ""
    var profileImage = ""
    var messageID = ""
    var reactionID = ""
    var reactedBy = ""
    
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.reaction = self.ReturnValueCheck(value: dictionary["reaction"] as Any)
        self.firstname = self.ReturnValueCheck(value: dictionary["firstname"] as Any)
        self.lastname = self.ReturnValueCheck(value: dictionary["lastname"] as Any)
        self.profileImage = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.messageID = self.ReturnValueCheck(value: dictionary["message_id"] as Any)
        self.reactedBy = self.ReturnValueCheck(value: dictionary["reacted_by"] as Any)
        self.reactionID = self.ReturnValueCheck(value: dictionary["id"] as Any)
    }
}
