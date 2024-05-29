//
//  SharedRequestManager.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class SharedRequestManager: NSObject {
    static let requestManager = SharedRequestManager()
    
    override init() {
        super .init()
    }
    
    // Managing header of request...
    static func getCustomHeader()->HTTPHeaders  {
        var header: HTTPHeaders = HTTPHeaders()
        let authorization = "Bearer "+AppConfigurations().HeaderToken
        let token = Shared.instance.userToken()
        
        var jwtToken = ""
        if Shared.instance.userObj != nil {
            if Shared.instance.userObj!.data.jwtToken != nil {
                jwtToken = Shared.instance.userObj!.data.jwtToken!
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
    static func uploadMultipartRequest(params:[String:String],fileObjectArray:[ShareCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, showProgress:Bool = true)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
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
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.3) else { return }
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
                else if fileObject.isType == PostDataType.Video
                {
                    guard let imgData = fileObject.imageMain.jpegData(compressionQuality: 0.5) else { return }
                    multipartFormData.append(imgData, withName: String(format:"filesArr[%d][thumbnail_file]", i), fileName:String(format: "%@.jpeg",fileName), mimeType: "image/jpeg")
                    multipartFormData.append(("false").data(using: String.Encoding.utf8)!, withName: String(format: "filesArr[%d][enable_faster_upload]", i))
                    multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"filesArr[%d][language_id]", i))
                    multipartFormData.append(fileObject.videoURL, withName: fileArray)
                }
                    
                else if fileObject.isType == PostDataType.AudioMusic {
                    //multipartFormData.append("1".data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
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

                    }

                }})
    }
    
    
    //Create post
    
    static func uploadMultipartCreateRequests(params:[String:String],fileObjectArray:[ShareCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, isShowProgress:Bool)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
        //            if isShowProgress {
        //                SharedManager.shared.showHudWithProgress(view: SharedManager.shared.createPostView!)
        //            }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            for i in 0 ..< fileObjectArray.count{
                let fileObject=fileObjectArray[i]
                if fileObject.isUploading {
                    if fileObject.hashString != ""{

                        multipartFormData.append((fileObject.hashString).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                    }
                    if fileObject.thumbURL != "" {
                        multipartFormData.append((fileObject.thumbURL).data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnail_url]", i))
                    }
                    if fileObject.langID != "" {
                        multipartFormData.append(fileObject.langID.data(using: String.Encoding.utf8)!, withName: String(format:"files_info[%d][language_id]", i))
                    }
                }else if fileObject.isEditPost {
                    multipartFormData.append((fileObject.fileUrl).data(using: String.Encoding.utf8)!, withName: String(format: "file_urls[%d]", i))
                    if fileObject.thumbURL != "" {
                        multipartFormData.append((fileObject.thumbURL).data(using: String.Encoding.utf8)!, withName: String(format: "files_info[%d][thumbnail_url]", i))
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
                            //                                SharedManager.shared.removeProgressRing()
                            
                            failure(error!)
                        }
                    }
                case .failure(_):
                    debugPrint("")
                }})
    }
    
    
    static func uploadMultipartVideoClip(params:[String:Any],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void, isShowProgress:Bool)
    {
        var dict: [String : Any] = params
        let finalUrl = self.getBaseUrlPost(param: &dict)
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
                            //                              SharedManager.shared.removeProgressRing()
                            failure(error!)
                        }
                    }
                case .failure(_):
                    debugPrint("")
                }})
    }
    
    //Create post
    static func uploadMultipartProcessFileRequests(params:[String:String],fileObjectArray:[ShareCollectionViewObject],success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
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
                    failure(error)
                }})
    }
    
    //GET Request...
    static func fetchDataGet(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:String]) {
        var dict: [String : Any] = param
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        let request = Alamofire.request(url!, method: .get, parameters: dict,
                                        encoding: URLEncoding.queryString, headers: self.getCustomHeader())
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
                    let code = meta["code"] as! Int
                    let dataDic = respDict["data"]
                    if code == ResponseKey.successResp.rawValue{
                        Completion(.success(dataDic!))
                    }else {
                        Completion(.success(meta["message"]!))
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
        })
    }
}
