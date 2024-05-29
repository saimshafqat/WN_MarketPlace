//
//  FeedDetailCallbackManager.swift
//  WorldNoor
//
//  Created by Raza najam on 2/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FeedDetailCallbackManager: NSObject {
    static let shared = FeedDetailCallbackManager()
    var speakerHandlerFeedDetail:((IndexPath) ->())?
    var videoFeedDetailTranscriptCallBackHandler:((IndexPath, Bool) ->())?
    var videoDetailTranscriptGalleryCallBackHandler:((IndexPath, IndexPath, Bool) ->())?
    var FeedDetailPreviewLinkHandler:((String) ->())?
    var commentReplySheetHandler:((IndexPath, IndexPath) ->())?
    var commentImageTappedHandler:((IndexPath, IndexPath) ->())?
    var replyLikeCounterHandler:((IndexPath, IndexPath) ->())?
    var replyDisLikeCounterHandler:((IndexPath, IndexPath) ->())?
    var replyBtnClickedHandler:((IndexPath, IndexPath) ->())?
    var refreshReplyHandler:((IndexPath) ->())?
    var commentFileDownloadHandler:((CommentFile) ->())?

    
    func manageCommentCount(commentObj:Comment)-> NSMutableDictionary{
        let counterDict = NSMutableDictionary()
        counterDict["like"] = ""
        counterDict["disLike"] = ""
        if let likeCounter = commentObj.likeCommentCount {
            var counterValue = ""
            if likeCounter <= 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(likeCounter)
            }
            counterDict["like"] = counterValue
        }
        if let disLikeCounter = commentObj.disLikeCommentCount {
            var counterValue = ""
            if disLikeCounter <= 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(disLikeCounter)
            }
            counterDict["disLike"] = counterValue
        }
        return counterDict
    }
    // Hanlding LikeDislikeCallBack...
    func handlingLikeDislike(isLike:Bool, value:Bool, commentObj:Comment, commentIndex:IndexPath){
        if isLike {
            if value {
                commentObj.likeCommentCount = commentObj.likeCommentCount! + 1
                if commentObj.isDisliked! {
                    commentObj.disLikeCommentCount = commentObj.disLikeCommentCount! - 1
                }
            }else {
                commentObj.likeCommentCount = commentObj.likeCommentCount! - 1
            }
            commentObj.isLiked = value
            commentObj.isDisliked = false
        }else {
            if value {
                commentObj.disLikeCommentCount = commentObj.disLikeCommentCount! + 1
                if commentObj.isLiked! {
                    commentObj.likeCommentCount = commentObj.likeCommentCount! - 1
                }
            }else {
                commentObj.disLikeCommentCount = commentObj.disLikeCommentCount! - 1
            }
            commentObj.isDisliked = value
            commentObj.isLiked = false
        }
    }
}

