//
//  FeedCallBManager.swift
//  WorldNoor
//
//  Created by Raza najam on 1/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FeedCallBManager: NSObject {
    
    static let shared = FeedCallBManager()
    var likeCallBackManager:((Int)->())?
    var galleryCellIndexCallbackHandler:((IndexPath, IndexPath, Bool)->())?
    var galleryCellIndexCallbackHandlerforFullView:((IndexPath, IndexPath)->())?
    var speakerHandler:((IndexPath, Bool) ->())?
    var myFeedArray:[FeedData] = []
    var videoCellIndexCallbackHandler:((IndexPath)->())?
    var feedDetailgalleryCellIndexCallbackHandler:((IndexPath, Bool)->())?
    var linkPreviewUpdateHandler:((String) ->())?
    var dropDownFeedHanlder:((IndexPath)->())?
    var dropDownFeedCommentHanlder:((IndexPath)->())?
    var commentImageTappedHandler:((IndexPath) ->())?
    var downloadShareFile:((IndexPath , IndexPath) ->())?
    var commentImageTappedDetailHandler:((IndexPath) ->())?
//    var videoTranscriptCallBackHandler:((IndexPath, Bool) ->())?
//    var videoTranscriptGalleryCallBackHandler:((IndexPath, IndexPath, Bool) ->())?
    
    var updateVideoViewSeekTimeForNewsFeedHandler:((IndexPath, IndexPath, Double) ->())?
    var updateVideoViewSeekTimeForNewsFullGalleryHandler:((IndexPath, IndexPath, Double) ->())?
    var uploadingCloseHandler:((IndexPath) ->())?
    var uploadingInstantHandler:((IndexPath, FeedUpload, String) ->())?
    var downloadFileHandler:((IndexPath, CommentFile) ->())?
    var notificationBadgeHandler:(() ->())?

    //Hanlding of video clips
    var videoClipArray:[FeedVideoModel] = [FeedVideoModel]()
    var watchArray:[FeedData] = [FeedData]()

    var cacheVideoClipDict:[String:RequestManagerUploading] = [String:RequestManagerUploading]()
    var showMessageAlertyHandler:((String) ->())?
    var videoProcessingCompletedHandler:((Int, Int) ->())?
    var userProfileHandler:((String) ->())?
    
    var commentOptionBtnHandler:((IndexPath, UIButton)->())?
    
    var feedDownloadDict:[Int:DownloadFeedManager] = [:]
    
    
    func manageSpeakerForVisibleCell(tableCellArr:[UITableViewCell], currentIndex:IndexPath, feedArray:[FeedData], isComment:Bool = false){
        self.myFeedArray = feedArray
        for i in 0 ..< tableCellArr.count{
            let feedObj = feedArray[i]
            feedObj.isSpeakerPlaying = false
            self.myFeedArray[i] = feedObj
            if tableCellArr[i] is PostCell {
                let myCell:PostCell = tableCellArr[i] as! PostCell
                myCell.headerViewRef.speakerButton.isSelected = false
            }else if tableCellArr[i] is AudioCell {
                let myCell = tableCellArr[i] as! AudioCell
                myCell.headerViewRef.speakerButton.isSelected = false
            }else if tableCellArr[i] is VideoCell {
                let myCell = tableCellArr[i] as! VideoCell
                myCell.headerViewRef.speakerButton.isSelected = false
            }else if tableCellArr[i] is GalleryCell {
                let myCell = tableCellArr[i] as! GalleryCell
                myCell.headerViewRef.speakerButton.isSelected = false
            }else if tableCellArr[i] is ImageCellSingle {
                let myCell = tableCellArr[i] as! ImageCellSingle
                myCell.headerViewRef.speakerButton.isSelected = false
            }else if tableCellArr[i] is SharedCell {
                let myCell = tableCellArr[i] as! SharedCell
                myCell.headerViewRef.speakerButton.isSelected = false
            }
            
        }
        if feedArray.count >= currentIndex.row {
            let feedObj = feedArray[currentIndex.row]
            if isComment {
                if feedObj.comments!.count > 0 {
                    let commentObj = feedObj.comments![0]
                    commentObj.isSpeakerPlaying = true
                    feedObj.isSpeakerPlaying = false
                    feedObj.comments![0] = commentObj
                }
            }else {
                feedObj.isSpeakerPlaying = true
            }
            self.myFeedArray[currentIndex.row] = feedObj
        }
    }
    
    
    func showAudioRecorder(cell:UITableViewCell) {
        if cell is PostCell {
            let myCell:PostCell = cell as! PostCell
        }else if cell is AudioCell {
            let myCell = cell as! AudioCell
        }else if cell is VideoCell {
            let myCell = cell as! VideoCell
        }else if cell is GalleryCell {
            let myCell = cell as! GalleryCell
        }else if cell is ImageCellSingle {
            let myCell = cell as! ImageCellSingle
        }else if cell is SharedCell {
            let myCell = cell as! SharedCell
        }
    }
    
    func manageMovingToDetailFeedScreen(tableCellArr:[UITableViewCell]){

        
        for i in 0 ..< tableCellArr.count{

            if tableCellArr[i] is PostCell {
                let myCell:PostCell = tableCellArr[i] as! PostCell
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
            }else if tableCellArr[i] is AudioCell {
                let myCell = tableCellArr[i] as! AudioCell
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                
                myCell.xqAudioPlayer.resetXQPlayer()
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }else if tableCellArr[i] is NewAudioFeedCell {
                let myCell = tableCellArr[i] as! NewAudioFeedCell
//                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
//                    xqPlayer.resetXQPlayer()
//                }
                
                myCell.stopPlayer()
//                myCell.xqAudioPlayer.resetXQPlayer()
//                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
//                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }else if tableCellArr[i] is VideoCell {
                let myCell = tableCellArr[i] as! VideoCell
                myCell.resetVideoPlayer()
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }else if tableCellArr[i] is GalleryCell {
                let myCell = tableCellArr[i] as! GalleryCell
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                myCell.resetVisibleCellVideo()
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }
            else if tableCellArr[i] is ImageCellSingle {
                let myCell = tableCellArr[i] as! ImageCellSingle
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }else if tableCellArr[i] is SharedCell {
                let myCell = tableCellArr[i] as! SharedCell
                if  let xqPlayer = myCell.commentViewRef.xqAudioPlayer {
                    xqPlayer.resetXQPlayer()
                }
                myCell.resetSharedElements()
                myCell.commentViewRef.audioRecorderObj?.doResetRecording()
                myCell.commentViewRef.videoView?.resetVideoPlayer()
                
            }
        }
    }
    
    func getLanguageCode(languageID : String)-> String{
        
        var languageCode = "en"
        switch languageID {
        case "25":
            languageCode = "vi"
            break
        case "24":
            languageCode = "uk"
            break
        case "23":
            languageCode = "tr"
            break
        case "22":
            languageCode = "sv"
            break
        case "21":
            languageCode = "sk"
            break
        case "20":
            languageCode = "pt"
            break
        case "19":
            languageCode = "pl"
            break
        case "18":
            languageCode = "ko"
            break
        case "17":
            languageCode = "id"
            break
        case "16":
            languageCode = "hu"
            break
        case "15":
            languageCode = "el"
            break
        case "14":
            languageCode = "fi"
            break
        case "13":
            languageCode = "fil"
            break
        case "12":
            languageCode = "nl"
            break
        case "11":
            languageCode = "da"
            break
        case "10":
            languageCode = "cs"
            break
        case "9":
            languageCode = "hi"
            break
        case "8":
            languageCode = "es"
            break
        case "7":
            languageCode = "ru"
            break
        case "6":
            languageCode = "ja"
            break
        case "5":
            languageCode = "it"
            break
        case "4":
            languageCode = "de"
            break
        case "3":
            languageCode = "fr"
            break
        case "2":
            languageCode = "ar"
            break
        default:
            languageCode = "en"
        }
        return languageCode
    }
    
    func manageVideoProcessingResponse(feedObj:[FeedData], id:String){

        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token":SharedManager.shared.userToken()]
        
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(_):
                LogClass.debugLog("error.")
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let res = res as? [String:Any] {
                    let postDict = res["post"] as! [String:Any]
                    let postArray = postDict["post_files"] as! [[String:Any]]
                    let postID:Int = postDict["post_id"] as! Int
                    
                    var counter = -1
                    for feedDataObj in feedObj {
                        if feedDataObj.postID == postID {
                            if let isLive = postDict["is_live"] as? Int {
                                feedDataObj.isLive = isLive
                                if let postType = postDict["post_type"] as? String {
                                    feedDataObj.postType = postType
                                }
                            }
                            for postObj in feedDataObj.post! {
                                for postReceived in postArray {
                                    if postObj.fileID == (postReceived["id"] as! Int) {
                                        postObj.filePath = (postReceived["file_path"] as! String)
                                        postObj.filetranslationlink = (postReceived["file_translation_link"] as? String) ?? ""
                                        if postObj.filetranslationlink == "" {
                                            postObj.filetranslationlink = nil
                                        }
                                        postObj.processingStatus = "done"
                                        postObj.isSpeechExist = (postReceived["has_speech_to_text"] as? Int) ?? 0
                                    }
                                }
                            }
                            counter = counter + 1
                        }
                    }
                    FeedCallBManager.shared.videoProcessingCompletedHandler?(postID, counter)
                }
            }
        }, param: parameters)
    }
    
    func getIndexPathFromVisibleCell(tableCellArr:[UITableViewCell], postID:Int, indexValue:Int)-> Int {
        for i in 0 ..< tableCellArr.count{
            if tableCellArr[i] is PostCell {
                let myCell:PostCell = tableCellArr[i] as! PostCell
                if myCell.feedObj?.postID == postID {
                    return indexValue
                }
            }else if tableCellArr[i] is AudioCell {
                let myCell = tableCellArr[i] as! AudioCell
                if myCell.feedObj?.postID == postID {
                    return indexValue
                }
            }else if tableCellArr[i] is VideoCell {
                let myCell = tableCellArr[i] as! VideoCell
                if myCell.feedObj?.postID == postID {
                    return indexValue
                }
            }else if tableCellArr[i] is GalleryCell {
                let myCell = tableCellArr[i] as! GalleryCell
                if myCell.feedDataObj?.postID == postID {
                    return indexValue
                }
            }else if tableCellArr[i] is ImageCellSingle {
                let myCell = tableCellArr[i] as! ImageCellSingle
                if myCell.feedObj?.postID == postID {
                    return indexValue
                }
            }else if tableCellArr[i] is SharedCell {
                let myCell = tableCellArr[i] as! SharedCell
                if myCell.feedObj?.postID == postID {
                    return indexValue
                }
            }
        }
        return -1
    }
}
