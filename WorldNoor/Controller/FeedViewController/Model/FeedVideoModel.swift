////
////  FeedVideoModel.swift
////  WorldNoor
////
////  Created by Raza najam on 4/7/20.
////  Copyright © 2020 Raza najam. All rights reserved.
////
//
//import UIKit



//
//  FeedVideoModel.swift
//  WorldNoor
//
//  Created by Lucky on 07/08/2022.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import UIKit

class FeedVideoModel: NSCopying {

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
    var storyindex :Int!
    var snapsCount = 0
    var isCancelledAbruptly = false
    var isCompletelyVisible = false
    public var snaps: [StoryObject] = [StoryObject]()
    var lastPlayedSnapIndex = 0
    
    public var user:IGUser?
    
    init() {
   }
    
    init(dict:[String:Any]) {
        if let authorDict = dict["author"] as? [String:Any] {
            self.authorName = SharedManager.shared.ReturnValueAsString(value: authorDict["author_name"] as Any)
            self.authorImage = SharedManager.shared.ReturnValueAsString(value: authorDict["profile_image"] as Any)
            self.internalidentifier = SharedManager.shared.ReturnValueAsString(value: authorDict["id"] as Any)
        }
        self.videoUrl = SharedManager.shared.ReturnValueAsString(value: dict["path"] as Any)
        self.videoThumbnail = SharedManager.shared.ReturnValueAsString(value: dict["thumbnail"] as Any)
        self.videoID = SharedManager.shared.ReturnValueAsString(value: dict["id"] as Any)
        self.hasSpeechToText = SharedManager.shared.ReturnValueAsBool(value: dict["has_speech_to_text"] as Any)
        self.hasSpeechToTextString = SharedManager.shared.ReturnValueAsString(value: dict["has_speech_to_text"] as Any)
        
        self.languageID =  SharedManager.shared.ReturnValueAsString(value: dict["file_language_id"] as Any)
        self.thumbnail =  SharedManager.shared.ReturnValueAsString(value: dict["thumbnail"] as Any)
        self.postID = SharedManager.shared.ReturnValueAsString(value: dict["post_file_id"] as Any)
        self.langName = SharedManager.shared.ReturnValueAsString(value: dict["language_name_readable"] as Any)
        self.postType = SharedManager.shared.ReturnValueAsString(value: dict["post_type"] as Any)
        self.colorcode = SharedManager.shared.ReturnValueAsString(value: dict["color_code"] as Any)
        self.body = SharedManager.shared.ReturnValueAsString(value: dict["body"] as Any)
        self.commentCount = SharedManager.shared.ReturnValueAsString(value: dict["countComment"] as Any)
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
        
        
        
        self.reactionCount = SharedManager.shared.ReturnValueAsString(value: dict["reactionCount"] as Any)
        user = IGUser.manageUserData(id: internalidentifier, userName: self.authorName, pic: videoUrl)
        let snap  = StoryObject.init(dict: dict)
        snaps.append(snap)
        
        
        self.snapsCount = snaps.count
        
    }
    
    init(dict:[String:Any], status: String) {
        
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
                self.status = status
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
        if let storiesArray = dict["stories"] as? [[String : Any]] {
            for indexObj in storiesArray {
                
                self.snaps.append(StoryObject.init(dict: indexObj as [String : Any]))
            }
        }
        if snaps.count > 0 {
            let storyObj = snaps[0]
            self.internalidentifier = storyObj.videoID
            user = IGUser.manageUserData(id: storyObj.videoID, userName: storyObj.authorName, pic: storyObj.authorImage)
        }
       
        self.snapsCount = snaps.count
        
    }
    
    func getVideoModelArray(arr:[[String:Any]])-> [FeedVideoModel] {
        var videoArray:[FeedVideoModel] = [FeedVideoModel]()
        for dict in arr {
           
            let videoModel = FeedVideoModel.init(dict: dict, status: "")
            if videoModel.snaps.count > 0 {
            videoArray.append(videoModel)
            }
        }
        return videoArray
    }
    
    
    func getVideoModel(dict:[String:Any])-> [FeedVideoModel] {
        var videoArray:[FeedVideoModel] = [FeedVideoModel]()
            let videoModel   =  FeedVideoModel.init(dict: dict, status: "")
            if videoModel.snaps.count > 0{
            videoArray.append(videoModel)
            }
        return videoArray
    }
    
    func getVideoObj(dict:[String:Any])-> FeedVideoModel {
        let fileName = SharedManager.shared.getIdentifierForMessage()
        let fileNameExt = fileName + ".jpg"
        let feedObj:FeedVideoModel = FeedVideoModel.init()
        feedObj.status = "toUpload"
        feedObj.authorName = SharedManager.shared.getFullName()
        feedObj.internalidentifier = SharedManager.shared.ReturnValueAsString(value: SharedManager.shared.getUserID())
        feedObj.videoUrl = SharedManager.shared.ReturnValueAsString(value: dict["path"] as Any)
        FileBasedManager.shared.saveFileTemporarily(fileObj: (dict["storedImage"] as! UIImage), name:fileNameExt)
        feedObj.videoThumbnail = FileBasedManager.shared.getSavedImagePath(name: fileNameExt)
        feedObj.authorImage = SharedManager.shared.userObj?.data.profile_image ?? ""
        feedObj.identifierString = fileName
        return feedObj
    }
    
    func getVideoResponseObject(arr:[[String:Any]])->FeedVideoModel {
        var feedObj:FeedVideoModel?
        if arr.count > 0 {
            let videoModel = FeedVideoModel.init(dict: arr[0])
            feedObj = videoModel
        }
        return feedObj!
    }
    
    func getVideoResponseObjectUpdated(arr:[String:Any])->FeedVideoModel {
        var feedObj:FeedVideoModel?
        if arr.count > 0 {
            if let dataDict = arr["data"] as? [String:Any] {
                let videoModel = FeedVideoModel.init(dict: dataDict, status: "processing")
                feedObj = videoModel
            }
        }
        return feedObj!
    }
    func copy(with zone: NSZone? = nil) -> Any {
        let copyStatus = FeedVideoModel()
        copyStatus.snaps = self.snaps
        copyStatus.snapsCount = self.snapsCount
        copyStatus.videoID = self.videoID
        copyStatus.videoUrl = self.videoUrl
        copyStatus.authorName = self.authorName
        copyStatus.internalidentifier = self.internalidentifier
        copyStatus.postType = self.postType
        copyStatus.body = self.body
        copyStatus.colorcode = self.colorcode
        copyStatus.videoThumbnail = self.videoThumbnail
        copyStatus.authorImage = self.authorImage
        copyStatus.languageID = self.languageID
        copyStatus.langName = self.langName
  //      copyStatus.lastUpdated = self.lastUpdated
        copyStatus.user = self.user
        copyStatus.lastPlayedSnapIndex = self.lastPlayedSnapIndex
        copyStatus.isCompletelyVisible = self.isCompletelyVisible
        copyStatus.isCancelledAbruptly = self.isCancelledAbruptly
        return copyStatus
    }
    func removeCachedFile(for urlString: String) {
        IGVideoCacheManager.shared.getFile(for: urlString) { (result) in
            switch result {
            case .success(let url):
                IGVideoCacheManager.shared.clearCache(for: url.absoluteString)
            case .failure(let error):
                LogClass.debugLog("File read error: \(error)")
            }
        }
    }
    
    static func removeAllVideoFilesFromCache() {
        IGVideoCacheManager.shared.clearCache()
    }
}
extension FeedVideoModel: Equatable {
    public static func == (lhs: FeedVideoModel, rhs: FeedVideoModel) -> Bool {
        return lhs.internalidentifier == rhs.internalidentifier
    }
}

class StoryReactionModel: ResponseModel {
    
    var count: Int?
    var type: String?
    
    override init() {
        super.init()
   }
    
    init(countP:Int, typeP:String) {
        self.count = countP
        self.type = typeP
    }
    
    init(dict: NSDictionary) {
        super.init()
        self.count =  dict["count"] as! Int
        self.type = SharedManager.shared.ReturnValueAsString(value: dict["type"] as Any)
    }
}
