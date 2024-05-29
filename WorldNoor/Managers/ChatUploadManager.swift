//
//  ChatUploadManager.swift
//  WorldNoor
//
//  Created by Hawais on 06/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Alamofire

protocol ChatUploadManagerProtocol {
    func requestChatUploadingStartedDelegate(uploadTag : Int )
    func requestChatProgressDelegate(progress:CGFloat , uploadTag : Int )
    func requestChatUploadedDelegate()
    func requestChatFailureDelegate()
}

struct ChatUploadModal {
    var fileType = ""
    var fileName = ""
    var mimeType = ""
    var filePath: URL?
    
    var thumbnailName = ""
    var thumbnailPath: URL?
    var thumbnailMimeType = ""
    
    var preSignedUrl = ""
    var preSignedthumbnilUrl = ""
    
    var s3FileUrl = ""
    var s3ThumbnailUrl = ""
}

class ChatUploadManager: NSObject {
    var delegate: ChatUploadManagerProtocol?
    var uploadTag = 0
    var chatID = ""
    var identifier = ""
    var chatUploadModal : ChatUploadModal = ChatUploadModal()
    
    override init() {
        super .init()
    }
    
    func callingServiceToUploadOnS3() {
        let parametersUpload = ["action": "s3url", "token": SharedManager.shared.userToken()]
        
        var arrayObject = [[String: AnyObject]]()
        
        var newDict = [String: AnyObject]()
        newDict["mimeType"] = chatUploadModal.mimeType as AnyObject
        newDict["fileName"] = chatUploadModal.fileName as AnyObject
        arrayObject.append(newDict)
        
        if chatUploadModal.fileType == "video" {
            var newDict = [String: AnyObject]()
            newDict["mimeType"] = chatUploadModal.thumbnailMimeType as AnyObject
            newDict["fileName"] = chatUploadModal.thumbnailName as AnyObject
            arrayObject.append(newDict)
        }
        
        LogClass.debugLog("*****S3: \(arrayObject)")
        
        var newFileParam = [String: AnyObject]()
        newFileParam["file"] = arrayObject as AnyObject
        
        RequestManagerGen.uploadChatURLPost(Completion: { response in
            switch response {
            case .failure(let error):
                if error is ErrorModel {
                    LogClass.debugLog(error)
                }
                
            case .success(let res):
                if let dataArr = (res as? uploadMediaModel)?.data {
                    for indexobj in dataArr {
                        
                        if indexobj.fileName == self.chatUploadModal.fileName {
                            self.chatUploadModal.preSignedUrl = indexobj.preSignedUrl ?? ""
                            self.chatUploadModal.s3FileUrl = indexobj.fileUrl ?? ""
                            
                        }else if indexobj.fileName == self.chatUploadModal.thumbnailName {
                            self.chatUploadModal.preSignedthumbnilUrl = indexobj.preSignedUrl ?? ""
                            self.chatUploadModal.s3ThumbnailUrl = indexobj.fileUrl ?? ""
                        }
                    }
                    
                    self.uploadMediaOnS3()
                }
            }
        }, param: newFileParam, dictURL: parametersUpload)
    }
    
    func uploadMediaOnS3(){
        
        if(self.chatUploadModal.preSignedthumbnilUrl.count > 0) {
            uploadThumbImage()
        }
        else {
            uploadFile()
        }
    }
    
    
    func uploadThumbImage(){
        uploadFileOnS3(fileURL: self.chatUploadModal.thumbnailPath, urlMain: self.chatUploadModal.preSignedthumbnilUrl) { success in
            if success {
                self.uploadFile()
            }
        }
    }
    
    func uploadFile() {
        uploadFileOnS3(fileURL: self.chatUploadModal.filePath, urlMain: self.chatUploadModal.preSignedUrl) { success in
            if success {
                if let msgObj = DBMessageManager.getMessageFromDb(messageID: self.identifier) {
                    msgObj.uploadingStatus = "uploaded"
                    SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifierString)
                    CoreDbManager.shared.saveContext()
                    
                    if self.chatUploadModal.fileType == "audio" {
                        msgObj.audio_msg_url = self.chatUploadModal.s3FileUrl
                        self.uploadAudioOnSockt(
                            text: msgObj.body,
                            audio_msg_url: self.chatUploadModal.s3FileUrl ,
                            identiferString: self.identifier,
                            replied_to_message_id: msgObj.replied_to_message_id)
                        
                    }
                    else
                    if self.chatUploadModal.s3ThumbnailUrl.count > 0 {
                        self.UploadImageOnSocket(
                            mainURL: self.chatUploadModal.s3FileUrl,
                            newTime: self.identifier,
                            fileType:self.chatUploadModal.fileType,
                            thumbnailURL: self.chatUploadModal.s3ThumbnailUrl,
                            msgObj: msgObj)
                    }
                    else
                    {
                        self.UploadImageOnSocket(
                            mainURL: self.chatUploadModal.s3FileUrl,
                            newTime: self.identifier,
                            fileType:self.chatUploadModal.fileType,
                            thumbnailURL: "",
                            msgObj: msgObj)
                    }
                }
            }
        }
    }
    
    func uploadFileOnS3(fileURL: URL?, urlMain: String, success: @escaping (Bool) -> Void) {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else {
            if let msgObj = DBMessageManager.getMessageFromDb(messageID: self.identifier) {
                msgObj.uploadingStatus = "uploaded"
                SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifierString)
                CoreDbManager.shared.saveContext()
            }
            self.delegate?.requestChatFailureDelegate()
            success(false)
            return
        }
        
        Alamofire.upload(data, to: urlMain, method: .put)
            .validate(statusCode: 200..<300)
            .uploadProgress { progress in
                if(urlMain != self.chatUploadModal.preSignedthumbnilUrl)
                {
                    let progressValue = CGFloat(progress.fractionCompleted * 100)
                    self.delegate?.requestChatProgressDelegate(progress: progressValue, uploadTag: self.uploadTag)
                }
            }
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    success(true)
                } else {
                    if let msgObj = DBMessageManager.getMessageFromDb(messageID: self.identifier) {
                        msgObj.uploadingStatus = "uploaded"
                        SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifierString)
                        CoreDbManager.shared.saveContext()
                    }
                    self.delegate?.requestChatFailureDelegate()
                    success(false)
                }
            }
    }
    
    func uploadAudioOnSockt(text : String ,audio_msg_url : String , identiferString : String , replied_to_message_id : String = ""){
        let dict:NSDictionary = ["body":text,"author_id":SharedManager.shared.getUserID(), "audio_msg_url":audio_msg_url, "uploads":[], "conversation_id":chatID, "identifierString":identiferString, "message_files":[], "audio_file":"", "replied_to_message_id" : replied_to_message_id]
        LogClass.debugLog("uploadAudioOnSockt ===>")
        LogClass.debugLog(dict)
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
    
    func UploadImageOnSocket(mainURL : String , newTime : String , fileType:String, thumbnailURL : String, msgObj:Message ){
        
        if msgObj.reply_to != nil {
            self.replyChatAttachText(mainURL: mainURL, newTime: newTime, fileType: fileType, thumbnailURL: thumbnailURL, msgObj: msgObj)
        }else {
            self.sendAttachOnSocket(mainURL: mainURL, newTime: newTime, fileType: fileType, thumbnailURL: thumbnailURL, msgObj: msgObj)
        }
    }
    
    func replyChatAttachText(mainURL : String , newTime : String , fileType:String, thumbnailURL : String, msgObj:Message ){
        
        var urlSendArray = [[String : Any]]()
        var urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = thumbnailURL
        
        if fileType == "video" {
            urlSend["type"] = "video/mov"
        }else if fileType == "attachment" {
            urlSend["type"] = "attachment"
        }else {
            urlSend["type"] = "image/jpeg"
        }
        
        urlSendArray.append(urlSend)
        let myComment = ChatManager.shared.validateTextMessage(comment: msgObj.body)
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":chatID, "identifierString":msgObj.identifierString, "message_files":[], "audio_file":"", "replied_to_message_id" : msgObj.replied_to_message_id]
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
    
    func sendAttachOnSocket(mainURL : String , newTime : String , fileType:String, thumbnailURL : String, msgObj:Message ){
        var urlSendArray = [[String : Any]]()
        var urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = thumbnailURL
        
        if fileType == "video" {
            urlSend["type"] = "video/mov"
            urlSend["language_id"] = "1"
        }else if fileType == "attachment" {
            urlSend["type"] = "attachment"
        }else {
            urlSend["type"] = "image/jpeg"
        }
        
        urlSendArray.append(urlSend)
        var newTimeP = newTime
        if newTime.count == 0 {
            newTimeP = SharedManager.shared.getCurrentDateString()
        }
        
        LogClass.debugLog("msgObj.replied_to_message_id ===>")
        LogClass.debugLog(msgObj.replied_to_message_id)
        let myComment = ChatManager.shared.validateTextMessage(comment: msgObj.body)
        let dict:NSDictionary = [ "body" : myComment ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":chatID, "identifierString":newTimeP, "message_files":[], "audio_file":"" , "replied_to_message_id" : msgObj.replied_to_message_id ]
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
}
