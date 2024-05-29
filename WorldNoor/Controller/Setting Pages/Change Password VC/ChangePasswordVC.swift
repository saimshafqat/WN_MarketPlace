//
//  ChangePasswordVC.swift
//  WorldNoor
//
//  Created by apple on 4/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet var tfOldPassword : UITextField!
    @IBOutlet var tfNewPassword : UITextField!
    @IBOutlet var tfConfirmPassword : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change Password".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func submitAction(sender : UIButton) {
        
        if self.tfOldPassword.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Please enter old password.".localized(), view: self)
            return
        }
        
        if self.tfNewPassword.text?.count == 0 {
            SharedManager.shared.showAlert(message: "Please enter new password.".localized(), view: self)
            return
        }
        
        if self.tfConfirmPassword.text?.count == 0 {
            SharedManager.shared.showAlert(message: "Please enter confirm password.".localized(), view: self)
            return
        }
        
        if self.tfNewPassword.text == self.tfConfirmPassword.text &&
            self.tfOldPassword.text == self.tfNewPassword.text {
            SharedManager.shared.showAlert(message: "Old password and new password should not be the same.".localized(),
                                           view: self)
            return
        }
        
        if self.tfNewPassword.text != self.tfConfirmPassword.text {
            SharedManager.shared.showAlert(message: "New and confirm password are not match.".localized(), view: self)
            return
        }
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        let parameters = ["action": "profile/update_password","token": SharedManager.shared.userToken() , "current_password" : self.tfOldPassword.text! , "new_password" : self.tfNewPassword.text! , "new_password_confirmation" : self.tfConfirmPassword.text! ]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if let newRes = res as? String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: newRes)
                } else {
                    SharedManager.shared.ShowSuccessAlert(message: "Password updated successfully.".localized(), view: self)
                }
            }
        }, param: parameters)
    }
}
