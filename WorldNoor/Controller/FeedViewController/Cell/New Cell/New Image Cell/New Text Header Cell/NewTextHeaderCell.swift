//
//  NewTextHeaderCell.swift
//  WorldNoor
//
//  Created by apple on 8/16/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import ActiveLabel

class NewTextHeaderCell : UITableViewCell {
    
    @IBOutlet var lblMain : ActiveLabel!
    
    @IBOutlet var lblShowMore : UILabel!
    
    @IBOutlet var viewLoading : UIView!
    
    @IBOutlet var btnShowOriginal : UIButton!
    @IBOutlet var btnSpeaker : UIButton!
    @IBOutlet var btnShowMore : UIButton!
    var numberOfLine = 3
    var feedObj : FeedData!
    var isFromWatch : Bool = false
    
    var isReload : Bool = true
    
    var cellDelegate : ReloadDelegate!
    
    var textArray = [String]()
    var urlArray = [String]()
    var fontArray = [UIFont]()
    var colorArray = [UIColor]()
    
    func reloadHeaderData(){
        
        self.lblMain.text = ""
//        SpeechManager.shared.speechSynthesizerDelegate = self
        btnSpeaker.setImage(UIImage(named: "speakerOff"), for: .normal)
        btnSpeaker.setImage(UIImage(named: "speakerOn"), for: .selected)
        self.lblMain.dynamicBodyRegular17WithoutClip()
        self.lblShowMore.dynamicBodyRegular17()
        self.btnShowOriginal.titleLabel?.dynamicBodyRegular17()
        if self.lblMain.text == SpeechManager.shared.speechText && SpeechManager.shared.isSpeaking {
            SpeechManager.shared.pauseSpeaking()
            btnSpeaker.isSelected = true
        }
        else {
            btnSpeaker.isSelected = false
        }
        
        lblMain.enabledTypes = [.url,.hashtag]
        lblMain.handleURLTap({ url in
            UIApplication.shared.open(url)
        })
        
        lblMain.handleHashtagTap { hashTag in
            let tagSection = HashTagVC.instantiate(fromAppStoryboard: .Shared)
            tagSection.Hashtags = hashTag
            UIApplication.topViewController()!.navigationController?.pushViewController(tagSection, animated: true)
        }
        
        self.viewLoading.isHidden = true
        
        self.btnShowOriginal.setTitle("View Translated".localized(), for: .selected)
        
        self.btnShowOriginal.isSelected = !self.feedObj.isTranslation
        
        self.btnShowOriginal.contentHorizontalAlignment = .center
        if self.feedObj.isExpand {
            self.lblMain.numberOfLines = 0
            self.lblShowMore.text = "Show Less".localized()
        }else {
            self.lblMain.numberOfLines = 3
            self.lblShowMore.text = "Show More".localized()
            self.lblMain.lineBreakMode = .byTruncatingTail
        }
        
        self.btnShowOriginal.isHidden = true
        if !SharedManager.shared.getTrsaltionLang() {
            self.btnShowOriginal.isHidden = false
            if SharedManager.shared.isTransCalled {
                if self.feedObj.isTranslation {
                    self.lblMain.text = self.feedObj?.orignalBody
                }else {
                    self.lblMain.text = self.feedObj?.body
                }
            }else {
                if self.feedObj.isTranslation {
                    self.lblMain.text = self.feedObj?.orignalBody
                }else {
                    self.lblMain.text = self.feedObj?.body
                }
            }
        }else {
            if self.feedObj.isTranslation {
                self.lblMain.text = self.feedObj?.orignalBody
            }else {
                self.lblMain.text = self.feedObj?.body
            }
        }
        
        if SharedManager.shared.checkLanguageAlignment() {
            self.lblMain.textAlignment = .right
        }else {
            self.lblMain.textAlignment = .left
        }
        self.lblMain.sizeToFit()
        
        if isFromWatch {
            self.contentView.rotateViewForLanguage()
            self.labelRotateCell(viewMain: self.lblMain)
            self.lblMain.rotateViewForLanguage()
            self.lblMain.rotateForTextAligment()
        }
        
       
        self.btnShowMore.isHidden = true
        self.lblShowMore.isHidden = true
        
        
        if self.lblMain.text != nil {
            if (self.lblMain.text ?? "").count > 0 {
                if self.lblMain.isTruncated || self.feedObj.isExpand {
                    self.btnShowMore.isHidden = false
                    self.lblShowMore.isHidden = false
                }
            }
            
        }
        
        
        
        if self.feedObj.language?.languageName == SharedManager.shared.getLang() {
            self.btnShowOriginal.isHidden = true
        } else {
            self.btnShowOriginal.isHidden = false
            
            if self.feedObj.language != nil {
                if let langName = self.feedObj.language?.languageName as? String {
                    self.lblMain.rotateForTextAligment(languageMain: langName)
                }
            }
        }
        self.isReload = false
        
        let langDirection = SharedManager.shared.detectedLangauge(for: self.lblMain.text ?? "")
        self.lblMain.textAlignment = NSTextAlignment.left
        if langDirection == "right" {
            self.lblMain.textAlignment = NSTextAlignment.right
        }
 
        

        
        let langCode = SharedManager.shared.detectedLangaugeCode(for: self.lblMain.text ?? "")
        if langCode == "ar" {
            self.lblMain.font = UIFont(name: "BahijTheSansArabicPlain", size: 13)
        }else {
            self.lblMain.font = UIFont.systemFont(ofSize: 15)
        }
        
    }
    
    
    func reloadLine(numberofLine : Int = 3){
        self.numberOfLine = numberofLine
    }
    
    @IBAction func speakerAction(sender : UIButton){
        if self.lblMain.text == SpeechManager.shared.speechText && SpeechManager.shared.isSpeaking {
            SpeechManager.shared.pauseSpeaking()
            btnSpeaker.isSelected = false
        } else if self.lblMain.text == SpeechManager.shared.speechText && SpeechManager.shared.speechSynthesizer.isPaused {
            btnSpeaker.isSelected = true
            SpeechManager.shared.continueSpeaking()
        } else {
            if (self.lblMain.text ?? "").count > 0 {
                btnSpeaker.isSelected = true
                SpeechManager.shared.textToSpeech(message:self.lblMain.text ?? "")
            }
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    @IBAction func translateAction(sender : UIButton){
        self.btnShowOriginal.isSelected = !self.btnShowOriginal.isSelected
        if self.feedObj.orignalBody == nil {
            self.getTranslation()
        }else if self.feedObj.orignalBody?.count == 0 {
            self.getTranslation()
        }
        self.feedObj.isTranslation = !self.btnShowOriginal.isSelected
        let langDirection = SharedManager.shared.detectedLangauge(for: self.lblMain.text ?? "")
        self.lblMain.textAlignment = NSTextAlignment.left
        if langDirection == "right" {
            self.lblMain.textAlignment = NSTextAlignment.right
        }
        guard let strValue = UserDefaults.standard.value(forKey: "Lang") as? String else {
            return
        }
        let langCode = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        if langCode == "ar" {
            self.lblMain.font = UIFont(name: "BahijTheSansArabicPlain", size: 13)
        }else {
            self.lblMain.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
    func getTranslation() {
        self.viewLoading.isHidden = false
        self.btnShowOriginal.isHidden = true
        var parameters = ["action": "post/translation/" + String(self.feedObj.postID!)]
        var langCode = "en"
        if UserDefaults.standard.value(forKey: "LangN") is String {
            for indexObj in SharedManager.shared.populateLangData() {
                if indexObj.languageName == UserDefaults.standard.value(forKey: "LangN") as! String {
                    langCode = indexObj.languageCode
                    break
                }
            }
        }else {
            if let langID = SharedManager.shared.userBasicInfo["language_id"] as? Int   {
                for indexObj in SharedManager.shared.populateLangData() {
                    if Int(indexObj.languageID) == langID {
                        langCode = indexObj.languageCode
                        UserDefaults.standard.set(indexObj.languageName, forKey: "LangN")
                        UserDefaults.standard.synchronize()
                        break
                    }
                }
            }
        }
        
        parameters["lang_code"] = langCode
        RequestManager.fetchDataGet(Completion: { response in
            self.viewLoading.isHidden = true
            self.btnShowOriginal.isHidden = false
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
                }
            case .success(let res):
                if res is Int {
                    //                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //                    SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let dataMain = res as? [String : Any] {
                    }else if let dataMain = res as? [[String : Any]] {
                        let mainData = dataMain[0]
                        if let stringValue = mainData["body"] as? String{
                            self.feedObj.orignalBody = stringValue
                            let langDirection = SharedManager.shared.detectedLangauge(for: self.lblMain.text ?? "")
                            self.lblMain.textAlignment = NSTextAlignment.left
                            if langDirection == "right" {
                                self.lblMain.textAlignment = NSTextAlignment.right
                            }
                        }
                        self.cellDelegate.reloadRow()
                    }
                }
            }
        }, param:parameters)
    }
    
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.lblMain.text else { return }
        for indexObj in self.urlArray {
            let conditionsRange = (text as NSString).range(of: indexObj)
            if gesture.didTapAttributedTextInLabel(label: self.lblMain, inRange: conditionsRange) {
                UIApplication.shared.open(URL.init(string: indexObj)!)
            }
        }
    }
    
    
    func getAttributedString(arrayText:[String]?, arrayColors:[UIColor]?, arrayFonts:[UIFont]?) -> NSMutableAttributedString {
        
        let finalAttributedString = NSMutableAttributedString()
        
        for i in 0 ..< (arrayText?.count)! {
            
            let attributes = [NSAttributedString.Key.foregroundColor: arrayColors?[i], NSAttributedString.Key.font: arrayFonts?[i]]
            let attributedStr = (NSAttributedString.init(string: arrayText?[i] ?? "", attributes: attributes as [NSAttributedString.Key : Any]))
            
            if i != 0 {
                
                finalAttributedString.append(NSAttributedString.init(string: " "))
            }
            
            finalAttributedString.append(attributedStr)
        }
        
        return finalAttributedString
    }
}

//extension NewTextHeaderCell : SpeechManagerSynthesizerDelegate {
//    func speechDidFinish() {
//        if self.lblMain.text != "Loading..." {
//            cellDelegate.reloadRow()
//        }
//    }
//}
extension UILabel {
    
    var isTruncated: Bool {
        
        guard let labelText = text else {
            return false
        }
        
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
        // Define a tolerance value to handle floating-point precision issues
        return labelTextSize.height > (bounds.size.height)
    }
    
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 4
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
