//
//  PostCollectionViewObject.swift
//  WorldNoor
//
//  Created by Raza najam on 5/13/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import TLPhotoPicker

class PostCollectionViewObject : NSObject {
    var imageMain : UIImage!
    var imageUrl = ""
    var id:String = ""
    var videoURL : URL!
    var assetMain : TLPHAsset!
    var isType = PostDataType.Empty
    var photoUrl:URL!
    var messageBody:String!
    var langID:String = ""
    var isEditPost:Bool = false
    var isUploading = false
    var thumbURL:String = ""
    var hashString:String = ""
    var fileUrl:String = ""
    var isCompress:Bool = true
    
    var isUploaded :Bool = false
    var isThumbUploaded :Bool = false
    var S3ImageURL :String = ""
    var S3VideoURL :String = ""
    
    var S3ImagePath :String = ""
    var S3VideoPath :String = ""
    
    
    var videoName :String = ""
    var ImageName :String = ""
    override init() {
        
    }
    
    init(dict:NSDictionary) {
        
        LogClass.debugLog("PostCollectionViewObject dict  ===>")
        LogClass.debugLog(dict)
        self.isUploading = true
        if let thumb = dict["thumbnail"] as? String {
            self.thumbURL = SharedManager.shared.ReturnValueAsString(value: thumb as Any)
        }
        if let url = dict["url"] {
            self.hashString = SharedManager.shared.ReturnValueAsString(value:url as Any)
        }
        if let langObjID = dict["language_id"] {
            self.langID = SharedManager.shared.ReturnValueAsString(value:langObjID as Any)
        }
        
        
        if let typeMain = dict["type"] {
            
            
            let typeString = SharedManager.shared.ReturnValueAsString(value:typeMain as Any)
            
//        case Image = 1
//        case Video = 2
//        case Audio = 3
//        case Text  = 4
//        case GIF  = 6
//        case Empty  = 0
//        case imageText  = 5
//        case GIFBrowse  = 7
//        case AudioMusic  = 8
//        case Attachment  = 9
            
            if typeString == "1"  {
                self.isType = PostDataType.Image
            }else if typeString == "2" {
                self.isType = PostDataType.Video
            }else if typeString == "3" || typeString ==  "8" {
                self.isType = PostDataType.Audio
            }else if typeString == "4" {
                self.isType = PostDataType.Text
            }else if typeString == "6" {
                self.isType = PostDataType.GIF
            }else if typeString == "5" {
                self.isType = PostDataType.imageText
            }else if typeString == "7" {
                self.isType = PostDataType.GIFBrowse
            }else if typeString == "9" {
                self.isType = PostDataType.Attachment
            }else {
                self.isType = PostDataType.Empty
            }
            
        }
    }
    
    init(postFile:PostFile) {
        self.isEditPost  = true
        if postFile.fileType == FeedType.image.rawValue {
            self.imageUrl = postFile.filePath ?? ""
            self.videoURL = URL(string:postFile.filePath ?? "")
            self.isType = PostDataType.Image
        } else if postFile.fileType == FeedType.video.rawValue {
            self.thumbURL = postFile.thumbnail ?? ""
            self.isType = PostDataType.Video
            self.videoURL = URL(string:postFile.filePath ?? "")
            self.langID = postFile.uploadedLang ?? ""
        } else if postFile.fileType == FeedType.audio.rawValue {
            self.isType = PostDataType.Audio
            self.langID = postFile.uploadedLang ?? ""
            self.videoURL = URL(string:postFile.filePath ?? "")
        } else if postFile.fileType == FeedType.file.rawValue {
            self.isType = PostDataType.Attachment
            self.langID = postFile.uploadedLang ?? ""
            self.videoURL = URL(string:postFile.filePath ?? "")
        }
        
        LogClass.debugLog("self.isType ===>")
        LogClass.debugLog(self.isType)
        LogClass.debugLog(self.langID)
        LogClass.debugLog(postFile.uploadedLang)
        LogClass.debugLog(self.videoURL)
        self.fileUrl = postFile.filePath ?? ""
    }
    
    func getPostData(respArray:NSArray) -> [PostCollectionViewObject] {
        var postArray:[PostCollectionViewObject] = [PostCollectionViewObject]()
        for data in respArray {
            postArray.append(PostCollectionViewObject.init(dict: data as! NSDictionary))
        }
        return postArray
    }
    
    func manageEditPost(feedObj: FeedData) -> [PostCollectionViewObject]  {
        
        var postArray: [PostCollectionViewObject] = [PostCollectionViewObject]()
        if feedObj.postType! == FeedType.gallery.rawValue {
            for data in feedObj.post! {
                postArray.append(PostCollectionViewObject.init(postFile: data))
            }
        } else {
            if feedObj.postType! == FeedType.post.rawValue {
                return postArray
            } else {
                if feedObj.post!.count > 0 {
                    postArray.append(PostCollectionViewObject.init(postFile: feedObj.post![0]))
                }
            }
        }
        return postArray
    }
}
