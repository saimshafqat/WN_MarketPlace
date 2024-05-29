//
//  AudioRecordVC.swift
//  WorldNoor
//
//  Created by apple on 10/5/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation
import SwiftSiriWaveformView

class AudioRecordVC: UIViewController {
    
    @IBOutlet weak var recordingAnimationView: SwiftSiriWaveformView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var runningAverage:CGFloat = 0
    var sampleCount:CGFloat = 0
    var powerMin:CGFloat = 100
    var meterTimer: Timer! = nil
    var currentTimeInterval: TimeInterval = 0.0
    let session = AVAudioSession.sharedInstance()
    @IBOutlet var viewPlay : UIView!
    @IBOutlet var viewRecord : UIView!
    @IBOutlet var lblAudioTime : UILabel!
    @IBOutlet var lblRecordTime : UILabel!
    @IBOutlet var viewBG : UIView!
    var player: AVPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    @IBOutlet var imgViewBtnPlay : UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet var imgViewPlay : UIImageView!
    var isRecord : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordingAnimationView.amplitude = 0.0
        
        self.viewBG.roundCornersWith(corners: [.layerMinXMinYCorner , .layerMaxXMinYCorner], cornerRadius: 15.0)
        self.viewPlay.isHidden = true
        self.viewRecord.isHidden = false
        imgViewBtnPlay.image = UIImage.init(named: "chatRecordButton.png")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.lblRecordTime.text = "00:00"
        self.startRecord()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        finishRecording(success: false)
        self.stopPlayer()
    }
    
    @objc func audioPlayerEnd() {
        stopPlayer()
    }
    
    func stopPlayer() {
        if let play = player {
            play.pause()
            player = nil
            slider.value = 0
            self.imgViewPlay.image = UIImage.init(named: "play-blue.png")
        } else {

        }
    }
    
    @IBAction func reRecordAction(sender : UIButton){
        self.viewRecord.isHidden = false
        self.viewPlay.isHidden = true
        
        self.lblRecordTime.text = "00:00"
        self.startRecord()
        self.isRecord = true
        currentTimeInterval = 0.0
        
        
    }
    
    @IBAction func recordAction(sender : UIButton){
        
        if self.audioRecorder != nil {
            finishRecording(success: false)
            return
        }
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecord()
                    } else {

                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    
    @IBAction func pauseRecord(sender : UIButton){
        if audioRecorder == nil {
            return
        }
        
        if self.isRecord {
            audioRecorder.pause()
            imgViewBtnPlay.image = UIImage.init(named: "play-red.png")
        }else {
            audioRecorder.record()
            refreshAudioView()
            imgViewBtnPlay.image = UIImage.init(named: "chatRecordButton.png")
        }
        
        self.isRecord = !self.isRecord
    }
    
    func startRecord(){
        deleteAudioFile()
        refreshAudioView()
        meterTimer =  Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:#selector(updateAudioMeter(timer:)), userInfo:nil, repeats:true)
        RunLoop.current.add(meterTimer, forMode: .common)
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey:AVAudioQuality.low.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.updateMeters()
            
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func finishRecording(success: Bool) {
        
        self.imgViewPlay.image = UIImage.init(named: "play-blue.png")
        if audioRecorder.isRecording {
            audioRecorder.stop()
        }
        recordingAnimationView.amplitude = 0.0
        meterTimer.invalidate()
        audioRecorder = nil
        self.viewPlay.isHidden = false
        self.viewRecord.isHidden = true
        
        slider.maximumValue = Float(currentTimeInterval)
        slider.minimumValue = 0.0
        slider.value = 0.0
        
        
    }
    
    func refreshAudioView() {
        
        let avgSample = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
        let sample = (51 + CGFloat(avgSample < -50 ? -50:avgSample ))/20
        runningAverage = ((runningAverage * sampleCount) + sample ) / (sampleCount + 1)
        sampleCount += 1
        
        var power = 1.75 * sample / runningAverage //- 0.25           // Normalized power
        
        if powerMin > power  { powerMin = power }
        
        power = power - powerMin                                   // Min normalization
        power = (power > 2 ? 2:power)                              // Saturate at max 2
        power = (power + recordingAnimationView.amplitude * 3) / 4 // Smoothness
        
        recordingAnimationView.amplitude = power
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) { [weak self] in
            if self?.audioRecorder?.isRecording ?? false {
                self?.refreshAudioView()
            }
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            currentTimeInterval = currentTimeInterval + 0.01
            let min = Int(currentTimeInterval / 60)
            let sec = Int(currentTimeInterval.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            self.lblRecordTime.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    @IBAction func playAction(sender : UIButton){
        setupAVPlayer()
    }
    
    @IBAction func submitAudio(sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}



extension AudioRecordVC: AVAudioRecorderDelegate  {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        LogClass.debugLog("Error while recording audio \(error!.localizedDescription)")
    }
    
    
    @IBAction func actionSlider(_ sender: UISlider) {
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        if player?.rate == nil {
            player?.play()
        }
    }
    
    func setupAVPlayer() {
        self.switchToSpeakerAudio()
        if player?.rate != nil {
            if player?.timeControlStatus == .playing {
                player?.pause()
                self.imgViewPlay.image = UIImage.init(named: "play-blue.png")
            } else if player?.timeControlStatus == .paused {
                player?.play()
                self.imgViewPlay.image = UIImage.init(named: "pause-blue.png")
            }
        } else {
            self.imgViewPlay.image = UIImage.init(named: "pause-blue.png")
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
            let playerItem = CachingPlayerItem(url: audioFilename)
            player = AVPlayer(playerItem: playerItem)
            player?.automaticallyWaitsToMinimizeStalling = false
            player?.play()
            slider.maximumValue = Float(currentTimeInterval)
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: {[weak self] (cmTime) in
                guard let self = self else {return}
                if self.player?.currentItem?.status == .readyToPlay {
                    let time: Float64 = CMTimeGetSeconds((self.player?.currentTime())!)
                    self.slider.value = Float(time)
                    self.lblAudioTime.text = self.player?.currentTime().durationText
                }
            })
        }
    }
    
    func switchToSpeakerAudio() {
        do {
            if AVAudioSession.isHeadphonesConnected {
                try? session.overrideOutputAudioPort(.none)
            } else {
                try? session.overrideOutputAudioPort(.speaker)
            }
            try audioSession.setCategory(.playback)
            try session.setActive(true)
            
        } catch let error as NSError {
            LogClass.debugLog("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func deleteAudioFile()  {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        FileManager.default.removeFileFromDocumentsDirectory(fileUrl: audioFilename)
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
}
