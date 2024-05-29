//
//  BaseChatCell+AudioView.swift
//  WorldNoor
//
//  Created by Awais on 22/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

extension BaseChatCell {
    func setAudioView(isSenderCell: Bool = true) {
        self.audioBubbleView.isHidden = false
        self.lblAudioBody.text = self.chatObj.body
        LinkDetector.lblHandling(lblNewBody: lblAudioBody)

        self.viewAudioText.isHidden = self.lblAudioBody.text?.isEmpty ?? true
        let audioURLString = self.chatObj.audio_msg_url
        if audioURLString.count > 0, let audioURL = URL(string: audioURLString) {
            self.audioView.configure(with: audioURL, identifier: self.chatObj.id, isSenderCell: isSenderCell)
        }
    }
}
