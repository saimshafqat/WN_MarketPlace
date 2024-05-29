//
//  RequestManager.swift
//  WorldNoor
//
//  Created by Raza najam on 9/4/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Alamofire
import AlamofireRSSParser

class CreateRequestManager: NSObject {
    
    static let requestManager = CreateRequestManager()
    
    override init() {
        super .init()
    }
    
    // Managing header of request...
    static func getCustomHeader() -> HTTPHeaders {
        var header: HTTPHeaders = HTTPHeaders()
        let authorization = "Bearer " + AppConfigurations().HeaderToken
        let token = SharedManager.shared.userToken()
        
        var jwtToken = ""
        if SharedManager.shared.userObj != nil {
            
            if SharedManager.shared.userObj!.data.jwtToken != nil {
                jwtToken = SharedManager.shared.userObj!.data.jwtToken!
            }
        }
        
        
        header = [
            "Authorization": authorization,
            "Accept": "application/json",
            "jwtToken": jwtToken,
        ]
        if token != "" {
            header["token"] = token
        }
        return header
    }
    
    // Managing BaseUrl for post...
    static func getBaseUrlPost(param:inout [String:Any])->String{
        var baseURL = ""
        var finalUrl = ""
        
        if let serviceType = param["serviceType"]   {
            if (serviceType as? String) == "Node" {
                baseURL = AppConfigurations().BaseUrlNodeApi
                finalUrl = baseURL+((param[Const.KAction]! as? String)!)
                param.removeValue(forKey: "serviceType")
            }else if (serviceType as? String) == "Media" {
                baseURL = AppConfigurations().BaseUrlMedia
                finalUrl = baseURL+((param[Const.KAction]! as? String)!)
                param.removeValue(forKey: "serviceType")
            }
        }else {
            baseURL = AppConfigurations().BaseUrl
            finalUrl = baseURL+((param[Const.KAction]! as? String)!)
        }
        param.removeValue(forKey: Const.KAction)
        return finalUrl
    }
    
    // Managing BaseUrl for get...
    static func getBaseUrlGet(param:inout [String:String])->String{
        let baseURL = AppConfigurations().BaseUrl
        var finalUrl:String
        
        
        if param.count > 1 {
            finalUrl = baseURL+param[Const.KAction]!+"?"
        }else {
            finalUrl = baseURL+param[Const.KAction]!
        }
        param.removeValue(forKey: Const.KAction)
        for (key, value) in param{
            
            finalUrl = finalUrl+"\(key)="+"\(value)&"
        }
        return finalUrl
    }
    
    //Raza upload multipart Request ...
    static func uploadMultipartRequest(params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, showProgress:Bool = true)
    {
        
        
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        if showProgress {
            if SharedManager.shared.createPostView != nil {
                SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
            }
            
        }
        
        LogClass.debugLog("dict  ====> uploadMultipartRequest")
        LogClass.debugLog(dict)
        LogClass.debugLog("finalUrl")
        LogClass.debugLog(finalUrl)
        LogClass.debugLog(params)
        LogClass.debugLog(fileObjectArray.count)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count{
                let fileObject = fileObjectArray[i]
                let fileArray = String(format: "filesArr[%d][file]", i)
                let fileName=String(format:"filesArr_%d",i)
                if fileObject.isType == PostDataType.Image
                {
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:String(format: "%@.jpeg",fileName), mimeType: "image/jpeg")
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                }else if fileObject.isType == PostDataType.GIFBrowse    {
                    multipartFormData.append((fileObject.photoUrl.absoluteString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                }else if fileObject.isType == PostDataType.GIF    {
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                    multipartFormData.append(fileObject.photoUrl, withName: fileArray)
                }
                else if fileObject.isType==PostDataType.imageText{
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:String(format: "%@.jpeg",fileName), mimeType: "image/jpeg")
                }
                else if fileObject.isType == PostDataType.Video {
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: String(format:"filesArr[%d][thumbnail_file]", i), fileName:String(format: "%@.jpeg",fileName), mimeType: "image/jpeg")
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                    multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"filesArr[%d][language_id]", i))
                    multipartFormData.append(fileObject.videoURL, withName: fileArray)
                }
                else if fileObject.isType == PostDataType.AudioMusic {
                    multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"filesArr[%d][language_id]", i))
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                    multipartFormData.append(fileObject.videoURL, withName: fileArray)
                }
                else if fileObject.isType == PostDataType.Audio
                {
                    do {
                        multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                        multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"filesArr[%d][language_id]", i))
                        let data = try Data(contentsOf: fileObject.videoURL as URL)
                        multipartFormData.append(data, withName: fileArray, fileName:String(format: "%@.wav",fileName), mimeType: "audio/wav")
                    } catch {
                        
                    }
                }else if fileObject.isType == PostDataType.Attachment {
                    do {
                        multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                        multipartFormData.append(fileObject.videoURL, withName: String(format:"filesArr[%d][file]", i))
                    } catch {
                        
                    }
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
                            { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    if showProgress {
                        if SharedManager.shared.progressRing != nil {
                            SharedManager.shared.progressRing.progress = CGFloat(Progress.fractionCompleted*100)
                        }
                        
                    }
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resJson = response.result.value! as! NSDictionary
                        success(resJson)
                    }
                    else if response.result.isFailure
                    {
                        let error=response.result.error
                        failure(error!)
                    }
                }
            case .failure(let error):
                
                if showProgress {
                    if SharedManager.shared.progressRing != nil {
                        SharedManager.shared.removeProgressRing()
                    }
                }
                failure(error)
            }})
    }
    
    
    
    static func uploadMultipartRequestOnS3(urlMain:String ,params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void)
    {
        
        
        let dict: [String : Any] = params
        let finalUrl = urlMain
        
        LogClass.debugLog("dict  ====> uploadMultipartRequest")
        LogClass.debugLog(dict)
        LogClass.debugLog("finalUrl")
        LogClass.debugLog(finalUrl)
        LogClass.debugLog(params)
        LogClass.debugLog(fileObjectArray.count)
        
        
        if fileObjectArray[0].isType == PostDataType.Attachment {
                guard let dataVideo = try? Data(contentsOf:fileObjectArray[0].videoURL) else { return }
                LogClass.debugLog(dataVideo)
                
                Alamofire.upload(dataVideo, to: urlMain ,method: .put)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        // handle response
                        LogClass.debugLog("response upload ")
                        LogClass.debugLog(response)
                        
                        
                        if response.response?.statusCode == 200 {
                            success(true)
                        }else {
                            success(false)
                        }
                    }
        }else if fileObjectArray[0].isType == PostDataType.Video {
            if fileObjectArray[0].isThumbUploaded {
                guard let dataVideo = try? Data(contentsOf:fileObjectArray[0].videoURL) else { return }
                LogClass.debugLog(dataVideo)
                
                Alamofire.upload(dataVideo, to: urlMain ,method: .put)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        // handle response
                        LogClass.debugLog("response upload ")
                        LogClass.debugLog(response)
                        
                        
                        if response.response?.statusCode == 200 {
                            success(true)
                        }else {
                            success(false)
                        }
                    }
            }else {
                
                guard let imgData = fileObjectArray[0].imageMain.jpegData(compressionQuality: 0.5) else { return }
//                guard let dataVideo = try? Data(contentsOf:fileObjectArray[0].imageMain) else { return }
                LogClass.debugLog(imgData)
                
                Alamofire.upload(imgData, to: urlMain ,method: .put)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        // handle response
                        LogClass.debugLog("imgData upload ")
                        LogClass.debugLog(response)
                        
                        
                        if response.response?.statusCode == 200 {
                            success(true)
                        }else {
                            success(false)
                        }
                    }
            }
           
        }else if fileObjectArray[0].isType == PostDataType.Image || fileObjectArray[0].isType == PostDataType.imageText {
            guard let imgData = fileObjectArray[0].imageMain.jpegData(compressionQuality: 0.5) else { return }
            
            Alamofire.upload(imgData, to: urlMain ,method: .put)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    // handle response
                    LogClass.debugLog("response upload ")
                    LogClass.debugLog(response)
                    
                    
                    if response.response?.statusCode == 200 {
                        success(true)
                    }else {
                        success(false)
                    }
                }
        }else if fileObjectArray[0].isType == PostDataType.Audio || fileObjectArray[0].isType == PostDataType.AudioMusic {
            
            
            guard let dataAudio = try? Data(contentsOf:fileObjectArray[0].videoURL) else { return }
            
            Alamofire.upload(dataAudio, to: urlMain ,method: .put)
                .validate(statusCode: 200..<300)
                .responseJSON { response in

                                        
                    if response.response?.statusCode == 200 {
                        success(true)
                    }else {
                        success(false)
                    }
                }
        }

    }
    
  
    
    static func fetchDataPost(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
        var dict = param
        let startTime = DispatchTime.now()
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        let encodingType:ParameterEncoding = URLEncoding.httpBody
     
        
        LogClass.debugLog("fetchDataPost dict ===>")
        LogClass.debugLog(dict)
        LogClass.debugLog(finalUrl)
        LogClass.debugLog(encodingType)
        LogClass.debugLog(self.getCustomHeader())
        
        let apiResponseTimer = APIResponseTimer(startTime: startTime)
        
        let request = Alamofire.request(url!, method: .post, parameters: dict,
                                        encoding: encodingType, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            let endTime = DispatchTime.now()
            let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let responseTime = Double(nanoTime) / 1_000_000 // Convert to milliseconds
            let seconds = Int(responseTime) / 1000

            
            let elapsedTime = apiResponseTimer.calculateElapsedTime() 
            
            LogClass.debugLog("End Point \(url) ==> Response Time REquest = \(elapsedTime) ==> Response Time seconds = \(seconds)")
            LogClass.debugLog("End Point  ===> 1")
            guard response.error == nil else {
                LogClass.debugLog("End Point  ===> 2")
                Completion(.failure(response.error!))
                return
            }
            LogClass.debugLog("End Point  ===> 3")
            do {
                LogClass.debugLog("End Point  ===> 4")
                switch response.result  {
                case .success(let resp):
                    
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let code = meta["code"] as! Int
                    let dataDic = respDict["data"]
                    
                    if code == ResponseKey.successResp.rawValue || code == 202 {
                        if let arrayData = dataDic as? [String : Any] {
                            if arrayData.isEmpty {
                                Completion(.success(meta["message"] as? String as Any))
                            }else {
                                Completion(.success(dataDic!))
                            }
                        } else if let dataData = dataDic as? [[String : Any]]{
                            if dataData.isEmpty {
                                Completion(.success(meta["message"] as? String as Any))
                            }else {
                                Completion(.success(dataDic!))
                            }
                        } else {
                            Completion(.success(dataDic!))
                        }
                        
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                         Completion(.success(meta["message"]!))
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        Completion(.success(meta["message"]!))
                    }
                case .failure(let error):
                    LogClass.debugLog("End Point  ===> 5")
                    LogClass.debugLog(error.localizedDescription)
                    Completion(.failure(error))
                }
            }
        })
    }
    
    static func uploadMultipartCreateRequests(params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, isShowProgress:Bool)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        if isShowProgress {
            SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count {
                let fileObject=fileObjectArray[i]
                if fileObject.isUploading {
                    if fileObject.hashString != "" {
                        multipartFormData.append((fileObject.hashString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                        if let url = URL(string: fileObject.hashString) {
                            let dimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url)
                            if dimension != nil {
                                multipartFormData.append(("\(Int(dimension!.width))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][videoWidth]", i))
                                multipartFormData.append(("\(Int(dimension!.height))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][videoHeight]", i))
                            }
                        }
                    }
                    if fileObject.thumbURL != "" {
                        multipartFormData.append((fileObject.thumbURL).data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnail_url]", i))
                        if let url = URL(string: fileObject.thumbURL) {
                            let thumbnailDimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url)
                            if thumbnailDimension != nil {
                                multipartFormData.append(("\(Int(thumbnailDimension!.width))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnailWidth]", i))
                                multipartFormData.append(("\(Int(thumbnailDimension!.height))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnailHeight]", i))
                            }
                        }
                    }
                    if fileObject.langID != "" {
                        multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
                    }
                } else if fileObject.isEditPost {
                    multipartFormData.append((fileObject.fileUrl).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                    if let url = URL(string: fileObject.fileUrl) {
                        let dimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url)
                        if dimension != nil {
                            multipartFormData.append(("\(Int(dimension!.width))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][videoWidth]", i))
                            multipartFormData.append(("\(Int(dimension!.height))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][videoHeight]", i))
                        }
                    }

                    if fileObject.thumbURL != "" {
                        multipartFormData.append((fileObject.thumbURL).data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnail_url]", i))
                        if let url = URL(string: fileObject.thumbURL) {
                            let thumbnailDimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url)
                            if thumbnailDimension != nil {
                                multipartFormData.append(("\(Int(thumbnailDimension!.width))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnailWidth]", i))
                                multipartFormData.append(("\(Int(thumbnailDimension!.height))").data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnailHeight]", i))
                            }
                        }
                    }
                }
                else {
                    if fileObject.isType == PostDataType.GIFBrowse    {
                        multipartFormData.append((fileObject.photoUrl.absoluteString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                    }
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
                            { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    if isShowProgress {
                        SharedManager.shared.progressRing.progress = CGFloat(Progress.fractionCompleted*100)
                    }
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resJson = response.result.value! as! NSDictionary
                        success(resJson)
                    } else if response.result.isFailure {
                        let error=response.result.error
                        SharedManager.shared.removeProgressRing()
                        failure(error!)
                    }
                }
            case .failure(_):
                LogClass.debugLog("Upload Failure")
            }
        })
    }
    
    static func uploadMultipartVideoClip(params:[String:Any],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, isShowProgress:Bool)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        if isShowProgress {
            SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                }else {
                    let arrData =  try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    multipartFormData.append(arrData, withName: key as String)
                }
                
            }
            
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
                            { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    if isShowProgress {
                        SharedManager.shared.progressRing.progress = CGFloat(Progress.fractionCompleted*100)
                    }
                    
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resJson = response.result.value! as! NSDictionary
                        success(resJson)
                    }
                    else if response.result.isFailure
                    {
                        let error=response.result.error
                        SharedManager.shared.removeProgressRing()
                        
                        failure(error!)
                    }
                }
            case .failure(_):
                LogClass.debugLog("Upload Failure")
            }})
        
    }
    
    
    
    static func uploadMultipartVideoClipStory(params:[String:Any], success:@escaping (NSDictionary) -> Void, failure: @escaping (Error) -> Void, isShowProgress: Bool) {
        
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        if isShowProgress {
            SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        }
        
        LogClass.debugLog( dict)
        LogClass.debugLog( finalUrl)
        LogClass.debugLog( params)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in dict {
                if key == "thumbnail" {
                    
                    multipartFormData.append(URL.init(fileURLWithPath: value as! String), withName: "thumbnail")
                }
                if key == "file" {
                    
                    multipartFormData.append(URL.init(fileURLWithPath: value as! String), withName: "file")
                   
                }
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                } else {
                    let arrData =  try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    multipartFormData.append(arrData, withName: key as String)
                }
            }
            
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(), encodingCompletion: { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    if isShowProgress {
                        SharedManager.shared.progressRing.progress = CGFloat(Progress.fractionCompleted*100)
                    }
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        let resJson = response.result.value! as! NSDictionary
                        success(resJson)
                    } else if response.result.isFailure {
                        
                        let error=response.result.error
                        SharedManager.shared.removeProgressRing()
                        
                        failure(error!)
                    }
                }
            case .failure(_):
                LogClass.debugLog("Upload Failure")
            }})
        
    }
    
    //Create post
    static func uploadMultipartProcessFileRequests(params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count{
                let fileObject=fileObjectArray[i]
                if fileObject.isUploading {
                    if fileObject.hashString != ""{
                        multipartFormData.append((fileObject.hashString).data(using: String.Encoding.utf8)!, withName: String(format: "hashes[%d]", i))
                    }
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
                            { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        SharedManager.shared.removeProgressRing()
                        let resJson = response.result.value! as! NSDictionary
                        success(resJson)
                    }
                    else if response.result.isFailure
                    {
                        SharedManager.shared.removeProgressRing()
                        let error=response.result.error
                        failure(error!)
                    }
                }
            case .failure(let error):
                failure(error)
                SharedManager.shared.removeProgressRing()
            }
        })
    }
}
