//
//  CreatePostHandler.swift
//  WorldNoor
//
//  Created by Raza najam on 3/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class CreatePostHandler: NSObject {
    static let shared = CreatePostHandler()

    var videoLangChangeHandler:((IndexPath, String)->())?
    var singleFeedHandler:(([Int:String])->())?

    func checkIfLanguageSelected(postArray:[PostCollectionViewObject])-> Bool{
        for postObj in postArray {
            if postObj.isType == PostDataType.Video ||  postObj.isType == PostDataType.Audio || postObj.isType == PostDataType.AudioMusic{
                
                if postObj.isType == PostDataType.Video {
                    postObj.langID = "0"
                }
                
                if postObj.langID == "" {
                    return true
                }
            }
        }
        return false
    }
    
    func checkIfFileExist(postArray:[PostCollectionViewObject])-> Bool{
        let checkIFExist = false
        for postObj in postArray {
            if postObj.isType == PostDataType.Video ||  postObj.isType == PostDataType.Audio || postObj.isType == PostDataType.AudioMusic ||  postObj.isType == PostDataType.GIF || postObj.isType == PostDataType.imageText  || postObj.isType == PostDataType.Image || postObj.isType == PostDataType.Attachment{
                return true
            }
        }
        return false
    }
    func checkIfVideoExist(postArray:[PostCollectionViewObject])-> Bool{
           for postObj in postArray {
               if postObj.isType == PostDataType.Video {
                   return true
               }
           }
           return false
       }
    
    
    func manageVideoProcessingResponse(id:Int){
        let actionString = String(format: "post/get-single-newsfeed-item/%i",id)
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
                    if let contactGroupArray =  postDict["shared_with_contact_groups"] as? [[String:Any]] {
                        var counter = 0
                        var dict:[Int:String] = [:]
                        for value in contactGroupArray {
                            dict[counter] = String(value["contact_group_id"] as! Int)
                            counter = counter + 1
                        }
                        if dict.count > 0 {
                            self.singleFeedHandler?(dict)
                        }
                    }
                }
            }
        }, param: parameters)
    }
}
