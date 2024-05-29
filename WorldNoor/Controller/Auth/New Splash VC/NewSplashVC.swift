//
//  New Splash VC.swift
//  WorldNoor
//
//  Created by apple on 1/14/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import AuthenticationServices

class NewSplashVC : UIViewController {
    
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblOR: UILabel!
    
    @IBOutlet weak var lblSignin: UILabel!
    @IBOutlet weak var lblApple: UILabel!
    @IBOutlet weak var lblGoogle: UILabel!
    
    @IBOutlet weak var lblInfo: UILabel!
    //    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lblbtnSignUp: UILabel!
    //    @IBOutlet weak var lblbtnLogin: UILabel!
    
    //    @IBOutlet weak var viewFree: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedManager.shared.getPermanentlyLanguage()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.infoString()
        self.lblOR.text = "OR".localized()
        self.lblSignin.text = "signin".localized()
        self.lblApple.text = "Continue with Apple".localized()
        self.lblGoogle.text = "Continue with Google".localized()
        self.lblbtnSignUp.text = "Register as new user".localized()
        
        self.navigationController?.navigationBar.isHidden = true
        guard let strValue = UserDefaults.standard.value(forKey: "Lang") as? String else {
            return
        }
        self.lblLanguage.text = SharedManager.shared.getLanguageIDForTop(languageP: strValue)
        self.checkIfUserSessionExist()
        
        SharedClass.shared.clearAllFiles()
    }
    
    
    func infoString(){
        let fontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        //        let WorldAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(named: "Blue Color"), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        //        let NoorAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(named: "Yellow Color"), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        let partOne = NSMutableAttributedString(string: "MeetMillions".localized(), attributes: fontAttributes)
        //        let partWorld = NSMutableAttributedString(string: "World", attributes: WorldAttributes)
        //        let partNoor = NSMutableAttributedString(string: "Noor", attributes: NoorAttributes)
        
        let partWorld = NSMutableAttributedString(string: "World", attributes: fontAttributes)
        let partNoor = NSMutableAttributedString(string: "noor", attributes: fontAttributes)
        
        let combination = NSMutableAttributedString()
        combination.append(partOne)
        combination.append(partWorld)
        combination.append(partNoor)
        self.lblInfo.attributedText = combination
    }
    
    func checkIfUserSessionExist() {
        if UserDefaults.standard.value(forKey: "isStartApp") != nil {
            if let isUserObj:User = SharedManager.shared.getProfile() {
                if isUserObj.data.firstname == nil ||
                    isUserObj.data.lastname == nil ||
                    isUserObj.data.token == nil ||
                    isUserObj.data.id == nil {
                    SharedManager.shared.removeProfile()
                    CoreDbManager.shared.deleteAllEntities()
                } else {
                    SharedManager.shared.userObj = isUserObj
                    //                    self.getLanguages()
                    
                    if SharedManager.shared.userObj!.data.isProfileCompleted! {
                        self.getLanguages()
                    }else {
                        self.getUsernfo()
                    }
                    
                }
            }
        }
        else {
            CoreDbManager.shared.deleteAllEntities()
        }
    }
    func checkScreenPinFlag(){
        //        if SharedManager.shared.userObj?.data.screenPin == true{
        //            self.goToPinScreen()
        //        }else{
        AppDelegate.shared().loadTabBar()
        //        }
    }
    
    func getLanguages(){
        if SharedManager.shared.lanaguageModelArray.count == 0 {
            self.getAPILanguages()
        }else {
            checkScreenPinFlag()
        }
    }
    
    func getAPILanguages(){
        let URLMAin = "meta/languages"
        //        SharedManager.shared.showOnWindow()
        // Loader.startLoading()
        let param = ["action": URLMAin, "token": SharedManager.shared.userToken(), "user_id":String(SharedManager.shared.getUserID())]
        RequestManager.fetchDataGet(Completion: { response in
            // SharedManager.shared.hideLoadingHubFromKeyWindow()
           // Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String { }
            case .success(let res):
                if res is Int {
                    
                }else  if res is String {
                    
                }else {
                    if let valueMain = res as? [[String : Any]] {
                        for indexObj in valueMain {
                            SharedManager.shared.lanaguageModelArray.append(LanguageModel.init(fromDictionary: indexObj))
                        }
                        
                        SharedManager.shared.saveLanguagePermanentally()
                        self.checkScreenPinFlag()
                    }
                }
            }
        }, param:param)
    }
    
    
    @IBAction func chooseLanguage(sender : UIButton){
        let hiddenVC = self.GetView(nameVC: "AppLanguagesVC", nameSB: "EditProfile" ) as! AppLanguagesVC
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    @IBAction func signinAppleAction(_ sender: Any) {
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
    
    @IBAction func loginAction(sender : UIButton){
        let hiddenVC = self.GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    @IBAction func signinWithGoogle(_ sender: Any) {
        
        FileBasedManager.shared.removeImage()
        SharedManager.shared.removeFeedArray()
        FileBasedManager.shared.removeImage(nameImage: "myImageCoverToUpload.jpg")
        GoogleSignInManager.signIn(controller: self) { result in
            guard let user = result?.user else { return }
            let locale = Locale.current
            var firstName = ""
            var lastname = ""
            
            if user != nil {
                if user.profile != nil {
                    firstName = user.profile?.givenName ?? ""
                    lastname = user.profile?.familyName ?? ""
                }
            }
            var parameters :[String : Any] = [
                "action": "google-auth",
                "country": locale.regionCode!,
                "google_id": user.userID as! String,
                //                "google_id": "118044288649852854090",
                "voip_token":SharedManager.shared.callKitToken,
                "device_type":"ios" ,
                "auth_type" : "google",
                "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                "firstname" : firstName ,
                "lastname" : lastname
            ]
            parameters["email"] = user.profile?.email
            //            parameters["email"] = "test030061210@gmail.com"
            
            
            
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    
                    if res is String {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                    } else {
                        let verifDict = res as! NSDictionary
                        self.callingSkipService(token: verifDict["token"] as? String ?? .emptyString)
                    }
                }
            }, param:parameters)
        } errorCompletion: { error in
            self.ShowAlert(message: error.localizedDescription)
        }
    }
    
    @IBAction func signupAction(sender : UIButton){
        let hiddenVC = self.GetView(nameVC: "JoinVC", nameSB: "Registeration" ) as! JoinVC
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func callingSkipService(token:String) {
        
        ChatDBManager.deleteChat()
        
        let parameters = ["action": "login-verify","token":token, "skip_verification": "1"]
        RequestManagerGen.fetchDataPost(Completion: { (response: Result<(User), Error>) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    self.handleFailureResponse(errorMsg: error as! ErrorModel)
                } else {
                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
                }
            case .success(let res):
                self.handleUserResponse(userObj: res)
            }
        }, param:parameters)
    }
    
    
    func handleUserResponse(userObj:User){
        if ResponseKey(rawValue:(userObj.meta?.code)!) == .successResp  {
            SharedManager.shared.userObj = userObj
            SharedManager.shared.userObj?.data.isSocialLogin = true
            SharedManager.shared.saveProfile(userObj: userObj)
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
                    LogClass.debugLog("SharedManager.shared.userEditObj.relationshipArray ===>")
                    LogClass.debugLog(SharedManager.shared.userEditObj.relationshipArray.count)
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
                    
                    if SharedManager.shared.userEditObj.profileImage != nil {
                        if let imageURL = URL(string: SharedManager.shared.userEditObj.profileImage) {
                            // Load the image asynchronously
                            DispatchQueue.global().async {
                                if let imageData = try? Data(contentsOf: imageURL) {
                                    if let image = UIImage(data: imageData) {
                                        // Save the image to the Documents directory
                                        self.saveImageToDocumentsDirectory(image: image, fileName: "myImageToUpload.jpg")
                                    }
                                }
                            }
                        }
                    }
                    self.getLanguages()
                }
            }
        }, param:parameters)
    }
    
    
    func saveImageToDocumentsDirectory(image: UIImage, fileName: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
            }
        }
    }
    
    func handleFailureResponse(errorMsg:ErrorModel){
        if let message = errorMsg.meta?.message   {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}

extension NewSplashVC : ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        return view.window!
    }
    func authorizationController(controller : ASAuthorizationController, didCompleteWithError error : Error) {
        
        
    }
}

extension NewSplashVC : ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller : ASAuthorizationController , didCompleteWithAuthorization authorization : ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential :
            let appleID = credentials.user
            let appleToken = String(data: credentials.identityToken!, encoding: .utf8) ?? ""
            let firstName = credentials.fullName?.givenName ?? ""
            let lastName = credentials.fullName?.familyName ?? ""
            let email = credentials.email ?? ""
            
            let locale = Locale.current
            
            if locale != nil {
                var parameters :[String : Any] = [
                    "action": "google-auth",
                    "country": locale.regionCode ?? "+1",
                    "google_token": appleToken,
                    "google_id": appleID,
                    "voip_token":SharedManager.shared.callKitToken,
                    "device_type":"ios" ,
                    "auth_type" : "apple",
                    "firstname" : firstName,
                    "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                    "lastname" : lastName
                ]
                parameters["email"] = email
                self.sendAppleDatatoServer(parameters: parameters)
            }else {
                var parameters :[String : Any] = [
                    "action": "google-auth",
                    "country": "+1",
                    "google_id": appleID,
                    "voip_token":SharedManager.shared.callKitToken,
                    "device_type":"ios" ,
                    "auth_type" : "apple",
                    "google_token": appleToken,
                    "firstname" : firstName,
                    "os" : ProcessInfo().operatingSystemVersion.getFullVersion(),
                    "lastname" : lastName
                ]
                parameters["email"] = email
                self.sendAppleDatatoServer(parameters: parameters)
            }
            
            break
        default:
            break
            
        }
    }
    
    func sendAppleDatatoServer(parameters : [String : Any]) {
        
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
                    let verifDict = res as! NSDictionary
                    self.callingSkipService(token: verifDict["token"] as! String ?? "")
                }
            }
        }, param:parameters)
    }
}
