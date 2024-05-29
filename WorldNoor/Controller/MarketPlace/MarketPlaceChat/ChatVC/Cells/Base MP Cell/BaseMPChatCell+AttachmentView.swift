//
//  BaseMPChatCell+AttachmentView.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell
{
    func setAttachmentView()
    {
        self.attachmentBubbleView.isHidden = false
        self.lblAttachmentBody.text = self.chatObj.content
        LinkDetector.lblHandling(lblNewBody: lblAttachmentBody)
        
        self.viewAttachmentText.isHidden = false
        if(self.lblAttachmentBody.text?.count ?? 0 == 0)
        {
            self.viewAttachmentText.isHidden = true
        }
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0, let messagefile = self.chatObj.toMessageFile?.first as? MPMessageFile {
            let urlMain = URL.init(string: messagefile.url)
            self.lblFileName.text = messagefile.name.count > 0 ? messagefile.name : urlMain?.lastPathComponent
        }
        
        if(self.lblFileName.text?.count ?? 0 == 0)
        {
            self.lblFileName.text = "File"
        }
    }
    
    @IBAction func downloadAction(sender : UIButton){
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0, let messagefile = self.chatObj.toMessageFile?.first as? MPMessageFile {
            if let url = URL(string: messagefile.url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
