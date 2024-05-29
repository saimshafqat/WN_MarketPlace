//
//  AudioRecorder.swift
//  WorldNoor
//
//  Created by Raza najam on 11/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//
import UIKit
import AVFoundation

enum AGAudioRecorderState {
    case Pause
    case Play
    case Finish
    case Failed(String)
    case Recording
    case Ready
    case error(Error)
}

protocol AGAudioRecorderDelegate {
    func agAudioRecorder(_ recorder: AudioRecorder, withStates state: AGAudioRecorderState)
    func agAudioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String)
    func agPlayerFinishedPlaying()
    func agPlayerTimerDelegate(timeLeft:String)
}

class AudioRecorder: NSObject {
    var audioCheck:Bool = false
    var isPause:Bool = false
    var isPauseAudioPlayer:Bool = false
    var delegate: AGAudioRecorderDelegate?
    var filename: String = ""
    var isAudioRecordingGranted: Bool = false
    var audioRecorder: AVAudioRecorder! = nil
    var audioPlayer: AVAudioPlayer! = nil
    var meterTimer: Timer! = nil
    var currentTimeInterval: TimeInterval = 0.0
    var progressTimer: Timer?
    var audioPlayerTimer: Timer?
    var progressSlider:UISlider?
    var audioPlayerSeekTime:TimeInterval = 0.0
    var totalRecordedTime:Int = 0
    
    var recorderState: AGAudioRecorderState = .Ready {
        willSet {
            delegate?.agAudioRecorder(self, withStates: newValue)
        }
    }
    
    init(withFileName filename: String) {
        super.init()
        self.recorderState = .Ready
    }
    
    func requestRecordPermission(){
        AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
            if allowed {
                self.isAudioRecordingGranted = true
            } else {
                self.isAudioRecordingGranted = false
            }
        })
    }
    
    func check_record_permission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            LogClass.debugLog("Not found...")
        }
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func fileUrl() -> URL {
        let filename = "\(self.filename).wav"
        let filePath = documentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func changeFile(withFileName filename: String) {
        self.filename = filename
        if audioPlayer != nil {
            doPauseAudio()
            doPausePlayer()
        }
        if audioRecorder != nil {
            doStopRecording()
            setupRecorder()
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
            //    try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatLinearPCM),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: fileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                self.recorderState = .Ready
            }
            catch let error {
                recorderState = .error(error)
            }
        }
        else {
            recorderState = .Failed("Don't have access to use your microphone.")
        }
    }
    
    @objc  func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            currentTimeInterval = currentTimeInterval + 0.01
            //let hr = Int((currentTimeInterval / 60) / 60)
            let min = Int(currentTimeInterval / 60)
            let sec = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            self.totalRecordedTime = sec
            //let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            delegate?.agAudioRecorder(self, currentTime: currentTimeInterval, formattedString: totalTimeString)
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder?.stop()
            meterTimer?.invalidate()
            recorderState = .Finish
        }
        else {
            recorderState = .Failed("Recording failed.")
        }
    }
    
    func preparePlay() {
        do {
            if self.filename != "" {
                audioPlayer = try AVAudioPlayer(contentsOf: fileUrl())
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                if self.isPause {
                    recorderState = .Pause
                }else {
                    recorderState = .Ready
                }
            }
        }
        catch {
            recorderState = .error(error)
        }
    }
    
    func doRecord() {
        self.check_record_permission()
        if !isAudioRecordingGranted {
            return
        }
        if audioRecorder == nil {
            setupRecorder()
        }
        if audioRecorder.isRecording {
            meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            RunLoop.main.add(meterTimer, forMode: .common)
            recorderState = .Recording
            self.isPause = false
        }else {
            audioRecorder.record()
            if !self.isPause {
                currentTimeInterval = 0.0
            }
            meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            RunLoop.main.add(meterTimer, forMode: .common)
            recorderState = .Recording
            self.isPause = false
        }
    }
    
    func doStopRecording() {
        guard audioRecorder != nil else {
            return
        }
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            finishAudioRecording(success: true)
        } catch {
            recorderState = .error(error)
        }
    }
    
    func doPlay() {
        self.isPauseAudioPlayer = false
        if audioPlayer == nil {
            self.preparePlay()
        }
        if audioPlayer.isPlaying {
            doPausePlayer()
        }else{
            if FileManager.default.fileExists(atPath: fileUrl().path) {
                preparePlay()
                audioPlayer.play()
                if self.audioPlayerSeekTime != 0.0  {
                    self.audioPlayer.currentTime = self.audioPlayerSeekTime
                }
                recorderState = .Play
            }
            else {
                recorderState = .Failed("Audio file is missing.")
            }
        }
    }
    
    func doPauseAudio() {
        self.isPause = true
        if audioRecorder != nil, audioRecorder.isRecording {
            meterTimer.invalidate()
            self.audioRecorder.pause()
        }
        recorderState = .Pause
    }
    
    func doPausePlayer(){
        guard audioPlayer != nil else {
            return
        }
        if (audioPlayer.isPlaying){
            self.isPauseAudioPlayer = true
            audioPlayer.pause()
            self.resetSlider()
        }
    }
    
    func doResetRecording() {
        audioRecorder?.stop()
        meterTimer?.invalidate()
        meterTimer = nil
        currentTimeInterval=0.0
        recorderState = .Finish
        self.audioRecorder = nil
        self.doPausePlayer()
        self.filename = ""
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        
    }
    
    func doHanldeProgressSliderTime(sender:UISlider!)   {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        let seekTime:TimeInterval = TimeInterval(sender!.value)
        self.audioPlayer?.stop()
        self.audioPlayer?.currentTime = seekTime
        self.audioPlayerSeekTime = seekTime
        if (!self.isPauseAudioPlayer){
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
            self.manageSliderTimer()
        }
    }
    
    func configureSlider(slider:UISlider){
        self.progressSlider = slider
        self.progressSlider!.value = 0.0
    }
    
    func manageSliderTimer(){
        self.progressSlider?.maximumValue = Float(self.audioPlayer.duration)
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        RunLoop.main.add(self.progressTimer!, forMode: .common)
    }
    
    func resetSlider(){
        if !self.audioCheck {
            self.audioPlayerSeekTime = self.audioPlayer.currentTime
            self.progressTimer?.invalidate()
            self.progressTimer = nil
        }
    }
    
    @objc func updateSlider(){
        let normalizedTime = Float(self.audioPlayer.currentTime)
        self.progressSlider!.value = normalizedTime
        let timeLeft:Int = Int(self.audioPlayer.duration) - Int(self.audioPlayer.currentTime)
        delegate?.agPlayerTimerDelegate(timeLeft: self.getStringTimer(value: timeLeft))
    }
    
    func getStringTimer(value:Int)->String{
        let totalSeconds:Int = value
        let hours: Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int(totalSeconds % 60)
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPauseAudioPlayer = true
        delegate?.agPlayerFinishedPlaying()
    }
}
