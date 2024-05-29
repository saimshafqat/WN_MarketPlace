//
//  EmailVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit
import Combine
import Alamofire

class EmailVC: UIViewController {
    
    var selectedData = RegisterationData()
    var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI(){
        emailTF.paddingLeft(padding: 8)
        setLocalizations()
    }
    func setLocalizations(){
        emailTF.placeholder = "Email".localized()
        titleLbl.text = "What's your email?".localized()
        detailsLbl.text = "Enter the email where you can be contacted. No one will see this on your profile.".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        phoneBtn.setTitle("Sign up with mobile number".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        if !validateData() {
            return
        }
        emailVerificaiton()
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func validateData ()->Bool {
        if emailTF.text!.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your email address.".localized())
            return false
        }
        if !EmailValidationOnstring(strEmail: emailTF.text!.replacingOccurrences(of: " ", with: "")) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid email address.".localized())
            return false
        }
        return true
    }
    
    
    func emailVerificaiton() {
        
        let email = emailTF.text!.replacingOccurrences(of: " ", with: "")
        let parameters: [String: String] = [
            "email": email,
            "type": "email",
            "action": "check-email",
        ]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { [weak self]response in
            guard let self = self else{return}
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                let msg = res as? String ?? .emptyString
                if msg == "Eamil Validated" {
                    self.selectedData.resetPhone()
                    self.selectedData.selectedEmail = email
                    let PasswordVC = self.GetView(nameVC: "PasswordVC", nameSB: "Registeration") as! PasswordVC
                    PasswordVC.selectedData = self.selectedData
                    self.navigationController?.pushViewController(PasswordVC, animated: true)
                } else {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                }
            }
        }, param:parameters)
    }
}
