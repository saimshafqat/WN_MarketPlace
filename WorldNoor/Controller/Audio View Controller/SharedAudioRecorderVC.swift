//
//  SharedAudioRecorderVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 28/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import MediaPlayer
import Foundation
import MediaPlayer
import MobileCoreServices

class SharedAudioRecorderVC: UIViewController {
    @IBOutlet weak var btnCancelRecorder: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var playerContentView: UIView!
    
    @IBOutlet weak var waveformView: WaveformLiveView!
    @IBOutlet var waveformImageView: UIImageView!
    @IBOutlet var playbackWaveformImageView: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnRecording: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblMinTime: UILabel!
    
    var getAudioUrl : ((URL) -> Void)?
    
    var imageDrawer: WaveformImageDrawer!
    var audioRecorder: AVAudioRecorder!
    let waveformImageDrawer = WaveformImageDrawer()
    var player: AVPlayer?
    var uniqueValueForAudio = UUID().uuidString
    var currentTimeInterval: TimeInterval = 0.0
    var meterTimer: Timer! = nil
    var recordingSession: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        slider.addGestureRecognizer(panGestureRecognizer)
        manageWave()
        setupInitialView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if audioRecorder != nil {
            finishRecording(success: true)
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        stopRecorder()
        
        let url = getFileURL()
        self.updateWaveformImages(audioURL: url)
    }
    
    @IBAction func sendRecording(_ sender: UIButton) {
        if audioRecorder != nil {
            finishRecording(success: true)
        }
        
        let url = getFileURL()
        if let getAudioUrl = getAudioUrl {
            getAudioUrl(url)
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        setupAVPlayer()
    }
    
    @IBAction func cancelRecorder(_ sender: UIButton) {
        cancelRecordingVoice()
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        }
    }
    
    @IBAction func actionSlider(_ sender: UISlider) {
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        if player?.rate == nil {
            player?.play()
        }
        self.shuffleProgressUIKit(time: Double(slider.value/slider.maximumValue))
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let pointTapped = gestureRecognizer.location(in: slider)
        let widthOfSlider = slider.frame.size.width
        let newValue = Float((pointTapped.x / widthOfSlider) * CGFloat(slider.maximumValue))
        slider.setValue(newValue, animated: true)
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        if player?.rate == nil {
            player?.play()
        }
        self.shuffleProgressUIKit(time: Double(slider.value/slider.maximumValue))
    }
    
    func manageWave(){
        playerContentView.isHidden = true
        imageDrawer = WaveformImageDrawer()
        waveformView.configuration = waveformView.configuration.with(
            style: .striped(.init(color: .strippedWaveColor, width: 2, spacing: 3))
        )
    }
    
    func setupInitialView() {
        btnRecording.isHidden = false
        btnCancelRecorder.isHidden = true
        btnSend.isHidden = true
        slider.isHidden = true
        btnStop.isHidden = true
        lblTimer.isHidden = false
    }
    
    func setupRecorderView() {
        getRecordingSession()
        slider.isHidden = true
        btnStop.isHidden = false
        btnRecording.isHidden = true
        lblTimer.isHidden = false
        lblMinTime.isHidden = true
        btnCancelRecorder.isHidden = false
        btnSend.isHidden = false
        
    }
    
    func getRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission {(grant) in
                if grant {
                    
                } else {
                    
                }
            }
        } catch {
        }
    }
    
    func setupAVPlayer() {
        if player?.rate != nil {
            if player?.timeControlStatus == .playing {
                player?.pause()
                btnPlay.setImage(UIImage(named: "play"), for: .normal)
            } else if player?.timeControlStatus == .paused {
                player?.play()
                btnPlay.setImage(UIImage(named: "pause"), for: .normal)
            }
        } else {
            let playerItem = CachingPlayerItem(url: getFileURL())
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false
            if(slider.value != 0.0)
            {
                let seconds : Int64 = Int64(slider.value)
                let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                player?.seek(to: targetTime)
            }
            player?.play()
            slider.maximumValue = Float(currentTimeInterval)
            btnPlay.setImage(UIImage(named: "pause"), for: .normal)
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000), queue: DispatchQueue.main, using: {[weak self] (cmTime) in
                guard let self = self else {return}
                if self.player?.currentItem?.status == .readyToPlay {
                    let time: Float64 = CMTimeGetSeconds((self.player?.currentTime())!)
                    self.slider.value = Float(time)
                    self.shuffleProgressUIKit(time:Double(self.slider.value / slider.maximumValue))
                    self.lblMinTime.text = self.player?.currentTime().durationText
                }
            })
        }
    }
    
    func finishRecording(success: Bool) {
        if audioRecorder.isRecording {
            audioRecorder.stop()
        }
        meterTimer.invalidate()
        audioRecorder = nil
        slider.value = 0
    }
    
    func refreshAudioView() {
        let linear = 1 - pow(10, (self.audioRecorder?.averagePower(forChannel: 0) ?? -160) / 20)
        
        waveformView.add(samples: [linear, linear, linear])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
            if self?.audioRecorder?.isRecording ?? false {
                self?.refreshAudioView()
            }
        }
    }
    
    func startRecording() {
        setupRecorderView()
        deleteAudioFile()
        let audioUrl = getFileURL()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.updateMeters()
            audioRecorder.record()
            refreshAudioView()
            meterTimer =  Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            RunLoop.current.add(meterTimer, forMode: .common)
        } catch {
            finishRecording(success: false)
        }
    }
    
    @objc private func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            currentTimeInterval = currentTimeInterval + 0.01
            let min = Int(currentTimeInterval / 60)
            let sec = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            lblTimer.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func stopPlayer() {
        if let play = player {
            play.pause()
            player = nil
            slider.value = 0
            btnPlay.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    func stopRecorder() {
        if audioRecorder != nil {
            finishRecording(success: true)
            btnRecording.isHidden = true
            btnStop.isHidden = true
            btnSend.isHidden = false
            btnCancelRecorder.isHidden = false
            lblTimer.isHidden = true
            lblMinTime.text = lblTimer.text
            slider.isHidden = false
            lblMinTime.isHidden = false
            self.waveformImageView.isHidden = false
            self.playbackWaveformImageView.isHidden = false
            waveformView.reset()
            playerContentView.isHidden = false
        }
    }
    
    func cancelRecordingVoice() {
        deleteAudioFile()
        uniqueValueForAudio = UUID().uuidString
        lblTimer.isHidden = false
        lblTimer.text = "00:00"
        lblMinTime.isHidden = true
        btnStop.isHidden = true
        btnRecording.isHidden = false
        btnSend.isHidden = true
        btnCancelRecorder.isHidden = true
        if audioRecorder != nil {
            finishRecording(success: true)
        }
        stopPlayer()
        slider.isHidden = true
        currentTimeInterval = 0.0
        waveformView.reset()
        self.waveformImageView.isHidden = true
        self.playbackWaveformImageView.isHidden = true
        playerContentView.isHidden = true
        
    }
    
    @objc func audioPlayerEnd() {
        stopPlayer()
    }
}

extension SharedAudioRecorderVC: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

    }
    
}

extension SharedAudioRecorderVC {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording_\(uniqueValueForAudio).wav")
        LogClass.debugLog(path)
        return path as URL
    }
    
    func removeFileFromDocumentsDirectory(fileUrl: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: fileUrl)
            return true
        } catch {
            return false
        }
    }
    
    func updateWaveformImages(audioURL:URL) {
        waveformImageDrawer.waveformImage(
            fromAudioAt: audioURL,
            with: .init(size: playbackWaveformImageView.bounds.size, style: .striped(.init(color: .darkGray, width: 2, spacing: 3)))
        ) { image in
            DispatchQueue.main.async {
                self.waveformImageView.image = image
                self.playbackWaveformImageView.image = image?.withTintColor(.green, renderingMode: .alwaysOriginal)
                self.shuffleProgressUIKit(time: 0)
            }
        }
    }
    
    func shuffleProgressUIKit(time:Double) {
        updateProgressWaveform(time)
    }
    
    func updateProgressWaveform(_ progress: Double) {
        let fullRect = playbackWaveformImageView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        playbackWaveformImageView.layer.mask = maskLayer
    }
    
    @discardableResult func deleteAudioFile() -> Bool {
        return self.removeFileFromDocumentsDirectory(fileUrl: getFileURL())
    }
    
}

extension UIColor {
    static let strippedWaveColor = UIColor(red: 93.0/255.0, green: 105.0/255.0, blue: 128.0/255.0, alpha: 1.0)
}

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

