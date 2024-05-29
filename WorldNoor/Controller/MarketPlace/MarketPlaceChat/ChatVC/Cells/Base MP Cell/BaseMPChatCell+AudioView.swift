//
//  BaseMPChatCell+AudioView.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell {
    func setAudioView(isSenderCell: Bool = true) {
        self.audioBubbleView.isHidden = false
        self.lblAudioBody.text = self.chatObj.content
        LinkDetector.lblHandling(lblNewBody: lblAudioBody)

        self.viewAudioText.isHidden = self.lblAudioBody.text?.isEmpty ?? true
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0, let messagefile = self.chatObj.toMessageFile?.first as? MPMessageFile {
            let audioURLString = messagefile.url
            if audioURLString.count > 0, let audioURL = URL(string: audioURLString) {
                self.audioView.configure(with: audioURL, identifier: self.chatObj.id, isSenderCell: isSenderCell)
            }
        }
    }
}
