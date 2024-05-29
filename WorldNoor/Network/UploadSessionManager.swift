//
//  UploadSessionManager.swift
//  WorldNoor
//
//  Created by Raza najam on 1/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class UploadSessionManager: NSObject {
    
    static var shared = UploadSessionManager()
    var buffer:NSMutableData = NSMutableData()
    var expectedContentLength:Int = 0
    var sessionIdentifier = "com.worldnoor.upload"
    
    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }
    
    func upload(){
        
        guard let videoPath = Bundle.main.path(forResource: "video2", ofType:"mov") else {
            return
        }
        let videoUrlPath = URL(fileURLWithPath: videoPath)
        do {
            let videoData = try Data(contentsOf: videoUrlPath)
            let contentSizeString = String(videoData.count)
            let url = URL(string: "http://192.168.0.73:8080/upload")!
            let tempDir = FileManager.default.temporaryDirectory
            let localURL = tempDir.appendingPathComponent("throwaway1")
            try? videoData.write(to: localURL)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer 77a75176-6f0a-481b-adca-331a0ba694ad", forHTTPHeaderField: "Authorization")
            
            let jwtToken = SharedManager.shared.userObj?.data.jwtToken
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(jwtToken, forHTTPHeaderField: "jwtToken")
            request.setValue("video/mov", forHTTPHeaderField: "type")
            request.setValue((sessionIdentifier), forHTTPHeaderField: "x-FileID")
            request.setValue((contentSizeString), forHTTPHeaderField: "x-file-size")
            request.setValue("video1.mov", forHTTPHeaderField: "name")
            let task = self.activate().uploadTask(with: request, fromFile: localURL)
            task.resume()
        } catch let error {
         
        }
    }
}

extension UploadSessionManager:URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
    
}
