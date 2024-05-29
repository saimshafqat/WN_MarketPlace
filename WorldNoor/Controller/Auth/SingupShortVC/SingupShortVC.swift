//
//  SingupShortVC.swift
//  WorldNoor
//
//  Created by apple on 10/21/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import PhoneNumberKit

class SingupShortVC : UIViewController {
    
    @IBOutlet weak var lblShowPassword: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    
    @IBOutlet var tfUserName : UITextField!
    @IBOutlet var tfEmail : UITextField!
    @IBOutlet var tfPassword : UITextField!
    
    @IBOutlet var viewShowPassword : UIView!
    @IBOutlet var viewAgree : UIView!
    
    @IBOutlet var tfAgree : UITextView!
    @IBOutlet var btnRegister : UIButton!
    @IBOutlet var lblRegister : UILabel!
    
    @IBOutlet var lblLogin : UILabel!
    @IBOutlet var lblLoginInfo : UILabel!
    
    var country = CountryModel.init()
    
//    let allowingDigit = "0123456789"

//    var isPhone = false
    
    override func viewDidLoad() {
        self.tfPassword.isSecureTextEntry = true
        self.btnRegister.isEnabled = false
        self.btnRegister.backgroundColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FileBasedManager.shared.removeImage()
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        
        self.managePrivacyPolicy(textView: self.tfAgree)
        self.PhoneCodeCheck()
        
        guard let strValue = UserDefaults.standard.value(forKey: "Lang") as? String else {
            return
        }
        
        
        self.title = "Register".localized()
        self.lblLanguage.text = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        self.lblShowPassword.text = "Show Password".localized()
        
        self.tfEmail.placeholder = "Your Email Address".localized()
        self.tfPassword.placeholder = "Your Password".localized()
        self.tfUserName.placeholder = "Your display name".localized()
        self.lblRegister.text = "Register".localized()
        self.lblLogin.text = "Login".localized()
        self.lblLoginInfo.text = "to existing account".localized()
        
    }
    
    func PhoneCodeCheck() {
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            
            self.country.id = locale.regionCode!
            self.country.name = self.countryName(from: locale.regionCode!)
            self.country.code = countCode
        }
    }
    
    func countryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }
    
    @IBAction func showPasswordAction(sener : UIButton){
        
        self.tfPassword.isSecureTextEntry = !self.viewShowPassword.isHidden
        self.viewShowPassword.isHidden = !self.viewShowPassword.isHidden
    }
    
    @IBAction func agreeAction(sener : UIButton){
        self.viewAgree.isHidden = !self.viewAgree.isHidden
        self.btnRegister.isEnabled = !self.viewAgree.isHidden
        
        if self.btnRegister.isEnabled {
            self.btnRegister.backgroundColor = UIColor.themeBlueColor
        }else {
            self.btnRegister.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func signUpAction(sener : UIButton){
        
        
        if self.tfUserName.text?.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert".localized(), body: "Enter your name".localized())
            return
        }
        
        
        if self.tfEmail.text!.isNumber {
            if self.tfEmail.text!.count > 0 {
                if !isNumberValid(){
                    SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number".localized())
                    return
                }
            }else {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValid.localized())
                return
            }
        }else {
            if !self.EmailValidationOnstring(strEmail: self.tfEmail.text!) {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValid.localized())
                return
            }
        }
        
        if self.tfPassword.text!.count < 8 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Password must be 8-200 characters long.".localized())
            return
        }
        
        var parameters :[String : Any] = [
            "action": "register_new",
            "fcm_token":FireConfiguration.shared.fcmToken,
            "firstname" : self.tfUserName.text! ,
            "password": self.tfPassword.text!,
            "password_confirmation": self.tfPassword.text!,
            "phone_code": self.country.code,
            "country_code": self.country.id,
            "voip_token":SharedManager.shared.callKitToken,
            "device_type":"ios"
        ]

        
        if self.tfEmail.text!.isNumber {
            parameters["phone"] = self.tfEmail.text!
        }else {
            parameters["email"] = self.tfEmail.text!
        }
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error) 
            case .success(let res):
                if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                } else {
                    
                    if self.tfEmail.text!.isNumber {
                        self.loginAction()
                    } else {
                        SharedManager.shared.ShowsuccessAlert(message:"Registered Successfully.4 digit code has been sent to your provided email address to verify your account.".localized(),AcceptButton: "OK".localized()) { status in
                            let hiddenVC = self.GetView(nameVC: "NewCodeSingupVC", nameSB: "Main" ) as! NewCodeSingupVC
                            hiddenVC.phoneSignup = self.tfEmail.text!
                            hiddenVC.tfPassword = self.tfPassword.text!
                            self.navigationController?.pushViewController(hiddenVC, animated: true)
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
    
    func callingSkipService(token:String) {
        ChatDBManager.deleteChat()
        
        let parameters = ["action": "login-verify","token":token, "skip_verification": "1"]
        RequestManagerGen.fetchDataPost(Completion: { (response: Result<(User), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                self.handleUserResponse(userObj: res)
            }
        }, param:parameters)
    }
    
    func getUsernfo(){

        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "profile/about","token": userToken]
      
        SharedManager.shared.showOnWindow()
        RequestManager.fetchDataGet(Completion: { response in
            SharedManager.shared.hideLoadingHubFromKeyWindow()
            switch response {
            case .failure(let error):
                if error is String {
                    SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [String : Any] {

                    SharedManager.shared.userEditObj = UserProfile.init(fromDictionary: res as! [String : Any])
                    SharedManager.shared.userObj?.data.placesAdded = false
                    if SharedManager.shared.userEditObj.places.count > 0 {
                        SharedManager.shared.userObj?.data.placesAdded = true
                    }
                    
                    SharedManager.shared.userObj?.data.RelationAdded = false
                    if SharedManager.shared.userEditObj.relationshipArray.count > 0 {
                        SharedManager.shared.userObj?.data.RelationAdded = true
                    }
                    
                    SharedManager.shared.userObj?.data.workAdded = false
                    if SharedManager.shared.userEditObj.workExperiences.count > 0 {
                        SharedManager.shared.userObj?.data.workAdded = true
                    }
                    
                    
                    if SharedManager.shared.userEditObj.phone != nil {
                        SharedManager.shared.userObj?.data.phone = SharedManager.shared.userEditObj.phone
                    }
                    
                    if SharedManager.shared.userEditObj.email != nil {
                        SharedManager.shared.userObj?.data.email = SharedManager.shared.userEditObj.email
                    }
                    
                    AppDelegate.shared().loadTabBar()
                }
                

                
            }
        }, param:parameters)
    }
    
    
    func handleUserResponse(userObj:User){
        
        if ResponseKey(rawValue:(userObj.meta?.code)!) == .successResp  {
            SharedManager.shared.userObj = userObj
            SharedManager.shared.userObj?.data.isGoogleAccount = true
            SharedManager.shared.userObj?.data.isProfileCompleted = false
            SharedManager.shared.userObj?.data.isSocialLogin = false
            SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
            self.getUsernfo()
  
        }
    }
    
    
    func handleFailureResponse(errorMsg:ErrorModel){
        if let message = errorMsg.meta?.message   {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
    
    @IBAction func chooseLanguage(sender : UIButton){
        let hiddenVC = self.GetView(nameVC: "AppLanguagesVC", nameSB: "EditProfile" ) as! AppLanguagesVC
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    @IBAction func signInAction(sener : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func managePrivacyPolicy(textView : UITextView){
        let font = UIFont.systemFont(ofSize: 14.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5.0
        let attributes = [NSAttributedString.Key.font: font as Any, NSAttributedString.Key.paragraphStyle: paragraphStyle]

        let str1 = NSMutableAttributedString(string: "By creating account you agree to ".localized(), attributes: [NSAttributedString.Key.font : font])
        str1.append(NSMutableAttributedString(string: "our Terms and confitions, End User License Agreement".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().LiscenseLink]))
        str1.append(NSMutableAttributedString(string: " and ".localized(), attributes: [NSAttributedString.Key.font : font]))
        str1.append(NSMutableAttributedString(string: "Privacy Policy.".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().privacyLink]))
        textView.attributedText = str1
        
    }
    
    
    func loginAction(){
        var parameters = [
            "action": "login",
            "country": self.country.id,
            "password": self.tfPassword.text!,
            "voip_token":SharedManager.shared.callKitToken,
            "device_type":"ios"
        ]
        
        parameters["email"] = self.tfEmail.text!
        parameters["country_code"] = "+1" + self.country.code
        
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    let verifDict = res as! NSDictionary
                    self.callingSkipService(token: verifDict["token"] as! String ?? "")

                }
            }
        }, param:parameters)
    }
}


extension SingupShortVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    func isNumberValid()-> Bool{
        var isvalid = false
        var number = self.country.code
        number.append(self.tfEmail.text!)
        let phoneNumberKit = PhoneNumberKit()
        isvalid = phoneNumberKit.isValidPhoneNumber(number ?? "")
        return isvalid
    }
}
