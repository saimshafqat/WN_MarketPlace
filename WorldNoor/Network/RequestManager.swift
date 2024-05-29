//
//  RequestManager.swift
//  WorldNoor
//
//  Created by Raza najam on 9/4/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Alamofire
import AlamofireRSSParser

class RequestManager: NSObject {

    static let requestManager = RequestManager()
    override init() {
        super .init()
    }
    
    // Managing header of request...
    static func getCustomHeader()->HTTPHeaders  {
        var header: HTTPHeaders = HTTPHeaders()
        let authorization = "Bearer "+AppConfigurations().HeaderToken
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
            if (serviceType as! String) == "Node" {
                baseURL = AppConfigurations().BaseUrlNodeApi
                finalUrl = baseURL+(param[Const.KAction]! as! String)
                param.removeValue(forKey: "serviceType")
            }else if (serviceType as! String) == "Media" {
                baseURL = AppConfigurations().BaseUrlMedia
                finalUrl = baseURL+(param[Const.KAction]! as! String)
            }else if (serviceType as! String) == "Stream" {
                baseURL = AppConfigurations().BaseUrlStream
                finalUrl = baseURL+(param[Const.KAction]! as! String)
                param.removeValue(forKey: "serviceType")
            }else {
                baseURL = AppConfigurations().BaseUrlMedia
                finalUrl = baseURL+(param[Const.KAction]! as! String)
                param.removeValue(forKey: "serviceType")
            }
        }else {
            baseURL = AppConfigurations().BaseUrl
            finalUrl = baseURL+(param[Const.KAction]! as! String)
        }
        param.removeValue(forKey: Const.KAction)
        return finalUrl
    }
    
    // Managing BaseUrl for get...
    static func getBaseUrlGet(param:inout [String:String])->String{
        var baseURL = AppConfigurations().BaseUrl
        var finalUrl:String
        if param.count > 1 {
            if let serviceType = param["serviceType"]   {
                if (serviceType ) == "Node" {
                    baseURL = AppConfigurations().BaseUrlNodeApi
                    finalUrl = baseURL+(param[Const.KAction]! )
                    param.removeValue(forKey: "serviceType")
                }
            }
            finalUrl = baseURL+param[Const.KAction]!+"?"
        } else {
            finalUrl = baseURL+param[Const.KAction]!
        }
        param.removeValue(forKey: Const.KAction)
        for (key, value) in param{
            finalUrl = finalUrl+"\(key)="+"\(value)&"
        }
        return finalUrl
    }
    
    
    static func cancelTagRequest(){
    Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
        sessionDataTask.forEach {
            if (($0.originalRequest?.url?.absoluteString.contains("hashtag-suggest")) != nil)  {
                        $0.cancel()
                }
                
            }
        }
    }
    
    
    static func cancelAllRequest(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //        sessionDataTask.forEach {
            //            LogClass.debugLog($0.originalRequest?.url?.absoluteString)
            //            if ($0.originalRequest?.url?.absoluteString.contains(where:"hashtag-suggest"))  {
            //                        $0.cancel()
            //                }
            //
            //            }
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    static func cancelSearchRequest(_ endPoint: String = "search/all"){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach {
                LogClass.debugLog($0.originalRequest?.url?.absoluteString)
                
                //                        if ($0.originalRequest!.url!.absoluteString.contains(where: { "search/all" in
                //                            $0.cancel()
                //                        })
                
                sessionDataTask.forEach {
                    if (($0.originalRequest?.url?.absoluteString.contains(endPoint)) != nil)  {
                        $0.cancel()
                    }
                    
                }
                
                
                //                        if ($0.originalRequest!.url!.absoluteString.contains(where:"search/all"))  {
                //                                    $0.cancel()
                //                            }
                //                        }
                //            sessionDataTask.forEach { $0.cancel() }
                //            uploadData.forEach { $0.cancel() }
                //            downloadData.forEach { $0.cancel() }
            }
        }
    }
    
    //POST Request...
    static func fetchDataPost(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
        var dict = param
        let startTime = DispatchTime.now()
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        var encodingType:ParameterEncoding = URLEncoding.httpBody
        if finalUrl.contains("node"){
            encodingType = JSONEncoding.default
        }
        
        LogClass.debugLog(dict)
        LogClass.debugLog(url)
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
//            let minutes = Int(responseTime) / 60
            

//            let formattedResponseTime = String(format: "%02d minutes :%02d seconds", minutes, seconds)
//            LogClass.debugLog("End Point \(endPoint.path) ==> Response Time REquest = \(elapsedTime)")
            
            let elapsedTime = apiResponseTimer.calculateElapsedTime() ?? .emptyString
            
            LogClass.debugLog("End Point \(url) ==> Response Time REquest = \(elapsedTime) ==> Response Time seconds = \(seconds)")
            
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let code = meta["code"] as? Int ?? 0
                    let dataDic = respDict["data"]
                    
                    if code == ResponseKey.successResp.rawValue || code == 202 {
                        if let arrayData = dataDic as? [String : Any] {
                            if arrayData.isEmpty {
                                let msg = meta["message"] as? String ?? .emptyString
                                Completion(.success(msg))
                            } else {
                                Completion(.success(dataDic!))
                            }
                        } else if let dataData = dataDic as? [[String : Any]]{
                            if dataData.isEmpty {
                                let msg = meta["message"] as? String ?? .emptyString
                                Completion(.success(msg))
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
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    
    //POST Request...
    static func fetchDataRequestPost(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
        var dict = param
        let startTime = DispatchTime.now()
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        var encodingType:ParameterEncoding = URLEncoding.httpBody
        if finalUrl.contains("node"){
            encodingType = JSONEncoding.default
        }
        
        LogClass.debugLog(dict)
        LogClass.debugLog(url)
        LogClass.debugLog(finalUrl)
        LogClass.debugLog(encodingType)
        LogClass.debugLog(self.getCustomHeader())
        let apiResponseTimer = APIResponseTimer(startTime: startTime)
        let request = Alamofire.request(url!, method: .post, parameters: dict,
                                        encoding: encodingType, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            let elapsedTime = apiResponseTimer.calculateElapsedTime()
            LogClass.debugLog("End Point \(finalUrl) ==> Response Time = \(elapsedTime)")

            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let actionAPI = respDict["action"] as! String
                    let code = meta["code"] as! Int
                    let dataDic = respDict["data"]
                    
                    if code == ResponseKey.successResp.rawValue || code == 202 {
                        if let arrayData = dataDic as? [String : Any] {
                            if arrayData.isEmpty || ((arrayData["result"] != nil) && (arrayData["result"] as? Int  == 1)) {
                                Completion(.success(meta["message"] as? String))
                            }else {
                                Completion(.success(dataDic!))
                            }
                        } else if let dataData = dataDic as? [[String : Any]]{
                            if dataData.isEmpty {
                                Completion(.success(meta["message"] as? String))
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
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    
    static func fetchDataPostwithCompleteResponse(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
        var dict = param
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        var encodingType:ParameterEncoding = URLEncoding.httpBody
        if finalUrl.contains("node"){
            encodingType = JSONEncoding.default
        }
        
        let request = Alamofire.request(url!, method: .post, parameters: dict,
                                        encoding: encodingType, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    _ = respDict["action"] as! String
                    let code = meta["code"] as! Int
                    let dataDic = respDict["data"]
                    if code == ResponseKey.successResp.rawValue || code == 202{
                        if let message = meta["message"] as? String {
                            if message == "Registered Successfully. An email has been sent to your provided email address to verify your account."
                            {
                                Completion(.success(message))
                            }
                            else{
                            Completion(.success(dataDic!))
                            }
                        }
                        else{
                        Completion(.success(dataDic!))
                        }
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                         Completion(.success(meta["message"]!))
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        Completion(.success(meta["message"]!))
                    }
                    
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    //GET Request...
    static func fetchDataGet(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:String]) {
        var dict = param
        let finalUrl = self.getBaseUrlGet(param: &dict)
        let escapedString = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:escapedString!)
        
        LogClass.debugLog(url)
        LogClass.debugLog(dict)
        LogClass.debugLog(self.getCustomHeader())
        let apiResponseTimer = APIResponseTimer(startTime: .now())
        let request = Alamofire.request(url!, method: .get, parameters: dict,
                                        encoding: URLEncoding.queryString, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            let elapsedTime = apiResponseTimer.calculateElapsedTime()
            LogClass.debugLog("End Point \(url) ==> Response Time = \(elapsedTime)")
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let code = meta["code"] as! Int
                    let dataDic = respDict["data"]
                    if code == ResponseKey.successResp.rawValue{
                        Completion(.success(dataDic!))
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                         Completion(.success(meta["message"]!))
                        
                        if let topVC = UIApplication.topViewController()! as? LoginViewController {

                        }else{
                            AppDelegate.shared().loadLoginScreen()
                        }
                        
                    }else {
                        Completion(.success(meta["message"]!))
                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    

    static func uploadFile(params:[String:String],fileObjectURL:URL , key : String ,success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
    {
        
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            multipartFormData.append(fileObjectURL, withName: key, fileName: key, mimeType: "audio/wav")
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        
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
                case .failure(_):
                    LogClass.debugLog("failure")
                    
                }})
    }
    
    //Saim upload multipart Request ...
    static func uploadMultipartRequest(params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count{
                let fileObject=fileObjectArray[i]
                let fileArray = String(format: "files[%d]", i)
                let fileName=String(format:"file_%d",i)
                if fileObject.isType == PostDataType.Image
                {
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:fileName, mimeType: "")
                    //Next line will be use when we will tell user the video id.
                    //  multipartFormData.append("1".data(using: String.Encoding.utf8)!, withName: "file_info[0][language_id]")
                }else if fileObject.isType == PostDataType.GIFBrowse    {
                    multipartFormData.append((fileObject.photoUrl.absoluteString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                }else if fileObject.isType == PostDataType.GIF    {
                    multipartFormData.append(fileObject.photoUrl, withName: fileArray)
                }
                else if fileObject.isType==PostDataType.imageText{
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:   fileName, mimeType: "")
                }
                else if fileObject.isType == PostDataType.Video
                {
                    multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
                    multipartFormData.append(fileObject.videoURL, withName: fileArray)
                }else if fileObject.isType == PostDataType.AudioMusic {

                    multipartFormData.append(fileObject.videoURL, withName: fileArray)
                }
                else if fileObject.isType == PostDataType.Audio
                {
                    do {
                        multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
                        let data = try Data(contentsOf: fileObject.videoURL as URL)
                        multipartFormData.append(data, withName: fileArray, fileName:   fileName, mimeType: "")
                    } catch {
                        
                    }
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        SharedManager.shared.progressRing.progress = CGFloat(Progress.fractionCompleted*100)
                    })
                    upload.responseJSON { response in
                        SharedManager.shared.removeProgressRing()
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
                case .failure(_):
                    SharedManager.shared.removeProgressRing()
                }})
    }
    
    static func uploadMultipartRequests(params:[String:String],fileObjectArray:[PostCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        //            SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count{
                let fileObject=fileObjectArray[i]
                let fileArray = String(format: "files[%d]", i)
                let fileName=String(format:"file_%d",i)
                if fileObject.isType == PostDataType.Image
                {
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:fileName, mimeType: "")
                    //Next line will be use when we will tell user the video id.
                    //                  multipartFormData.append("1".data(using: String.Encoding.utf8)!, withName: "file_info[0][language_id]")
                }else if fileObject.isType == PostDataType.GIFBrowse    {
                    multipartFormData.append((fileObject.photoUrl.absoluteString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                }else if fileObject.isType == PostDataType.GIF    {
                    multipartFormData.append(fileObject.photoUrl, withName: fileArray)
                }
                else if fileObject.isType==PostDataType.imageText{
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: fileArray, fileName:   fileName, mimeType: "")
                }
                else if fileObject.isType == PostDataType.Video
                {
                    do {
                        //                        multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
                        multipartFormData.append(fileObject.videoURL, withName: fileArray)
                    } catch {

                    }
                }
                else if fileObject.isType == PostDataType.Audio
                {
                    do {

                        let data = try Data(contentsOf: fileObject.videoURL as URL)
                        multipartFormData.append(data, withName: fileArray, fileName:   fileName, mimeType: "")
                    } catch {

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
                            let resJson = response.result.value! as! NSDictionary
                            success(resJson)
                        }
                        else if response.result.isFailure
                        {
                            let error=response.result.error
                            failure(error!)
                        }
                    }
                case .failure(_):
                    LogClass.debugLog("Upload Failure 4")
                }})
    }
    
    //Raza function to upload multipart request
    static func fetchDataMultipart(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:String], fileUrl:String) {
        var dict: [String : Any] = param
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 500
        manager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                if dict[key] as! String == "image"{
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "comment_file")
                }else if dict[key] as! String == "GIF"{
                    multipartFormData.append((dict["fileUrl"] as! String).data(using: String.Encoding.utf8)!, withName: "comment_file")
                }else if dict[key] as! String == "video"
                {
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "comment_file")
                }else if dict[key] as! String == "attachment"
                {
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "comment_file")
                }else if dict[key] as! String == "audio"
                {
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "comment_file")
                }else {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            if fileUrl != ""    {
                multipartFormData.append(URL(string: fileUrl)!, withName: "audio_recording")
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                    })
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            let resJson = response.result.value! as! NSDictionary
                            let meta = resJson["meta"] as? NSDictionary
                            if let code = meta!["code"] as? Int {
                                if code == ResponseKey.unAuthorizedResp.rawValue{
                                    AppDelegate.shared().loadLoginScreen()
                                }else {
                                    Completion(.success(resJson))
                                }
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
    
    static func fetchDataMultiparts(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any], fileUrl:String) {
        var dict: [String : Any] = param
        let finalUrl = self.getBaseUrlPost(param: &dict)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                if let newDictValue = dict[key] as? String {
                    if newDictValue == "image"{
                        let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                        if let userValue = dict["isFromUser"] as? String {
                            multipartFormData.append(fileUrl, withName: userValue)
                        }else {
//                            multipartFormData.append(fileUrl, withName: "file")
                            
                            multipartFormData.append(fileUrl, withName: "file", fileName: "image.png", mimeType: "image/jpeg")
                        }
                    }else if newDictValue == "video"
                    {
                        let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                        multipartFormData.append(fileUrl, withName: "file")
                    }else if newDictValue == "audio"
                    {
                        let fileUrl = URL.init(string: dict["fileUrl"] as! String)!
//                        let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                        multipartFormData.append(fileUrl, withName: "file", fileName: ".wav", mimeType: "audio/wav")
                        "audio/wav"
                    }else if newDictValue == "attachment"
                    {
                        let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                        multipartFormData.append(fileUrl, withName: "file")
                    }else if newDictValue == "gif"
                    {
                        multipartFormData.append((dict["fileUrl"] as! String).data(using: String.Encoding.utf8)!, withName: key)
                        
                    }else {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                    }
                }else {
                    guard let imgData = (dict[key] as! UIImage).jpegData(compressionQuality: 1.0) else {

                        return
                    }
                    multipartFormData.append(imgData, withName: "thumbnail", fileName: ".png", mimeType: "image/jpeg")
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        var testFromDefaults = UserDefaults.standard.object([String: String].self, with: "VideoUpload")
                        if (testFromDefaults != nil)  {
                            if let value = param["DBKey"] as? String {
                                var str = String(Float(Progress.fractionCompleted*100))
                                str = str.addDecimalPoints(decimalPoint: "2")
                                testFromDefaults![value] = str.addDecimalPoints(decimalPoint: "2")
                                UserDefaults.standard.set(object: testFromDefaults, forKey: "VideoUpload")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    })
                    upload.responseJSON { response in
                        LogClass.debugLog(response)
                        LogClass.debugLog(response.result)
                        if response.result.isSuccess {
                            let resJson = response.result.value! as! NSDictionary
                            let meta = resJson["meta"] as? NSDictionary

                            if let code = meta!["code"] as? Int {
                                if code == ResponseKey.unAuthorizedResp.rawValue{
                                    AppDelegate.shared().loadLoginScreen()
                                }else {
                                    Completion(.success(resJson))
                                }
                            }
                            
                        }
                        else if response.result.isFailure
                        {

                        }
                    }
                case .failure(let error):
                    Completion(.failure(error))
                }})
    }
    
    //POST Request...
    static func fetchDataPostWithURL(MainURL : String , Completion:@escaping (Swift.Result<Any, Error>)->()) {
        let url = URL(string:MainURL)
        let request = Alamofire.request(url!, method: .post)
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):

                    let respDict = resp as! NSDictionary
                    let dataDic = respDict["data"]
                    Completion(.success(dataDic))
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    //Get Request...
    static func fetchDataGetWithURL(MainURL : String , Completion:@escaping (Swift.Result<Any, Error>)->()) {
        let url = URL(string:MainURL)
        let request = Alamofire.request(url!, method: .get)
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):

                    let respDict = resp as! NSDictionary
                    let dataDic = respDict["data"]
                    Completion(.success(dataDic))
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    static func fetchDataGetURL(MainURL : String , Completion:@escaping (Swift.Result<Any, Error>)->()) {
        let url = URL(string:MainURL)
        let request = Alamofire.request(url!, method: .get)
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    Completion(.success(resp))
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    
    static func fetchDataParamURL(param:[String:String] , MainURL : String , Completion:@escaping (Swift.Result<Any, Error>)->()) {
        let url = URL(string:MainURL)
        let request = Alamofire.request(url!, method: .get, parameters: param , headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    Completion(.success(resp))
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            }
        })
    }
    
    //GET Request...
    static func fetchRSS(Completion:@escaping (Swift.Result<Any, Error>)->(), urlString:String) {
        let url = URL(string: urlString)
        
        
        Alamofire.request(url!).responseRSS() { (response) -> Void in
            
            if let feed: RSSFeed = response.result.value {
                if feed.items.count > 0 {
                    Completion(.success(feed))
                }else {
                    Completion(.success("Nothing found."))
                }
            }else {
                Completion(.failure(response.error!))
                
            }
        }
    }
    
    static func fetchDataMultipartWithName(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:Any]) {
//        self.changeFeedStatus(status: "Uploading")
        var dict: [String : Any] = param
        let finalUrl = RequestManager.getBaseUrlPost(param: &dict)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                if key == "fileUrl"{
                    
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl"] as! String)
                    multipartFormData.append(fileUrl, withName: "profile_picture")
                }else if key == "fileUrl2"{
                    
                    let fileUrl = URL(fileURLWithPath: dict["fileUrl2"] as! String)
                    multipartFormData.append(fileUrl, withName: "cover_file")
                }else if key == "cover_photo"{
                    
                    let fileUrl = URL(fileURLWithPath: dict["cover_photo"] as! String)
                    multipartFormData.append(fileUrl, withName: "cover_photo")
                }else {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, usingThreshold: UInt64(), to: URL(string:finalUrl)!, method: .post, headers: RequestManager.getCustomHeader(),encodingCompletion:
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        _ = CGFloat(Progress.fractionCompleted*100)
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
