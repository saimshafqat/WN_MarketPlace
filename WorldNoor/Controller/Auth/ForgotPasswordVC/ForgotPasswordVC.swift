//
//  ForgotPasswordVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 14/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import CountryPickerView
import PhoneNumberKit

class ForgotPasswordVC : UIViewController {
    
    
    @IBOutlet var tfMain : UITextField!
        
    var countCode = ""
    var phoneCode = ""
    
    override func viewDidLoad() {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    func isNumberValid()-> Bool{
        var isvalid = false
        var number = countCode
        number.append(tfMain.text!)
        let phoneNumberKit = PhoneNumberKit()
        isvalid = phoneNumberKit.isValidPhoneNumber(number ?? "")
        return isvalid
    }
 
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if self.tfMain.text!.count > 0 {
            let parameters = ["action": "update-password","new_password": self.tfMain.text!,"new_password_confirmation": self.tfMain.text! , "phone" : self.phoneCode]
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    LogClass.debugLog(res)
                    
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    }else if res is String {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                    }else {
                       if let dataDict = res as? [String : Any] {
                           LogClass.debugLog("dataDict ===>")
                           LogClass.debugLog(dataDict)
                           SharedManager.shared.ShowsuccessAlert(message:"Password Change.".localized(),AcceptButton: "OK".localized()) { status in
                               DispatchQueue.main.async {
                                   self.navigationController?.popToRootViewController(animated: true)
                               }
                           }
                        }
                    }
                }
            }, param:parameters)
        } else {
            
        }
    }
    
    
    @IBAction func resendCodeAction(sender : UIButton){
        let parameters = ["action": "resend-otp","phone": self.phoneCode,"device_type": "ios" , "country_code" : self.countCode]
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
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
                }else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                }else {
                   if let dataDict = res as? [String : Any] {
                       
                       LogClass.debugLog("dataDict ===>")
                       LogClass.debugLog(dataDict)
                       
                       
                       self.showToast(with: "Otp Send on Verified Phone number.", type: .success)
                       
                    }
                }

            }
        }, param:parameters)
    }
    
    

    
}
