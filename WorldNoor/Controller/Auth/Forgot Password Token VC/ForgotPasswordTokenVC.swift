//
//  ForgotPasswordTokenVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 12/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import CountryPickerView
import PhoneNumberKit

class ForgotPasswordTokenVC : UIViewController {
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var btnMobileBottom : UIButton!
    @IBOutlet var tfMain : UITextField!
    
    var isPhoneSelected : Bool = false
    var countCode = ""
    override func viewDidLoad() {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.manageUI()
        let locale = Locale.current
        let countCodeP = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCodeP != "" {
            countCode = "+" + countCodeP
        }
    }
    
    
    func isNumberValid() -> Bool {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let code = self.countCode
            let number = self.tfMain.text ?? .emptyString
            let phoneNumber = code + number
            print("phoneNumber ====>")
            print(phoneNumber)
            let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber)
            return phoneNumberKit.isValidPhoneNumber(parsedPhoneNumber.numberString)
        } catch {
            return false
        }
    }
    
    func manageUI(){
        
        self.lblHeading.fadeTransition(0.5)
        self.tfMain.fadeTransition(0.5)
        self.btnMobileBottom.fadeTransition(0.5)
        self.tfMain.text = ""
        if self.isPhoneSelected {
            self.lblHeading.text = "Enter phone number.".localized()
            self.tfMain.placeholder = "Mobile Number".localized()
            self.btnMobileBottom.setTitle("Search by email instead".localized(), for: .normal)
        }else {
            self.lblHeading.text = "Please enter your email address.".localized()

            self.tfMain.placeholder = "Email Address".localized()
            self.btnMobileBottom.setTitle("Search by mobile number instead".localized(), for: .normal)
        }
        
    }
    
    @IBAction func phoneSelected(_ sender: Any) {
        self.isPhoneSelected = !self.isPhoneSelected
        self.manageUI()
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if self.isPhoneSelected {
            if self.validateParams() {
                self.forgetPhoneService()
            }
        }else {
            self.validateEmail()
        }
    }
    
    
    func forgetPhoneService() {
        let parameters = ["action": "resend-otp","phone": self.tfMain.text!,"device_type": "ios" , "country_code" : self.countCode]
        
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
                }else if res is String {
                                                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                }else {
                   if let dataDict = res as? [String : Any] {
                       let viewUpdate = self.GetView(nameVC: "TokenConfirmVC", nameSB: "Main") as! TokenConfirmVC
                       viewUpdate.countCode = self.countCode
                       viewUpdate.phoneCode = self.tfMain.text!
                       self.navigationController?.pushViewController(viewUpdate, animated: true)
                    }
                }

            }
        }, param:parameters)
    }
    
    func validateEmail() {
        guard let email = self.tfMain.text?.replacingOccurrences(of: " ", with: "") else {return}
        if email == "" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your email address.".localized())
        } else if !self.EmailValidationOnstring(strEmail: email) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid email address.".localized())
        } else {
            forgetEmailService()
        }
    }
    
    func validateParams()-> Bool  {
        if self.tfMain.text == "" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your phone number.".localized())
            return false
        } else if !isNumberValid(){
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number.".localized())
            return false
        }
        return true
    }
    
    func forgetEmailService() {
        
        let parameters = ["action": "resend-forget-otp?screen_type=forget_otp","email": self.tfMain.text!]
        

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
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                }else {
                    let hiddenVC = self.GetView(nameVC: "NewCodeSingupVC", nameSB: "Main" ) as! NewCodeSingupVC
                    hiddenVC.phoneSignup = self.tfMain.text!
                    hiddenVC.tfPassword = ""
                    hiddenVC.isFromForgot = true
                    self.navigationController?.pushViewController(hiddenVC, animated: true)
                }
            }
        }, param:parameters)
    }
    
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
