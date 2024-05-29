//
//  RegisterationTermsVC.swift
//  WorldNoor
//
//  Created by Walid Ahmed on 25/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class RegisterationTermsVC: UIViewController {
    
    var selectedData = RegisterationData()
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var viewAgree : UIView!
    @IBOutlet var textView : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        nextBtn.isEnabled = false
        nextBtn.backgroundColor = UIColor.lightGray
        managePrivacyPolicy(textView: textView)
        setLocalizations()
    }
    
    func setLocalizations() {
        titleLbl.text = "Agree to WorldNoor's terms and policies".localized()
        nextBtn.setTitle("I agree".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func agreeCheckBtnPressed(sener : UIButton) {
        
        viewAgree.isHidden = !viewAgree.isHidden
        nextBtn.isEnabled = !viewAgree.isHidden
        
        if self.nextBtn.isEnabled {
            nextBtn.backgroundColor = UIColor.themeBlueColor
        } else {
            nextBtn.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        var parameters: [String : Any] = [
            "action": "register_new",
            "firstname" : selectedData.selectedFirstName,
            "lastname" : selectedData.selectedLastName,
            "gender" : selectedData.selectedGender,
            "pronoun" : selectedData.selectedPronoun,
            "custom_gender" : selectedData.selectedCustomGender,
            "dob" : selectedData.selectedBirthDateStr,
            "password": selectedData.selectedPassword,
            "password_confirmation": selectedData.selectedPassword,
            "phone_code": selectedData.selectedCountryCode,
            "country_code": selectedData.selectedCountryId,
            "voip_token":SharedManager.shared.callKitToken,
            "fcm_token":FireConfiguration.shared.fcmToken,
            "device_type":"ios"
        ]
        
        if selectedData.selectedPhone.isEmpty {
            parameters["email"] = selectedData.selectedEmail
        } else{
            parameters["phone"] = selectedData.selectedPhone
        }
        
        LogClass.debugLog(parameters)
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { [weak self]response in
            guard let self = self else{return}
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                let message = error.localizedDescription
                DispatchQueue.main.async {
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            case .success(let res):
                if res is String {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    DispatchQueue.main.async {
                                                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                    }
                } else {
                    if !self.selectedData.selectedPhone.isEmpty {
                        self.loginAction()
                    } else {
//                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                        Loader.stopLoading()
                        SharedManager.shared.ShowsuccessAlert(message:"Registered Successfully.4 digit code has been sent to your provided email address to verify your account.".localized(),AcceptButton: "OK".localized()) { status in
                            DispatchQueue.main.async {
                                let hiddenVC = self.GetView(nameVC: "NewCodeSingupVC", nameSB: "Main" ) as! NewCodeSingupVC
                                hiddenVC.phoneSignup = self.selectedData.selectedEmail
                                hiddenVC.tfPassword = self.selectedData.selectedPassword
                                self.navigationController?.pushViewController(hiddenVC, animated: true)
                            }
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
    func loginAction() {
        var parameters = [
            "action": "login",
            "country": selectedData.selectedCountryId,
            "password": selectedData.selectedPassword,
            "voip_token":SharedManager.shared.callKitToken,
            "device_type":"ios"
        ]
        parameters["email"] = selectedData.selectedPhone.isEmpty ? selectedData.selectedEmail : selectedData.selectedPhone
        parameters["country_code"] = "+" + selectedData.selectedCountryCode
        
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
            case .success(let res):
                if res is String {
                    DispatchQueue.main.async {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                    }
                } else {
                    let verifDict = res as? NSDictionary ?? NSDictionary()
                    self.callingSkipService(token: verifDict["token"] as? String ?? .emptyString)
                }
            }
        }, param:parameters)
    }
    
    func callingSkipService(token: String) {
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
    
    func handleFailureResponse(errorMsg: ErrorModel) {
        if let message = errorMsg.meta?.message   {
            DispatchQueue.main.async {
                SharedManager.shared.showAlert(message: message, view: self)
            }
        }
    }
    
    func handleUserResponse(userObj: User) {
        if ResponseKey(rawValue:(userObj.meta?.code)!) == .successResp  {
            SharedManager.shared.userObj = userObj
            SharedManager.shared.userObj?.data.isSocialLogin = false
            SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
//            if SharedManager.shared.userObj?.data.screenPin == true{
//                goToPinScreen()
//            } else {
                
//            }
            
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
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func managePrivacyPolicy(textView : UITextView) {
        
        let font = UIFont.systemFont(ofSize: 14.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5.0
        let attributes = [NSAttributedString.Key.font: font as Any,
                          NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        let str1 = NSMutableAttributedString(string: "By creating account you agree to ".localized(), attributes: [NSAttributedString.Key.font : font])
        str1.append(NSMutableAttributedString(string: " " + "our Terms and confitions, End User License Agreement".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().LiscenseLink]))
        str1.append(NSMutableAttributedString(string: " and ".localized(), attributes: [NSAttributedString.Key.font : font]))
        str1.append(NSMutableAttributedString(string: "Privacy Policy.".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().privacyLink]))
        textView.attributedText = str1
    }
}
