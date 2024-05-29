//
//  NewCodeSingupVC.swift
//  WorldNoor
//
//  Created by apple on 2/23/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewCodeSingupVC : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tfOne : UITextField!
    @IBOutlet var tfTwo : UITextField!
    @IBOutlet var tfThree : UITextField!
    @IBOutlet var tfFour : UITextField!
    @IBOutlet var tfMain : UITextField!
    
    @IBOutlet var viewResend : UIView!
    @IBOutlet var viewTimer : UIView!
    @IBOutlet var lblTimer : UILabel!
    
    @IBOutlet var lblHeading : UILabel!
    
    
    var timer: Timer?
    var totalTime = 60
    
    
    var isFromForgot : Bool = false
    
    var phoneSignup = ""
    var tfPassword = ""
    
    var codeSignup = ""
    
    override func viewDidLoad() {
        
        self.tfMain.delegate = self
        tfOne.delegate = self
        tfTwo.delegate = self
        tfThree.delegate = self
        tfFour.delegate = self
        self.lblTimer.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tfMain.becomeFirstResponder()
        self.navigationController?.navigationBar.isHidden = true
        self.lblHeading.text = "Please check your inbox".localized() + "\n" + self.phoneSignup
        self.stopOtpTimer()
    }
    
    @IBAction func verifyAccount (sender : UIButton) {
        
        
        if self.tfMain.text!.isEmpty {
            SharedManager.shared.showAlert(message: "Enter verification code", view: self)
            return
        }
        if self.tfMain.text!.count < 4 {
            SharedManager.shared.showAlert(message: "Enter valid code.", view: self)
            return
        }
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        var parameters = [String : Any]()
        parameters["email"] = self.phoneSignup
        parameters["code"] = self.tfMain.text
        
        parameters["action"] = "email-verify-code"
        
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)  
            case .success(let res):
                LogClass.debugLog(res)
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    
                    if let newDict = res as? [String : Any] {
                        
                        if (newDict["code_status"] as? String) == "verified" {
                            
                            if self.tfPassword.count == 0 {
                                let viewUpdate = self.GetView(nameVC: "UpdatePasswordVC", nameSB: "Main") as! UpdatePasswordVC
                                viewUpdate.email = self.phoneSignup
                                viewUpdate.emailCode = self.tfMain.text!
                                self.navigationController?.pushViewController(viewUpdate, animated: true)
                            } else {
                                self.loginAction()
                            }
                        } else {
                            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Code is Invalid".localized())
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
    func loginAction() {
        
        stopOtpTimer()
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        var parameters = [
            "action": "login",
            "country": locale.regionCode!,
            "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
            "password": self.tfPassword,
            "voip_token":SharedManager.shared.callKitToken,
            "device_type":"ios"
        ]
        
        if countCode != "" {
            parameters["country_code"] = "+" + countCode
        } else {
            parameters["country_code"] = "1"
        }
        
        parameters["email"] = self.phoneSignup
        
        RequestManager.fetchDataPost(Completion: { response in
           
            
            switch response {
            case .failure(let error):
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)   
            case .success(let res):
                if res is String {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    let verifDict = res as! NSDictionary
                    self.callingSkipService(token: verifDict["token"] as! String)
                }
            }
        }, param:parameters)
    }

    func callingSkipService(token:String) {
        
        ChatDBManager.deleteChat()
        
        let parameters = ["action": "login-verify", "token": token, "skip_verification": "1"]
        RequestManagerGen.fetchDataPost(Completion: { (response: Result<(User), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                // for new registers users
                let alert = UIAlertController(title: "Welcome".localized(),
                                              message: "You are successfully registered".localized(),
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok".localized(),
                                              style: UIAlertAction.Style.default,
                                              handler: {_ in
                    self.handleUserResponse(userObj: res)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }, param:parameters)
    }
    
    func handleUserResponse(userObj:User) {
        
        if ResponseKey(rawValue:(userObj.meta?.code)!) == .successResp  {
            SharedManager.shared.userObj = userObj
            
            SharedManager.shared.userObj?.data.isGoogleAccount = true
            SharedManager.shared.userObj?.data.isSocialLogin = false
            SharedManager.shared.userObj?.data.isProfileCompleted = false
            
            SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
            self.getUsernfo()
        }
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
        
    @IBAction func resendCodeAccount (sender : UIButton){
        
        var screenType = "resent_otp"
        
        if tfPassword.count == 0 {
            screenType = "forget_otp"
        }
        var parameters = [
            "action": "resend-forget-otp",
            "email": self.phoneSignup,
            "screen_type" : screenType
        ]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
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
                    
                    if let newDict = res as? [String : Any] {
                        if (newDict["code_status"] as? String)!.contains("sent"){
                            SharedManager.shared.showAlert(message: "4 digit code has been sent to your provided email address to verify your account.".localized(), view: self)
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
    @IBAction func loginAction(sender : UIButton){
        self.navigationController!.popToViewController(ofClass: NewSplashVC.self)
    }
}

extension NewCodeSingupVC  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
//        if string.count > 0 {
//            if self.tfFour.text!.count == 1 {
//                return false
//            }
//        }
//
//        _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.setText), userInfo: nil, repeats: false)
//
//        if string.count > 1 {
//            return false
//        }
//
        return true
    }
    
//    @objc func setText() {
//
//        self.tfTwo.text = ""
//        self.tfOne.text = ""
//        self.tfThree.text = ""
//        self.tfFour.text = ""
//        //        self.tfFive.text = ""
//        //        self.tfSix.text = ""
//
//        switch self.tfMain.text!.count {
//        case 1:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//        case 2:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//            self.tfTwo.text = String(Array(self.tfMain.text!)[1])
//        case 3:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//            self.tfTwo.text = String(Array(self.tfMain.text!)[1])
//            self.tfThree.text = String(Array(self.tfMain.text!)[2])
//        case 4:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//            self.tfTwo.text = String(Array(self.tfMain.text!)[1])
//            self.tfThree.text = String(Array(self.tfMain.text!)[2])
//            self.tfFour.text = String(Array(self.tfMain.text!)[3])
//
//        case 5:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//            self.tfTwo.text = String(Array(self.tfMain.text!)[1])
//            self.tfThree.text = String(Array(self.tfMain.text!)[2])
//            self.tfFour.text = String(Array(self.tfMain.text!)[3])
//
//        case 6:
//            self.tfOne.text = String(Array(self.tfMain.text!)[0])
//            self.tfTwo.text = String(Array(self.tfMain.text!)[1])
//            self.tfThree.text = String(Array(self.tfMain.text!)[2])
//            self.tfFour.text = String(Array(self.tfMain.text!)[3])
//
//        default:
//            LogClass.debugLog("default ==>")
//        }
//    }
    
    private func startOtpTimer() {
        self.totalTime = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopOtpTimer() {
        
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc func updateTimer() {
        self.lblTimer.text = self.timeFormatted(self.totalTime) // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            //            self.viewTimer.isHidden = true
            //            self.viewResend.isHidden = false
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
