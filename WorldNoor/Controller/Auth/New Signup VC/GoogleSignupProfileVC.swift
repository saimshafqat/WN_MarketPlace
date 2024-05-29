//
//  GoogleSignupProfileVC.swift
//  WorldNoor
//
//  Created by Lucky on 23/09/2022.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import UIKit
import CountryPickerView
import GoogleSignIn

class GoogleSignupProfileVC: UIViewController, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    var DOB = ""
    var month = ""
    var year = ""
    var day = ""
    var isSelectTerms : Bool = true
    
    var isNextTap : Bool = false
    
    var gender = ""
    var CustomgenderTitle = ""
    var CustomgenderDescription = ""
    var CustomgenderText = ""
    var pronounTxt = ""
    
    let arrayMonth = ["January","February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December"]
    let genderArray = ["Agender","Androgynous","Bigender","Cis","Cis Female","Cis Male","Cis Man","Cis Women","Cisgender","Cisgneder Male","Cisgender Female","Cisgender Man","Cisgender Woman","Female to Male","FTM","Gender Fluid","Gender Identity","Gender","Gender Nonconforming"]
    let countryPickerView = CountryPickerView()
    var country = CountryModel.init()
    @IBOutlet weak var tableSignup: UITableView!
    @IBOutlet weak var viewGray: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableSignup.register(UINib.init(nibName: "SUBackCell", bundle: nil), forCellReuseIdentifier: "SUBackCell")
        self.tableSignup.register(UINib.init(nibName: "SUCountryCell", bundle: nil), forCellReuseIdentifier: "SUCountryCell")
        self.tableSignup.register(UINib.init(nibName: "SULogoCell", bundle: nil), forCellReuseIdentifier: "SULogoCell")
        self.tableSignup.register(UINib.init(nibName: "SUGenderCell", bundle: nil), forCellReuseIdentifier: "SUGenderCell")
        self.tableSignup.register(UINib.init(nibName: "SUButtonCell", bundle: nil), forCellReuseIdentifier: "SUButtonCell")
        self.tableSignup.register(UINib.init(nibName: "SUButtonLogoutCell", bundle: nil), forCellReuseIdentifier: "SUButtonLogoutCell")
        self.tableSignup.register(UINib.init(nibName: "SUCustomGenderCell", bundle: nil), forCellReuseIdentifier: "SUCustomGenderCell")
        
        self.tableSignup.register(UINib.init(nibName: "SignupTextViewCell", bundle: nil), forCellReuseIdentifier: "SignupTextViewCell")
        self.tableSignup.register(UINib.init(nibName: "SUTFCell", bundle: nil), forCellReuseIdentifier: "SUTFCell")
        self.country.id = Locale.current.regionCode!
        self.country.name = self.countryName(from: Locale.current.regionCode!)
        // Do any additional setup after loading the view.
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
    func getTotalDays() -> Int {
        let dateComponents = DateComponents(year: Int(self.year), month: (self.arrayMonth.firstIndex(of: self.month)!) + 1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        
        
        if self.isNextTap {
            if SUSecondOptions.allCases[indexPath.row] == .SUCGender {
                if self.gender.count > 0 && self.gender != "M" && self.gender != "F"{
                    return UITableView.automaticDimension
                }else {
                    return 0
                }
            }
        }
        
        
        
        return UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isNextTap {
            return SUSecondOptions.allCases.count
        }
        
        return SUNewOptions.allCases.count
        
    }
                 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if self.isNextTap {
            
//            if SUSecondOptions.allCases[indexPath.row] == .SUBack {
//                let cellBack = tableView.dequeueReusableCell(withIdentifier: "SUBackCell", for: indexPath) as! SUBackCell
//
//                cellBack.btnBack.addTarget(self, action: #selector(self.firstStep), for: .touchUpInside)
//                cellBack.selectionStyle = .none
//                return cellBack
//            }
            if SUSecondOptions.allCases[indexPath.row] == .SULogo {
                let cellLogo = tableView.dequeueReusableCell(withIdentifier: "SULogoCell", for: indexPath) as! SULogoCell
                
                cellLogo.lblHeading.text = "Complete Your Profile".uppercased()
                cellLogo.userLbl.text = "Welcome " + (SharedManager.shared.userObj?.data.firstname?.uppercased() ?? "") + " " + (SharedManager.shared.userObj?.data.lastname?.uppercased() ?? "")
                cellLogo.lblHeading.rotateViewForInner()
                cellLogo.lblHeading.rotateForTextAligment()
                cellLogo.lblHeading.textAlignment = .center
                cellLogo.userLbl.textAlignment = .center
                cellLogo.btnback.addTarget(self, action: #selector(self.firstStep), for: .touchUpInside)
                cellLogo.viewBack.isHidden = false
                return cellLogo
            }
            if SUSecondOptions.allCases[indexPath.row] == .SUBtn {
                let cellBtn = tableView.dequeueReusableCell(withIdentifier: "SUButtonCell", for: indexPath) as! SUButtonCell
                
                cellBtn.viewLine.isHidden = true
                
                cellBtn.btnMain.tag = indexPath.row
                cellBtn.lblHeading.text = SUSecondOptions.allCases[indexPath.row].rawValue.localized()
                cellBtn.btnMain.addTarget(self, action: #selector(self.CompleteProfile), for: .touchUpInside)
                
                cellBtn.viewBG.backgroundColor = UIColor.themeBlueColor
                
                cellBtn.lblHeading.textColor = UIColor.white
                cellBtn.lblHeading.rotateViewForInner()
                cellBtn.lblHeading.rotateForTextAligment()
                
                cellBtn.selectionStyle = .none
                return cellBtn
                
            }
            
            if SUSecondOptions.allCases[indexPath.row] == .SUCGender {
                let cellGender = tableView.dequeueReusableCell(withIdentifier: "SUCustomGenderCell", for: indexPath) as! SUCustomGenderCell
                
//                if self.CustomgenderTitle.count > 0 {
//                    self.gender = self.CustomgenderTitle
//                }
                
                cellGender.customTitleLbl.text = self.CustomgenderTitle
                self.pronounTxt = self.CustomgenderTitle
                cellGender.genderTF.text = self.CustomgenderText
                cellGender.genderTF.tag = 100
                cellGender.genderTF.delegate = self
                cellGender.btnDropDown.tag = indexPath.row
                cellGender.genderTF.returnKeyType = .done
                cellGender.btnDropDown.addTarget(self, action: #selector(self.showDropDown), for: .touchUpInside)
                cellGender.genderTF.delegate = self
                cellGender.selectionStyle = .none
                return cellGender
            }
            if SUSecondOptions.allCases[indexPath.row] == .SUGender {
                let cellcountry = tableView.dequeueReusableCell(withIdentifier: "SUGenderCell", for: indexPath) as! SUGenderCell
                
                
                cellcountry.tfMale.placeholder = "Male".localized()
                cellcountry.tfFemale.placeholder = "Female".localized()
                cellcountry.tfCustom.placeholder = "Custom".localized()
                cellcountry.tfMale.backgroundColor = UIColor.white
                cellcountry.tfFemale.backgroundColor = UIColor.white
                if(self.gender == "M")
                {
                    cellcountry.tfMale.backgroundColor = UIColor.yellow
                    cellcountry.tfMale.textColor = UIColor.white
                    cellcountry.tfFemale.backgroundColor = UIColor.white
                    cellcountry.tfFemale.textColor = UIColor.black
                    cellcountry.tfCustom.backgroundColor = UIColor.white
                }
                else if(self.gender == "F")
                {
                    cellcountry.tfMale.backgroundColor = UIColor.white
                    cellcountry.tfFemale.backgroundColor = UIColor.yellow
                    cellcountry.tfFemale.textColor = UIColor.white
                    cellcountry.tfMale.textColor = UIColor.black
                    cellcountry.tfCustom.backgroundColor = UIColor.white
                    
                }
                else if(self.genderArray.contains(self.gender))
                {
                    cellcountry.tfCustom.text = self.gender
                    cellcountry.tfCustom.backgroundColor = UIColor.yellow
                    cellcountry.tfFemale.backgroundColor = UIColor.white
                    cellcountry.tfMale.backgroundColor = UIColor.white
                }
                
                cellcountry.tfMale.rotateViewForInner()
                
                cellcountry.tfFemale.rotateViewForInner()
                
                cellcountry.tfCustom.rotateViewForInner()
                
                
                
                cellcountry.tfMale.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfMale.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )
                
                
                
                cellcountry.tfFemale.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfFemale.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )
                
                
                cellcountry.tfCustom.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfCustom.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )
                
                cellcountry.tfMale.tag = -11
                cellcountry.tfFemale.tag = -22
                cellcountry.tfCustom.tag = -33
                
                cellcountry.tfMale.delegate = self
                cellcountry.tfFemale.delegate = self
                cellcountry.tfCustom.delegate = self
                
                
                cellcountry.lblHeading.rotateViewForInner()
                cellcountry.lblHeading.rotateForTextAligment()
                
                cellcountry.lblInfo.rotateViewForInner()
                cellcountry.lblInfo.rotateForTextAligment()
                
                
                cellcountry.lblHeading.text = SUSecondOptions.allCases[indexPath.row].rawValue.localized()
                
                cellcountry.selectionStyle = .none
                return cellcountry
            }
            
            
            let cellBtn = tableView.dequeueReusableCell(withIdentifier: "SUButtonLogoutCell", for: indexPath) as! SUButtonLogoutCell
            cellBtn.lblHeading.text = SUSecondOptions.allCases[indexPath.row].rawValue.localized()
            cellBtn.btnMain.tag = indexPath.row
            cellBtn.btnMain.addTarget(self, action: #selector(self.logoutAction), for: .touchUpInside)
            cellBtn.viewLine.isHidden = false
            cellBtn.viewBG.backgroundColor = UIColor.clear
            
            cellBtn.lblHeading.textColor = UIColor.themeBlueColor
            cellBtn.lblHeading.rotateViewForInner()
            cellBtn.lblHeading.rotateForTextAligment()
            
            cellBtn.selectionStyle = .none
            return cellBtn
        }

            if SUNewOptions.allCases[indexPath.row] == .SUDOB {
                let cellcountry = tableView.dequeueReusableCell(withIdentifier: "SUCountryCell", for: indexPath) as! SUCountryCell

                cellcountry.lblInfo.text = "age 18 year".localized()

                cellcountry.tfDay.placeholder = "Day".localized()
                cellcountry.tfMonth.placeholder = "Month".localized()
                cellcountry.tfYear.placeholder = "Year".localized()


                cellcountry.tfDay.rotateViewForInner()

                cellcountry.tfMonth.rotateViewForInner()

                cellcountry.tfYear.rotateViewForInner()



                cellcountry.tfDay.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfDay.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )



                cellcountry.tfMonth.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfMonth.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )


                cellcountry.tfYear.attributedPlaceholder = NSAttributedString(
                    string: cellcountry.tfYear.placeholder!,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                )

                cellcountry.tfDay.text = day
                cellcountry.tfMonth.text = month
                cellcountry.tfYear.text = year

                cellcountry.tfDay.tag = -300
                cellcountry.tfMonth.tag = -200
                cellcountry.tfYear.tag = -100

                cellcountry.tfDay.delegate = self
                cellcountry.tfMonth.delegate = self
                cellcountry.tfYear.delegate = self


                cellcountry.lblHeading.rotateViewForInner()
                cellcountry.lblHeading.rotateForTextAligment()

                cellcountry.lblInfo.rotateViewForInner()
                cellcountry.lblInfo.rotateForTextAligment()


                cellcountry.lblHeading.text = SUNewOptions.allCases[indexPath.row].rawValue.localized()

                cellcountry.selectionStyle = .none
                return cellcountry
            }
            
            if SUNewOptions.allCases[indexPath.row] == .SUTextView {
               let cellText = tableView.dequeueReusableCell(withIdentifier: "SignupTextViewCell", for: indexPath) as! SignupTextViewCell
               
               self.managePrivacyPolicy(textView: cellText.tVMain)
               cellText.btnSelect.addTarget(self, action: #selector(self.selectTermsAction), for: .touchUpInside)
               
               
               cellText.tVMain.rotateForLanguage()
               cellText.tVMain.rotateViewForLanguage()
               
               cellText.btnSelect.tag = indexPath.row
               cellText.selectionStyle = .none
               return cellText
           }
            
            if SUNewOptions.allCases[indexPath.row] == .SULogo {
                let cellLogo = tableView.dequeueReusableCell(withIdentifier: "SULogoCell", for: indexPath) as! SULogoCell
                cellLogo.viewBack.isHidden = true
                cellLogo.lblHeading.text = "Complete Your Profile".uppercased()
                cellLogo.userLbl.text = "Welcome " + (SharedManager.shared.userObj?.data.firstname?.uppercased() ?? "") + " " + (SharedManager.shared.userObj?.data.lastname?.uppercased() ?? "")
                cellLogo.lblHeading.rotateViewForInner()
                cellLogo.lblHeading.rotateForTextAligment()
                cellLogo.lblHeading.textAlignment = .center
                cellLogo.userLbl.textAlignment = .center

                return cellLogo
            }
            if SUNewOptions.allCases[indexPath.row] == .SUBtn {
                let cellBtn = tableView.dequeueReusableCell(withIdentifier: "SUButtonCell", for: indexPath) as! SUButtonCell

                cellBtn.viewLine.isHidden = true

                cellBtn.btnMain.tag = 100
                cellBtn.lblHeading.text = SUNewOptions.allCases[indexPath.row].rawValue.localized()
                cellBtn.btnMain.addTarget(self, action: #selector(self.CompleteProfile), for: .touchUpInside)

                cellBtn.viewBG.backgroundColor = UIColor.themeBlueColor
                if self.isSelectTerms {
                    cellBtn.viewBG.backgroundColor = UIColor.lightGray
                }

                cellBtn.lblHeading.textColor = UIColor.white
                cellBtn.lblHeading.rotateViewForInner()
                cellBtn.lblHeading.rotateForTextAligment()

                cellBtn.selectionStyle = .none
                return cellBtn

            }
        
            let cellBtn = tableView.dequeueReusableCell(withIdentifier: "SUButtonLogoutCell", for: indexPath) as! SUButtonLogoutCell
            cellBtn.lblHeading.text = SUNewOptions.allCases[indexPath.row].rawValue.localized()
            cellBtn.btnMain.tag = indexPath.row
            cellBtn.btnMain.addTarget(self, action: #selector(self.logoutAction), for: .touchUpInside)
            cellBtn.viewLine.isHidden = false
            cellBtn.viewBG.backgroundColor = UIColor.clear
            
            cellBtn.lblHeading.textColor = UIColor.themeBlueColor
            cellBtn.lblHeading.rotateViewForInner()
            cellBtn.lblHeading.rotateForTextAligment()
            
            cellBtn.selectionStyle = .none
            return cellBtn
        

        
    }
    @objc func selectTermsAction(sender : UIButton){
        let cellMain = self.tableSignup.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! SignupTextViewCell
        
        cellMain.viewSelect.isHidden = !cellMain.viewSelect.isHidden
        
        cellMain.viewSelect.rotateViewForLanguage()
        self.isSelectTerms = cellMain.viewSelect.isHidden
        
        
        self.tableSignup.reloadData()
        
    }
    
    @objc func showDropDown(sender : UIButton){
        let CustomGenderVC = GetView(nameVC: "CustomGenderVC", nameSB: "Registeration" ) as! CustomGenderVC
        CustomGenderVC.modalPresentationStyle = .overCurrentContext
        self.viewGray.isHidden = false
        CustomGenderVC.onConfirm = {[weak self] selectedData in
            guard let self = self else{return}
            self.CustomgenderTitle = selectedData.selectedPronoun
            self.tableSignup.reloadData()
            self.dismissVC {
                self.viewGray.isHidden = true
            }
        }
        presentVC(CustomGenderVC, completion: nil)
    }
    @objc func logoutAction(sender : UIButton){

            let parameters = ["action": "logout","token":SharedManager.shared.userToken()]
            
//            SharedManager.shared.showOnWindow()
        Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    
                    SharedManager.shared.ShowsuccessAlert(message: res as! String,AcceptButton: "OK".localized()) { status in
                        self.logoutFromApp()
                    }
                }
            }, param:parameters)
        }
        
        func logoutFromApp(){
            GoogleSignInManager.signOut()
            FeedCallBManager.shared.videoClipArray.removeAll()
            SocketSharedManager.sharedSocket.closeConnection()
            SharedManager.shared.userObj = nil
            SharedManager.shared.removeProfile()
            AppDelegate.shared().loadLoginScreen()
            RecentSearchRequestUtility.shared.clearFromCache()
        }
    
    @objc func firstStep(sender : UIButton){
        self.isNextTap = false
        self.gender = ""
        self.CustomgenderTitle = ""
        self.CustomgenderDescription = ""
        self.CustomgenderText = ""
        self.pronounTxt = ""

        self.tableSignup.reloadData()
    }
@objc func CompleteProfile(sender : UIButton){
    
    self.view.endEditing(true)
    if sender.tag == 100 {
        
        if self.isSelectTerms {
           return
       }
        if self.validateBDayData() {
            self.isNextTap = true
            self.tableSignup.reloadData()
            return
        }else {
            return
        }
        
    }
   
    
    if self.validateData()
    {

        let parameters = self.getRequestDict()
        LogClass.debugLog(parameters)
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPostwithCompleteResponse(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error) 
            case .success(let res):
                LogClass.debugLog("res ===>")
                LogClass.debugLog(res)
                if res is String {
                    if let message = res as? String {
                        if message == "Profile Completed successfully." {
                            self.ShowAlertWithPop(message: message)
                        }
                        else {
                            SharedManager.shared.showAlert(message: message, view: self)
                        }
                    }
                } else {
                    if let message = res as? String {
                        SharedManager.shared.showAlert(message: message, view: self)

                    } else if let message = res as? Any {
                        if var isUserObj:User = SharedManager.shared.getProfile() {
                            isUserObj.data.isGoogleAccount = true
                            isUserObj.data.isProfileCompleted = false
                            SharedManager.shared.userObj = isUserObj
                            SharedManager.shared.saveProfile(userObj: isUserObj)
                        }
                        self.dismissVC(completion: nil)
                    }
                }
                if let message = res as? String {

                    SharedManager.shared.ShowSuccessAlert(message:message , view: self)
                }
            }
        }, param:parameters)
    }
}
    func validateData ()->Bool {

         if self.country.name.isEmpty  {
            SharedManager.shared.showAlert(message: "Please select your country".localized(), view: self)
            return false
        }
        return true
    }
    
    func validateBDayData ()->Bool {
        if self.year.isEmpty  {
            SharedManager.shared.showAlert(message: "Please select year of birth".localized(), view: self)
            return false
        }
        else if self.month.isEmpty  {
            SharedManager.shared.showAlert(message: "Please select month of birth".localized(), view: self)
            return false
        }
        else if self.day.isEmpty  {
            SharedManager.shared.showAlert(message: "Please select day of birth".localized(), view: self)
            return false
        }
        
        return true
    }
    func getRequestDict() -> [String:String] {
        
        let locale = Locale.current
        var param:[String:String] = [:]
        
        
        let dobMain = self.year + "-" + String((self.arrayMonth.firstIndex(of: self.month)!) + 1) + "-" + self.day
        param["action"] = "profile/profile-complete"
        param["token"] = SharedManager.shared.userToken()
        param["dob"] = dobMain
        param["country_code"] = self.country.id
        param["gender"] = self.gender
        param["custom_gender"] = self.CustomgenderText
        param["pronoun"] = self.pronounTxt
        param["country"] = self.country.name
        param["device_type"] = "ios"

        
        return param
    }
    func managePrivacyPolicy(textView : UITextView){
        let font = UIFont.systemFont(ofSize: 14.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5.0
        let attributes = [NSAttributedString.Key.font: font as Any, NSAttributedString.Key.paragraphStyle: paragraphStyle]

        let str1 = NSMutableAttributedString(string: "By creating account you agree to ".localized(), attributes: [NSAttributedString.Key.font : font])
        str1.append(NSMutableAttributedString(string: "our Terms and confitions, End User License Agreement".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().LiscenseLink]))
        str1.append(NSMutableAttributedString(string: " and ".localized(), attributes: [NSAttributedString.Key.font : font]))
        str1.append(NSMutableAttributedString(string: "Privacy Policy.".localized(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.link:AppConfigurations().privacyLink]))
        textView.attributedText = str1
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100 {
            
//            self.pronounTxt = self.gender
            self.gender = ""
            self.CustomgenderText = textField.text!
            self.tableSignup.reloadRows(at: [IndexPath.init(row: textField.tag, section: 0)], with: .automatic)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       
        
        if textField.tag == 100 {
         return true
        }
        if textField.tag == -300 {
            if self.month.count > 0 && self.year.count > 0{
                var arrayDays = [String]()
                
                for index in 1..<(self.getTotalDays() + 1) {
                    arrayDays.append(String(index))
                }
                
                let pickerDialogue = PickerDialog.init()
                pickerDialogue.show("Choose Day".localized(), arrayMain: arrayDays) { (selectedIndex) in
                    if selectedIndex != nil {
                        if selectedIndex! > -1  {
                            self.day = arrayDays[selectedIndex!]
                        }
                    }
                    self.tableSignup.reloadData()
                }
            }
            
            
            return false
            
        }else if textField.tag == -200 {
            
            
            
            let pickerDialogue = PickerDialog.init()
            pickerDialogue.show("Choose Month".localized(), arrayMain: self.arrayMonth) { (selectedIndex) in
                if selectedIndex != nil {
                    if selectedIndex! > -1  {
                        self.month = self.arrayMonth[selectedIndex!]
                        self.day = ""
                    }
                }
                self.tableSignup.reloadData()
            }
            
            return false
        }else if textField.tag == -100 {
            let yearToday = Int(Date().dateString("yyyy"))
            var arrayYear = [String]()
            for index in 1900..<(yearToday! - 14) {
                arrayYear.append(String(index))
            }
            arrayYear = Array(arrayYear.reversed())
            
            let pickerDialogue = PickerDialog.init()
            pickerDialogue.show("Choose Year".localized(), arrayMain: arrayYear) { (selectedIndex) in
                if selectedIndex != nil {
                    if selectedIndex! > -1  {
                        self.year = arrayYear[selectedIndex!]
                        self.day = ""
                    }
                }
                self.tableSignup.reloadData()
            }
            
            return false
        }
        else if (textField.tag == -11)
        {
            self.gender = "M"
            self.pronounTxt = ""
            self.CustomgenderText = ""
            self.tableSignup.reloadData()
            return false
        }
        else if (textField.tag == -22)
        {
            self.gender = "F"
            self.pronounTxt = ""
            self.CustomgenderText = ""
            self.tableSignup.reloadData()
            return false
        }
        else if(textField.tag == -33)
        {
            
            self.gender = "C"
            
            self.showDropDown(sender: UIButton.init())
//            let CustomGenderVC = GetView(nameVC: "CustomGenderVC", nameSB: "Registeration" ) as! CustomGenderVC
//            CustomGenderVC.modalPresentationStyle = .overCurrentContext
//            self.viewGray.isHidden = false
//            CustomGenderVC.onConfirm = {[weak self] selectedData in
//                guard let self = self else{return}
//                self.CustomgenderTitle = selectedData.selectedPronoun
//                self.tableSignup.reloadData()
//                self.dismissVC {
//                    self.viewGray.isHidden = true
//                }
//            }
//            presentVC(CustomGenderVC, completion: nil)
            return false

        }
            
        else if SUNewOptions.allCases[textField.tag] == .SUDOB {
            let pickerMain = DatePickerDialog.init()
            pickerMain.show("Date of birth".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: Date(), minimumDate: nil, maximumDate: Date(), datePickerMode: .date) { (datePicker) in

                if datePicker != nil {
                    self.DOB = datePicker!.dateString("dd-MM-yyyy")
                    self.tableSignup.reloadData()
                }
            }
            return false
        }
        return true
    }
}
extension GoogleSignupProfileVC : CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
            self.country.code = country.phoneCode
            self.country.name = country.name
            self.country.id = country.code
        self.tableSignup.reloadData()
    }
}



enum SUNewOptions:String,CaseIterable {
    case SULogo = "Logo"
    case SUDOB = "Select your date of birth"
    case SUTextView = "TextN"
    case SUBtn = "Next"
    case SULoginBTN = "Logout"
}

enum SUSecondOptions:String,CaseIterable {
//    case SUBack = "Back"
    case SULogo = "Logo"
    case SUGender = "Select your gender"
    case SUCGender = "Custom gender"
    case SUBtn = "FINISH"
    case SULoginBTN = "Logout"
}


class SignupTextViewCell: UITableViewCell {
    @IBOutlet var tVMain: UITextView!

    @IBOutlet var viewSelect: UIView!
    @IBOutlet var btnSelect: UIButton!
}
