//
//  RequestManagerGen.swift
//  WorldNoor
//
//  Created by Raza najam on 10/14/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import Alamofire
import TLPhotoPicker

class RequestManagerGen: NSObject {
    
    static let requestManager = RequestManagerGen()
    override init() {
        super .init()
    }
    
    // Managing header of request...
    private static func getCustomHeader()->HTTPHeaders{
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
            "jwtToken": jwtToken,
            "Accept": "application/json"
            
        ]
        if token != "" {
            header["token"] = token
        }
        
        return header
    }
    
    // Managing BaseUrl for post...
    private static func getBaseUrlPost(param:inout [String:String])->String{
        let baseURL = AppConfigurations().BaseUrl
        let finalUrl = baseURL+param[Const.KAction]!
        param.removeValue(forKey: Const.KAction)
        return finalUrl
    }
    
    // Managing BaseUrl for get...
    private static func getBaseUrlGet(param:inout [String:String])->String{
        
        var baseURL = AppConfigurations().BaseUrl
        if let serviceType = param["serviceType"]   {            
            if (serviceType as? String) == "Node" {
                baseURL = AppConfigurations().BaseUrlNodeApi
                param.removeValue(forKey: "serviceType")
            }
        }
        
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
    
    static func uploadChatURLPost(Completion:@escaping (Swift.Result<Any, Error>)->(), param:[String:AnyObject] , dictURL : [String : String]) {
        
        var dict = dictURL
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let escapedString = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:escapedString!)
        
        RequestManagerGen.cancelSpecificTask()
        
        let request = Alamofire.request(url!, method: .post, parameters: param,
                                        encoding: JSONEncoding.default, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    LogClass.debugLog("resp  ====>")
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let code = meta["code"] as! Int
                    let decoder = JSONDecoder()
                    if code == ResponseKey.successResp.rawValue{

                        let model = try decoder.decode(uploadMediaModel.self, from:response.data!)
                        Completion(.success(model))
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
                        Completion(.failure(model))
                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            } catch let parsingError {
                Completion(.failure(parsingError))
            }
        })
    }
    
    static func fetchUploadURLPost<T:Decodable>(Completion:@escaping (Swift.Result<T, Error>)->(), param:[String:AnyObject] , dictURL : [String : String]) {
        
        var dict = dictURL
//        let finalUrl = self.getBaseUrlGet(param: &dict)
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let escapedString = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:escapedString!)

        RequestManagerGen.cancelSpecificTask()
        
        let request = Alamofire.request(url!, method: .post, parameters: param,
                                        encoding: JSONEncoding.default, headers: self.getCustomHeader())
        request.responseJSON(completionHandler: { response in
            
            guard response.error == nil else {
                Completion(.failure(response.error!))
                return
            }
            do {
                switch response.result  {
                case .success(let resp):
                    
                    
                    LogClass.debugLog("resp  ====>")
                    LogClass.debugLog(resp)
                    
                    
//                    let respDict = resp as! NSDictionary
//                    let meta = respDict["meta"] as! NSDictionary
//                    let code = meta["code"] as! Int
                    let decoder = JSONDecoder()
//                    if code == ResponseKey.successResp.rawValue{
//
                        let model = try decoder.decode(T.self, from:response.data!)
                        Completion(.success(model))
//                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
//                        AppDelegate.shared().loadLoginScreen()
//                    }else {
//                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
//                        Completion(.failure(model))
//                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            } catch let parsingError {
                Completion(.failure(parsingError))
            }
        })
        
        
//        var dict = param
//        let finalUrl = self.getBaseUrlPost(param: &dict)
//        let url = URL(string:finalUrl)
//        
//        
//        LogClass.debugLog("finalUrl   ===>")
//        LogClass.debugLog(finalUrl)
//        LogClass.debugLog(dict)
//        let request = Alamofire.request(url!, method: .get, parameters: dict,
//                                        encoding: URLEncoding.httpBody, headers: self.getCustomHeader())
//        request.responseJSON(completionHandler: { response in
//            LogClass.debugLog("finalUrl   ===> response")
//            LogClass.debugLog(response)
//            guard response.error == nil else {
//                Completion(.failure(response.error!))
//                return
//            }
//            do {
//                switch response.result  {
//                case .success(let resp):
//                    
//                    let respDict = resp as! NSDictionary
//
////                    let meta = respDict["meta"] as! NSDictionary
////                    let code = meta["code"] as! Int
//                    let decoder = JSONDecoder()
////                    if code == ResponseKey.successResp.rawValue{
//                        let model = try decoder.decode(T.self, from:response.data!)
//                        Completion(.success(model))
////                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
////                        AppDelegate.shared().loadLoginScreen()
////                    }else {
////                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
////                        Completion(.failure(model))
////                    }
//                case .failure(let error):
//                    LogClass.debugLog(error.localizedDescription)
//                }
//            } catch let parsingError {
//                Completion(.failure(parsingError))
//            }
//        })
    }
    
    //POST Request...
    static func fetchDataPost<T:Decodable>(Completion:@escaping (Swift.Result<T, Error>)->(), param:[String:String]) {
        var dict = param
        let finalUrl = self.getBaseUrlPost(param: &dict)
        let url = URL(string:finalUrl)
        let request = Alamofire.request(url!, method: .post, parameters: dict,
                                        encoding: URLEncoding.httpBody, headers: self.getCustomHeader())
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
                    let decoder = JSONDecoder()
                    
                    LogClass.debugLog("respDict ====>")
                    LogClass.debugLog(respDict)
                    if code == ResponseKey.successResp.rawValue{
                        let model = try decoder.decode(T.self, from:response.data!)
                        Completion(.success(model))
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
                        Completion(.failure(model))
                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            } catch let parsingError {
                Completion(.failure(parsingError))
            }
        })
    }
    
    //GET Request...
    static func fetchDataGet<T:Decodable>(Completion:@escaping (Swift.Result<T, Error>)->(), param:[String:String]) {
        var dict = param
        let finalUrl = self.getBaseUrlGet(param: &dict)
        let escapedString = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:escapedString!)

        RequestManagerGen.cancelSpecificTask()
        
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
                    
                    
                    LogClass.debugLog("resp  ====>")
                    LogClass.debugLog(resp)
                    let respDict = resp as! NSDictionary
                    let meta = respDict["meta"] as! NSDictionary
                    let code = meta["code"] as! Int
                    let decoder = JSONDecoder()
                    if code == ResponseKey.successResp.rawValue{

                        let model = try decoder.decode(T.self, from:response.data!)
                        Completion(.success(model))
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
                        Completion(.failure(model))
                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            } catch let parsingError {
                Completion(.failure(parsingError))
            }
        })
    }
    
    
    static func cancelSpecificTask() {
        Alamofire.SessionManager.default.session.getAllTasks{sessionTasks in
            for task in sessionTasks {
                if task.originalRequest!.url!.absoluteString.contains("profile/photos") ||
                    task.originalRequest!.url!.absoluteString.contains("profile/videos") {
                    task.cancel()
                }
            }

        }
    }
    
    //GET Request...
    static func fetchDataGetNotification<T:Decodable>(Completion:@escaping (Swift.Result<T, Error>)->(), param:[String:String]) {
        var dict = param
        let finalUrl = self.getBaseUrlGet(param: &dict)
        let escapedString = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:escapedString!)

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
                    let decoder = JSONDecoder()
                    if code == ResponseKey.successResp.rawValue{
                        let model = try decoder.decode(T.self, from:response.data!)
                        Completion(.success(model))
                    }else if code == ResponseKey.unAuthorizedResp.rawValue{
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        let model = try decoder.decode((ErrorModel.self), from:response.data!)
                        Completion(.failure(model))
                    }
                case .failure(let error):
                    LogClass.debugLog(error.localizedDescription)
                }
            } catch let parsingError {
                Completion(.failure(parsingError))
            }
        })
    }
}
