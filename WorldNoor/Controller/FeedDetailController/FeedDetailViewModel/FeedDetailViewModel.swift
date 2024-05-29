//
//  FeedDetailViewModel.swift
//  WorldNoor
//
//  Created by Raza najam on 10/26/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class FeedDetailViewModel: NSObject {
    var feedObj:FeedData?
    
    func manageCount(feedObj:FeedData)-> NSMutableDictionary{
        self.feedObj = feedObj
        let counterDict = NSMutableDictionary()
        counterDict["like"] = ""
        counterDict["disLike"] = ""
        counterDict["comment"] = ""
        counterDict["share"] = ""
        
        if let likeCounter = self.feedObj?.likeCount {
            var counterValue = ""
            if likeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(likeCounter)
            }
            counterDict["like"] = counterValue
        }
        if let disLikeCounter = self.feedObj?.simple_dislike_count {
            var counterValue = ""
            if disLikeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(disLikeCounter)
            }
            counterDict["disLike"] = counterValue
        }
        if let commentCount = self.feedObj?.commentCount {
            var counterValue = ""
            if commentCount == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(commentCount)
            }
            counterDict["comment"] = counterValue
        }
        if let shareCount = self.feedObj?.shareCount {
            var counterValue = ""
            if shareCount == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(shareCount)
            }
            counterDict["share"] = counterValue
        }
        return counterDict
    }
    //
    // Hanlding LikeDislikeCallBack...
    func handlingLikeDislike(isLike:Bool, value:Bool, feedObjUpdate:FeedData){
        if isLike {
            if value {
                feedObjUpdate.likeCount = feedObjUpdate.likeCount! + 1
                if feedObjUpdate.isDisliked! {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                }
            }else {
                feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
            }
            feedObjUpdate.isLiked = value
            feedObjUpdate.isDisliked = false
        }else {
            if value {
                feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! + 1
                if feedObjUpdate.isLiked! {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                }
            }else {
                feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
            }
            feedObjUpdate.isDisliked = value
            feedObjUpdate.isLiked = false
        }
    }
}
