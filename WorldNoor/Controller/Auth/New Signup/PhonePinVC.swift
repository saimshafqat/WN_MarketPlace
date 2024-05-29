//
//  PhonePinVC.swift
//  WorldNoor
//
//  Created by Walid Ahmed on 30/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class PhonePinVC: UIViewController,UIGestureRecognizerDelegate {
    
    var createIconClick = true
    var confirmIconClick = true
    
    @IBOutlet weak var confirmEyeBtn: UIButton!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var createTF: UITextField!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        haveAccountBtn.isHidden = false
        createTF.keyboardType = .asciiCapableNumberPad
        confirmTF.keyboardType = .asciiCapableNumberPad
        createTF.paddingLeft(padding: 8)
        confirmTF.paddingLeft(padding: 8)
        createTF.delegate = self
        confirmTF.delegate = self
        setLocalizations()
    }
    
    func setLocalizations() {
        createTF.placeholder = "Create Pin".localized()
        confirmTF.placeholder = "Confirm Pin".localized()
        titleLbl.text = "Create your pin".localized()
        detailsLbl.text = "This 6-digit PIN can be used to change or reset your password.".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    @IBAction func eyeBtnPressed(_ sender: Any) {
        if(createIconClick == true) {
            createTF.isSecureTextEntry = false
            eyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            createTF.isSecureTextEntry = true
            eyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        createIconClick = !createIconClick
    }
    
    @IBAction func confirmEyeBtnPressed(_ sender: Any) {
        if(confirmIconClick == true) {
            confirmTF.isSecureTextEntry = false
            confirmEyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            confirmTF.isSecureTextEntry = true
            confirmEyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        confirmIconClick = !confirmIconClick
    }
    
    func logoutFromApp() {
        

        SharedClass.shared.logoutFromKeychain()
        GoogleSignInManager.signOut()
        FeedCallBManager.shared.videoClipArray.removeAll()
        SocketSharedManager.sharedSocket.closeConnection()
        SharedManager.shared.userObj = nil
        SharedManager.shared.removeProfile()
        RecentSearchRequestUtility.shared.clearFromCache()
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if !validateData() {
            return
        }
        createPin()
    }
    
    func createPin() {
        
        var parameters :[String : Any] = [
            "action": "create/pin",
            "pin" : createTF.text!
        ]
        LogClass.debugLog(parameters)
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { [weak self]response in
            guard let self = self else { return }
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                Loader.stopLoading()
                if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                } else {
                    SharedManager.shared.userObj?.data.screenPin = false
                    SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
                    
                    let alert = UIAlertController(title: "Welcome".localized(),
                                                  message: "You are successfully registered".localized(),
                                                  preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(),
                                                  style: UIAlertAction.Style.default,
                                                  handler: {_ in
                        AppDelegate.shared().loadTabBar()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }, param:parameters)
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        logoutFromApp()
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func validateData () -> Bool {
        if createTF.text!.count != 6 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Pin must be 6 digits.".localized())
            return false
        }
        if confirmTF.text!.count != 6 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Confirm Pin must be 6 digits.".localized())
            return false
        }
        if createTF.text! != confirmTF.text! {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Pin and confirm pin are not matching.".localized())
            return false
        }
        return true
    }
}

extension PhonePinVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}
