//
//  SoundManager.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    enum SoundName: String {
        case pop = "pop"
        case refresh = "refreshSound"
        var type: String {
            rawValue
        }
    }
    
    enum SoundExt: String {
        case wav = "wav"
        case mp3 = "mp3"
        var type: String {
            rawValue
        }
    }

    static var share = SoundManager()
    
    var audioPlayer: AVAudioPlayer?
    
    func playSound(_ name: SoundName = .refresh, ext: SoundExt = .wav) {
        // Initialize the audio player
        if let soundFilePath = Bundle.main.path(forResource: name.type, ofType: ext.rawValue) {
            let soundURL = URL(fileURLWithPath: soundFilePath)
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch let error {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found in the bundle.")
        }
        guard let audioPlayer = audioPlayer else {
            print("Audio player is nil. Cannot play sound.")
            return
        }
        
        if audioPlayer.isPlaying {
            print("Sound is already playing.")
        } else {
            audioPlayer.play()
            print("Playing sound.")
        }
    }
}

