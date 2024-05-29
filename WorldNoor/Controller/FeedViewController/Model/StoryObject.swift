//
//  SnapModel.swift
//  WorldNoor
//
//  Created by Lucky on 08/08/2022.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import UIKit


class StoryObject:NSObject {
    var videoID:String = ""
    var videoUrl:String = ""
    var translatedVideo:String = ""
    var videoThumbnail:String = ""
    var authorName:String = ""
    var authorImage:String = ""
    var internalidentifier:String = ""
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
    var commentCount = ""
    var reactionCount = ""
    var comments = [Comment]()
    var reationsTypesMobile = [StoryReactionModel]()
    var isReaction : String? = ""
    var snapIndex :Int!
    override init()
    {
        
    }
    init(dict:[String : Any]) {
        if let authorDict = dict["author"] as? [String:Any] {
            self.authorName = SharedManager.shared.ReturnValueAsString(value: authorDict["author_name"] as Any)
            self.authorImage = SharedManager.shared.ReturnValueAsString(value: authorDict["profile_image"] as Any)
        //    self.internalidentifier = SharedManager.shared.ReturnValueAsString(value: authorDict["id"] as Any)
            
        }
        if let postFileArr = dict["post_files"] as? [Any] {
            if postFileArr.count > 0 {
                let postFile = postFileArr[0] as! [String:Any]
            //    self.videoUrl = SharedManager.shared.ReturnValueAsString(value: postFile["file_path"] as Any)
        //        self.videoThumbnail = SharedManager.shared.ReturnValueAsString(value: postFile["thumbnail_path"] as Any)
           //     self.videoID = SharedManager.shared.ReturnValueAsString(value: postFile["id"] as Any)
                self.hasSpeechToText = SharedManager.shared.ReturnValueAsBool(value: postFile["has_speech_to_text"] as Any)
                self.languageID =  SharedManager.shared.ReturnValueAsString(value: postFile["language_id"] as Any)
                self.thumbnail =  SharedManager.shared.ReturnValueAsString(value: postFile["thumbnail_path"] as Any)
                
            }
        }
        
        self.postType = SharedManager.shared.ReturnValueAsString(value: dict["post_type"] as Any)
        self.colorcode = SharedManager.shared.ReturnValueAsString(value: dict["color_code"] as Any)
        self.body = SharedManager.shared.ReturnValueAsString(value: dict["body"] as Any)
        self.videoID = SharedManager.shared.ReturnValueAsString(value: dict["id"] as Any)
        self.internalidentifier = SharedManager.shared.ReturnValueAsString(value: dict["id"] as Any)
        self.videoUrl = SharedManager.shared.ReturnValueAsString(value: dict["path"] as Any)
        self.videoThumbnail = SharedManager.shared.ReturnValueAsString(value: dict["thumbnail"] as Any)
        self.commentCount = SharedManager.shared.ReturnValueAsString(value: dict["countComment"] as Any)
        self.reactionCount = SharedManager.shared.ReturnValueAsString(value: dict["reactionCount"] as Any)
        self.isReaction = SharedManager.shared.ReturnValueAsString(value: dict["isReaction"] as Any)
        if dict["comments"] != nil{

            if let commentsArray = dict["comments"] as? [[String : Any]] {
                for indexObj in commentsArray {
                    self.comments.append(Comment.init(dict: indexObj as NSDictionary))
                }
            }
        }
        if let commentsArray = dict["reationsTypesMobile"] as? [[String : Any]] {
            for indexObj in commentsArray {
                
                self.reationsTypesMobile.append(StoryReactionModel.init(dict: indexObj as NSDictionary))
            }
        }
        
        
        if self.colorcode.count == 0 {
            self.colorcode = SharedManager.shared.ReturnValueAsString(value: dict["post_type_color_code"] as Any)
        }
        
        if self.postType.count == 0 {
            if SharedManager.shared.ReturnValueAsString(value: dict["post_type_id"] as Any) == "1" {
                self.postType = FeedType.post.rawValue
            }else if SharedManager.shared.ReturnValueAsString(value: dict["post_type_id"] as Any) == "2" {
                self.postType = FeedType.image.rawValue
            }else if SharedManager.shared.ReturnValueAsString(value: dict["post_type_id"] as Any) == "3" {
                self.postType = FeedType.video.rawValue
            }
            
            
        }
        
        if self.postID.count == 0 {
            self.postID = SharedManager.shared.ReturnValueAsString(value: dict["id"] as Any)
        }
    }
}
