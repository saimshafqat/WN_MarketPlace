//
//  AudioRecordViewController.swift
//  WorldNoor
//
//  Created by Lucky on 29/10/2019.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioDelegate {
    func audioURL(text: String)
}

class AudioRecordViewController: UIViewController , AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var delegate: AudioDelegate?
    var isRecording:Bool=false
    var isRecorded:Bool=false
    
    @IBOutlet var view_Play: UIView!
    @IBOutlet var view_Record: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playAudioBtn: UIButton!
    @IBOutlet var recordAgainButton : UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var maxValueLabel: UILabel!
    @IBOutlet weak var pauseResumeBtn: UIButton!
    @IBOutlet var sliderPlay : UISlider!
    @IBOutlet var playerTimerLbl : UILabel!

    @IBOutlet weak var stopPlayerBtn: UIButton!
    @IBOutlet weak var stopRecordBtn: UIButton!
    @IBOutlet weak var pausePlayerBtn: UIButton!
    
    var meterTimer: Timer!
    var soundFileURL: URL!
    var playerCurrentSeek = 0
    var timerValue = 0
    var timeinMillis:Int64 = 0
    var fileName = "recording.wav"
    var timerMain : Timer!
    var updateSliderTimer : Timer!
    var audioRecorder:AudioRecorder? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_Record.isHidden=false
        self.view_Play.isHidden=true
        timeinMillis=getCurrentMillis()
        fileName=String(format:"rec_%d.wav",timeinMillis)
        self.audioRecorder = AudioRecorder(withFileName: fileName)
        self.audioRecorder!.audioCheck = true
        self.audioRecorder?.delegate=self
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let slider = updateSliderTimer {
            slider.invalidate()
//            slider = nil
        }
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    @IBAction func slidervalueUpdate(_ sender: UISlider) {
        updateSliderTimer.invalidate()
        self.audioRecorder?.audioPlayer.stop()
        self.audioRecorder!.audioPlayer.currentTime = TimeInterval(sender.value)
        self.audioRecorder!.audioPlayer.prepareToPlay()
        self.audioRecorder!.audioPlayer.play()
//      updateSliderTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: Selector(("updateSlider")), userInfo: nil, repeats: true)
        updateSliderTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(AudioRecorder.updateSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        
        if let recorder = self.recorder {
            if recorder.isRecording {
                
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                timerValue = sec
                let str = String(format: "%02d:%02d", min, sec)
                statusLabel.text = str
                recorder.updateMeters()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
    }
    
    @IBAction func RecordAgain(sender : UIButton){
        //self.removeFile(name: fileName)
        self.audioRecorder?.doResetRecording()
        self.playAudioBtn.tag=10
        self.doneBtn.isHidden=true
        self.statusLabel.text="00:00"
        self.recordBtn.setBackgroundImage(UIImage(named: "record-blue"), for: .normal)
        self.pauseResumeBtn.setBackgroundImage(UIImage(named: "pause-blue"), for: .normal)
        isRecorded=false
        self.view_Play.isHidden=true
        self.view_Record.isHidden=false
        self.pauseResumeBtn.isHidden=true
        self.recordAgainButton.isHidden=true
    }
}

// MARK: AVAudioRecorderDelegate

//extension UITapGestureRecognizer {
   
//   func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
//       guard let attributedText = label.attributedText else { return false }
//
//       let mutableStr = NSMutableAttributedString.init(attributedString: attributedText)
//       mutableStr.addAttributes([NSAttributedString.Key.font : label.font!], range: NSRange.init(location: 0, length: attributedText.length))
//
//       // If the label have text alignment. Delete this code if label have a default (left) aligment. Possible to add the attribute in previous adding.
//       let paragraphStyle = NSMutableParagraphStyle()
//       paragraphStyle.alignment = .center
//       mutableStr.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
//
//       // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
//       let layoutManager = NSLayoutManager()
//       let textContainer = NSTextContainer(size: CGSize.zero)
//       let textStorage = NSTextStorage(attributedString: mutableStr)
//
//       // Configure layoutManager and textStorage
//       layoutManager.addTextContainer(textContainer)
//       textStorage.addLayoutManager(layoutManager)
//
//       // Configure textContainer
//       textContainer.lineFragmentPadding = 0.0
//       textContainer.lineBreakMode = label.lineBreakMode
//       textContainer.maximumNumberOfLines = label.numberOfLines
//       let labelSize = label.bounds.size
//       textContainer.size = labelSize
//
//       // Find the tapped character location and compare it to the specified range
//       let locationOfTouchInLabel = self.location(in: label)
//       let textBoundingBox = layoutManager.usedRect(for: textContainer)
//       let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
//                                         y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
//       let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
//                                                    y: locationOfTouchInLabel.y - textContainerOffset.y);
//       let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//       return NSLocationInRange(indexOfCharacter, targetRange)
//   }
   
//}

extension AudioRecordViewController:AGAudioRecorderDelegate {
    func agPlayerTimerDelegate(timeLeft: String) {
    }
    
    func agPlayerFinishedPlaying() {
        self.audioRecorder?.doPausePlayer()
        self.updateSliderTimer.invalidate()
        self.sliderPlay.value = self.sliderPlay.minimumValue
        self.playAudioBtn.tag = 10        
        self.playAudioBtn.setBackgroundImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
        self.pausePlayerBtn.setBackgroundImage(UIImage(named: "pause-gray"), for: UIControl.State.normal)
        self.stopPlayerBtn.setBackgroundImage(UIImage(named: "stop-gray"), for: UIControl.State.normal)
    }
        
    func agAudioRecorder(_ recorder: AudioRecorder, withStates state: AGAudioRecorderState) {
        
    }
    
    func agAudioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
        self.statusLabel.isHidden=false
        self.statusLabel.text = formattedString
        let double=Float(timeInterval)
        let intValue=ceil(double)
        timerValue=Int(intValue)
        
    }
    
    @IBAction func cancelAction(sender : UIButton){
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func startRecording(sender : UIButton){
        self.audioRecorder?.filename=fileName
        if isRecorded==false {
            self.audioRecorder?.doRecord()
            isRecorded=true
            self.recordAgainButton.isHidden=false
            self.pauseResumeBtn.isHidden=false
            self.recordBtn.setBackgroundImage(UIImage(named: "stop-blue"), for: .normal)
        }
        else
        {
            self.recordBtn.setBackgroundImage(UIImage(named: "record-blue"), for: .normal)
            self.audioRecorder?.doStopRecording()
            self.doneBtn.isHidden=false
            self.view_Record.isHidden=true
            self.view_Play.isHidden=false
        }
    }
    @IBAction func playAction(sender : UIButton){
        if self.playAudioBtn.tag==10 {
            self.playAudioBtn.tag = 11
            self.playAudioBtn.setBackgroundImage(UIImage(named: "play-gray"), for: .normal)
            self.pausePlayerBtn.setBackgroundImage(UIImage(named: "pause-blue"), for: .normal)
            self.stopPlayerBtn.setBackgroundImage(UIImage(named: "stop-blue"), for: .normal)
            self.audioRecorder?.doPlay()
            self.sliderPlay.maximumValue = Float(self.timerValue)
            updateSliderTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: Selector(("updateSlider")), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stopRecording(_ sender: Any)
    {
        self.audioRecorder?.doStopRecording()
        self.playAudioBtn.isHidden=false
        self.recordAgainButton.isHidden=false
        self.sliderPlay.isHidden=false
        self.statusLabel.isHidden=true
        
    }
    
    @IBAction func DoneAction(sender : UIButton){
        if delegate != nil {
            self.delegate?.audioURL(text: (self.audioRecorder?.fileUrl().absoluteString)!)
        }
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func sliderValueChange(sliderMain : UISlider){
    
    }
    
    @IBAction func sliderValueDown(sliderMain : UISlider){

    }
    
    @objc func updateSlider(){
        if self.audioRecorder?.audioPlayer != nil {
            self.sliderPlay.value = Float((self.audioRecorder?.audioPlayer.currentTime)!)
            let timeLeft:Int = Int(self.audioRecorder!.audioPlayer.duration) - Int(self.audioRecorder!.audioPlayer.currentTime)
            self.playerTimerLbl.text = self.audioRecorder?.getStringTimer(value:timeLeft)
        }
    }
  
    @IBAction func pauseResumeRecording(_ sender: Any) {
        if self.audioRecorder!.isPause
        {
            pauseResumeBtn.setBackgroundImage(UIImage(named: "pause-blue"), for: .normal)
            self.audioRecorder?.doRecord()
        }
        else
        {
            pauseResumeBtn.setBackgroundImage(UIImage(named: "play-blue"), for: .normal)
            self.audioRecorder?.doPauseAudio()
        }
    }
    
    @IBAction func pausePlayer(_ sender: Any) {
        if playAudioBtn.tag==11 {
            self.audioRecorder?.doPausePlayer()
            self.updateSliderTimer.invalidate()
            self.sliderPlay.value = Float((self.audioRecorder?.audioPlayer.currentTime)!)
            self.playAudioBtn.setBackgroundImage(UIImage(named: "play-blue"), for: .normal)
            self.pausePlayerBtn.setBackgroundImage(UIImage(named: "pause-gray"), for: .normal)
            self.stopPlayerBtn.setBackgroundImage(UIImage(named: "stop-gray"), for: .normal)
            self.playAudioBtn.tag=10
        }
    }
    
    @IBAction func stopPlayer(_ sender: Any)
    {
        if playAudioBtn.tag==11 {
            self.audioRecorder?.doPausePlayer()
            self.updateSliderTimer.invalidate()
            self.sliderPlay.value = self.sliderPlay.minimumValue
            self.playAudioBtn.setBackgroundImage(UIImage(named: "play-blue"), for: .normal)
            self.pausePlayerBtn.setBackgroundImage(UIImage(named: "pause-gray"), for: .normal)
            self.stopPlayerBtn.setBackgroundImage(UIImage(named: "stop-gray"), for: .normal)
            self.playAudioBtn.tag=10
        }
    }
}

// MARK: AVAudioPlayerDelegate


func changeName(fileName : String , newName : String){
    do {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentDirectory = URL(fileURLWithPath: path)
        let originPath = documentDirectory.appendingPathComponent(fileName)
        let destinationPath = documentDirectory.appendingPathComponent(newName)
        try FileManager.default.moveItem(at: originPath, to: destinationPath)
    } catch {
        
    }
}

extension UIViewController {

    
    func EmailValidationOnstring(strEmail  : String) -> Bool  {
        
        if strEmail.isEmpty  {
            return false
        }else {
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: strEmail)

        }
    }
    
    func addBottomSpace(tbleViewMain : UITableView){
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tbleViewMain.contentInset = insets
    }
    
    func ChangeTabbarText() {
        if self.tabBarController != nil {
            self.tabBarController!.tabBar.items![0].title = "Home".localized()
            self.tabBarController!.tabBar.items![1].title = "Friends".localized()
            self.tabBarController!.tabBar.items![2].title = "watch".localized()
            self.tabBarController!.tabBar.items![3].title = "Profile".localized()
            self.tabBarController!.tabBar.items![4].title = "Menu".localized()
           
            //            let viewAll = self.tabBarController?.orderedTabBarItemViews()
            
            //            let frameTab = (viewAll![2] as! UIView).frame
            //            let viewNew = UIView.init(frame:CGRect.init(x: -5, y:0, width: frameTab.size.width + 5, height: frameTab.size.height) )
            //
            //            let imgNew = UIImageView.init(frame:CGRect.init(x: 0, y:0, width: frameTab.size.width + 5, height: frameTab.size.height) )
            //            imgNew.image = UIImage.init(named: "NewsTabBG.png")
            //            imgNew.contentMode = .scaleAspectFill
            //            viewNew.addSubview(imgNew)
            //
            //            viewNew.backgroundColor = UIColor.yellow
            //            viewNew.isUserInteractionEnabled = false
            //            (viewAll![2] as! UIView).addSubview(viewNew)
            //            for indexObj in viewAll![2].subviews {
            //
            //                if indexObj.isKind(of: UIImageView.self) {
            //                    (indexObj as? UIImageView)?.image = UIImage.init(named: "WatchWhiteIcon")
            //                }
            //                if indexObj.isKind(of: UILabel.self) {
            //                    (indexObj as? UILabel)?.textColor = UIColor.white
            //                }
            //                viewAll![2].bringSubviewToFront(indexObj)
            //            }
         }
    }
    
    func SaveImage(imageName : String , imageMain : UIImage){
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           // choose a name for your image
           let fileName = imageName
           // create the destination file url to save your image
           let fileURL = documentsDirectory.appendingPathComponent(fileName)
           // get your UIImage jpeg data representation and check if the destination file url already exists
           if let data = imageMain.jpegData(compressionQuality:  1.0),
               !FileManager.default.fileExists(atPath: fileURL.path) {
               do {
                   // writes the image data to disk
                   try data.write(to: fileURL)
               } catch {
                   
               }
           }
       }
       
       func loadImage(imageName : String) -> (UIImage,Bool) {
           let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
           let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
           let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
           if let dirPath          = paths.first
           {
               let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(imageName)
               let image    = UIImage(contentsOfFile: imageURL.path)
               if image == nil {
                   return (UIImage.init() , false)
               }else {
                   return (image! , true)
               }
               
               // Do whatever you want with the image
           }else {
               return (UIImage.init() , false)
           }
       }
    
    
    func removeAllfiles() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("diskCache")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
    func removeFile(name : String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        
        let filePath = "\(dirPath)/" + name
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            
        }
        }
    func savefileDocumentDirectory(name:String,image:UIImage)
    {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                try imageData.write(to: fileURL)
            }
        } catch {
            
        }
    }
}
