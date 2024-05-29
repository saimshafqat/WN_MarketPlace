//
//  MPChatUploadManager.swift
//  WorldNoor
//
//  Created by Awais on 15/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Alamofire

protocol MPChatUploadManagerProtocol {
    func requestChatUploadingStartedDelegate(uploadTag : Int )
    func requestChatProgressDelegate(progress:CGFloat , uploadTag : Int )
    func requestChatUploadedDelegate()
    func requestChatFailureDelegate()
}

struct MPChatUploadModal {
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

class MPChatUploadManager: NSObject {
    var delegate: MPChatUploadManagerProtocol?
    var uploadTag = 0
    var chatID = ""
    var identifier = ""
    var chatUploadModal : MPChatUploadModal = MPChatUploadModal()
    
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
                if let msgObj = MPMessageDBManager.getMessageFromDb(messageID: self.identifier) {
                    msgObj.uploadingStatus = "uploaded"
                    SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifier)
                    CoreDbManager.shared.saveContext()
                    
                    var filesDict = [String: Any]()
                    filesDict["name"] = self.chatUploadModal.fileName
                    filesDict["original_url"] = self.chatUploadModal.s3FileUrl
                    filesDict["thumbnail_url"] = self.chatUploadModal.s3ThumbnailUrl
                    filesDict["size"] = nil
                    filesDict["type"] = self.chatUploadModal.fileType
                    filesDict["length"] = nil
                    
                    if self.chatUploadModal.fileType == "audio" {
                        
                        self.uploadAudioOnSockt(
                            text: msgObj.content,
                            files: [filesDict],
                            identiferString: msgObj.identifier,
                            replied_to_message_id: msgObj.repliedToMessageId)
                        
                    }
                    else
                    if self.chatUploadModal.s3ThumbnailUrl.count > 0 {
                        
                        self.UploadImageOnSocket(
                            mainURL: self.chatUploadModal.s3FileUrl,
                            files: [filesDict],
                            fileType:self.chatUploadModal.fileType,
                            identiferString: msgObj.identifier,
                            msgObj: msgObj)
                    }
                    else
                    {
                        
                        self.UploadImageOnSocket(
                            mainURL: self.chatUploadModal.s3FileUrl,
                            files: [filesDict],
                            fileType:self.chatUploadModal.fileType,
                            identiferString: msgObj.identifier,
                            msgObj: msgObj)
                    }
                }
            }
        }
    }
    
    func uploadFileOnS3(fileURL: URL?, urlMain: String, success: @escaping (Bool) -> Void) {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else {
            if let msgObj = MPMessageDBManager.getMessageFromDb(messageID: self.identifier) {
                msgObj.uploadingStatus = "uploaded"
                SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifier)
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
                    if let msgObj = MPMessageDBManager.getMessageFromDb(messageID: self.identifier) {
                        msgObj.uploadingStatus = "uploaded"
                        SharedManager.shared.chatUploadingDict.removeValue(forKey: msgObj.identifier)
                        CoreDbManager.shared.saveContext()
                    }
                    self.delegate?.requestChatFailureDelegate()
                    success(false)
                }
            }
    }
    
    func uploadAudioOnSockt(text : String ,files : [[String: Any]] , identiferString : String , replied_to_message_id : String = ""){
        var dict: [String: Any] = [
            "message": text,
            "conversation_id": chatID,
            "identifier": identiferString,
            "files": files,
            "message_type": FeedType.audio.rawValue,
            "created_at": SharedManager.shared.getUTCDateTimeString()
        ]
        
        if(!replied_to_message_id.isEmpty) {
            dict["replied_to_message_id"] = replied_to_message_id
        }

        LogClass.debugLog("uploadAudioOnSockt ===>")
        LogClass.debugLog(dict)
        MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
    
    func UploadImageOnSocket(mainURL : String ,files : [[String: Any]], fileType: String, identiferString : String, msgObj:MPMessage ){
        
        self.sendChatAttachText(mainURL: mainURL, files: files, fileType: fileType, identiferString: identiferString, msgObj: msgObj)
    }
    
    func sendChatAttachText(mainURL : String , files : [[String: Any]], fileType:String, identiferString : String, msgObj:MPMessage ){
        
        let myComment = ChatManager.shared.validateTextMessage(comment: msgObj.content)
        
        var dict: [String: Any] = [
            "message": myComment,
            "conversation_id": chatID,
            "identifier": identiferString,
            "files": files,
            "message_type": fileType,
            "created_at": SharedManager.shared.getUTCDateTimeString()
        ]
        
        if(!msgObj.repliedToMessageId.isEmpty) {
            dict["replied_to_message_id"] = msgObj.repliedToMessageId
        }
        
        MPSocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
}

