//
//  MPRequestManager.swift
//  WorldNoor
//
//  Created by Awais on 29/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Alamofire

class MPRequestManager {
    
    static let shared = MPRequestManager()
    
    func request(endpoint: String, method: Alamofire.HTTPMethod = .get, params:[String:Any]? = nil, completion: @escaping (Swift.Result<Any, Error>) -> Void) {
        AppLogger.log("sasasas")
        let headers: HTTPHeaders = [
//            "token": SharedManager.shared.marketplaceUserToken()
            "token": "0a175f4946723cf87d38ade21a3989b0154c8a2f95b30d04115c5a4a0e80722e8b5dd20f8120b660558edb7d9ed697fd2359c79b3e337a19dd868b13"
        ]
        
        let urlString = AppConfigurations().MPBaseUrl + endpoint
        AppLogger.log("URL :\(urlString) \nParams :\(params)")
        Alamofire.request(urlString, method: method, parameters: params, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    self.handleSuccess(result: result, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                    LogClass.debugLog(error.localizedDescription)
                }
            }
    }
    
    private func handleSuccess(result: Any, completion: @escaping (Swift.Result<Any, Error>) -> Void) {
        LogClass.debugLog(result)
        
        guard let encryptedString = result as? String else {
            completion(.failure(MPError.invalidResponse))
            LogClass.debugLog("Invalid response format")
            return
        }
        
        AESDataDecryptor.decryptAESData(encryptedHexString: encryptedString) { responseString in
            LogClass.debugLog(responseString ?? "NO RESPONSE")
            guard let jsonData = responseString?.data(using: .utf8) else {
                completion(.failure(MPError.decryptionFailed))
                LogClass.debugLog("Failed to convert JSON string to Data.")
                return
            }
            
            completion(.success(jsonData))
        }
    }
}

enum MPError: Error {
    case invalidResponse
    case decryptionFailed
}

