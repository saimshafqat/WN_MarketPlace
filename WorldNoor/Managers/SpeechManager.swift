//
//  SpeechManager.swift
//  WorldNoor
//
//  Created by Raza najam on 12/3/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Speech
import Accelerate
import AVFoundation
import NaturalLanguage

//
//protocol SpeechManagerDelegate {
//
//    func enableMicButtonSpeechDelegate(enable:Bool)
//    func updateTextSpeechDelegate()
//    func waveFormSpeechDelegate(enable:Bool)
//    func audioMeteringBufferSpeechDelegate(buffer:AVAudioPCMBuffer)
//    func showAlertSpeechDelegate(message:String)
//    func waveFormMeteringValueSpeechDelegate(value:CGFloat)
//    func handleSpeechResultDelegate(message:String)
//    func speechDidEndDelegate()
//}
//@objc protocol SpeechManagerSynthesizerDelegate {
//    @objc optional func speechDidFinish()
//    @objc optional func speechDidFinish(at indexPath: IndexPath?)
//}

//class SpeechManager: NSObject {
//    var speechSynthesizer = AVSpeechSynthesizer()
//    
//    static let shared = SpeechManager()
//    var speechText = ""
//    var isSpeaking = false
//    
//    override init() {
//        super.init()

//    }
//    
//    // Handling voice to run on speaker...
//    func manageAudioSpeaker() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord , mode: .default , options: .defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
//            
//        } catch let error as NSError {
//            
//        }
//    }
//    
//    func configureAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default)
//            try audioSession.setActive(true)
//        }
//        catch {
//            
//        }
//    }
//    
//    func detectedLangaugeCode(for string: String) -> String {
//        if #available(iOS 12.0, *) {
//            let recognizer = NLLanguageRecognizer()
//            recognizer.processString(string)
//            guard let languageCode = recognizer.dominantLanguage?.rawValue else { return "en"}
//            if languageCode != "" {
//                return languageCode
//            }
//        }
//        return "en"
//    }
//    
//    func textToSpeech(message:String) {
//        // Line 1. Create an instance of AVSpeechSynthesizer.
//        self.stopSpeaking()
//        //   self.speechSynthesizer = AVSpeechSynthesizer()
//        self.speechSynthesizer.delegate = self
//        // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
//        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: message)
//        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
//        speechUtterance.pitchMultiplier = 1
//        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
//        // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: self.detectedLangaugeCode(for: message))
//        // Line 5. Pass in the urrerance to the synthesizer to actually speak.
//        self.speechSynthesizer.speak(speechUtterance)
//    }
//    
//    func pauseSpeaking () {
//        if self.speechSynthesizer.isSpeaking {
//            self.speechSynthesizer.pauseSpeaking(at: .immediate)
//        }
//    }
//    func continueSpeaking () {
//        if self.speechSynthesizer.isPaused {
//            self.speechSynthesizer.continueSpeaking()
//        }
//    }
//    func stopSpeaking() {
//        if speechSynthesizer.isSpeaking {
//            self.speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//    }
//}
//
//extension SpeechManager: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        speechText = ""
//        isSpeaking = false
//        
//    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        speechText = utterance.speechString
//        isSpeaking = true
//    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
//        isSpeaking = false
//    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
//        isSpeaking = true
//    }
//}


class SpeechManager: NSObject {
    var speechSynthesizer = AVSpeechSynthesizer()
    
    static let shared = SpeechManager()
    
    var speechFinishCompletion: (() -> Void)? = nil
    var speechText: String = .emptyString
    var isSpeaking = false
    
    override init() {
        super.init()
        // Initialize speech synthesizer and set delegate
        self.speechSynthesizer.delegate = self
        // Configure audio session
        self.configureAudioSession()
    }
    
    // Handling voice to run on speaker...
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
    
    func detectedLangaugeCode(for string: String) -> String {
        if #available(iOS 12.0, *) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(string)
            guard let languageCode = recognizer.dominantLanguage?.rawValue else { return "en"}
            if !languageCode.isEmpty {
                return languageCode
            }
        }
        return "en"
    }
    
    func textToSpeech(message: String) {
        self.stopSpeaking()
        
        let speechUtterance = AVSpeechUtterance(string: message)
        speechUtterance.pitchMultiplier = 1
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: self.detectedLangaugeCode(for: message))
        
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    func pauseSpeaking() {
        if self.speechSynthesizer.isSpeaking {
            self.speechSynthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    func continueSpeaking() {
        if self.speechSynthesizer.isPaused {
            self.speechSynthesizer.continueSpeaking()
        }
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechText = .emptyString
        isSpeaking = false
        speechFinishCompletion?()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        speechText = utterance.speechString
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
}
