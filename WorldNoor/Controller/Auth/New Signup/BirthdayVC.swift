//
//  BirthdayVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit

class BirthdayVC: UIViewController {
    
    var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd MMM yyyy"
      formatter.locale = Locale(identifier: "en_US")
      return formatter
    }()
    var selectedData = RegisterationData()

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var birthdateLbl: UILabel!
    @IBOutlet weak var birthdatebgV: UIView!
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
        birthdatebgV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(birthdatebgVTapped(gesture:))))
        birthdatebgV.isUserInteractionEnabled = true
        setLocalizations()
    }
    func setLocalizations(){
        titleLbl.text = "What's your birthday?".localized()
        detailsLbl.text = "Choose your date of birth.".localized()
        birthdateLbl.text = "Birthday".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    @objc func birthdatebgVTapped(gesture: UIGestureRecognizer) {
        let dateMain = DatePickerDialog.init(textColor: UIColor.black , buttonColor: UIColor.themeBlueColor, font: UIFont.boldSystemFont(ofSize: 12.0), locale: Locale.current, showCancelButton: true)
        dateMain.show("Date Of Birth".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: selectedData.selectedBirthDate ?? (Date().dateByAddingYears(-16)), minimumDate: nil, maximumDate: Date().dateByAddingYears(-16), datePickerMode: .date) {[weak self]
            (date) -> Void in
            guard let self = self else{return}
            if let dt = date{
                self.selectedData.selectedBirthDate = dt
                self.birthdateLbl.textColor = .black
                self.birthdateLbl.text = self.dateFormatter.string(from: dt)
                self.selectedData.setBirthdayString()
            }
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if !validateData() {
            return
        }
        let GenderVC = GetView(nameVC: "GenderVC", nameSB: "Registeration" ) as! GenderVC
        GenderVC.selectedData = selectedData
        navigationController?.pushViewController(GenderVC, animated: true)
    }
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
    func validateData ()->Bool {
        if selectedData.selectedBirthDateStr.isEmpty {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body:"Please choose your date of birth.".localized())
            return false
        }
        if checkIfUserYongerThanThirteen(){
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body:"You must be at least 13 years old".localized())
            return false
        }
        return true
    }
    func checkIfUserYongerThanThirteen() -> Bool{
        let dateOfBirth = selectedData.selectedBirthDate ?? Date()
        let today = Date()
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let age = gregorian.components([.year], from: dateOfBirth, to: today, options: [])

        if age.year! < 14 {
            return true
        }else{
            return false
        }
    }
}
