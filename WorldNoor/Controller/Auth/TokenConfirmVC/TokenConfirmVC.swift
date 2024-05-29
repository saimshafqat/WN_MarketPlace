//
//  TokenConfirmVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 13/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class TokenConfirmVC : UIViewController {
    
    
    @IBOutlet var tfMain : UITextField!
        
    var countCode = ""
    var phoneCode = ""
    
    override func viewDidLoad() {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tfMain.placeholder = "Code".localized()
    }
    
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        
        
        if self.tfMain.text!.count > 0 {
            let parameters = ["action": "verify-code-reset-password","phone": self.phoneCode,"device_type": "ios" , "code" : self.tfMain.text!]
            
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
                           
                           let viewUpdate = self.GetView(nameVC: "ForgotPasswordVC", nameSB: "Main") as! ForgotPasswordVC
                           viewUpdate.countCode = self.countCode
                           viewUpdate.phoneCode = self.phoneCode
                           self.navigationController?.pushViewController(viewUpdate, animated: true)
                        }
                    }

                }
            }, param:parameters)
        }else {
            
            if self.tfMain.text!.isEmpty {
                SharedManager.shared.showAlert(message: "Enter verification code", view: self)
                return
            }else {
                self.showToast(with: "Enter valid code.".localized(), type: .error)
            }
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
