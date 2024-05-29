//
//  Status.swift
//  WorldNoor
//
//  Created by Lucky on 08/08/2022.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import UIKit

class Status: NSObject {
    var videoID:String = ""
    var videoUrl:String = ""
    var translatedVideo:String = ""
    var videoThumbnail:String = ""
    var authorName:String = ""
    var authorImage:String = ""
    var identifier:String = ""
    var status:String = ""
    var identifierString = ""
    var langModel:LanguageModel?
    var hasSpeechToText:Bool?
    var hasSpeechToTextString:String = ""
    var languageID:String?
    var thumbnail:String?
    var postID:String = ""
    var langName:String = ""
    var postType = ""
    var colorcode = ""
    var body = ""
    override init()
    {
        
    }
    init(dict:[String : Any]) {
        if let authorDict = dict["author"] as? [String:Any] {
            self.authorName = SharedManager.shared.ReturnValueAsString(value: authorDict["author_name"] as Any)
            self.authorImage = SharedManager.shared.ReturnValueAsString(value: authorDict["profile_image"] as Any)
            self.identifier = SharedManager.shared.ReturnValueAsString(value: authorDict["id"] as Any)
            
        }
        if let postFileArr = dict["post_files"] as? [Any] {
            if postFileArr.count > 0 {
                let postFile = postFileArr[0] as! [String:Any]
                self.hasSpeechToText = SharedManager.shared.ReturnValueAsBool(value: postFile["has_speech_to_text"] as Any)
                self.languageID =  SharedManager.shared.ReturnValueAsString(value: postFile["language_id"] as Any)
                self.thumbnail =  SharedManager.shared.ReturnValueAsString(value: postFile["thumbnail_path"] as Any)
            }
        }
        self.postType = SharedManager.shared.ReturnValueAsString(value: dict["post_type"] as Any)
        self.colorcode = SharedManager.shared.ReturnValueAsString(value: dict["color_code"] as Any)
        self.body = SharedManager.shared.ReturnValueAsString(value: dict["body"] as Any)
        self.videoID = SharedManager.shared.ReturnValueAsString(value: dict["id"] as Any)
        self.videoUrl = SharedManager.shared.ReturnValueAsString(value: dict["path"] as Any)
        self.videoThumbnail = SharedManager.shared.ReturnValueAsString(value: dict["thumbnail"] as Any)

        
    }
}
