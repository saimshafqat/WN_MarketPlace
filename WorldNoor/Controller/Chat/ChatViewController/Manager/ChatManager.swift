//
//  ChatManager.swift
//  WorldNoor
//
//  Created by Raza najam on 1/17/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
class ChatManager: NSObject {
    static let shared = ChatManager()
    var conversationID = -1
    var chatCurrentIdentifierString = ""
    
    func manageChatData(postObj:[PostCollectionViewObject])-> NSArray{
        let messageMainArray:NSMutableArray = NSMutableArray()
        if postObj.count < 4 {
            for postObj in postObj {
                let messageArray:NSMutableArray = NSMutableArray()
                let dict:NSMutableDictionary = [
                    "audio_file":"",
                    "audio_msg_url":"",
                    "author_id":SharedManager.shared.getUserID(),
                    "auto_translate":"0",
                    "body":"",
                    "conversation_id":conversationID,
                    "created_at":"",
                    "full_name":SharedManager.shared.getFullName(),
                    "id":"",
                    "identifierString":self.chatCurrentIdentifierString,
                    "profile_image":"",
                    "user_id":SharedManager.shared.getUserID(),
                ]
                if postObj.isType == PostDataType.Image {
                    dict["post_type"] = "image"
                    let innerDict:NSDictionary = ["id":"", "post_type":"image","url":"containsFullImage","img":postObj.imageMain as UIImage, "localImageUrl":postObj.photoUrl!]
                    messageArray.add(innerDict)
                    dict["message_files"] = messageArray as NSArray
                    messageMainArray.add(dict)
                }else  if postObj.isType == PostDataType.Audio {
                    dict["audio_file"] = postObj.videoURL.path
                    dict["audio_msg_url"] = postObj.videoURL.path
                    dict["post_type"] = "audio"
                    dict["message_files"] = []
                    dict["body"] = postObj.messageBody
                    messageMainArray.add(dict)
                }else  if postObj.isType == PostDataType.Video {
                    let innerDict:NSDictionary = ["id":"", "post_type":"video","url":"containsFullImage","img":postObj.imageMain as UIImage,                                          "localVideoUrl":postObj.videoURL!]
                    messageArray.add(innerDict)
                    dict["message_files"] = messageArray as NSArray
                    messageMainArray.add(dict)
                }
            }
            return messageMainArray
        }else {
            let dict:NSMutableDictionary = [
                "audio_file":"",
                "audio_msg_url":"",
                "author_id":SharedManager.shared.getUserID(),
                "auto_translate":"0",
                "body":"",
                "post_type":"gallery",
                "conversation_id":conversationID,
                "created_at":"",
                "full_name":SharedManager.shared.getFullName(),
                "id":"",
                "identifierString":self.chatCurrentIdentifierString,
                "profile_image":"",
                "user_id":SharedManager.shared.getUserID(),
            ]
            let messageArray:NSMutableArray = NSMutableArray()
            for postObj in postObj {
                if postObj.isType == PostDataType.Image {
                    let innerDict:NSDictionary = ["id":"", "post_type":"image","url":"containsFullImage","img":postObj.imageMain as UIImage,                                          "localImageUrl":postObj.photoUrl!]
                    messageArray.add(innerDict)
                }else  if postObj.isType == PostDataType.Audio {
                    let innerDict:NSDictionary = ["id":"", "post_type":"audio","url":postObj.videoURL.path]
                    messageArray.add(innerDict)
                    messageArray.add(innerDict)
                }else  if postObj.isType == PostDataType.Video {
                    
                }
            }
            dict["message_files"] = messageArray as NSArray
            messageMainArray.add(dict)
            return messageMainArray
        }
    }
    
    func getUrlFromPHAsset(asset: PHAsset, completion: @escaping (_ url: URL?) -> Void) {
        asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
            if let url = contentEditingInput!.fullSizeImageURL {
                _ = url.path
                completion(url)
            } else {
            }
        })
    }
    
    func validateTextMessage(comment:String) -> String{
        var myComment = comment.trimmingCharacters(in: .whitespaces)
        if myComment == "" || myComment == Const.chatTextViewPlaceholder.localized() {
            myComment = ""
            return ""
        }
        return myComment
    }
    
    func getAudioObject(urlString:String, body:String)->NSArray{
        var someArray:[PostCollectionViewObject] = []
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.Audio
        newObj.videoURL = URL.init(string: urlString)
        newObj.messageBody = body
        someArray.append(newObj)
        return self.manageChatData(postObj: someArray)
    }
}


extension PHAsset {
    func getAssetThumbnail() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self,
                             targetSize: CGSize(width: 63.0, height: 63.0),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, info) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
}
