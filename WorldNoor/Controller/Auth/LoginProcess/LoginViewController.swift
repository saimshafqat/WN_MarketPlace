//
//  LoginViewController.swift
//  WorldNoor
//
//  Created by apple on 9/4/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import GoogleSignIn
import GoogleSignIn
import AuthenticationServices

//test commit

//localcommit
class LoginViewController: UIViewController  , UITextFieldDelegate{
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var lblApple: UILabel!
    @IBOutlet weak var btnGoogle: UIButton!
    
    
    @IBOutlet weak var appleSigninView: UIView!
    @IBOutlet weak var viewPhone: UIView!{
        didSet {
            viewPhone.roundedLeftTopBottom()
        }
    }
    
    var isSocialLogin : Bool = false
    
    let pickerView = CountryPickerView()
    var countryCode = ""
    @IBOutlet weak var phoneNumbLblView: UIView!{
        didSet {
            phoneNumbLblView.roundRight(bordorColor: UIColor.themeBlueColor, borderWidth: 0.5)
        }
    }
    
    @IBOutlet weak var phoneNumbView: UIView!{
        didSet {
            phoneNumbView.roundedLeftTopBottom()
        }
    }
    @IBOutlet weak var phonecodeBtn: UIButton!
    
    @IBOutlet weak var phoneCodeLbl: UILabel!{
        didSet{
            phoneCodeLbl.makeFontDynamicBody()
        }
    }
    
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginbBtn: UIButton!
    @IBOutlet weak var textHideShowBtn: UIButton!
    @IBOutlet weak var imgvieweye: UIImageView!
    @IBOutlet weak var imgviewLogo: UIImageView!
    @IBOutlet weak var lblSignup: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var lblRegister: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblDontAccount: UILabel!
    @IBOutlet weak var lblForGotPassword: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPhone.isHidden = true
//        self.emailTF.delegate = self

        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            phoneCodeLbl.text = "+" + countCode
            self.countryCode = locale.regionCode ?? ""
        }
        if UserDefaults.standard.value(forKey: "isStartApp") != nil {
            self.checkIfUserSessionExist()
        }
    }
    
    
    func isNumberValid() -> Bool {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let code = phoneCodeLbl.text ?? .emptyString
            let number = emailTF.text ?? .emptyString
            let phoneNumber = code + number
            let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber)
            return phoneNumberKit.isValidPhoneNumber(parsedPhoneNumber.numberString)
        } catch {
            return false
        }
    }
    
    
    @IBAction func continueWithGoogle(_ sender: Any)
    {
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage()
        self.isSocialLogin = true
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        GoogleSignInManager.signIn(controller: self) { result in
            guard let user = result?.user else { return }
            let locale = Locale.current
            var parameters :[String : Any] = [
                "action": "google-auth",
                "country": locale.regionCode!,
                "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                "google_id": user.userID!,
                "voip_token":SharedManager.shared.callKitToken,
                "device_type":"ios" ,
                "firstname" : user.profile?.givenName ?? "",
                "lastname" : user.profile?.familyName ?? ""
            ]
            parameters["email"] = user.profile?.email
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                switch response {
                case .failure(let error):
                    Loader.stopLoading()
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is String {
                        Loader.stopLoading()
                        SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                    }else {
                        let verifDict = res as! NSDictionary
                        self.callingSkipService(token: verifDict["token"] as! String ?? "")

                    }
                }
            }, param:parameters)
        } errorCompletion: { error in
            self.ShowAlert(message: error.localizedDescription)
        }
    }
    
    @IBAction func appleSigninAction(_ sender: Any) {
        FileBasedManager.shared.removeImage()
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        let provider = ASAuthorizationAppleIDProvider()
                let request = provider.createRequest()
                request.requestedScopes = [.fullName , .email]
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests()

    }
    
    @IBAction func phoneCodeBtn(_ sender: UIButton) {
        pickerView.delegate = self
        pickerView.showCountriesList(from: self)
    }
    
    
    func getLanguages(){
        self.getAPILanguages()
    }
    
    func getAPILanguages() {
        
        let URLMAin = "meta/languages"
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let param = ["action": URLMAin, "token": SharedManager.shared.userToken(), "user_id":String(SharedManager.shared.getUserID())]
        
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String { }
            case .success(let res):
                if res is Int {

                } else  if res is String {

                } else {
                    if let valueMain = res as? [[String : Any]] {
                        for indexObj in valueMain {
                            SharedManager.shared.lanaguageModelArray.append(LanguageModel.init(fromDictionary: indexObj))
                        }
                        
                        SharedManager.shared.saveLanguagePermanentally()
//                        if SharedManager.shared.userObj?.data.screenPin == true {
//                            self.goToPinScreen()
//                        } else{
                            AppDelegate.shared().loadTabBar()
//                        }
                    }
                }
            }
        }, param:param)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FileBasedManager.shared.removeImage()
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        
        self.viewPhone.isHidden = true
        self.view.rotateViewForLanguage()
        self.emailTF.placeholder = "Your Email Address".localized()
        self.lblForGotPassword.text = "Forgot Password?".localized()
        self.loginbBtn.setTitle("LOG IN".localized(), for: .normal)
        self.lblSignup.text = "it's free!".localized()
        self.passwordTF.placeholder = "Your Password".localized()
        self.lblDontAccount.text = "New User?".localized()
        self.lblRegister.text = "Register".localized()
        self.lblApple.text = "Continue with Apple".localized()
        self.btnGoogle.setTitle("Continue with Google".localized(), for: .normal)
        self.emailTF.rotateViewForLanguage()
        self.lblApple.rotateViewForLanguage()
        self.btnGoogle.rotateViewForLanguage()
        self.passwordTF.rotateViewForLanguage()
        self.emailTF.rotateForLanguage()
        self.passwordTF.rotateForLanguage()
        
        self.lblInfo.rotateViewForInner()
        self.lblInfo.rotateForTextAligment()
        
        self.loginbBtn.rotateViewForInner()
        
        self.lblSignup.rotateViewForInner()
        self.lblSignup.rotateForTextAligment()
        
        self.lblDontAccount.rotateViewForInner()
        self.lblDontAccount.rotateForTextAligment()
        
        self.lblRegister.rotateViewForInner()
        self.lblRegister.rotateForTextAligment()
        
        self.lblHeading.rotateViewForInner()
        self.lblHeading.rotateForTextAligment()
        
        self.lblForGotPassword.rotateViewForInner()
        self.lblForGotPassword.rotateForTextAligment()
        self.lblApple.rotateForTextAligment()
//        self.btnGoogle.rotateForTextAligment()
        
        self.imgviewLogo.rotateViewForLanguage()

        self.lblInfo.text = "Login button to continue".localized()
        
        self.lblHeading.text = "LOGIN".localized()
        self.navigationController?.navigationBar.isHidden = true

        guard let strValue = UserDefaults.standard.value(forKey: "Lang") as? String else {
            return
        }
        
        
        self.emailTF.attributedPlaceholder = NSAttributedString(
            string: self.emailTF.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        
        self.passwordTF.attributedPlaceholder = NSAttributedString(
            string: self.passwordTF.placeholder!,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        
        self.lblLanguage.text = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        
        
        
        self.lblLanguage.rotateViewForInner()
        self.lblLanguage.rotateForTextAligment()
        self.emailTF.text = "moeezakramghauri@gmail.com"
        self.passwordTF.text = "12345678"
    }
    func checkIfUserSessionExist(){
        if let isUserObj:User = SharedManager.shared.getProfile() {
            SharedManager.shared.userObj = isUserObj
            self.getLanguages()
        }
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        
        let locale = Locale.current
        
        
        if self.validateData()  {
            self.isSocialLogin = false
            var parameters = [
                "action": "login",
                "country": locale.regionCode!,
                "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                "password": self.passwordTF.text!,
                "voip_token":SharedManager.shared.callKitToken,
                "device_type":"ios"
            ]
            
            parameters["country_code"] = self.phoneCodeLbl.text!
            parameters["email"] = self.emailTF.text!

            
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                switch response {
                case .failure(let error):
                    Loader.stopLoading()
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is String {
                        Loader.stopLoading()
                        if (res as? String) == "Email not verified" {
                            let hiddenVC = self.GetView(nameVC: "NewCodeSingupVC", nameSB: "Main" ) as! NewCodeSingupVC
                            hiddenVC.phoneSignup = self.emailTF.text!
                            hiddenVC.tfPassword = self.passwordTF.text!
                            self.navigationController?.pushViewController(hiddenVC, animated: true)
                        }else {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        }
                        
                    }else {
                        let verifDict = res as! NSDictionary
                        self.callingSkipService(token: verifDict["token"] as? String ?? .emptyString)

                    }
                }
            }, param:parameters)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func callingSkipService(token:String) {
        
        ChatDBManager.deleteChat()
        
        let parameters = ["action": "login-verify","token":token, "skip_verification": "1"]
        RequestManagerGen.fetchDataPost(Completion: { (response: Result<(User), Error>) in
            
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                LogClass.debugLog("res  ==>")
                LogClass.debugLog(res)
                self.handleUserResponse(userObj: res)
            }
        }, param:parameters)
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        let hiddenVC = self.GetView(nameVC: "JoinVC", nameSB: "Registeration" ) as! JoinVC
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    @IBAction func textHideShow(_ sender: Any) {
        if self.passwordTF.isSecureTextEntry {
            self.passwordTF.isSecureTextEntry = false
            self.imgvieweye.image = UIImage.init(named: "NewHide-eye.png")
        }else
        {
            self.passwordTF.isSecureTextEntry = true
            self.imgvieweye.image = UIImage.init(named: "NewEye.png")
        }
    }
    @IBAction func chooseLanguage(sender : UIButton){
        let hiddenVC = self.GetView(nameVC: "AppLanguagesVC", nameSB: "EditProfile" ) as! AppLanguagesVC
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
}

// Response Handling...

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}

extension LoginViewController   {
    
    
    func validateData ()->Bool {
        guard let emailText = self.emailTF.text, !emailText.isEmpty else {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValid.localized())
            return false
        }
        
        if !emailText.isNumber {
            if !emailText.isValidEmail(){
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.emailValid.localized())
                return false
            }else if self.passwordTF.text!.isEmpty {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValidNEw.localized())
                return false
            }
        }else {
            if !isNumberValid(){
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number.".localized())
                return false
            } else if self.emailTF.text!.isEmpty {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValidNEw.localized())
                return false
            }else if self.passwordTF.text!.isEmpty {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: Const.paswordValidNEw.localized())
                return false
            }
        }
        return true
    }
   
    func handleUserResponse(userObj:User){
        if ResponseKey(rawValue:(userObj.meta?.code)!) == .successResp  {
            SharedManager.shared.userObj = userObj
            SharedManager.shared.userObj?.data.isSocialLogin = self.isSocialLogin
            SharedManager.shared.saveProfile(userObj: userObj)
            
                if let profile_image = SharedManager.shared.userObj?.data.profile_image as? String {
                    SharedManager.shared.downloadProfileImage(filePAth: profile_image)
                }
                
                if let profile_image = SharedManager.shared.userObj?.data.cover_image as? String {
                    SharedManager.shared.downloadProfileCover(filePAth: profile_image)
                }

            SharedClass.shared.saveXDataApp()
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
                    
                    self.getLanguages()
                }
                

                
            }
        }, param:parameters)
    }
}


extension LoginViewController: CountryPickerViewDelegate
{
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        phoneCodeLbl.text = country.phoneCode
        countryCode = country.code
    }
    
    @IBAction func loginAction(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController : ASAuthorizationControllerDelegate
{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        return view.window!
    }
    func authorizationController(controller : ASAuthorizationController, didCompleteWithError error : Error)
    {

    }
}
extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
   
    func authorizationController(controller : ASAuthorizationController , didCompleteWithAuthorization authorization : ASAuthorization)
    {
        
        SharedManager.shared.removeFeedArray()
        switch authorization.credential
        {
        case let credentials as ASAuthorizationAppleIDCredential :
            let appleID = credentials.user
            let firstName = credentials.fullName?.givenName ?? ""
            let lastName = credentials.fullName?.familyName ?? ""
            let email = credentials.email ?? ""
            let appleToken = String(data: credentials.identityToken!, encoding: .utf8) ?? ""
            
            self.isSocialLogin = true
            let locale = Locale.current
            var parameters :[String : Any] = [
                "action": "google-auth",
                "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                "country": locale.regionCode!,
                "google_id": appleID,
                "voip_token":SharedManager.shared.callKitToken,
                "device_type":"ios" ,
                "auth_type" : "apple",
                "google_token": appleToken,
                "firstname" : firstName,
                "lastname" : lastName
        ]
                parameters["email"] = email
            self.sendAppleDatatoServer(parameters: parameters)
            break
        default:
            break
            
        }
        
    }
    
    
  
    func sendAppleDatatoServer(parameters : [String : Any])
    {
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is String {
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                }else {
                    let verifDict = res as? NSDictionary
                    self.callingSkipService(token: verifDict?["token"] as? String ?? .emptyString)

                }
            }
        }, param:parameters)
    }
}


extension OperatingSystemVersion {
    func getFullVersion(separator: String = ".") -> String {
        return "\(majorVersion)\(separator)\(minorVersion)\(separator)\(patchVersion)"
    }
}
