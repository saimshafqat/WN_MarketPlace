//
//  AudioView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class AudioView: ParentFeedView {
    var xqAudioPlayer:XQAudioPlayer!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var speechTxtView: UITextView!
    @IBOutlet weak var origTransBtn: UIButton!
    var postFile:PostFile?
    
    override func awakeFromNib() {
        self.xqAudioPlayer = self.getAudioPlayerView()
        self.bgView.addSubview(self.xqAudioPlayer)
        self.xqAudioPlayer.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
    func getAudioPlayerView()-> XQAudioPlayer   {
        let audioPlayer = Bundle.main.loadNibNamed(Const.XQAudioPlayer, owner: self, options: nil)?.first as! XQAudioPlayer
        return audioPlayer
    }
    
    func manageAudio(postObj: PostFile) {
        self.postFile = postObj
        self.manageAudioText(postObj: postObj)
         self.origTransBtn.isHidden = true
        if let convertedUrl = postObj.filetranslationlink {
            self.xqAudioPlayer.config(urlString: convertedUrl)
             self.origTransBtn.isHidden = false
        }else {
            self.xqAudioPlayer.config(urlString:postObj.filePath ?? "")
        }
        self.xqAudioPlayer.manageProgressUI()
    }
    
    func manageAudioText(postObj:PostFile, isShowOrig:Bool = false) {
        let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
        if let contentLangCode = postObj.orignalLanguageID {
            if (langCode == contentLangCode) || isShowOrig {
                self.speechTxtView.text = postObj.speechToText
            }else {
                self.speechTxtView.text = postObj.SpeechToTextTranslated
            }
        }
        if self.speechTxtView.text != nil {
            let langDirection = SharedManager.shared.detectedLangauge(for: self.speechTxtView.text!) ?? "left"
            (langDirection == "right") ? (self.speechTxtView.textAlignment = NSTextAlignment.right): (self.speechTxtView.textAlignment = NSTextAlignment.left)
        }
    }
    
    func manageAudioToggle(isOrig:Bool) {
        let orignalLink = self.postFile?.filePath
        let translatedLink = self.postFile?.filetranslationlink
        if isOrig {
            self.manageAudioText(postObj: self.postFile!, isShowOrig: true)
            self.xqAudioPlayer.config(urlString: orignalLink!)
        }else {
            self.manageAudioText(postObj: self.postFile!, isShowOrig: false)
            self.xqAudioPlayer.config(urlString: translatedLink!)
        }
    }
    
    @IBAction func origTransBtnClicked(_ sender: Any) {
        self.xqAudioPlayer.resetXQPlayer()
        if self.origTransBtn.isSelected {
            self.manageAudioToggle(isOrig: false)
        }else {
            self.manageAudioToggle(isOrig: true)
        }
        self.origTransBtn.isSelected = !self.origTransBtn.isSelected
    }
}
