//
//  BaseChatCell+TextView.swift
//  WorldNoor
//
//  Created by Awais on 22/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension BaseChatCell
{
    func setTextView()
    {
        self.textBubbleView.isHidden = false
        self.lblTextBody.text = self.chatObj.body
        LinkDetector.lblHandling(lblNewBody: lblTextBody)
    }
}
