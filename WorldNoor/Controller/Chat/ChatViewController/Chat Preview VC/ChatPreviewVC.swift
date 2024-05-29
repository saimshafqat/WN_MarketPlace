//
//  ChatPreviewVC.swift
//  WorldNoor
//
//  Created by apple on 9/25/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

class ChatPreviewVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var videoPlay: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var langHeadingLbl: UILabel!
    @IBOutlet weak var langBtn: UIButton!
    @IBOutlet weak var viewVideo: UIView!
    
    @IBOutlet weak var viewAudio: UIView!
    @IBOutlet weak var langAudioLbl: UILabel!
    @IBOutlet weak var langHeadingAudioLbl: UILabel!
    @IBOutlet weak var btnAudioPlay: UIButton!
    @IBOutlet weak var btnAudioStop: UIButton!
    @IBOutlet weak var lblAudioTimer: UILabel!
    @IBOutlet weak var sliderAudio: UISlider!
    var audioPlayer = AVAudioPlayer()
    
    var sheetController = SheetViewController()
    
    var delegateChat : DelegateChatPreview!
    
    var dataMain = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.langLbl.text = SharedManager.shared.getLanguageName(id: SharedManager.shared.getCurrentLanguageID())
        self.langAudioLbl.text = ""
    }
    
    func reloadView(mainData : [String : Any]){
        dataMain = mainData
        
        self.videoPlay.isHidden = true
        self.viewVideo.isHidden = true
        self.viewAudio.isHidden = true
        
        if let type = mainData["Type"] as? String  {
            if type == FeedType.video.rawValue {
                self.viewVideo.isHidden = false
                self.langHeadingLbl.text = "Language of Video:".localized()
                if let imageMain = mainData["Image"] as? UIImage {
                    DispatchQueue.main.async {
                        self.imgView.image = imageMain
                        self.videoPlay.isHidden = false
                    }
                }
                
            }else if type == FeedType.audio.rawValue {
                self.viewAudio.isHidden = false
                self.langHeadingAudioLbl.text = ""
                
                let audioUrl = mainData["URL"] as? String
                
                self.btnAudioStop.isHidden = true
                self.btnAudioPlay.isHidden = false
                
                let pathURL = URL.init(string: audioUrl!)
                do {
                    
                    try audioPlayer = AVAudioPlayer(contentsOf: pathURL!)
                    
                } catch {
                    
                }
                
                var timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                self.sliderAudio.maximumValue = Float(audioPlayer.duration)
            }
        }
    }
    
    @IBAction func changeLanguageAction(sender : UIButton){
        self.langSelectionView()
        
    }
    
    func langSelectionView()    {
        let langController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "LanguageSelectionController") as! LanguageSelectionController
        langController.delegate = self
        self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(500)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        SharedManager.shared.feedRef!.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func closeChatPreview(sender : UIButton){
        self.view.removeFromSuperview()
        delegateChat.delegateRemoveView(dataMain: dataMain, isDelete: true)
    }
}

extension ChatPreviewVC {
    @IBAction func playAudioAction(sender : UIButton){
        self.btnAudioStop.isHidden = false
        self.btnAudioPlay.isHidden = true
        
        audioPlayer.play()
        updateTime()
    }
    
    @IBAction func stopAudioAction(sender : UIButton){
        self.btnAudioStop.isHidden = true
        self.btnAudioPlay.isHidden = false
        
        audioPlayer.stop()
    }
    
    func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let duration = Int(audioPlayer.duration)
        let total = currentTime - duration
        let totalString = String(total)
        
        let minutes = currentTime/60
        let seconds = currentTime - minutes / 60
        
        self.lblAudioTimer.text = NSString(format: "%02d:%02d", minutes,seconds) as String
        
        if !audioPlayer.isPlaying {
            self.btnAudioPlay.isHidden = false
            self.btnAudioStop.isHidden = true
        }
    }
    
    @IBAction func scrubAudio(sender: AnyObject) {
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(self.sliderAudio.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @objc func updateSlider() {
        self.updateTime()
        self.sliderAudio.value = Float(audioPlayer.currentTime)
    }
    
}
extension ChatPreviewVC:LanguageSelectionDelegate {
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        
    }
    func lanaguageSelected(langObj: LanguageModel) {
        self.sheetController.closeSheet()
        
        self.langLbl.text = langObj.languageName
        self.langAudioLbl.text = ""
        var dataLang = [String : Any]()
        dataLang["LanguageID"] = langObj.languageID
        dataLang["LanguageName"] = langObj.languageName
        delegateChat.delegateChooseLanguage(dataMain: dataLang)
    }
}
