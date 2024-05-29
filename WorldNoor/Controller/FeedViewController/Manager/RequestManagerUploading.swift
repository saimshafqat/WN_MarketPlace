//
//  RequestManager.swift
//  WorldNoor
//
//  Created by Raza najam on 9/4/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Alamofire
import AlamofireRSSParser

protocol RequestManagerUploadingProtocol {
    func requestManagerUploadingStartedDelegate(uploadTag : Int )
    func requestManagerProgressDelegate(progress:CGFloat , uploadTag : Int )
    func requestManagerResponseUploadedDelegate(res:Any , uploadTag : Int )
    func requestManagerResponseFailureDelegate(res:Any , uploadTag : Int )
}

class RequestManagerUploading: NSObject {
    var delegate: RequestManagerUploadingProtocol?
    var feedObj:FeedVideoModel?
    var uploadTag = 0
    override init() {
        super .init()
    }
    
    func callingService(feedObj:FeedVideoModel)  {
        self.feedObj = feedObj
        let param = ["action":"upload", "api_token":SharedManager.shared.userToken(), "fileUrl":self.feedObj!.videoThumbnail, "videoUrl":self.feedObj!.videoUrl, "serviceType":"Media",
                     "multiple_uploads":"true","type":"create_post","post_scope_id":"2"]
        self.fetchDataMultipart(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                    self.delegate?.requestManagerResponseFailureDelegate(res: error, uploadTag: self.uploadTag)
                }
            case .success(let res):
                if res is String {
                    self.changeFeedStatus(status: "Failed")
                }else {
                    self.changeFeedStatusUploaded(resArray: res as! [Any])
                    self.delegate?.requestManagerResponseUploadedDelegate(res: res , uploadTag: self.uploadTag)
                }
            }
        }, param:param)
    }
    
    func callingServiceForVideoClip(videoURL : String , imgThumb : UIImage){
        let param = ["action":"upload", "api_token":SharedManager.shared.userToken(), "thumbImg":imgThumb, "videoUrl":videoURL, "serviceType":"Media",
                     "multiple_uploads":"true","type":"create_post","post_scope_id":"2"] as [String : Any]
        self.fetchDataMultipart(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                    self.delegate?.requestManagerResponseFailureDelegate(res: error, uploadTag: self.uploadTag)
                }
            case .success(let res):
                if res is String {
                    self.changeFeedStatus(status: "Failed")
                }else {
                    self.changeFeedStatusUploaded(resArray: res as! [Any])
                    self.delegate?.requestManagerResponseUploadedDelegate(res: res, uploadTag: self.uploadTag)
                }
            }
        }, param:param)
    }
    
    func changeFeedStatus(status:String){
        var counter = 0
        var isMatched = false
        for videoObj in FeedCallBManager.shared.videoClipArray {
            if videoObj.identifierString == self.feedObj?.identifierString {
                isMatched = true
                break
            }
            counter = counter + 1
        }
        if isMatched {
            let feedVideoObj:FeedVideoModel = FeedCallBManager.shared.videoClipArray[counter]
            feedVideoObj.status = status
            FeedCallBManager.shared.videoClipArray[counter] = feedVideoObj
        }
    }
    
    func changeFeedStatusUploaded(resArray:[Any]){
        var counter = 0
        var isMatched = false
        for videoObj in FeedCallBManager.shared.videoClipArray {
            if videoObj.identifierString == self.feedObj?.identifierString {
                isMatched = true
                break
            }
            counter = counter + 1
        }
        if isMatched {
            let feedVideoObj:FeedVideoModel = FeedCallBManager.shared.videoClipArray[counter]
            feedVideoObj.status = "Uploaded"
            if resArray.count > 0 {
                
                let res = resArray[0] as! NSDictionary
                if let thumb = res["thumbnail"] as? [String:Any] {
                    feedVideoObj.videoThumbnail = SharedManager.shared.ReturnValueAsString(value: thumb["url"] as Any)
                }
                if let url = res["url"] {
                    feedVideoObj.videoUrl = SharedManager.shared.ReturnValueAsString(value:url as Any)
                }
            }
            
            FeedCallBManager.shared.videoClipArray[counter] = feedVideoObj
        }
    }
    
    //Raza function to upload multipart request
    func fetchDataMultipart(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
        self.changeFeedStatus(status: "Uploading")
        var dict: [String : Any] = param
        let finalUrl = RequestManager.getBaseUrlPost(param: &dict)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                if key == "thumbImg"{
                    let fileObject = dict["thumbImg"] as! UIImage
                    guard let imgData = fileObject.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: "filesArr[0][thumbnail_file]", fileName:String(format: "name.png"), mimeType: "image/jpeg")
                    
                } else if key == "fileUrl"{
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "filesArr[0][thumbnail_file]")
                }else if key == "videoUrl"
                {
                    let fileUrl = URL(fileURLWithPath: dict["videoUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "filesArr[0][file]")
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: "filesArr[0][enable_faster_upload]")
                }else {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: RequestManager.getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        let progressVal = CGFloat(Progress.fractionCompleted*100)
                        self.delegate?.requestManagerProgressDelegate(progress: progressVal, uploadTag: self.uploadTag)
                    })
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            let resJson = response.result.value! as! NSDictionary
                            let meta = resJson["meta"] as! NSDictionary
                            let code = meta["code"] as! Int
                            let dataDic = resJson["data"]
                            if code == ResponseKey.successResp.rawValue{
                                Completion(.success(dataDic!))
                            }else {
                                Completion(.success(meta["message"]!))
                            }
                        }
                        else if response.result.isFailure
                        {
                            //Completion(.success(meta["message"]!))
                        }
                    }
                case .failure(_):
                    LogClass.debugLog("Upload Failure")
                }})
    }
    
   
}
