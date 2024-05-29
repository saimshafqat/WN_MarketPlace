//
//  AudioPlayerView.swift
//  WorldNoor
//
//  Created by Awais on 28/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class AudioPlayerView: UIView, AudioPlayerDelegate {
    let waveformImageDrawer = WaveformImageDrawer()
    private var audioURL: URL?
    private var downloadedURL: URL?
    private var audioData: Data?
    private var isPlaying: Bool = false
    private var waveImageSize: CGSize = .zero
    private var isSenderCell: Bool = true
    private var identifier: String = ""
    private var audioDuration: String = "00:00"
    
    @IBOutlet weak var waveformImageView: UIImageView!
    @IBOutlet weak var playbackWaveformImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    func prepareForReuse() {
        resetUI()
    }
    
    func configure(with audioURL: URL, identifier:String, isSenderCell: Bool = true) {
        self.audioURL = audioURL
        self.isSenderCell = isSenderCell
        self.identifier = identifier
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        DispatchQueue.main.async {
            self.waveImageSize = self.waveformImageView.bounds.size
            self.lblTime.text = "00:00"
            self.showDownloadIndicator(true)
            self.updatePlayPauseButton()
            self.setupWaveformImage()
        }
    }
    
    private func startAudioPlaying() {
        
        if(SharedManager.shared.chatAudioPlayMsgId != identifier)
        {
            AudioPlayerManager.shared.stopAudio(identifier: SharedManager.shared.chatAudioPlayMsgId)
        }
        
        let progress = Double(slider.value)
        guard let audioURL = downloadedURL else { return }
        AudioPlayerManager.shared.delegate = self
        SharedManager.shared.chatAudioPlayMsgId = identifier
        
        AudioPlayerManager.shared.prepareForPlay(from: audioURL, identifier: identifier) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let preparedPlayer):
                self.isPlaying = true
                self.updatePlayPauseButton()
                self.showDownloadIndicator(false)
                
                if (progress > 0)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        AudioPlayerManager.shared.seekTo(progress, forIdentifier: self.identifier)
                        AudioPlayerManager.shared.playPreparedAudio(preparedPlayer, identifier: self.identifier)
                    }
                }
                else {
                    AudioPlayerManager.shared.playPreparedAudio(preparedPlayer, identifier: identifier)
                }

            case .failure(let error):
                LogClass.debugLog("Error preparing audio: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isPlaying = false
                    self.updatePlayPauseButton()
                    self.showDownloadIndicator(false)
                }
            }
        }
    }
    
    private func startPlaying() {
        
        if(SharedManager.shared.chatAudioPlayMsgId != identifier)
        {
            AudioPlayerManager.shared.stopAudio(identifier: SharedManager.shared.chatAudioPlayMsgId)
        }
        
        let progress = Double(slider.value)
        guard let audioURL = downloadedURL else { return }
        AudioPlayerManager.shared.delegate = self
        SharedManager.shared.chatAudioPlayMsgId = identifier
        
        AudioPlayerManager.shared.playAudio(from: audioURL, identifier: identifier)
        
        if (progress > 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                AudioPlayerManager.shared.seekTo(progress, forIdentifier: self.identifier)
            }
        }
        
        isPlaying = true
        updatePlayPauseButton()
        showDownloadIndicator(false)
    }
    
    private func setupWaveformImage() {
        guard let audioURL = audioURL else { return }
//        AudioDownloadManager.shared.downloadAudio(from: audioURL) { [weak self] result in
        AudioDownloadManager.shared.downloadCacheAudio(from: audioURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let downloadedURL):
                DispatchQueue.main.async {
                    self.downloadedURL = downloadedURL
                    self.updateWaveformImage(audioURL: downloadedURL)
                    self.showDownloadIndicator(false)
                    self.updatePlayPauseButton()
                    
                    AudioUtility.getAudioDuration(from: downloadedURL.absoluteString) { duration, error in
                        if let duration = duration {
                            self.audioDuration = duration.durationText
                            self.lblTime.text = duration.durationText
                        } else {
                            self.lblTime.text = "00:00"
                        }
                    }
                    
                    self.updateUIBasedOnProgress()
                }
                
            case .failure(let error):
                LogClass.debugLog("Error downloading audio: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showDownloadIndicator(false)
                }
            }
        }
    }
    
    private func updateUIBasedOnProgress() {
        let progress = AudioPlayerManager.shared.getProgress(identifier: identifier)
        
        guard progress > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.slider.value = Float(progress)
            self.updateProgressWaveform(progress)
            self.updateTime(progress)
        }
    }
    
    private func resetProgress() {
        AudioPlayerManager.shared.resetProgress(identifier: identifier)
        
        DispatchQueue.main.async {
            self.slider.value = 0.0
            self.updateProgressWaveform(0.0)
            self.updateTime(0.0)
        }
    }
    
    private func updateWaveformImage(audioURL: URL) {
        waveformImageDrawer.waveformImage(
            fromAudioAt: audioURL,
            with: .init(size: self.waveImageSize, style: .striped(.init(color: isSenderCell ? .white : UIColor.init().hexStringToUIColor(hex: "494949"), width: 2, spacing: 3)))
        ) { [weak self] image in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.waveformImageView.image = image
                self.playbackWaveformImageView.image = image?.withTintColor(self.isSenderCell ? UIColor.init().hexStringToUIColor(hex: "#127FA5").withAlphaComponent(0.3) : UIColor.init().hexStringToUIColor(hex: "#029EDA").withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
                self.shuffleProgressUIKit(time: 0)
            }
        }
    }
    
    private func shuffleProgressUIKit(time: Double) {
        updateProgressWaveform(time)
    }
    
    private func updateProgressWaveform(_ progress: Double) {
        let fullRect = playbackWaveformImageView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        playbackWaveformImageView.layer.mask = maskLayer
    }
    
    private func updatePlayPauseButton() {
        let imageName = isPlaying ? "pause" : "play"
        playPauseButton.setImage(UIImage(named: imageName)?.withTintColor(isSenderCell ? .white : UIColor.init().hexStringToUIColor(hex: "494949")), for: .normal)
    }
    
    private func showDownloadIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            self.downloadIndicator.isHidden = !show
            self.downloadIndicator.color = self.isSenderCell ? .white : UIColor.init().hexStringToUIColor(hex: "494949")
            self.playPauseButton.isHidden = show
        }
    }
    
    private func updateTime(_ progress: Double) {
        
        if(progress > 0)
        {
            let durationInSeconds = AudioPlayerManager.shared.getDurationInSeconds(identifier: identifier)
            let currentTimeInSeconds = progress * durationInSeconds
            
            let minutes = Int(currentTimeInSeconds) / 60
            let seconds = Int(currentTimeInSeconds) % 60
            
            lblTime.text = String(format: "%02d:%02d", minutes, seconds)
        }
        else {
            lblTime.text = audioDuration
        }
    }
    
    // MARK: - Actions
    @objc private func playPauseButtonTapped() {
        if isPlaying {
            AudioPlayerManager.shared.pauseAudio(identifier: identifier)
            isPlaying = false
            updatePlayPauseButton()
        } else {
//            startPlaying()
            startAudioPlaying()
        }
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        let progress = Double(slider.value)
        AudioPlayerManager.shared.seekTo(progress, forIdentifier: identifier)
        shuffleProgressUIKit(time: Double(slider.value / slider.maximumValue))
    }
    
    private func resetUI() {
        waveformImageView.image = UIImage(named: isSenderCell ? "dummywaves" : "dummyreceiverwaves")
        playbackWaveformImageView.image = nil
        isPlaying = false
        slider.value = 0.0
        lblTime.text = "00:00"
        audioDuration = "00:00"
        showDownloadIndicator(false)
        updatePlayPauseButton()
    }
    
    // MARK: - AudioPlayerDelegate
    func audioPlayerDidUpdateProgress(_ progress: Double, identifier: String) {
        guard SharedManager.shared.chatAudioPlayMsgId == identifier else { return }
        DispatchQueue.main.async {
            self.slider.value = Float(progress)
            self.updateProgressWaveform(progress)
            self.updateTime(progress)
        }
    }
    
    func audioPlayerDidFinishPlaying(identifier: String) {
        isPlaying = false
        updatePlayPauseButton()
    }
}

