//
//  BaseSendMPChatCell.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class BaseSendMPChatCell: BaseMPChatCell {
    
    var progressBGView: CircularProgressView!
    
    @IBOutlet var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func manageUploadingStatus(){
        self.removeCircularProgress()
        if let chatUploading = SharedManager.shared.mpChatUploadingDict[self.chatObj.identifier], self.chatObj.uploadingStatus == "uploading" {
            chatUploading.delegate = self
            DispatchQueue.main.async {
                self.progressBGView.progressColor = UIColor.progressInnerBG
                self.progressBGView.isHidden = false
                self.showCircularProgress()
            }
        }
    }
    
    func manageMessageStatus(status:String) {
        if self.lblStatus != nil {
            self.lblStatus.text = "Sending".localized()
            if status == MessageStatus.delivered.rawValue {
                self.lblStatus.text = "Sent".localized()
            }else if status == MessageStatus.seen.rawValue {
                self.lblStatus.text = "Seen".localized()
            }
        }
    }
    
    func showCircularProgress(currentProgress: CGFloat = 0.0){
        DispatchQueue.main.async {
            self.progressBGView.progress = currentProgress
        }
    }
    
    func removeCircularProgress(){
        DispatchQueue.main.async {
            self.progressBGView.isHidden = true
        }
    }
}

extension BaseSendMPChatCell:MPChatUploadManagerProtocol {
    func requestChatUploadingStartedDelegate(uploadTag: Int) {
        
    }
    
    func requestChatProgressDelegate(progress: CGFloat, uploadTag: Int) {
        DispatchQueue.main.async {
            self.showCircularProgress(currentProgress: progress/100.0)
        }
    }
    
    func requestChatUploadedDelegate() {
        self.removeCircularProgress()
        self.chatObj.uploadingStatus = "complete"
        SharedManager.shared.chatUploadingDict.removeValue(forKey: self.chatObj.identifier)
        CoreDbManager.shared.saveContext()
    }
    
    func requestChatFailureDelegate() {
        self.removeCircularProgress()
        self.chatObj.uploadingStatus = "failed"
        SharedManager.shared.chatUploadingDict.removeValue(forKey: self.chatObj.identifier)
        CoreDbManager.shared.saveContext()
    }
    
}

