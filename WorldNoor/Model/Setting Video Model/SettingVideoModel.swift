//
//  SettingVideoModel.swift
//  WorldNoor
//
//  Created by apple on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class SettingVideoModel : ResponseModel {

    var author_name = ""
    var author_username = ""
    var comments_count = ""
    var file_path = ""
    var file_translation_link = ""
    var file_type = ""
    var id = ""
    var posted_time_ago = ""
    var shares_count = ""
    var simple_dislike_count = ""
    var simple_like_count = ""
    var thumbnail_path = "";
    var title = ""
    var views_count = ""
    var translationLink = ""
    var has_speech_to_text = ""
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.author_name = self.ReturnValueCheck(value: dictionary["author_name"] as Any)
        self.has_speech_to_text = self.ReturnValueCheck(value: dictionary["has_speech_to_text"] as Any)
        self.author_username = self.ReturnValueCheck(value: dictionary["author_username"] as Any)
        self.comments_count = self.ReturnValueCheck(value: dictionary["comments_count"] as Any)
        self.file_path = self.ReturnValueCheck(value: dictionary["file_path"] as Any)
        self.file_translation_link = self.ReturnValueCheck(value: dictionary["file_translation_link"] as Any)
        
        self.file_type = self.ReturnValueCheck(value: dictionary["file_type"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.posted_time_ago = self.ReturnValueCheck(value: dictionary["posted_time_ago"] as Any)
        self.shares_count = self.ReturnValueCheck(value: dictionary["shares_count"] as Any)
        self.simple_dislike_count = self.ReturnValueCheck(value: dictionary["simple_dislike_count"] as Any)
        self.simple_like_count = self.ReturnValueCheck(value: dictionary["simple_like_count"] as Any)
        self.thumbnail_path = self.ReturnValueCheck(value: dictionary["thumbnail_path"] as Any)
        self.title = self.ReturnValueCheck(value: dictionary["title"] as Any)
        self.views_count = self.ReturnValueCheck(value: dictionary["views_count"] as Any)
        
    }
}
