//
//  SpeakerUtility.swift
//  WorldNoor
//
//  Created by Asher Azeem on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class SpeakerUtility {
    
    static func speakerUtility(_ btn: UIButton, with text: String?) {
        let speechManager = SpeechManager.shared
        speechManager.speechFinishCompletion = {
            btn.isSelected = false
        }
        if let activeText = text {
            if activeText == speechManager.speechText && speechManager.isSpeaking {
                speechManager.pauseSpeaking()
                btn.isSelected = false
            } else if activeText == speechManager.speechText && speechManager.speechSynthesizer.isPaused {
                btn.isSelected = true
                speechManager.continueSpeaking()
            } else if activeText.count > 0 {
                btn.isSelected = true
                speechManager.textToSpeech(message: activeText)
            }
        }
    }
}

