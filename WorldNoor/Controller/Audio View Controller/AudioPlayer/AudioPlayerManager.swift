//
//  AudioPlayerManager.swift
//  WorldNoor
//
//  Created by Awais on 28/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayerDidUpdateProgress(_ progress: Double, identifier: String)
    func audioPlayerDidFinishPlaying(identifier: String)
}

class AudioPlayerManager {
    static let shared = AudioPlayerManager()

    weak var delegate: AudioPlayerDelegate?
    private var players: [String: AVPlayer] = [:]
    private var progressForIdentifier: [String: Double] = [:]
    private var observers: [Any] = []

    private func setupPlayerObserver(identifier: String) {
        guard let player = players[identifier] else { return }
        configureAudioSession()
        let playerItem = player.currentItem
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        guard let identifier = findIdentifierForPlayerItem(notification.object as? AVPlayerItem) else {
            return
        }
        self.delegate?.audioPlayerDidUpdateProgress(0.0, identifier: identifier)
        self.progressForIdentifier[identifier] = 0.0
        delegate?.audioPlayerDidFinishPlaying(identifier: identifier)
    }

    private func findIdentifierForPlayerItem(_ playerItem: AVPlayerItem?) -> String? {
        for (identifier, player) in players {
            if player.currentItem === playerItem {
                return identifier
            }
        }
        return nil
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        }
        catch {
            
        }
    }
    
    func prepareForPlay(from url: URL, identifier: String, completion: @escaping (Result<AVPlayer, Error>) -> Void) {
        stopAudio(identifier: identifier)

        let playerItem = AVPlayerItem(url: url)

        let player = AVPlayer(playerItem: playerItem)
        players[identifier] = player

        let observer = player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000),
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let self = self else { return }
            guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }

            let progress = time.seconds / duration
            self.delegate?.audioPlayerDidUpdateProgress(progress, identifier: identifier)
            self.progressForIdentifier[identifier] = progress
        }

        observers.append(observer)

        completion(.success(player))
    }

    func playPreparedAudio(_ player: AVPlayer, identifier: String) {
        
        player.play()
        setupPlayerObserver(identifier: identifier)
    }

    func playAudio(from url: URL, identifier: String) {
        stopAudio(identifier: identifier)

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        players[identifier] = player

        let observer = player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000),
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let self = self else { return }
            guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }

            let progress = time.seconds / duration
            self.delegate?.audioPlayerDidUpdateProgress(progress, identifier: identifier)
            self.progressForIdentifier[identifier] = progress
        }

        observers.append(observer)

        player.play()
        setupPlayerObserver(identifier: identifier)
    }
    
    func playAudio(from data: Data, identifier: String) {
        stopAudio(identifier: identifier)

        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(identifier).m4a")
            try data.write(to: tempURL)
            let playerItem = AVPlayerItem(url: tempURL)
            let player = AVPlayer(playerItem: playerItem)
            players[identifier] = player
            
            let observer = player.addPeriodicTimeObserver(
                forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000),
                queue: DispatchQueue.main
            ) { [weak self] time in
                guard let self = self else { return }
                guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
                
                let progress = time.seconds / duration
                self.delegate?.audioPlayerDidUpdateProgress(progress, identifier: identifier)
                self.progressForIdentifier[identifier] = progress
            }
            
            observers.append(observer)
            
            player.play()
            setupPlayerObserver(identifier: identifier)
        }
        catch {
            
        }
    }

    func seekTo(_ progress: Double, forIdentifier identifier: String) {
        guard let player = players[identifier], let currentItem = player.currentItem else { return }

        let duration = currentItem.duration.seconds
        let seekTime = CMTime(seconds: duration * progress, preferredTimescale: 1000)

        player.seek(to: seekTime)
        progressForIdentifier[identifier] = progress
    }

    func getProgress(identifier: String) -> Double {
        return progressForIdentifier[identifier] ?? 0.0
    }

    func resetProgress(identifier: String) {
        progressForIdentifier[identifier] = 0.0
    }

    func getDurationInSeconds(identifier: String) -> Double {
        guard let player = players[identifier], let duration = player.currentItem?.duration.seconds,
            !duration.isNaN, !duration.isInfinite else {
            return 0.0
        }
        return duration
    }

    func pauseAudio(identifier: String) {
        players[identifier]?.pause()
    }

    func stopAudio(identifier: String) {
        for (_, player) in players {
            player.pause()
        }

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()

        delegate?.audioPlayerDidFinishPlaying(identifier: identifier)
    }

    deinit {
        for (_, player) in players {
            player.pause()
        }
        players.removeAll()

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
    
    func recordAndDeleteAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsDirectory.appendingPathComponent("recordedAudio.wav")
            
            let audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                audioRecorder.stop()
            }
            
            try FileManager.default.removeItem(at: audioFilename)
        } catch {

        }
    }
}

