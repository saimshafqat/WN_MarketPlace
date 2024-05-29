//
//  BaseMPChatCell+TextView.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseMPChatCell
{
    func setTextView()
    {
        self.textBubbleView.isHidden = false
        self.lblTextBody.text = self.chatObj.content
        LinkDetector.lblHandling(lblNewBody: lblTextBody)
    }
}
