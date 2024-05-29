//
//  EditProfileAboutMEVC.swift
//  WorldNoor
//
//  Created by apple on 1/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class EditProfileAboutMEVC: UIViewController {
    
    @IBOutlet private weak var txtViewAboutMe : UITextView!
    @IBOutlet private weak var charactersCounterLabel: UILabel!
    
    var aboutMeStr = "About Me...".localized()
    
    var refreshParentView: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.txtViewAboutMe.text = SharedManager.shared.userEditObj.aboutme
        let count = SharedManager.shared.userEditObj.aboutme.count
        self.charactersCounterLabel.text = String(count) + "/100"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        if(touch.view!.tag == 100 ) {
            self.view.removeFromSuperview()
        }
    }
}

extension EditProfileAboutMEVC {
    
    @IBAction func submitAction(sender : UIButton) {
        
        self.view.endEditing(true)
        if self.txtViewAboutMe.text!.count == 0 || self.txtViewAboutMe.text == aboutMeStr {
            SharedManager.shared.showAlert(message: "Enter info about you.".localized(), view: self)
            return
        }
        
        let userToken = SharedManager.shared.userToken()
        let aboutMe = self.txtViewAboutMe.text!
        
        
        let parameters = ["action": "profile/update", "token": userToken, "about_me" : aboutMe]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SharedManager.shared.showAlert(message: res as! String, view: self)
                } else if res is [String : Any] {
                    
                    SharedManager.shared.userEditObj.aboutme = self.txtViewAboutMe.text!
                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
}

extension EditProfileAboutMEVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == aboutMeStr {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = aboutMeStr
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charactersCounterLabel.text = "\(textView.text.count)" + "/100"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
}
