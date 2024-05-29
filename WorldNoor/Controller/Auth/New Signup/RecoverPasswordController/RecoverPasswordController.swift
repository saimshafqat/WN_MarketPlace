//
//  RecoverPasswordController.swift
//  WorldNoor
//
//  Created by apple on 2/28/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//


import UIKit
import FittedSheets
import CountryPickerView
import PhoneNumberKit

class RecoverPasswordController: UIViewController {
    var userCheckTimer: Timer?
    var userNameExist = false
    var questionID = ""
    var sheetController:SheetViewController?
    var isShowPassword = false
    
    @IBOutlet weak var appNameLbl: UILabel!{
        didSet{
//            appNameLbl.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var recoverLbl: UILabel!{
        didSet{
//            recoverLbl.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var recoveremailLbl: UILabel!{
        didSet{
//            recoveremailLbl.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var recoverUserNamelbl: UILabel!{
        didSet{
//            recoverUserNamelbl.makeFontDynamicBody()
        }
    }
    
    @IBOutlet weak var backloginBtn: UIButton!
    @IBOutlet weak var resetUserTopConst: NSLayoutConstraint!
    @IBOutlet weak var mailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var mailView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var recoverPhoneView: UIView!
    
    @IBOutlet weak var userNameSLbl: UILabel!{
        didSet{
//            userNameSLbl.makeFontDynamicBody()
        }
    }
    
    @IBOutlet weak var phonecodeBtn: UIButton!{
        didSet{
//            phonecodeBtn.makeFontDynamicBody()
        }
    }
    
    @IBOutlet weak var phoneCodeLbl: UILabel!{
        didSet{
//            phoneCodeLbl.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var phoneField: UITextField!{
        didSet{
//            phoneField.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var enterEmailLbl: UILabel!{
        didSet{
//            enterEmailLbl.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var emailField: UITextField!{
        didSet{
//            emailField.makeFontDynamicBody()
        }
    }
    //MARK:- Outlets
    @IBOutlet weak var nextBtn: UIButton!{
        didSet {
            nextBtn.roundCorners(radius: 6, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
//            nextBtn.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var passwrodResetBtn: UIButton!{
        didSet{
            passwrodResetBtn.roundCorners(radius: 6, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)

//            passwrodResetBtn.makeFontDynamicBody()
        }
    }
    
    @IBOutlet weak var securityView: UIView!{
        didSet {
            securityView.roundCorners(radius: 22, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    @IBOutlet weak var answerView: UIView!{
        didSet {
            answerView.roundCorners(radius: 22, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    
    @IBOutlet weak var emailView: UIView!{
        didSet {
            emailView.roundCorners(radius: 6, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    
    @IBOutlet weak var userBView: UIView!{
        didSet {
            userBView.roundCorners(radius: 22, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    
    @IBOutlet weak var phoneNumbView: UIView!{
        didSet {
            phoneNumbView.roundCorners(radius: 22, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
//            phoneNumbView.roundedLeftTopBottom()
        }
    }
    
    @IBOutlet weak var phoneNumbLblView: UIView!{
        didSet {
//            phoneNumbLblView.roundRight(bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
            phoneNumbLblView.roundCorners(radius: 6, bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }

    var countryCode = ""
    let pickerView = CountryPickerView()

    //MARK:- Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manageUI()
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            phoneCodeLbl.text = "+" + countCode
//            phoneCodeLbl.text = "+92"
            self.countryCode = locale.regionCode ?? ""
//            if self.countryCode != "PK" {
//                self.recoverPhoneView.isHidden = true
//            }
        }
        self.backloginBtn.underlineButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.rotateViewForLanguage()
        self.phoneField.rotateViewForLanguage()
        self.phoneField.rotateForLanguage()
        
        self.emailField.rotateViewForLanguage()
        self.emailField.rotateForLanguage()
                
        self.recoveremailLbl.rotateViewForInner()
        self.recoveremailLbl.rotateForTextAligment()
        
        self.recoverLbl.rotateViewForInner()
        self.recoverLbl.rotateForTextAligment()
        
        self.recoverUserNamelbl.rotateViewForInner()
        self.recoverUserNamelbl.rotateForTextAligment()
        
        self.userNameSLbl.rotateViewForInner()
        self.userNameSLbl.rotateForTextAligment()
        
        self.phoneCodeLbl.rotateViewForInner()
        self.phoneCodeLbl.rotateForTextAligment()
        
        self.enterEmailLbl.rotateViewForInner()
        self.enterEmailLbl.rotateForTextAligment()
        
        
        self.nextBtn.rotateViewForInner()
        self.passwrodResetBtn.rotateViewForInner()
        self.mailImageView.rotateViewForLanguage()
        self.userImageView.rotateViewForLanguage()
        
//        self.connectSocket()
    }

//    func connectSocket(){
//        SocketCommon.sharedInstance.delegate = self
//        if SocketCommon.sharedInstance.manager?.status != .connected && SocketCommon.sharedInstance.manager?.status != .connecting{
//            SocketCommon.sharedInstance.establishConnection()
//        }
//    }
    
    func isNumberValid()-> Bool{
        var isvalid = false
        var number = phoneCodeLbl.text
        number?.append(phoneField.text!)
        let phoneNumberKit = PhoneNumberKit()
        isvalid = phoneNumberKit.isValidPhoneNumber(number ?? "")
        return isvalid
    }
    
    func manageUI(){
        recoverLbl.text = "Recover your account".localized()
        recoveremailLbl.text = "Recover using email".localized()
        recoverUserNamelbl.text = "Recover through phone".localized()
        emailField.placeholder = "Email Address".localized()
        enterEmailLbl.text = "Enter email".localized()
        passwrodResetBtn.setTitle("Send password reset email".localized(), for: .normal)
        userNameSLbl.text = "Enter your phone number".localized()
        phoneField.placeholder = "Mobile Number".localized()
//        securitySLbl.text = "Select your security question".localized()
        nextBtn.setTitle("Recover my account".localized(), for: .normal)
//        ansSLbl.text = "Enter your answer".localized()
//        ansField.placeholder = "Your answer".localized()
        let btn = UIButton.init()
        btn.tag = 0
        self.selectResetOption(btn)
    }

    @IBAction func phoneCodeBtn(_ sender: UIButton) {
//        pickerView.delegate = self
//        pickerView.showCountriesList(from: self)
    }
    
    func validateEmail() {
        guard let email = emailField.text?.replacingOccurrences(of: " ", with: "") else {return}
        if email == "" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your email address.".localized())
        } else if !self.EmailValidationOnstring(strEmail: email) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid email address.".localized())
        } else {
            forgetEmailService()
        }
    }
    
    func validateParams()-> Bool  {
        if self.phoneField.text == "" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your phone number.".localized())
            return false
        } else if !isNumberValid(){
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number.".localized())
            return false
        }else if countryCode == "" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please select country code.".localized())
            return false
        }
        return true
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func getParam()->[String:String] {
        let compPhone = phoneCodeLbl.text! + self.phoneField.text!
        let parm:[String:String] = ["phone": compPhone,
                                    "country_code": self.countryCode]
        return parm
    }
    
    //MARK:- API Calls
    
    func forgetPhoneService() {
        let parameters = ["action": "verify-phone-pin","phone": self.phoneField.text!]
        
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
                       let otpId = self.ReturnValueCheck(value:dataDict["otp_id"] ?? "")
                       let viewUpdate = self.GetView(nameVC: "UpdatePasswordVC", nameSB: "Main") as! UpdatePasswordVC
                       viewUpdate.selectedData.OTP_ID = otpId
                       viewUpdate.selectedData.selectedPhone = self.phoneField.text!
                       viewUpdate.selectedData.updatePasswordVia = .phone
                       self.navigationController?.pushViewController(viewUpdate, animated: true)
                    }
                }

            }
        }, param:parameters)
    }
    
    //MARK:- API Calls
    func forgetEmailService() {
        
        let parameters = ["action": "resend-forget-otp?screen_type=forget_otp","email": self.emailField.text!]
        

//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
 SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is String {
                    SharedManager.shared.ShowSuccessAlert(message:res as! String , view: self)
                }else {

                    
                    let hiddenVC = self.GetView(nameVC: "NewCodeSingupVC", nameSB: "Main" ) as! NewCodeSingupVC
                    hiddenVC.phoneSignup = self.emailField.text!
                    hiddenVC.tfPassword = ""
                    hiddenVC.isFromForgot = true
                    self.navigationController?.pushViewController(hiddenVC, animated: true)
                }
            }
        }, param:parameters)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if (sender as! UIButton).tag == 0 {
            if self.validateParams() {
                self.forgetPhoneService()
            }
        }else {
            self.validateEmail()
        }
    }
    
    @IBAction func selectResetOption(_ sender: Any) {
        if (sender as! UIButton).tag == 0 {
            self.mailView.isHidden = false
            self.userView.isHidden = true
            self.resetUserTopConst.constant = 200
            self.userImageView.image = UIImage(named: "tick_unfill")
            self.mailImageView.image = UIImage(named: "tick_fill")
        }else {
            self.userImageView.image = UIImage(named: "tick_fill")
            self.mailImageView.image = UIImage(named: "tick_unfill")
            self.resetUserTopConst.constant = 45
            self.mailView.isHidden = true
            self.userView.isHidden = false
        }
    }
    
    @IBAction func secuirtyQuestionClicked(_ sender: Any) {
//        let securityController = mainStoryboard.instantiateViewController(withIdentifier: SecurityQuestionController.className) as! SecurityQuestionController
//        securityController.delegate = self
//        // self.pushFromBottom(securityController)
//        self.sheetController = SheetViewController(controller: securityController, sizes: [.fixed(600)])
//        self.sheetController!.overlayColor = UIColor.black.withAlphaComponent(0.3)
//        // self.sheetController!.extendBackgroundBehindHandle = true
//        self.sheetController!.cornerRadius = 20
//        self.present(self.sheetController!, animated: true, completion: nil)
    }
}

extension RecoverPasswordController: UITextFieldDelegate
{
    func securityQuestionSelectedDelegate(data: String, id: String) {
        self.questionID = id
        self.sheetController?.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == usernameField {
//            return (string.isUserValid)
//        }
        return true
    }
}


extension RecoverPasswordController:CountryPickerViewDelegate
{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        phoneCodeLbl.text = country.phoneCode
        countryCode = country.code
    }
    
//    func didSelectLanguage(name: String, code: String, isAppLanguage:Bool) {
//        SharedManager.shared.saveAppLanguageCode(langCode: code)
//        langLbl.text = code
//        self.manageUI()
//    }
}

