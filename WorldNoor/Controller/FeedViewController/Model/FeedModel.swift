//
//  FeedModel.swift
//  WorldNoor
//
//  Created by Raza najam on 9/4/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import CoreMedia
import Photos

class TagsModel: Codable {
    let action:String?
    let data : TagsGraphModel?
    let meta : Meta?
}

class TagsGraphModel: Codable {
    let contributors_count : Int?
    let created_at : String?
    let news_feed : Int?
    let posts_url : String?
    let hash_tag_name : String?
    let hash_tag_description : String?
    
    let hashtag : HashTagMainModel?
    let graph_data : [graph_data]?
    
}
class graph_data : Codable {
    let count : Int?
    let hour : String?
}
class HashTagMainModel : Codable {
    let id : Int?
    let name : String?
    let created_at : String?
    let updated_at : String?
}


class FeedModel: Codable {
    let action:String?
    let data : [FeedData]?
    let meta : Meta?
}

class FeedTagsModel: Codable {
    let action:String?
    let data : TagData?
    let meta : Meta?
}

class TagData: Codable {
    let hash_tag_description:String?
    let news_feed : [FeedData]?
    let hash_tag_name : String?
}


class FeedSingleModel: Codable {
    let action:String?
    let data : FeedPostModel?
    let meta : Meta?
}

class FeedPostModel: Codable {
    let post : FeedData?
    
}

// MARK: - FeedData
class FeedData : Codable {
    var userSavedId: Int?
    var postID : Int?
    let saveID : Int?
    var authorName : String?
    var profileImage : String?
    let username : String?
    var authorID : Int?
    let postedOn : String?
    var memoryValue: String? = ""
    var postType : String?
    let post_type_color_code : String?
    var body : String?
    let previewLink : String?
    let linkImage : String?
    let linkDesc : String?
    let linkTitle : String?
    var orignalBody : String?
    var orignalSharedBody: String?
    let location : String?
    var simple_dislike_count : Int?
    var post: [PostFile]?
    var language:LanguageObj?
    var comments: [Comment]?
    var isLiked : Bool?
    var isDisliked : Bool?
    var commentCount:Int? = 0
    let shareCount:Int?
    var likeCount:Int?
    var isPostingNow:Bool = true
    var videoSeekTime:Double?
    let postedTime:String?
    var isSpeakerPlaying:Bool
    var isExpand: Bool = false
    var isVideoPlayed: Bool = false
    var isTranslation:Bool = false
    var isSharedTranslation: Bool = false
    var canIsendFriendRequest: Bool?
    var publishStatus:String?
    var saveTime: String?
    var sharedData:FeedData?
    var liveUrlStr: String?
    var liveThumbUrlStr: String?
    var privacyType:String?
    var liveStreamID:String?
    var isLive:Int?
    var uploadObj:FeedUpload?
    var page_title : String?
    var page_slug : String?
    var cellHeight : CGFloat? = 0.0
    var cellHeightExpand : CGFloat? = 0.0
    var isReaction : String? = ""
    var reationsTypesMobile : [ReactionModel]?
    var video_post_views : Int?
    var strID: String?
    var storyReactionMobile = [StoryReactionModel]()
    
    var isAuthorFriendOfViewer : String?
    var isSaved:Bool = false

    
    enum CodingKeys: String, CodingKey {
        case saveTime = "saveTime"
        case postID = "post_id"
        case userSavedId = "user_saved_id"
        case saveID = "saved_item_id"
        case authorName = "author_name"
        case profileImage = "profile_image"
        case username = "username"
        case authorID = "author_id"
        case postedOn = "posted_on"
        case postType = "post_type"
        case memoryValue = "post_age"
        case isAuthorFriendOfViewer = "isAuthorFriendOfViewer"
        case canIsendFriendRequest = "can_i_send_fr"
        case post_type_color_code = "post_type_color_code"
        case body = "body"
        case page_slug = "page_slug"
        case orignalBody = "original_body"
        case location = "location"
        case simple_dislike_count = "simple_dislike_count"
        case post = "post_files"
        case comments = "comments"
        case isLiked = "isLiked"
        case isDisliked = "isDisliked"
        case commentCount = "comments_count"
        case shareCount = "shares_count"
        case likeCount = "simple_like_count"
        case videoSeekTime = "videoSeekTime"
        case isSpeakerPlaying = "isSpeakerPlaying"
        case postedTime = "posted_time_ago"
        case language = "language"
        case publishStatus = "publish_status"
        case sharedData = "shared_post"
        case previewLink = "link"
        case linkTitle = "link_title"
        case linkImage = "link_image"
        case linkDesc = "link_meta"
        case liveUrlStr = "live_stream_url"
        case liveThumbUrlStr = "live_stream_thumbnail_url"
        case privacyType = "privacy_type"
        case liveStreamID = "live_stream_session_id"
        case isLive = "is_live"
        case page_title = "page_title"
        case isReaction = "isReaction"
        case video_post_views = "video_post_views"
        
        case reationsTypesMobile = "reationsTypesMobile"
        case strID = "str_id"
    }
    
    init(valueDict : [String : Any]) {
        self.saveTime = .emptyString
        self.postID = 0
        self.userSavedId = 0
        self.saveID = 0
        self.authorName  = ""
        self.profileImage  = ""
        self.username  = ""
        self.authorID = 0
        self.postedOn  = ""
        self.postType  = ""
        self.post_type_color_code  = ""
        self.body  = ""
        self.previewLink  = ""
        self.linkImage  = ""
        self.linkDesc  = ""
        self.linkTitle  = ""
        self.orignalBody  = ""
        self.orignalSharedBody = ""
        self.location  = ""
        self.simple_dislike_count = 0
        self.post  = nil
        self.memoryValue = ""
//        self.language = nil
        self.comments = [] //nil
        self.isLiked = false
        self.isDisliked = false
        self.commentCount = 0
        self.shareCount = 0
        self.likeCount = 0
        self.isPostingNow = true
        self.videoSeekTime = 0.0
        self.postedTime = ""
        self.isSpeakerPlaying = false
        self.publishStatus = ""
        self.sharedData = nil
        self.liveUrlStr = ""
        self.liveThumbUrlStr = ""
        self.privacyType = ""
        self.liveStreamID = ""
        self.page_title = ""
        self.page_slug = ""
        self.isLive = 0
        self.uploadObj = nil
        self.isVideoPlayed = false
        self.isTranslation = false
        self.isSharedTranslation = false
        self.strID = .emptyString
    }
    
    init(valueDictMain : [String : Any]) {
        self.saveTime = valueDictMain["saveTime"] as? String ?? .emptyString
        self.postID = (valueDictMain["post_id"] as! Int)
        self.userSavedId = (valueDictMain["user_saved_id"] as? Int ?? 0)
        self.saveID = 0
        self.isVideoPlayed = false
        self.isTranslation = false
        self.isSharedTranslation = false
        self.orignalSharedBody = ""
        self.authorName  = (valueDictMain["author_name"] as! String)
        self.profileImage  = (valueDictMain["profile_image"] as! String)
        self.username  = (valueDictMain["username"] as! String)
        self.authorID = (valueDictMain["author_id"] as! Int)
        self.postedOn  = (valueDictMain["posted_on"] as! String)
        self.postType  = (valueDictMain["post_type"] as! String)
        self.memoryValue  = (valueDictMain["post_age"] as? String) ?? ""
        self.strID = (valueDictMain["str_id"] as? String) ?? .emptyString
        self.isReaction  = (valueDictMain["isReaction"] as? String)
        if let countVideo = valueDictMain["video_post_views"] as? Int {
            self.video_post_views = countVideo
        }else {
            self.video_post_views = 0
        }
        
//        self.video_post_views  = (valueDictMain["video_post_views"] as? Int)
        
        
        if let reactionsArray = valueDictMain["reationsTypesMobile"] as? [[String : Any]] {
            for indexObj in reactionsArray {
                self.storyReactionMobile.append(StoryReactionModel.init(dict: indexObj as NSDictionary))
            }
        }
        
//        self.isReaction  = (valueDictMain["isReaction"] as? String)
        self.isAuthorFriendOfViewer  = (valueDictMain["isAuthorFriendOfViewer"] as? String)
        self.canIsendFriendRequest = (valueDictMain["can_i_send_fr"] as? Bool)

        if valueDictMain["page_title"] != nil {
            self.page_title  = (valueDictMain["page_title"] as? String)
            self.page_slug  = (valueDictMain["page_slug"] as? String)
        }
        
        self.post_type_color_code  = (valueDictMain["post_type_color_code"] as? String)
        self.body = (valueDictMain["body"] as? String)
        
        
        if valueDictMain["link"] != nil{
            if (valueDictMain["link"] as? String) == nil {
                self.previewLink  = nil
            } else{
                self.previewLink  = (valueDictMain["link"] as? String)
            }
        } else {
            self.previewLink  = nil
        }
        
        if valueDictMain["link_image"] != nil{
            if (valueDictMain["link_image"] as? String) == nil {
                self.linkImage  = nil
            }else{
                self.linkImage  = (valueDictMain["link_image"] as? String)
            }
        } else {
            self.linkImage  = nil
        }
        
        if valueDictMain["link_meta"] != nil{
            if (valueDictMain["link_meta"] as? String) == nil {
                self.linkDesc  = nil
            }else{
                self.linkDesc  = (valueDictMain["link_meta"] as? String)
            }
        } else {
            self.linkDesc  = nil
        }
        
        if valueDictMain["link_title"] != nil{
            if (valueDictMain["link_title"] as? String) == nil {
                self.linkTitle  = nil
            } else {
                self.linkTitle  = (valueDictMain["link_title"] as? String)
            }
        } else {
            self.linkTitle  = nil
        }
        
        
        if valueDictMain["original_body"] != nil{
            if (valueDictMain["original_body"] as? String) == nil {
                self.orignalBody  = nil
            } else{
                self.orignalBody  = (valueDictMain["original_body"] as? String)
            }
        } else {
            self.orignalBody  = nil
        }
        
        self.location  = (valueDictMain["location"] as? String)
        self.simple_dislike_count = (valueDictMain["simple_dislike_count"] as? Int)
        
        
        
        self.post  = [PostFile]()
        
        if valueDictMain["post_files"] != nil{

            if let commentsArray = valueDictMain["post_files"] as? [[String : Any]] {
                for indexObj in commentsArray {
                    self.post?.append(PostFile.init(dict: indexObj as NSDictionary))
                }
            }
        }
        
        
        self.language = nil
        if valueDictMain["language"] != nil{
            if let languageDict = valueDictMain["language"] as? [String : Any] {
                self.language = LanguageObj.init(valueDict: languageDict)
            }
        }
        self.comments = [Comment]()
        
        if valueDictMain["comments"] != nil{

            if let commentsArray = valueDictMain["comments"] as? [[String : Any]] {
                for indexObj in commentsArray {
                    self.comments?.append(Comment.init(dict: indexObj as NSDictionary))
                }
            }
        }
        

        
        if valueDictMain["has_liked"] != nil{
            if (valueDictMain["has_liked"] as? Int) == nil {
                self.isLiked  = false
            }else{
                self.isLiked  = ((valueDictMain["has_liked"] as! Int) != 0)
            }
        }else{
            self.isLiked  = false
        }
        

        if valueDictMain["has_disliked"] != nil{
            if (valueDictMain["has_disliked"] as? Int) == nil {
                self.isDisliked  = false
            }else{
                self.isDisliked  = ((valueDictMain["has_disliked"] as! Int) != 0)
            }
        }else{
            self.isDisliked  = false
        }
        

        if valueDictMain["comments_count"] != nil{
            if (valueDictMain["comments_count"] as? Int) == nil {
                self.commentCount  = 0
            }else{
                self.commentCount  = (valueDictMain["comments_count"] as! Int)
            }
        }else{
            self.commentCount  = 0
        }
        
        
        if valueDictMain["shares_count"] != nil{
            if (valueDictMain["shares_count"] as? Int) == nil {
                self.shareCount  = 0
            }else{
                self.shareCount  = (valueDictMain["shares_count"] as! Int)
            }
        }else{
            self.shareCount  = 0
        }
        
        
        if valueDictMain["simple_like_count"] != nil{
            if (valueDictMain["simple_like_count"] as? Int) == nil {
                self.likeCount  = 0
            }else{
                self.likeCount  = (valueDictMain["simple_like_count"] as! Int)
            }
        }else{
            self.likeCount  = 0
        }
        
        
        if valueDictMain["postingNow"] != nil{
            if (valueDictMain["postingNow"] as? Int) == nil {
                self.isPostingNow  = false
            }else{
                self.isPostingNow  = ((valueDictMain["postingNow"] as! Int) != 0)
            }
        }else{
            self.isPostingNow  = false
        }
        
        
        if valueDictMain["videoSeekTime"] != nil{
            if (valueDictMain["videoSeekTime"] as? Double) == nil {
                self.videoSeekTime  = 0.0
            }else{
                self.videoSeekTime  = (valueDictMain["videoSeekTime"] as! Double)
            }
        }else{
            self.videoSeekTime  = 0.0
        }
        
        if valueDictMain["posted_time_ago"] != nil{
            if (valueDictMain["posted_time_ago"] as? String) == nil {
                self.postedTime  = ""
            }else{
                self.postedTime  = (valueDictMain["posted_time_ago"] as! String)
            }
        }else{
            self.postedTime  = ""
        }

        if valueDictMain["isSpeakerPlaying"] != nil{
            if (valueDictMain["isSpeakerPlaying"] as? Int) == nil {
                self.isSpeakerPlaying  = false
            }else{
                self.isSpeakerPlaying  = ((valueDictMain["isSpeakerPlaying"] as! Int) != 0)
            }
        }else{
            self.isSpeakerPlaying  = false
        }
        
        self.publishStatus = (valueDictMain["publish_status"] as! String)
        
        if valueDictMain["shared_post"] != nil {
            self.sharedData = FeedData(valueDictMain: valueDictMain["shared_post"] as? [String: Any] ?? [:])
        }
        
        if valueDictMain["live_stream_url"] != nil{
            if (valueDictMain["live_stream_url"] as? String) == nil {
                self.liveUrlStr  = ""
            }else{
                self.liveUrlStr  = (valueDictMain["live_stream_url"] as! String)
                
                let arrayULR = self.liveUrlStr?.components(separatedBy: "/")
                if arrayULR!.count < 3 {
                    self.liveUrlStr = "https://live.worldnoor.com/WNLive/streams/" + arrayULR!.last!
                }
                
                
//                if self.liveUrlStr!.contains("https://live.worldnoor.com/WNLive/streams/") {
//
//                }else {
//                    self.liveUrlStr = "https://live.worldnoor.com/WNLive/streams/" + self.liveUrlStr!
//                }
            }
        }else{
            self.liveUrlStr  = ""
        }
        
        
        if valueDictMain["live_stream_thumbnail_url"] != nil{
            if (valueDictMain["live_stream_thumbnail_url"] as? String) == nil {

            }else{
                self.liveThumbUrlStr  = (valueDictMain["live_stream_thumbnail_url"] as! String)
            }
        }
        
        self.privacyType = (valueDictMain["privacy_type"] as! String)
        
        if valueDictMain["live_stream_session_id"] != nil{
            if (valueDictMain["live_stream_session_id"] as? String) == nil {
            }else{
                self.liveStreamID  = (valueDictMain["live_stream_session_id"] as! String)
            }
        }
        
        
        if valueDictMain["is_live"] != nil{
            if (valueDictMain["is_live"] as? Int) == nil {
                
            }else{
                self.isLive  = (valueDictMain["is_live"] as! Int)
            }
        }
        self.uploadObj = nil
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        saveTime =  try values.decodeIfPresent(String.self, forKey: .saveTime)
        postID =  try values.decodeIfPresent(Int.self, forKey: .postID)
        userSavedId =  try values.decodeIfPresent(Int.self, forKey: .userSavedId)
        page_title =  try values.decodeIfPresent(String.self, forKey: .page_title)
        page_slug =  try values.decodeIfPresent(String.self, forKey: .page_slug)
        isReaction =  try values.decodeIfPresent(String.self, forKey: .isReaction)
        video_post_views =  try values.decodeIfPresent(Int.self, forKey: .video_post_views)
        
        saveID =  try values.decodeIfPresent(Int.self, forKey: .saveID)
        authorName = try values.decodeIfPresent(String.self, forKey: .authorName)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        memoryValue =  try values.decodeIfPresent(String.self, forKey: .memoryValue)
        strID = try values.decodeIfPresent(String.self, forKey: .strID)
        
        username = try values.decodeIfPresent(String.self, forKey: .username)
        authorID = try values.decodeIfPresent(Int.self, forKey: .authorID)
        postedOn = try values.decodeIfPresent(String.self, forKey: .postedOn)
        postType = try values.decodeIfPresent(String.self, forKey: .postType)
        post_type_color_code = try values.decodeIfPresent(String.self, forKey: .post_type_color_code)
        body = try values.decodeIfPresent(String.self, forKey: .body)
        orignalBody = try values.decodeIfPresent(String.self, forKey: .orignalBody)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        simple_dislike_count = try values.decodeIfPresent(Int.self, forKey: .simple_dislike_count)
        comments = try values.decodeIfPresent([Comment].self, forKey: .comments)
        reationsTypesMobile = try values.decodeIfPresent([ReactionModel].self, forKey: .reationsTypesMobile)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        isDisliked = try values.decodeIfPresent(Bool.self, forKey: .isDisliked)
        post = try values.decodeIfPresent([PostFile].self, forKey: .post)
        language = try values.decodeIfPresent(LanguageObj.self, forKey: .language)
        commentCount = try values.decodeIfPresent(Int.self, forKey: .commentCount)
        shareCount = try values.decodeIfPresent(Int.self, forKey: .shareCount)
        likeCount = try values.decodeIfPresent(Int.self, forKey: .likeCount)
        videoSeekTime = try values.decodeIfPresent(Double.self, forKey: .videoSeekTime)
        isSpeakerPlaying = try (values.decodeIfPresent(Bool.self, forKey: .isSpeakerPlaying) ?? false)
        postedTime = try values.decodeIfPresent(String.self, forKey: .postedTime)
        isAuthorFriendOfViewer = try values.decodeIfPresent(String.self, forKey: .isAuthorFriendOfViewer)
        canIsendFriendRequest = try values.decodeIfPresent(Bool.self, forKey: .canIsendFriendRequest)

        publishStatus = try values.decodeIfPresent(String.self, forKey: .publishStatus)
        sharedData = try values.decodeIfPresent(FeedData.self, forKey: .sharedData)
        previewLink = try values.decodeIfPresent(String.self, forKey: .previewLink)
        linkTitle = try values.decodeIfPresent(String.self, forKey: .linkTitle)
        linkDesc = try values.decodeIfPresent(String.self, forKey: .linkDesc)
        linkImage = try values.decodeIfPresent(String.self, forKey: .linkImage)
        liveUrlStr = try values.decodeIfPresent(String.self, forKey: .liveUrlStr)
        liveThumbUrlStr = try values.decodeIfPresent(String.self, forKey: .liveThumbUrlStr)
        privacyType = try values.decodeIfPresent(String.self, forKey: .privacyType)
        liveStreamID = try values.decodeIfPresent(String.self, forKey: .liveStreamID)
        isLive = try values.decodeIfPresent(Int.self, forKey: .isLive)
    }
}

class FeedUpload:NSObject {
    var type:String = ""
    var thumbUrl:String = ""
    var imageUrl:String = ""
    var url:String = ""
    var isLangRequired:Bool = false
    var languageCode = ""
    var languageName = ""
    var imageObj:UIImage?
    var isImageExist:Bool = false
    var isLangSelected:Bool = false
    var identifier = ""
    var fileExt = ""
    
    
    init(body:String, firstName:String, lastName:String, profileImage:String, isPosting:Bool, identifierStr:String, fileType:String = "", selectLanguage:Bool = false, videoUrlToUpload:String = "", imgUrl:String = "", imageObj:UIImage = UIImage(), isImageObjExist:Bool = false, fileExt:String = "") {
        self.imageUrl = imgUrl
        self.isImageExist = isImageObjExist
        self.imageObj = imageObj
        self.type = fileType
        self.identifier = SharedManager.shared.getIdentifierForMessage()
        self.url = videoUrlToUpload
        self.fileExt = fileExt
        if fileType == "audio" || fileType == "video" || fileType == "attachment" {
            self.isLangRequired = true
            let langCode = SharedManager.shared.getCurrentLanguageID()
            if langCode != "" {
                self.isLangSelected = true
                self.languageCode = langCode
                self.languageName = SharedManager.shared.getSelectedLanguageName()
            }
        }
    }
}

// MARK: - PostFile
class PostFile: Codable {
    var fileID: Int?
    var fileType: String?
    var postID: Int?
    var videoHeight: Int?
    var videoWidth: Int?
    var video_height: Int?
    var video_width: Int?
    var thumbnailHeight: Int?
    var thumbnailWidth: Int?
    var filePath: String?
    let createdAt: String?
    let updatedAt: String?
    var thumbnail  : String? = ""
    var convertedURL:String
    var filetranslationlink : String?
    let speechToText:String?
    let SpeechToTextTranslated:String?
    let orignalLanguageID:Int?
    var isSpeechExist:Int?
    var videoSeekTime:Double?
    var imageLocal : UIImage?
    var uploadedLang:String?
    var processingStatus:String?
    
    var videoWidthCamelCase: Int?
    var videoHeightCamelCase: Int?
    
    enum CodingKeys: String, CodingKey {
        case fileID = "id"
        case fileType = "file_type"
        case postID = "post_id"
        case videoHeight = "video_height"
        case videoHeightCamelCase = "videoHeight"
        case videoWidth = "video_width"
        case videoWidthCamelCase = "videoWidth"
        case filePath = "file_path"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case thumbnail = "thumbnail_path"
        case speechToText = "speech_to_text"
        case SpeechToTextTranslated = "speech_to_text_TRANSLATION"
        case orignalLanguageID = "language_id"
        case filetranslationlink = "file_translation_link"
        case isSpeechExist = "has_speech_to_text"
        case videoSeekTime = "videoSeekTime"
        case uploadedLang = "language_name_readable"
        case processingStatus = "processing_status"
        case thumbnailWidth = "thumbnailWidth"
        case thumbnailHeight = "thumbnailHeight"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileID = try values.decodeIfPresent(Int.self, forKey: .fileID)
        fileType = try values.decodeIfPresent(String.self, forKey: .fileType)
        uploadedLang = try values.decodeIfPresent(String.self, forKey: .uploadedLang)
        postID = try values.decodeIfPresent(Int.self, forKey: .postID)

        videoWidth = try values.decode(Int.self, forKeys: [.videoWidth, .videoWidthCamelCase])
        videoHeight = try values.decode(Int.self, forKeys: [.videoHeight, .videoHeightCamelCase])
        
        thumbnailWidth =  try values.decodeIfPresent(Int.self, forKey: .thumbnailWidth)
        thumbnailHeight =  try values.decodeIfPresent(Int.self, forKey: .thumbnailHeight)
        filePath = try values.decodeIfPresent(String.self, forKey: .filePath)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        speechToText = try values.decodeIfPresent(String.self, forKey: .speechToText)
        SpeechToTextTranslated = try values.decodeIfPresent(String.self, forKey: .SpeechToTextTranslated)
        orignalLanguageID = try values.decodeIfPresent(Int.self, forKey: .orignalLanguageID)
        filetranslationlink = try values.decodeIfPresent(String.self, forKey: .filetranslationlink)
        isSpeechExist = try values.decodeIfPresent(Int.self, forKey: .isSpeechExist)
        videoSeekTime = try values.decodeIfPresent(Double.self, forKey: .videoSeekTime)
        convertedURL = ""
        processingStatus = try values.decodeIfPresent(String.self, forKey: .processingStatus)
    }
    
    
    init(dict: NSDictionary) {
        self.fileID = dict["id"] as? Int ?? 0
        self.postID = dict[CodingKeys.postID.rawValue] as? Int ?? 0
        
        self.videoWidth = dict[CodingKeys.videoWidth.rawValue] as? Int ?? 0
        if self.videoWidth == 0 {
            self.videoWidth =  dict[CodingKeys.videoWidthCamelCase.rawValue] as? Int ?? 0
        }
        self.videoHeight = dict[CodingKeys.videoHeight.rawValue] as? Int ?? 0
        if self.videoHeight == 0 {
            self.videoHeight =  dict[CodingKeys.videoHeightCamelCase.rawValue] as? Int ?? 0
        }
        self.thumbnailWidth = dict[CodingKeys.thumbnailWidth.rawValue] as? Int ?? 0
        self.thumbnailHeight = dict[CodingKeys.thumbnailHeight.rawValue] as? Int ?? 0
        self.orignalLanguageID = dict[CodingKeys.orignalLanguageID.rawValue] as? Int ?? 0
        self.isSpeechExist = dict[CodingKeys.isSpeechExist.rawValue] as? Int ?? 0
        self.videoSeekTime = dict[CodingKeys.videoSeekTime.rawValue] as? Double ?? 0.0
        self.fileType = dict[CodingKeys.fileType.rawValue] as? String ?? ""
        self.uploadedLang = dict[CodingKeys.uploadedLang.rawValue] as? String ?? ""
        self.filePath = dict[CodingKeys.filePath.rawValue] as? String ?? ""
        self.createdAt = dict[CodingKeys.createdAt.rawValue] as? String ?? ""
        self.updatedAt = dict[CodingKeys.updatedAt.rawValue] as? String ?? ""
        self.thumbnail = dict[CodingKeys.thumbnail.rawValue] as? String ?? ""
        self.speechToText = dict[CodingKeys.speechToText.rawValue] as? String ?? ""
        self.SpeechToTextTranslated = dict[CodingKeys.SpeechToTextTranslated.rawValue] as? String ?? ""
        self.filetranslationlink = dict[CodingKeys.filetranslationlink.rawValue] as? String ?? ""
        self.convertedURL = ""
        self.processingStatus = dict[CodingKeys.processingStatus.rawValue] as? String ?? ""
    }
    
    init() {
        fileID = 0
        fileType = ""
        uploadedLang = ""
        postID = 0
        videoHeight = 0
        videoWidth = 0
        video_width = 0
        video_height = 0
        thumbnailWidth = 0
        thumbnailHeight = 0
        filePath = ""
        createdAt = ""
        updatedAt = ""
        thumbnail = ""
        speechToText = ""
        SpeechToTextTranslated = ""
        orignalLanguageID = 0
        filetranslationlink = ""
        isSpeechExist = 0
        videoSeekTime = 0
        convertedURL = ""
        processingStatus = ""
    }
}
class LanguageObj: Codable {
    var code: String?
    var codeID:Int?
    var languageName:String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case codeID = "id"
        case languageName = "name"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        codeID = try values.decodeIfPresent(Int.self, forKey: .codeID)
        languageName = try values.decodeIfPresent(String.self, forKey: .languageName)
        
    }
    
    init(valueDict : [String : Any]) {
        code = valueDict[CodingKeys.code.rawValue] as? String ?? nil
        codeID = valueDict[CodingKeys.codeID.rawValue] as? Int ?? nil
        languageName = valueDict[CodingKeys.languageName.rawValue] as? String ?? nil
    }
}


// MARK: - Comment
class Comment: Codable,Equatable {
    var commentID: Int? = 0
    var body: String? = ""
    var original_body: String?  = ""
    let userID, postTypeID, postID: Int?
    let createdAt, updatedAt: String?  
    var author: Author?
    var isPostingNow:Bool?  = false
    var identifierStr:String?  = ""
    var audioUrl:String?  = ""
    var commentTime:String?  = ""
    var commentFile: [CommentFile]?
    var isSpeakerPlaying:Bool?  = false
    var selectLanguage:Bool? = true
    var likeCommentCount:Int?  = 0
    var disLikeCommentCount:Int?  = 0
    var isLiked : Bool?
    var isDisliked : Bool?
    var replies:[Comment]?
    var replyCount:Int?
    var comment_language : LanguageObj!
    
    var isExpand: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case body
        case commentID = "id"
        case original_body = "original_body"
        case userID = "user_id"
        case postTypeID = "post_type_id"
        case postID = "post_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author
        case isPostingNow = "postingNow"
        case identifierStr = "identifier"
        case audioUrl = "audio_file_url"
        case commentTime = "commented_time_ago"
        case commentFile = "comment_files"
        case isSpeakerPlaying = "isSpeakerPlaying"
        case selectLanguage = "selectLanguage"
        case likeCommentCount = "simple_like_count"
        case disLikeCommentCount = "simple_dislike_count"
        case isLiked = "has_liked"
        case isDisliked = "has_disliked"
        case replies = "replies"
        case replyCount = "replies_count"
        case comment_language = "comment_language"
    }
    
    init(original_body:String, body:String, firstName:String, lastName:String, profileImage:String, isPosting:Bool, identifierStr:String, fileType:String = "", selectLanguage:Bool = false, videoUrlToUpload:String = "") {
        self.selectLanguage = selectLanguage
        self.commentID = 0
        self.body = body
        self.original_body = original_body
        self.userID = 0
        self.postID = 0
        
        self.postTypeID = 0
        self.createdAt = ""
        self.updatedAt = ""
        self.audioUrl = ""
        self.isPostingNow = isPosting
        self.identifierStr = identifierStr
        self.commentTime = ""
        self.isSpeakerPlaying = false
        self.replyCount = 0
        self.replies = []
        self.author = Author(firstName: firstName, lastName: lastName, profileImage: profileImage)
        if fileType == "image" {
            let myFile = CommentFile(fileType:fileType)
            self.commentFile = [CommentFile]()
            self.commentFile?.insert(myFile, at: 0)
        }else if fileType == "GIF"{
            let myFile = CommentFile(fileType:fileType)
            self.commentFile = [CommentFile]()
            self.commentFile?.insert(myFile, at: 0)
        }
        
        else if fileType == "video" {
            var myFile:CommentFile?
            self.commentFile = [CommentFile]()
            if selectLanguage {
                myFile = CommentFile(fileType:fileType, url: videoUrlToUpload)
            }else {
                myFile = CommentFile(fileType:fileType)
            }
            self.commentFile?.insert(myFile!, at: 0)
        }
    }
    
    init(dict: NSDictionary) {
        self.commentID = dict["id"] as? Int ?? 0
        self.body = dict[CodingKeys.body.rawValue] as? String ?? ""
        self.original_body = dict[CodingKeys.original_body.rawValue] as? String ?? ""
        self.userID = dict[CodingKeys.userID.rawValue] as? Int ?? 0
        self.postID = dict[CodingKeys.postID.rawValue] as? Int ?? 0
        self.likeCommentCount = dict[CodingKeys.likeCommentCount.rawValue] as? Int ?? 0
        self.disLikeCommentCount = dict[CodingKeys.disLikeCommentCount.rawValue] as? Int ?? 0
        self.isLiked =  dict[CodingKeys.isLiked.rawValue] as? Bool ?? false
        self.isDisliked = dict[CodingKeys.isDisliked.rawValue] as? Bool ?? false
        self.postTypeID = dict[CodingKeys.postTypeID.rawValue] as? Int ?? 0
        self.createdAt = dict[CodingKeys.createdAt.rawValue] as? String ?? ""
        self.updatedAt = dict[CodingKeys.updatedAt.rawValue] as? String ?? ""
        self.isPostingNow = true
        self.commentTime = dict[CodingKeys.commentTime.rawValue] as? String ?? ""
        self.identifierStr = dict[CodingKeys.identifierStr.rawValue] as? String ?? ""
        self.audioUrl = dict[CodingKeys.audioUrl.rawValue] as? String ?? ""
        self.replyCount = dict[CodingKeys.replyCount.rawValue] as? Int ?? 1
        self.isSpeakerPlaying = false
        self.selectLanguage = false
        if let dictAuth = dict["author"]  {
            self.author = Author(dict:dictAuth as! NSDictionary)
        }
        if let checkArr = dict[CodingKeys.commentFile.rawValue] {
            if (checkArr as! NSArray).count > 0 {
                let someArr:NSArray = checkArr as! NSArray
                let myDict:NSDictionary = someArr[0] as! NSDictionary
                let myFile = CommentFile(dict: myDict)
                self.commentFile = [CommentFile]()
                self.commentFile?.insert(myFile, at: 0)
            }
        }
        self.replies = []
        if let replyArr = dict[CodingKeys.replies.rawValue] as? NSArray {
            for dict in replyArr {
                let commentObj:Comment = Comment(dict: dict as! NSDictionary)
                self.replies?.append(commentObj)
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        body = try values.decodeIfPresent(String.self, forKey: .body)
        original_body = try values.decodeIfPresent(String.self, forKey: .original_body)
        commentID = try values.decodeIfPresent(Int.self, forKey: .commentID)
        likeCommentCount = try values.decodeIfPresent(Int.self, forKey: .likeCommentCount)
        replyCount = try values.decodeIfPresent(Int.self, forKey: .replyCount)
        disLikeCommentCount = try values.decodeIfPresent(Int.self, forKey: .disLikeCommentCount)
        userID = try values.decodeIfPresent(Int.self, forKey: .userID)
        postTypeID = try values.decodeIfPresent(Int.self, forKey: .postTypeID)
        postID = try values.decodeIfPresent(Int.self, forKey: .postID)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        author = try values.decodeIfPresent(Author.self, forKey: .author)
        isPostingNow = try values.decodeIfPresent(Bool.self, forKey: .isPostingNow)
        audioUrl = try values.decodeIfPresent(String.self, forKey: .audioUrl)
        commentTime = try values.decodeIfPresent(String.self, forKey: .commentTime)
        commentFile = try values.decodeIfPresent([CommentFile].self, forKey: .commentFile)
        isSpeakerPlaying = try values.decodeIfPresent(Bool.self, forKey: .isSpeakerPlaying)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        isDisliked = try values.decodeIfPresent(Bool.self, forKey: .isDisliked)
        replies = try values.decodeIfPresent([Comment].self, forKey: .replies)
        comment_language = try values.decodeIfPresent(LanguageObj.self, forKey: .comment_language)

    }
    public static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.commentID == rhs.commentID
    }
}

class CommentFile:Codable {
    var commentID: Int?
    var createdAt: String?
    var updatedAt: String?
    var filePath:String?
    var fileType:String?
    var id:Int?
    var isSnapShot:Int?
    var orignalUrl:String?
    var url:String?
    var languageID:Int?
    var isLocalFileExist = false
    var localImage = UIImage()
    var assetObj:PHAsset?
    var thumbnail_url : String?
    var original_name : String?
    
    enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case createdAt = "created_at"
        case filePath = "file_path"
        case fileType = "file_type"
        case id = "id"
        case updatedAt = "updated_at"
        case isSnapShot = "is_snapshot"
        case orignalUrl = "original_url"
        case url = "url"
        case languageID = "language_id"
        case thumbnail_url = "thumbnail_url"
        case original_name = "original_name"
        
    }
    
    init(fileType:String, url:String = ""){
        self.fileType = fileType
        self.commentID = -1
        self.createdAt = ""
        self.updatedAt = ""
        self.filePath = ""
        self.id = -1
        self.isSnapShot = 0
        self.orignalUrl = ""
        self.url = url
        self.original_name = ""
    }
    
    init(dict:NSDictionary) {
        self.fileType = dict[CodingKeys.fileType.rawValue] as? String ?? ""
        self.commentID = dict[CodingKeys.commentID.rawValue] as? Int ?? -1
        self.createdAt = dict[CodingKeys.createdAt.rawValue] as? String ?? ""
        self.updatedAt = dict[CodingKeys.updatedAt.rawValue] as? String ?? ""
        self.filePath = dict[CodingKeys.filePath.rawValue] as? String ?? ""
        self.id = dict[CodingKeys.id.rawValue] as? Int ?? -1
        self.isSnapShot = 0
        self.orignalUrl = dict[CodingKeys.orignalUrl.rawValue] as? String ?? ""
        self.url = dict[CodingKeys.url.rawValue] as? String ?? ""
        self.thumbnail_url = dict[CodingKeys.thumbnail_url.rawValue] as? String ?? ""
        self.original_name = dict[CodingKeys.original_name.rawValue] as? String ?? ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        commentID = try values.decodeIfPresent(Int.self, forKey: .commentID)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        filePath = try values.decodeIfPresent(String.self, forKey: .filePath)
        fileType = try values.decodeIfPresent(String.self, forKey: .fileType)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        isSnapShot = try values.decodeIfPresent(Int.self, forKey: .isSnapShot)
        orignalUrl = try values.decodeIfPresent(String.self, forKey: .orignalUrl)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        languageID = try values.decodeIfPresent(Int.self, forKey: .languageID)
        thumbnail_url = try values.decodeIfPresent(String.self, forKey: .thumbnail_url)
        original_name = try values.decodeIfPresent(String.self, forKey: .original_name)
        
        
    }
}

// MARK: - Author
class Author: Codable {
    let authorID: Int?
    let profileImage: String?
    let firstname, lastname: String?
    
    enum CodingKeys: String, CodingKey {
        case authorID = "id"
        case profileImage = "profile_image"
        case firstname, lastname
    }
    
    init(firstName:String, lastName:String, profileImage:String) {
        self.authorID = 0
        self.profileImage = profileImage
        self.firstname = firstName
        self.lastname = lastName
    }
    
    init(dict:NSDictionary) {
        self.authorID = dict[CodingKeys.authorID.rawValue] as? Int ?? 0
        self.profileImage = dict[CodingKeys.profileImage.rawValue] as? String ?? ""
        self.firstname = dict[CodingKeys.firstname.rawValue] as? String ?? ""
        self.lastname = dict[CodingKeys.lastname.rawValue] as? String ?? ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authorID = try values.decodeIfPresent(Int.self, forKey: .authorID)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
    }
}

class ReactionModel: Codable {
    var count: Int?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case type = "type"
    }
    
    init(countP:Int, typeP:String) {
        self.count = countP
        self.type = typeP
    }
    
    init(dict: NSDictionary) {
        self.count =  dict["count"] as! Int
        self.type = SharedManager.shared.ReturnValueAsString(value: dict["type"] as Any)
        
    }

    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }
}

extension KeyedDecodingContainer {
    enum ParsingError:Error{
        case noKeyFound
    }
    
    func decode<T>(_ type: T.Type, forKeys keys: [K]) throws -> T where T: Decodable {
        for key in keys {
            if let val = try? self.decode(type, forKey: key) {
                return val
            }
        }
        
//        if type == Int.self { // Check if the type is Int
//            return 0 as! T // Return 0 as Int
//        }
        throw ParsingError.noKeyFound
    }
}
