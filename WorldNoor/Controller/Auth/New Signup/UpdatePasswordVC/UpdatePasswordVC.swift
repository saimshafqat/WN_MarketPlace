//
//  UpdatePasswordVC.swift
//  WorldNoor
//
//  Created by apple on 2/28/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation

class UpdatePasswordVC: UIViewController {

    var createIconClick = true
    var confirmIconClick = true
    var pinIconClick = true
    var selectedData = RegisterationData()
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var pinEyeBtn: UIButton!
    @IBOutlet weak var pinbgV: UIView!
    @IBOutlet weak var confirmEyeBtn: UIButton!
    @IBOutlet weak var newEyeBtn: UIButton!
    @IBOutlet var newPasswordTF : UITextField!
    @IBOutlet var confirmPasswordTF : UITextField!
    
    @IBOutlet var viewBack : UIView!
    
    var emailCode  = ""
    var email  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }
    
    func setupUI(){
        pinTF.delegate = self
        newPasswordTF.paddingLeft(padding: 8)
        confirmPasswordTF.paddingLeft(padding: 8)
        pinTF.paddingLeft(padding: 8)
        pinbgV.isHidden = selectedData.updatePasswordVia == .email
        setLocalizations()
    }
    
    func setLocalizations(){
        newPasswordTF.placeholder = "New Password".localized()
        confirmPasswordTF.placeholder = "Confirm Password".localized()
        pinTF.placeholder = "Pin".localized()
//        self.viewBack.isHidden = true
        
        if selectedData.updatePasswordVia == .phone {
            titleLbl.text = "Forgot Password".localized()
//            self.viewBack.isHidden = false
        } else {
            titleLbl.text = "Update Password".localized()
        }
        
        submitBtn.setTitle("Submit".localized(), for: .normal)
    }
    
    @IBAction func newEyeBtnPressed(_ sender: Any) {
        if(createIconClick == true) {
            newPasswordTF.isSecureTextEntry = false
            newEyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            newPasswordTF.isSecureTextEntry = true
            newEyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        createIconClick = !createIconClick
    }
    
    @IBAction func confirmEyeBtnPressed(_ sender: Any) {
        if(confirmIconClick == true) {
            confirmPasswordTF.isSecureTextEntry = false
            confirmEyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            confirmPasswordTF.isSecureTextEntry = true
            confirmEyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        confirmIconClick = !confirmIconClick
    }
    
    @IBAction func pinEyeBtnPressed(_ sender: Any) {
        if(pinIconClick == true) {
            pinTF.isSecureTextEntry = false
            pinEyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            pinTF.isSecureTextEntry = true
            pinEyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        pinIconClick = !pinIconClick
    }
    
    @IBAction func submitAction(sender : UIButton){
        if !validateData() {
            return
        }
        updatePasssword()
    }
    
    func updatePasssword(){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        var parameters = [
            "new_password": newPasswordTF.text! ,
            "new_password_confirmation": confirmPasswordTF.text!
        ]
        switch selectedData.updatePasswordVia{
        case .phone:
            parameters["action"] = "reset-password-pin"
            parameters["otp_id"] = selectedData.OTP_ID
            parameters["phone"] = selectedData.selectedPhone
            parameters["pin"] = pinTF.text!
        default:
            parameters["action"] = "update-password-email-otp"
            parameters["email"] = self.email
            parameters["code"] = self.emailCode
        }
               
               RequestManager.fetchDataPost(Completion: { (response) in
//                   SharedManager.shared.hideLoadingHubFromKeyWindow()
                   Loader.stopLoading()
                   switch response {
                   case .failure(let error):
                       SwiftMessages.apiServiceError(error: error)
                   case .success(let res):
                       // LogClass.debugLog("submitAction res ===>")
                       // LogClass.debugLog(res)
                       if let newRes = res as? String {
                           SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: newRes)
                       }else {
                            SharedManager.shared.ShowSuccessforRoot(message: "Password updated successfully.".localized(), view: self)
                        }

                   }
               }, param: parameters)
    }
 
    @IBAction func backAction(sender : UIButton){
        // self.popToViewController(viewPop: LoginViewController.self)
        navigationController?.popToViewController(ofClass: LoginViewController.self)
    }
    
    func validateData ()->Bool {
        if newPasswordTF.text!.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter new password.".localized())
            return false
        }
        if confirmPasswordTF.text!.isEmpty  {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter confirm password.".localized())
            return false
        }
        if newPasswordTF.text != confirmPasswordTF.text {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "New and confirm password are not match.".localized())
            return false
        }
        if selectedData.updatePasswordVia == .phone{
            if pinTF.text!.count != 6 {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Pin must be 6 digits.".localized())
                return false
            }
        }
        return true
    }
}

extension UpdatePasswordVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pinTF{
            let maxLength = 6
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            return newString.count <= maxLength
        }
        return true
    }
}
