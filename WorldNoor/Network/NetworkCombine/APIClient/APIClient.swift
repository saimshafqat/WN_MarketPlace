//
//  APIClient.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 16/05/2023.
//

import Foundation
import Combine
import UIKit

class APIClient {
    
    // MARK: - Variable -
    let errorMessagePublisher = PassthroughSubject<String, Never>()
    var apiResponseTimer: APIResponseTimer?
    
    // MARK: - Lazy Properties -
    lazy var session: URLSession = {
        let sessionConfig = SessionConfig()
        return sessionConfig.enableConfig()
    }()
    
    // MARK: - Methods -
    func request<T: Decodable>(endPoint: APIEndPoints, startTime: DispatchTime = .now()) -> AnyPublisher<T, APIError> {
        LogClass.debugLog(("URL Request ==> \(endPoint.request)"))
        LogClass.debugLog("Parameters ==> \(endPoint.params)")
        apiResponseTimer = APIResponseTimer(startTime: startTime)
        return session.dataTaskPublisher(for: endPoint.request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .retry(1)
            .tryMap { data, response -> T in
                let elapsedTime = self.apiResponseTimer?.calculateElapsedTime() ?? .emptyString
                LogClass.debugLog("End Point \(endPoint.path) ==> Response Time = \(elapsedTime)")
                let response = response as? HTTPURLResponse
                guard (200..<300).contains(response?.statusCode ?? 0) else {
                    switch response?.statusCode ?? 0 {
                    case 401:
                        // Unauthorized user
                        AppDelegate.shared().loadLoginScreen()
                        throw APIError.failedRequest
                    default:
                        throw APIError.failedRequest
                    }
                }
               do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary ?? NSDictionary()
                    LogClass.debugLog(json)
                    let meta = json["meta"] as? NSDictionary ?? NSDictionary()
                    let code = meta["code"] as? Int ?? 0
                    let msg = meta["message"] as? String ?? .emptyString
                    LogClass.debugLog("\(data.prettyPrintedJSONString ?? "")")
                   if code == ResponseKey.successResp.rawValue || code == ResponseKey.unAuthorizedRespForNode.rawValue { // 200 || 400 status code ==> success
                        return try JSONDecoder().decode(T.self, from: data)
                    } else if msg.contains("not found") && code == ResponseKey.unAuthorizedRespForNode.rawValue {
                        throw APIError.notFound
                    } else if code == ResponseKey.unAuthorizedResp.rawValue {
                        DispatchQueue.main.async(execute: {
                            AppDelegate.shared().loadLoginScreen()
                        })
                        throw APIError.unAuthorized
                    } else if code == ResponseKey.failureResp.rawValue || code == ResponseKey.unAuthorizedRespForNode.rawValue {
                        self.errorMessagePublisher.send(msg)
                    }
                } catch(let error) {
                    AppLogger.log(tag: .error, error.localizedDescription)
                    throw APIError.errorMessage(error.localizedDescription)
                }
                throw APIError.failedRequest // Added a fallback throw statement
            }
            .mapError { error -> APIError in
                switch error {
                case let apiError as APIError:
                    return apiError
                case URLError.notConnectedToInternet:
                    return APIError.unreachable
                default:
                    return APIError.failedRequest
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Multipart API -
    func createMultipartFormData(parameters: [String: String], files: [String: Data], boundary: String) -> Data {
        var body = Data()
        
        // Append parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        // Append files
        for (fileName, fileData) in files {
            let mimeType = getMimeType(for: fileName)
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    func getMimeType(for fileName: String) -> String {
        // Implement a function to determine the MIME type
        // For example:
        if fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg") {
            return "image/jpeg"
        } else if fileName.hasSuffix(".png") {
            return "image/png"
        } else if fileName.hasSuffix(".mp4") {
            return "video/mp4"
        }
        // Add other MIME types as needed
        return "application/octet-stream"
    }
    
    func multipartRequest<T: Decodable>(endPoint: URL, parameters: [String: String], files: [String: Data]) -> AnyPublisher<T, Error> {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: endPoint)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createMultipartFormData(parameters: parameters, files: files, boundary: boundary)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
