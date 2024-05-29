//
//  FeedLanguageViewModel.swift
//  WorldNoor
//
//  Created by Raza najam on 2/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FeedLanguageViewModel: NSObject {
    
    var langugageHandlerDetected:((Int)->())?
    var langugageHandlerDetectedAndAutoTranslation:((Int, Int)->())?

    var languageUpdateHandler:((Int)->())?
    var feedArray:[FeedData] = []
    var reloadSpecificRowCommentImageUpload:((IndexPath)->())?
    

    func callingLanguageChangeService(lang:String, isAuto:String){
        let parameters = ["action": "profile/update", "token": SharedManager.shared.userToken(), "language_ids[]":lang, "enable_auto_translate":isAuto]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblem, view: self)
                }
            case .success(let res):
                if res is String {

                }else {
                    let someDict = res as! NSDictionary
                    let dict = SharedManager.shared.userBasicInfo
                    dict["language_id"] = someDict.value(forKey: "language_id")
                    dict["auto_translate"] = someDict.value(forKey: "auto_translate")

                    SharedManager.shared.userBasicInfo = dict
                    NotificationCenter.default.post(name: Notification.Name(Const.KLangChangeNotif), object: nil)
                    self.languageUpdateHandler?(SharedManager.shared.userBasicInfo["language_id"] as! Int)
                    let defaults = UserDefaults.standard
                    defaults.set(SharedManager.shared.userBasicInfo, forKey: "userBasicProfile")
                }
            }
        }, param:parameters)
    }
    
    func callingBasicProfileService() {
        let parameters = ["action": "profile/basic", "token": SharedManager.shared.userToken()]
//        SharedManager.shared.showOnWindow()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {

                    SharedManager.shared.userBasicInfo = (res as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    for (k, v) in SharedManager.shared.userBasicInfo {
                        SharedManager.shared.userBasicInfo[k] = v is NSNull ? "" : v
                    }

                    let defaults = UserDefaults.standard
                    defaults.set(SharedManager.shared.userBasicInfo, forKey: "userBasicProfile")
                    
//                    if let profile_image = SharedManager.shared.userBasicInfo["profile_image"] as? String {
//                        SharedManager.shared.downloadProfileImage(filePAth: profile_image)
//                    }
//                    
//                    if let profile_image = SharedManager.shared.userBasicInfo["cover_image"] as? String {
//                        SharedManager.shared.downloadProfileCover(filePAth: profile_image)
//                    }
                    
                    if let langID = SharedManager.shared.userBasicInfo["language_id"] as? String {
                        if langID == "" {
                            self.langugageHandlerDetectedAndAutoTranslation?(1, 1)
                        }else {
                            self.langugageHandlerDetectedAndAutoTranslation?(SharedManager.shared.userBasicInfo["language_id"] as! Int, SharedManager.shared.userBasicInfo["auto_translate"] as! Int)
                        }
                    }else {
                        self.langugageHandlerDetectedAndAutoTranslation?(SharedManager.shared.userBasicInfo["language_id"] as! Int, SharedManager.shared.userBasicInfo["auto_translate"] as! Int)
                    }
                }
            }
        }, param:parameters)
    }
    
    func handlingUploadFeedView(currentIndex:IndexPath, fileType:String, selectLang:Bool = false, videoUrl:String = "", imgUrl:String = "", isPosting:Bool = false, imageObj:UIImage = UIImage(), isImageObjExist:Bool = false, fileExt:String = "") {
        let feedObjUpdate:FeedData = self.feedArray[currentIndex.row]
        let uploadObj:FeedUpload = FeedUpload(body:"", firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:true, identifierStr:"", fileType: fileType, selectLanguage: selectLang, videoUrlToUpload: videoUrl, imgUrl:imgUrl, imageObj: imageObj, isImageObjExist: isImageObjExist, fileExt: fileExt)
        feedObjUpdate.uploadObj = uploadObj
        self.feedArray[currentIndex.row] = feedObjUpdate
        self.reloadSpecificRowCommentImageUpload?(currentIndex)
    }

    // comment call back handler to update the comment instantly in feedobject
    func handlingInstantCommentCallback(currentIndex:IndexPath, fileType:String, selectLang:Bool = false, videoUrl:String = "", isPosting:Bool = false, imgUrl:String = "", imageObj:UIImage = UIImage(), isImageObjExist:Bool = false, isLangRequired:Bool = false, identifier:String = "")    {
        let feedObjUpdate:FeedData = self.feedArray[currentIndex.row]
        let commentObj:Comment = Comment(original_body:"" ,body:"", firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:true, identifierStr:identifier, fileType: fileType, selectLanguage: selectLang, videoUrlToUpload: videoUrl)
        var commentCount:Int = 0
        if feedObjUpdate.comments!.count > 0 {
            commentCount = (feedObjUpdate.comments?.count)!
        }
        feedObjUpdate.comments?.insert(commentObj, at: commentCount)
        feedObjUpdate.isPostingNow = isPosting
        self.feedArray[currentIndex.row] = feedObjUpdate
        self.reloadSpecificRowCommentImageUpload?(currentIndex)
    }

    // comment callback handler after service call
    func handlingCommentCallback(currentIndex:IndexPath, res:Any){
        let feedObjUpdate:FeedData = self.feedArray[currentIndex.row]
        if res is String {
            return
        }else if res is NSDictionary {
            let respDict:NSDictionary = res as! NSDictionary

            let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
            if dataDict.allKeys.count != 0 {
                let commentObj:Comment = Comment(dict: dataDict)
                var commentCount:Int = 0
                if feedObjUpdate.comments!.count > 0 {
                    commentCount = (feedObjUpdate.comments?.count)! - 1
                }
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true
                self.feedArray[currentIndex.row] = feedObjUpdate
                self.reloadSpecificRowCommentImageUpload?(currentIndex)
            }else {
                feedObjUpdate.comments?.removeFirst()
                self.feedArray[currentIndex.row] = feedObjUpdate
                self.reloadSpecificRowCommentImageUpload?(currentIndex)
            }
        }
    }
}
