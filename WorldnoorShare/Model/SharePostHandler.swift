//
//  SharePostHandler.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class SharePostHandler: NSObject {
    static let shared = SharePostHandler()
    
    var videoLangChangeHandler:((IndexPath, String)->())?
    var singleFeedHandler:(([Int:String])->())?
    var showLangSelectionHandler:((IndexPath)->())?

    func checkIfLanguageSelected(postArray:[ShareCollectionViewObject])-> Bool{
        for postObj in postArray {
            if postObj.isType == PostDataType.Video ||  postObj.isType == PostDataType.Audio || postObj.isType == PostDataType.AudioMusic{
                
                if postObj.isType == PostDataType.Video
                {
                    postObj.langID = "0"
                }
                
                if postObj.langID == "" {
                    return true
                }
                
            }
        }
        return false
    }
    
    func checkIfFileExist(postArray:[ShareCollectionViewObject])-> Bool{
        for postObj in postArray {
            if postObj.isType == PostDataType.Video ||  postObj.isType == PostDataType.Audio || postObj.isType == PostDataType.AudioMusic ||  postObj.isType == PostDataType.GIF || postObj.isType == PostDataType.imageText  || postObj.isType == PostDataType.Image || postObj.isType == PostDataType.Attachment{
                return true
            }
        }
        return false
    }
    func checkIfVideoExist(postArray:[ShareCollectionViewObject])-> Bool{
        for postObj in postArray {
            if postObj.isType == PostDataType.Video {
                return true
            }
        }
        return false
    }
    
}
