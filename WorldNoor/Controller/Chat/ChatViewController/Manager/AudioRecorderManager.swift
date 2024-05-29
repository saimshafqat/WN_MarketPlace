////
////  AudioRecorderManager.swift
////  WorldNoor
////
////  Created by Raza najam on 12/24/19.
////  Copyright © 2019 Raza najam. All rights reserved.
////
//
//import UIKit
//
//class AudioRecorderManager: NSObject {
//    var chatController:ChatViewController?
//    var audioRecorderObj:AudioRecorder? = nil
//    
//    override init() {
//        super.init()
//    }
//}
//
//extension AudioRecorderManager:AGAudioRecorderDelegate {
////    func manageAudioRecorder(){
////        self.chatController!.audioOptionView.isHidden = true
////        self.chatController!.playAudioBtn.isSelected = false
////        self.chatController!.progressSlider.isHidden = true
////        self.chatController!.commentPlayerTimeLbl.isHidden = true
////        self.chatController!.recordBtn.isSelected = false
////        self.chatController!.stopAudioBtn.isSelected = false
////        self.chatController!.audioTimerLbl.text = "00:00"
////        self.audioRecorderObj = AudioRecorder(withFileName: "AudioRecordingInChat")
////        self.chatController!.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
////        self.audioRecorderObj?.delegate = self
////        self.chatController!.progressSlider.minimumValue = 0.0
////        self.chatController!.progressSlider.value = 0.0
////        self.chatController?.progressSlider.thumbTintColor = UIColor.chatThumbColor
////        self.chatController?.progressSlider.minimumTrackTintColor = UIColor.chatThumbColor
////    }
//    
////    func micButtonClicked(sender:UIButton)    {
////        self.chatController!.audioOptionView.isHidden = !self.chatController!.audioOptionView.isHidden
////    }
//    
//    func progressValueChanged(_ sender: Any) {
//        self.audioRecorderObj?.doHanldeProgressSliderTime(sender: sender as? UISlider)
//    }
//    
////    func audioCancelBtnClicked(_ sender: Any) {
////        self.chatController!.audioOptionView.isHidden = true
////        self.audioRecorderObj?.doResetRecording()
////        self.chatController!.stopAudioBtn.isSelected = false
////        self.chatController!.playAudioBtn.isSelected = false
////        self.chatController!.recordBtn.isSelected = false
////        self.chatController!.audioTimerLbl.text = "00:00"
////        self.chatController!.audioTimerLbl.isHidden = false
////        self.chatController!.progressSlider.isHidden = true
////    }
//    
//    func audioPauseBtnClicked(_ sender: Any) {
//        self.audioRecorderObj?.doPauseAudio()
//        self.chatController!.progressSlider.isHidden = true
//        self.chatController!.commentPlayerTimeLbl.isHidden = true
//    }
//    
//    func audioRecordBtnClicked(_ sender: Any) {
//        self.audioRecorderObj?.check_record_permission()
//        if self.audioRecorderObj!.isAudioRecordingGranted {
//            if self.chatController!.recordBtn.isSelected {
//                self.chatController!.audioTimerLbl.isHidden = false
//                self.audioPauseBtnClicked(UIButton())
//                self.chatController!.recordBtn.isSelected = false
//                self.chatController!.progressSlider.isHidden = true
//                self.chatController!.commentPlayerTimeLbl.isHidden = true
//            }else {
//                self.chatController!.audioTimerLbl.isHidden = false
//                self.audioRecorderObj?.filename = "TestingFile"
//                self.audioRecorderObj?.doRecord()
//                self.chatController!.progressSlider.isHidden = true
//                self.chatController!.commentPlayerTimeLbl.isHidden = true
//                self.chatController!.playAudioBtn.isSelected = false
//                self.chatController!.recordBtn.isSelected = true
//            }
//            self.chatController!.stopAudioBtn.isSelected = true
//        }
//    }
//    
//    func audioPlayBtnClicked(_ sender: Any) {
//        if self.chatController!.playAudioBtn.isSelected == false {
//            return
//        }
//        if (self.audioRecorderObj?.audioRecorder.isRecording)! {
//            self.chatController!.audioTimerLbl.isHidden = true
//            self.chatController!.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
//        }else {
//            if self.chatController!.playAudioBtn.isSelected {
//                self.chatController!.audioTimerLbl.isHidden = true
//                if self.chatController!.playAudioBtn.tag == 20 {
//                    self.chatController!.playAudioBtn.tag = 21
//                    self.audioRecorderObj?.doPlay()
//                    self.chatController!.playAudioBtn.setImage(UIImage(named: "pause-blue"), for: UIControl.State.selected)
//                    self.audioRecorderObj?.manageSliderTimer()
//                }else {
//                    self.audioRecorderObj?.resetSlider()
//                    self.chatController!.playAudioBtn.tag = 20
//                    self.chatController!.playAudioBtn.setImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
//                    self.audioRecorderObj?.doPausePlayer()
//                }
//            }
//        }
//    }
//    
//    func audioStopBtnClicked(_ sender: Any) {
//        if self.chatController!.stopAudioBtn.isSelected {
//            self.audioRecorderObj?.doStopRecording()
//            self.chatController!.stopAudioBtn.isSelected = false
//            self.chatController!.playAudioBtn.isSelected = true
//            self.chatController!.recordBtn.isSelected = false
//            self.chatController!.playAudioBtn.tag = 20
//            self.chatController!.audioTimerLbl.isHidden = true
//            self.chatController!.progressSlider.isHidden = false
//            self.chatController!.commentPlayerTimeLbl.isHidden = false
//            self.audioRecorderObj?.configureSlider(slider: self.chatController!.progressSlider)
//            self.chatController!.playAudioBtn.setImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
//        }
//    }
//    
//    func agPlayerTimerDelegate(timeLeft:String){
//        self.chatController!.commentPlayerTimeLbl.text = timeLeft
//    }
//    
//    func agPlayerFinishedPlaying() {
//        self.chatController!.playAudioBtn.tag = 20
//        self.audioRecorderObj?.resetSlider()
//        self.chatController!.playAudioBtn.setImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
//    }
//    
//    func agAudioRecorder(_ recorder: AudioRecorder, withStates state: AGAudioRecorderState) {
//        
//    }
//    
//    func agAudioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
//        self.chatController!.audioTimerLbl.text = formattedString
//    }
//
//    func resetAudioRecorderUI(){
//        self.chatController!.audioOptionView.isHidden = true
//        self.chatController!.playAudioBtn.isSelected = false
//        self.chatController!.progressSlider.isHidden = true
//        self.chatController!.commentPlayerTimeLbl.isHidden = true
//        self.chatController!.recordBtn.isSelected = false
//        self.chatController!.stopAudioBtn.isSelected = false
//        self.chatController!.audioTimerLbl.text = "00:00"
//        self.chatController!.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
//        self.chatController!.progressSlider.minimumValue = 0.0
//        self.chatController!.progressSlider.value = 0.0
//    }
//}
