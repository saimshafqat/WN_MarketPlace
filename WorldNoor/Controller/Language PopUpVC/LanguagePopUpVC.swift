//
//  LanguagePopUpVC.swift
//  WorldNoor
//
//  Created by apple on 6/21/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import UIKit

class LanguagePopUpVC: UIView {

    @IBOutlet var switchMain : UISwitch!
    @IBOutlet var lblLanguageName : UILabel!
    @IBOutlet var lblAppLanguageName : UILabel!
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var selectedLangModel : LanguageModel!
    weak var parentView : UIViewController!
    var arrayLanguage = [String]()    
    var selectedLanguage = ""
    var selectedAppLanguage = ""
    
    
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    override func awakeFromNib() {
       
    }

    @IBAction func saveAciton(sender : UIButton){
        var isAuto = "0"
        if self.switchMain!.isOn {
            isAuto = "1"
        }
        
        if self.selectedLangModel != nil {
            if self.selectedLangModel?.languageID != "" {
                self.viewLanguageModel.callingLanguageChangeService(lang: self.selectedLangModel!.languageID, isAuto: isAuto)
            }
        }
        
        self.viewLanguageModel.languageUpdateHandler = { [weak self] (langugageID) in
            self?.saveAppLanguage()
            self?.removeFromSuperview()
            SharedManager.shared.userBasicInfo["auto_translate"] = self?.switchMain.isOn
            
        }
        
//        SharedManager.shared.removeFeedArray()
//        SharedManager.shared.reomveWatchArray()
    }
    
    
    func saveAppLanguage(){
        UserDefaults.standard.setValue(selectedAppLanguage, forKey: "Lang")
        UserDefaults.standard.setValue(selectedLanguage, forKey: "LangN")
        
        UserDefaults.standard.synchronize()
        
        SharedManager.shared.isLanguageChange = true
        
        self.parentView!.ChangeTabbarText()
        self.parentView!.tabBarController?.dismiss(animated: false, completion: {
            self.parentView!.appDelegate.loadTabBar()
        })
    }
    @IBAction func chooseLanguage(sender : UIButton){
        populateLangugaeData()
        let pickerMain = PickerDialog.init()
        
        var arrayName = [String]()
        for indexObj in self.lanaguageModelArray {
            arrayName.append(indexObj.languageName)
        }
        
        
        pickerMain.show("Choose Language", arrayMain: arrayName) { (pickerValue) in
            if pickerValue! > -1 {
                self.lblLanguageName.text = arrayName[pickerValue!]
                self.selectedLangModel = self.lanaguageModelArray[pickerValue!]
                self.selectedLanguage = self.selectedLangModel.languageName
            }
        }
    }
    
    
    @IBAction func chooseAppLanguage(sender : UIButton){
        let pickerMain = PickerDialog.init()
        
        
        pickerMain.show("Choose App Language", arrayMain: self.arrayLanguage) { (pickerValue) in
            if pickerValue! > -1 {
                self.lblAppLanguageName.text = self.arrayLanguage[pickerValue!]
                self.selectedAppLanguage = self.arrayLanguage[pickerValue!]
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if(touch.view?.tag == -100){
            self.removeFromSuperview()
            
        }
    }

    func populateLangugaeData(){
        self.lanaguageModelArray = SharedManager.shared.populateLangData()
        
        
    }
    
    
    func resetHandler()  {
        self.arrayLanguage = SharedManager.shared.appLanguage()
        self.selectedAppLanguage = UserDefaults.standard.value(forKey: "Lang") as! String
        
        if UserDefaults.standard.value(forKey: "LangN") != nil {            
            self.selectedLanguage = UserDefaults.standard.value(forKey: "LangN") as! String
        }else {
            self.selectedLanguage = "English"
        }
        
        self.lblAppLanguageName.text = self.selectedAppLanguage
        self.populateLangugaeData()
        if let langID = SharedManager.shared.userBasicInfo["language_id"] as? Int   {
            let isAuto = SharedManager.shared.userBasicInfo["auto_translate"] as! Int
            if self.lanaguageModelArray.count > 0 {
                
                
                
                for indexObj in self.lanaguageModelArray {
                    if Int(indexObj.languageID) == langID {
                        self.selectedLangModel = indexObj
                        break
                    }
                }
                
                self.lblLanguageName.text = self.selectedLanguage
                self.switchMain!.setOn(false, animated: false)
                if isAuto == 1 {
                    self.switchMain!.setOn(true, animated: false)
                }
            }else {
                self.lblLanguageName.text = self.selectedLanguage
            }
        }else {
            self.lblLanguageName.text = self.selectedLanguage

        }
        
    }
    
}
