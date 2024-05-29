//
//  PhoneVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit
import PhoneNumberKit
import Combine

class PhoneVC: UIViewController {
    
    // MARK: - Properties -
    var country = CountryModel.init()
    var selectedData = RegisterationData()
    var countryCode = ""
    var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - IBOutlets -
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        phoneTF.keyboardType = .asciiCapableNumberPad
        phoneTF.paddingLeft(padding: 8)
        PhoneCodeCheck()
        setLocalizations()
        getResponseMessages()
    }
    
    func getResponseMessages() {
        apiService.errorMessagePublisher
            .sink { msg in
                DispatchQueue.main.async {
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: msg)
                }
            }.store(in: &subscription)
    }
    
    func setLocalizations() {
        phoneTF.placeholder = "Mobile Number".localized()
        titleLbl.text = "What's your mobile number?".localized()
        detailsLbl.text = "Enter the mobile number where you can be contacted. No one will see this on your profile.".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        emailBtn.setTitle("Sign up with email".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func PhoneCodeCheck() {
        let locale = Locale.current
        let countCode = FindPhoneCode.shared.getCountryPhonceCode(locale.regionCode ?? "")
        if countCode != "" {
            country.id = locale.regionCode!
            country.name = countryName(from: locale.regionCode!)
            country.code = "+" + countCode
            selectedData.selectedCountryId = country.id
            selectedData.selectedCountryCode = country.code
        }
    }
    
    func countryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if !validateData() {
            return
        }
        // will check phone number already exist or not
        phonenoVerification()
    }
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        let EmailVC = GetView(nameVC: "EmailVC", nameSB: "Registeration" ) as! EmailVC
        EmailVC.selectedData = selectedData
        navigationController?.pushViewController(EmailVC, animated: true)
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
    
    func validateData () -> Bool {
        if phoneTF.text!.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter your phone number.".localized())
            return false
        }
        if !isNumberValid() {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please enter valid phone number.".localized())
            return false
        }
        return true
    }
    
    func isNumberValid() -> Bool {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let code = country.code
            let number = phoneTF.text ?? .emptyString
            let phoneNumber = code + number
            let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber)
            return phoneNumberKit.isValidPhoneNumber(parsedPhoneNumber.numberString)
        } catch {
            return false
        }
    }
    
    func phonenoVerification() {
        let phone = phoneTF.text ?? .emptyString
        let params: [String: String] = [
            "type": "phone",
            "phone": phone,
            "phone_code": selectedData.selectedCountryCode,
            "country_code": selectedData.selectedCountryId,
        ]
        Loader.startLoading()
        apiService.checkEmailRequest(endPoint: .checkEmail(params))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                case .failure(let errorType):
                    LogClass.debugLog(errorType.localizedDescription)
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: errorType.localizedDescription)
                }
            }, receiveValue: { response in
                Loader.stopLoading()
                if response.meta.message == "Phoneno Validated" {
                    self.selectedData.selectedPhone = phone
                    let PasswordVC = self.GetView(nameVC: "PasswordVC", nameSB: "Registeration" ) as! PasswordVC
                    PasswordVC.selectedData = self.selectedData
                    self.navigationController?.pushViewController(PasswordVC, animated: true)
                } else {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: response.meta.message ?? .emptyString)
                }
            })
            .store(in: &subscription)
    }
}
