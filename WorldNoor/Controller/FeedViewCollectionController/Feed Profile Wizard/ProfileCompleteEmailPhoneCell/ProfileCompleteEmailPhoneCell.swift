//
//  ProfileCompleteEmailPhoneCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 23/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ProfileCompleteEmailPhoneCell: UICollectionViewCell {

    @IBOutlet weak var emailPhoneTextField: UITextField!
    weak var delegate: ProfileWizardDelegate?
    
    var phoneCodeLbl = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        emailPhoneTextField.placeholder = "Enter email/number".localized()
    }

    
    func bindData(){
        
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            phoneCodeLbl = "+" + countCode
        }
        
        LogClass.debugLog("SharedManager.shared.userObj?.data.email ===>")
        LogClass.debugLog(SharedManager.shared.userObj?.data.email)
        LogClass.debugLog(SharedManager.shared.userObj?.data.phone)
        
        if SharedManager.shared.userObj?.data.email?.count == 0 || SharedManager.shared.userObj?.data.email == nil {
            emailPhoneTextField.placeholder = "Enter Email Address".localized()
        }else if SharedManager.shared.userObj?.data.phone?.count == 0 || SharedManager.shared.userObj?.data.phone == nil {
            emailPhoneTextField.placeholder = "Enter your phone number".localized()
            
        }
    }
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
        
    @IBAction func saveTapped(_ sender: Any) {
        
        if self.validateData()  {
            
            let userToken = SharedManager.shared.userToken()
            var parameters = [
                "action": "profile/update",
                "token": userToken,
            ]

            
            if SharedManager.shared.userObj?.data.email?.count == 0 || SharedManager.shared.userObj?.data.email == nil {
                parameters["email"] = self.emailPhoneTextField.text!
            }else {
                parameters["phone"] = self.emailPhoneTextField.text!
                parameters["country_code"] = self.phoneCodeLbl
            }
            
            
            LogClass.debugLog("parameters ===>")
            LogClass.debugLog(parameters)
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)    
                case .success(let res):
                    
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        
                        UIApplication.topViewController()?.ShowAlert(message: res as! String)
                    } else if res is [String : Any] {
                        
                        if SharedManager.shared.userObj?.data.email?.count == 0 || SharedManager.shared.userObj?.data.email == nil {
                            SharedManager.shared.userObj?.data.email = self.emailPhoneTextField.text!
                        }else {
                            SharedManager.shared.userObj?.data.phone = self.emailPhoneTextField.text!
                        }
                        self.delegate?.closeTapped(isSkipped: false)
                    }
                }
            }, param:parameters)
        }
    }
    
    func validateData ()->Bool {
        if SharedManager.shared.userObj?.data.email?.count == 0 || SharedManager.shared.userObj?.data.email == nil {
            if !self.emailPhoneTextField.text!.isValidEmail() {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.emailValid.localized())
                return false
            }
        }else {
            if !isNumberValid(){
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number.".localized())
                return false
            }
        }
        return true
    }
    
    func isNumberValid() -> Bool {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let code = phoneCodeLbl
            let number = emailPhoneTextField.text ?? .emptyString
            let phoneNumber = code + number
            let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber)
            return phoneNumberKit.isValidPhoneNumber(parsedPhoneNumber.numberString)
        } catch {
            return false
        }
    }
}
