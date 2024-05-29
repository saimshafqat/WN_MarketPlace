
//
//  VideoClipModel.swift
//  WorldNoor
//
//  Created by apple on 4/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class VideoClipModel : ResponseModel {
    
    var body = ""
    var file_language_id = ""
    var id = ""
    var postID = ""
    var is_being_deleted = ""
    var overlay_color = ""
    var path = ""
    var processing_status = "0"
    var speech_to_text = ""
    var speech_to_text_words = ""
    var thumbnail = ""
    var updated_at = ""
    var user_id = ""
    var views_count = ""
    var languageVideo = ""
    var videoUploadprogress = 0
    var localImage : UIImage!
    var localVideoURL = ""
    var languageID = ""
    var languageName = ""
    var has_speech_to_text = ""
    var transcript = ""
    var translatedVideo = ""
    var transcript_translated = ""
    var authorObj = authorModel.init()
    var languageSame  = ""
    var hashURL  = ""
    var isProcessing  = false
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.body = self.ReturnValueCheck(value: dictionary["body"] as Any)
        self.file_language_id = self.ReturnValueCheck(value: dictionary["file_language_id"] as Any)
        self.postID = self.ReturnValueCheck(value: dictionary["post_file_id"] as Any)
        self.id = self.ReturnValueCheck(value: dictionary["id"] as Any)
        self.is_being_deleted = self.ReturnValueCheck(value: dictionary["is_being_deleted"] as Any)
        self.overlay_color = self.ReturnValueCheck(value: dictionary["overlay_color"] as Any)
        self.path = self.ReturnValueCheck(value: dictionary["path"] as Any)
        self.processing_status = self.ReturnValueCheck(value: dictionary["processing_status"] as Any)
        self.speech_to_text = self.ReturnValueCheck(value: dictionary["speech_to_text"] as Any)
        self.speech_to_text_words = self.ReturnValueCheck(value: dictionary["speech_to_text_words"] as Any)
        self.has_speech_to_text = self.ReturnValueCheck(value: dictionary["has_speech_to_text"] as Any)
        self.thumbnail = self.ReturnValueCheck(value: dictionary["thumbnail"] as Any)
        self.updated_at = self.ReturnValueCheck(value: dictionary["updated_at"] as Any)
        self.user_id = self.ReturnValueCheck(value: dictionary["user_id"] as Any)
        self.views_count = self.ReturnValueCheck(value: dictionary["views_count"] as Any)
        self.body = self.ReturnValueCheck(value: dictionary["body"] as Any)
        self.languageVideo = self.ReturnValueCheck(value: dictionary["language_name_readable"] as Any)
        
        if let author = dictionary["author"] as? [String : Any] {
            self.authorObj = authorModel.init(fromDictionary: author)
        }
        self.languageSame = "1"
        
        if self.file_language_id.count > 0 {
            if Int(self.file_language_id) != nil {
                if !SharedManager.shared.isLangSame(langID: Int(self.file_language_id)!) {
                    self.languageSame = ""
                }
            }
        }
    }
    
    init(feedVideoArray:FeedVideoModel) {
        super.init()
        self.body = ""
        self.file_language_id = feedVideoArray.languageID ?? ""

        self.postID = feedVideoArray.postID
        self.id = feedVideoArray.videoID
        self.overlay_color = ""
        self.path = feedVideoArray.videoUrl
        self.processing_status = feedVideoArray.status
        self.speech_to_text = feedVideoArray.hasSpeechToTextString
        self.has_speech_to_text = self.speech_to_text
        self.thumbnail = feedVideoArray.videoThumbnail
        self.user_id = feedVideoArray.internalidentifier
        self.languageVideo = feedVideoArray.langName
        self.authorObj.profile_image = feedVideoArray.authorImage
        self.authorObj.username = feedVideoArray.authorName
        self.languageSame = "1"
        
        if self.file_language_id.count > 0 {
            if Int(self.file_language_id) != nil {
                if !SharedManager.shared.isLangSame(langID: Int(self.file_language_id)!) {
                    self.languageSame = ""
                }
            }
        }
    }
}

class authorModel : ResponseModel {
    
    var profile_image = ""
    var username = ""
    var language_id = ""
    
    override init() {
        super.init()
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        self.profile_image = self.ReturnValueCheck(value: dictionary["profile_image"] as Any)
        self.username = self.ReturnValueCheck(value: dictionary["username"] as Any)
        self.language_id = self.ReturnValueCheck(value: dictionary["language_id"] as Any)
    }
    
}
