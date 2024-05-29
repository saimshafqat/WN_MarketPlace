//
//  PasswordVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit

class PasswordVC: UIViewController {
    
    var iconClick = true
    var selectedData = RegisterationData()
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
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
        passwordTF.paddingLeft(padding: 8)
        setLocalizations()
    }
    
    func setLocalizations() {
        
        passwordTF.placeholder = "Password".localized()
        titleLbl.text = "Create a password".localized()
        detailsLbl.text = "Create a password with at least 8 letters or numbers. It should be something others can't guess.".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func eyeBtnPressed(_ sender: Any) {
        
        if(iconClick == true) {
            passwordTF.isSecureTextEntry = false
            eyeBtn.setImage(UIImage(named: "unhiddeneyeIcon"), for: .normal)
        } else {
            passwordTF.isSecureTextEntry = true
            eyeBtn.setImage(UIImage(named: "hiddenEyeIcon"), for: .normal)
        }
        iconClick = !iconClick
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if !validatePassword() {
//            SharedManager.shared.showPopupview(message: "Password must be Minimum 8 characters, at least 1 Uppercase letter, 1 Lowercase latter, 1 Number and 1 Special Character.".localized())
            return
        }
        selectedData.selectedPassword = passwordTF.text!
        let RegisterationTermsVC = GetView(nameVC: "RegisterationTermsVC",
                                           nameSB: "Registeration" ) as! RegisterationTermsVC
        RegisterationTermsVC.selectedData = selectedData
        self.navigationController?.pushViewController(RegisterationTermsVC, animated: true)
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        self.navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func validatePassword () -> Bool {
        
//        let password = passwordTF.text
//        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
//        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
//
        //------old code -------------
        if passwordTF.text!.count < 8 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Password must be 8-200 characters long.".localized())
            return false
        }
        return true
    }
}
