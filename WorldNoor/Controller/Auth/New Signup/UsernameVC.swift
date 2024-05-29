//
//  UsernameVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit

class UsernameVC: UIViewController {
    
    var selectedData = RegisterationData()
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
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
        firstNameTF.paddingLeft(padding: 8)
        lastNameTF.paddingLeft(padding: 8)
        setLocalizations()
        
        lastNameTF.delegate = self
        firstNameTF.delegate = self
    }
    
    func setLocalizations() {
        titleLbl.text = "What's your name?".localized()
        detailsLbl.text = "Enter the name you use in real life.".localized()
        firstNameTF.placeholder = "First Name".localized()
        lastNameTF.placeholder = "Last Name".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if !validateData() {
            return
        }
        selectedData.selectedFirstName = firstNameTF.text!
        selectedData.selectedLastName = lastNameTF.text!
        let BirthdayVC = GetView(nameVC: "BirthdayVC", nameSB: "Registeration" ) as! BirthdayVC
        BirthdayVC.selectedData = selectedData
        navigationController?.pushViewController(BirthdayVC, animated: true)
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func validateData () -> Bool {
        
        if firstNameTF.text!.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Enter your first name.")
            return false
        }
        if lastNameTF.text!.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Enter your last name.".localized())
            return false
        }
        
//        if firstNameTF.text!.count < 1 {
//            SharedManager.shared.showPopupview(message: "First name must be at least 1 charcters.".localized())
//            return false
//        }
//        if lastNameTF.text!.count < 1 {
//            SharedManager.shared.showPopupview(message: "Last name must be at least 1 charcters.".localized())
//            return false
//        }
        
        if lastNameTF.text!.contains(" ") || firstNameTF.text!.contains(" ") {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "First name and Last name not accpet spaces.".localized())
            return false
        }
        
        if !(firstNameTF.text!.containsOnlyLettersAndWhitespace()) || !(lastNameTF.text!.containsOnlyLettersAndWhitespace()) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "First name and Last name must be alphabtic only".localized())
            return false
        }
      
            
        // first name should start with number
//        let firstCharcter = firstNameTF.text?.first
//        if firstCharcter?.isWholeNumber ?? false {
//            SharedManager.shared.showPopupview(message: "First name should not start with number".localized())
//            return false
//        }
        
        return true
    }
}

extension UsernameVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, 
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let maxLength = 55
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}


extension String {
    func containsOnlyLettersAndWhitespace() -> Bool {
        let allowed = CharacterSet.letters
        return unicodeScalars.allSatisfy(allowed.contains)
    }
}
