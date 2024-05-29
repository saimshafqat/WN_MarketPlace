//
//  NewTextSharedCell.swift
//  WorldNoor
//
//  Created by apple on 11/15/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewTextSharedCell : UITableViewCell {
    @IBOutlet var lblMain : UILabel!
    
    @IBOutlet var btnShowOriginal : UIButton!
    @IBOutlet var btnSpeaker : UIButton!
    
    var feedObj : FeedData!
    var cellDelegate : ReloadDelegate!
    
    func reloadHeaderData(){
        self.lblMain.rotateForTextAligment()
        self.btnSpeaker.rotateForTextAligment()
        self.btnShowOriginal.rotateForTextAligment()
        
        
        self.btnShowOriginal.isHidden = true
        if SharedManager.shared.isTransCalled {
            self.lblMain.text = self.feedObj?.orignalBody
            self.btnShowOriginal.isSelected = true
            self.btnShowOriginal.isHidden = false
        }else {
            self.lblMain.text = self.feedObj?.body
        }
        
        self.btnSpeaker.isHidden = true
        if self.lblMain.text != nil {
            self.btnSpeaker.isHidden = self.lblMain.text!.count > 0 ? false : true
        }
        btnSpeaker.setImage(UIImage(named: "speakerOff"), for: .normal)
        btnSpeaker.setImage(UIImage(named: "speakerOn"), for: .selected)
//        SpeechManager.shared.speechSynthesizerDelegate = self
        if self.feedObj.language?.languageName == SharedManager.shared.getLang() {
            self.btnShowOriginal.isHidden = true
        }else {
            self.btnShowOriginal.isHidden = false
            if self.feedObj.language != nil {
                if let langName = self.feedObj.language?.languageName as? String {
                    self.lblMain.rotateForTextAligment(languageMain: langName)
                }
            }
        }
    }
    
    @IBAction func speakerAction(sender : UIButton){
        if self.lblMain.text == SpeechManager.shared.speechText && SpeechManager.shared.isSpeaking {
            SpeechManager.shared.pauseSpeaking()
            btnSpeaker.isSelected = false
        } else if self.lblMain.text == SpeechManager.shared.speechText && SpeechManager.shared.speechSynthesizer.isPaused {
            btnSpeaker.isSelected = true
            SpeechManager.shared.continueSpeaking()
        } else {
            if self.lblMain.text!.count > 0 {
                SpeechManager.shared.textToSpeech(message:self.lblMain.text!)
                btnSpeaker.isSelected = true
            }
        }
    }
    
    @IBAction func translateAction(sender : UIButton){
        
        self.btnShowOriginal.isSelected = !self.btnShowOriginal.isSelected
        if self.btnShowOriginal.isSelected {
            self.lblMain.text = self.feedObj?.orignalBody
        }else {
            self.lblMain.text = self.feedObj?.body
            
        }
        
    }
    
    
}
//extension NewTextSharedCell : SpeechManagerSynthesizerDelegate {
//    func speechDidFinish() {
//        if self.lblMain.text != "Loading..." {
//            cellDelegate.reloadRow()
//        }
//    }
//}
