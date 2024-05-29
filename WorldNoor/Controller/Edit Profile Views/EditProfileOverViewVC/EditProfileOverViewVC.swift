//
//  EditProfileOverViewVC.swift
//  WorldNoor
//
//  Created by apple on 1/21/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftDate
import CountryPickerView


class EditProfileOverViewVC: UIViewController {
    
    @IBOutlet var tbleViewOverView : UITableView!
    
    var parentview : ProfileViewController!
    var refreshParentView: (()->())?
    
    var stateArray = [StateModel]()
    var cityArray = [StateModel]()
    
    var arrayOverview = [[String : String]]()
    
    var countryArray = [CountryModel]()
    var chooseCountry = CountryModel.init()
    
    var chooseState = StateModel.init()
    var chooseCity = StateModel.init()
    
    let countryPickerView = CountryPickerView()
    
    var otherUserObj = UserProfile.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewOverView.register(UINib.init(nibName: "EditProfileWorkTextCell", bundle: nil), forCellReuseIdentifier: "EditProfileWorkTextCell")
        self.tbleViewOverView.register(UINib.init(nibName: "EditProfilePhoneTextCell", bundle: nil), forCellReuseIdentifier: "EditProfilePhoneTextCell")

        
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        arrayOverview.removeAll()
        
        self.getCountry()
    }
    

    func reloadDataTable(){
        
        for indexObj in self.countryArray {
            if indexObj.name == SharedManager.shared.userEditObj.country {
                self.chooseCountry = indexObj
            }
        }
        
        arrayOverview.append(["Type" : "1" , "Title" : "Date Of Birth".localized(), "PH" : "Date Of Birth".localized()  , "ID": "1" , "Text" : SharedManager.shared.userEditObj.dob.changeDateString(inputformat: "yyyy-MM-dd", outputformat: "EEE dd, yyyy")])
        
        arrayOverview.append(["Type" : "1" , "Title" : "Date Of Birth Privacy".localized(), "PH" : "Date Of Birth Privacy".localized()  , "ID": "101" , "Text" : SharedManager.shared.userEditObj.dob_privacy.capitalizingFirstLetter()])
        
        
        arrayOverview.append(["Type" : "1" , "Title" : "Gender".localized(), "PH" : "Gender".localized()  , "ID": "2" , "Text" : SharedManager.shared.userEditObj.gender])
        arrayOverview.append(["Type" : "1" , "Title" : "Your pronoun".localized(), "PH" : "Your pronoun".localized()  , "ID": "200" , "Text" : SharedManager.shared.userEditObj.genderPronounc])
        arrayOverview.append(["Type" : "1" , "Title" : "Email".localized(), "PH" : "Email".localized()  , "ID": "3" , "Text" : SharedManager.shared.userEditObj.email])
        arrayOverview.append(["Type" : "1" , "Title" : "Phone".localized(), "PH" : "Phone".localized()  , "ID": "4" , "Text" : SharedManager.shared.userEditObj.phone , "Text2" : SharedManager.shared.userEditObj.countryCode])
        
        arrayOverview.append(["Type" : "1" , "Title" : "Phone Privacy".localized(), "PH" : "Phone Privacy".localized()  , "ID": "102" , "Text" : SharedManager.shared.userEditObj.phone_privacy.capitalizingFirstLetter()])
        
        arrayOverview.append(["Type" : "1" , "Title" : "Country".localized(), "PH" : "Country".localized()  , "ID": "8" , "Text" : SharedManager.shared.userEditObj.country])
        
        arrayOverview.append(["Type" : "1" , "Title" : "State/Province".localized(), "PH" : "State/Province".localized()  , "ID": "7" , "Text" : SharedManager.shared.userEditObj.state])
        
        
        arrayOverview.append(["Type" : "1" , "Title" : "City".localized(), "PH" : "City".localized()  , "ID": "6" , "Text" : SharedManager.shared.userEditObj.city])
        
        arrayOverview.append(["Type" : "1" , "Title" : "Address".localized(), "PH" : "Address".localized()  , "ID": "5" , "Text" : SharedManager.shared.userEditObj.address])
        
      
       
        
        self.tbleViewOverView.reloadData()
    }
    
    
    func getCountry(){
        
        
        if self.countryArray.count > 0 {
            
            self.reloadDataTable()
            return
        }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/countries","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                    self.reloadDataTable()
                }
            }
        }, param: parameters)
    }
}


extension EditProfileOverViewVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOverview.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  self.arrayOverview[indexPath.row]["ID"] == "200" {
            
            if SharedManager.shared.userEditObj.genderPronounc.count > 0  {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        }
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return EditProfileWorkTextCell(tableView: tableView, cellForRowAt: indexPath)
        
    }
    
    
    func EditProfileWorkTextCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if  self.arrayOverview[indexPath.row]["ID"] == "4" {

            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfilePhoneTextCell", for: indexPath) as? EditProfilePhoneTextCell else {
                      return UITableViewCell()
                   }
            
            
            cell.lblHeading.text = self.arrayOverview[indexPath.row]["Title"]
            cell.txtFieldMain.text = self.arrayOverview[indexPath.row]["Text"]
            cell.txtFieldMain.placeholder = self.arrayOverview[indexPath.row]["PH"]
            
            
            cell.txtFieldCountry.text = self.arrayOverview[indexPath.row]["Text2"]
            cell.txtFieldMain.delegate = self
            cell.txtFieldMain.tag = indexPath.row
            
            cell.txtFieldCountry.delegate = self
            cell.txtFieldCountry.tag = -100
            
            cell.selectionStyle = .none
            return cell
            
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkTextCell", for: indexPath) as? EditProfileWorkTextCell else {
                  return UITableViewCell()
               }
        
        cell.lblHeading.text = self.arrayOverview[indexPath.row]["Title"]
        cell.txtFieldMain.text = self.arrayOverview[indexPath.row]["Text"]
        cell.txtFieldMain.placeholder = self.arrayOverview[indexPath.row]["PH"]
        
        cell.txtFieldMain.delegate = self
        cell.txtFieldMain.tag = indexPath.row
        cell.selectionStyle = .none
        return cell
    }
}

extension EditProfileOverViewVC : CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        
        for indexObj in 0..<self.arrayOverview.count {
            if self.arrayOverview[indexObj]["ID"] == "4" {
                self.arrayOverview[indexObj]["Text2"] = country.phoneCode
            }
        }
        
        self.tbleViewOverView.reloadData()
    }
}

extension EditProfileOverViewVC {
    @IBAction func submitAction(sender : UIButton){
        self.view.endEditing(true)
        var DOB = ""
        var DOBPrivacy = ""
        var gender = ""
        var email = ""
        var phone = ""
        var phonePrivacy = ""
        var address = ""
        var city = ""
        var state = ""
        var country = ""
        var countrycode = ""
        
        for indexObj in self.arrayOverview {
            if indexObj["ID"] == "1" {
                DOB = indexObj["Text"]!
            }else if indexObj["ID"] == "101" {
                DOBPrivacy = indexObj["Text"]!
            }else if indexObj["ID"] == "2" {
                gender = indexObj["Text"]!
            }else if indexObj["ID"] == "3" {
                email = indexObj["Text"]!
            }else if indexObj["ID"] == "102" {
                phonePrivacy = indexObj["Text"]!
            }else if indexObj["ID"] == "4" {
                phone = indexObj["Text"]!
                countrycode = indexObj["Text2"]!
            }else if indexObj["ID"] == "5" {
                address = indexObj["Text"]!
            }else if indexObj["ID"] == "6" {
                city = indexObj["Text"]!
            }else if indexObj["ID"] == "7" {
                state = indexObj["Text"]!
            }else if indexObj["ID"] == "8" {
                country = indexObj["Text"]!
            }
        }
        
        
        
        
        
        if DOB.count == 0 {
            SharedManager.shared.showAlert(message: "Date Of Birth is missing".localized(), view: self)
            return
        }
        
//        if gender.count == 0 {
//            SharedManager.shared.showAlert(message: "Gender is missing".localized(), view: self)
//            return
//        }
        
//        if email.count == 0 {
//            SharedManager.shared.showAlert(message: "Email is missing".localized(), view: self)
//            return
//        }
//
        if !self.parentview.EmailValidationOnstring(strEmail: email) {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Enter valid email".localized())
            return
        }
        
        if phone.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Phone is missing".localized())
            return
        }
        
        if countrycode.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Country Code is missing".localized())
            return
        }
        
        if address.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Address is missing".localized())
            return
        }
        
        if city.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "City is missing".localized())
            return
        }
        
        if state.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "State is missing".localized())
            return
        }
        
        if country.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Country is missing".localized())
            return
        }
        
        let userToken = SharedManager.shared.userToken()
        var parameters = [String : Any]()
        parameters["action"] = "profile/update"
        parameters["token"] = userToken
        
        if SharedManager.shared.userEditObj.gender != gender{
            if gender == "Male" {
                parameters["gender"] = "M"
            }else {
                parameters["gender"] = "F"
            }
        }
        
        if SharedManager.shared.userEditObj.dob.changeDateString(inputformat: "yyyy-MM-dd", outputformat: "EEE dd, yyyy") != DOB{
            parameters["dob"] = DOB.changeDateString(inputformat: "EEE dd, yyyy", outputformat: "yyyy-MM-dd")
        }
        
        if SharedManager.shared.userEditObj.phone != phone{
            parameters["phone"] = phone
        }
        
        if SharedManager.shared.userEditObj.countryCode != countrycode{
            parameters["country_code"] = countrycode
        }
        for indexObj in self.cityArray {

            if indexObj.name == self.chooseCity.name {
                self.chooseCity = indexObj
            }
        }
        
        
        if SharedManager.shared.userEditObj.city != city{
            parameters["city"] = city
            parameters["city_id"] = self.chooseCity.id
        }
        
        if SharedManager.shared.userEditObj.state != state{
            parameters["state_id"] = self.chooseState.id
        }
        
        parameters["country_id"] = self.chooseCountry.id
        parameters["dob_privacy"] = DOBPrivacy.lowercased()
        parameters["phone_privacy"] = phonePrivacy.lowercased()
        parameters["address1"] = address
        parameters["email"] = email
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
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if res is [String : Any] {
                    SharedManager.shared.userEditObj.dob = DOB.changeDateString(inputformat: "EEE dd, yyyy", outputformat: "yyyy-MM-dd")
                    SharedManager.shared.userEditObj.gender = gender
                    SharedManager.shared.userEditObj.email = email
                    SharedManager.shared.userEditObj.phone = phone
                    SharedManager.shared.userEditObj.address = address
                    SharedManager.shared.userEditObj.city = city
                    SharedManager.shared.userEditObj.state = state
                    SharedManager.shared.userEditObj.country = country
                    SharedManager.shared.userEditObj.countryCode = countrycode

                    
                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
}


extension EditProfileOverViewVC : UITextFieldDelegate  {
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if textField.tag == -100 {
            
            if self.otherUserObj.otp_id.count > 1 {
                return false
            }
            
            countryPickerView.showCountriesList(from: self)
            countryPickerView.delegate = self
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "102" {
            let indexMain = Int(self.arrayOverview[textField.tag]["ID"]!)
            self.showcountryPicker(Type: indexMain!)
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "101" {
            let indexMain = Int(self.arrayOverview[textField.tag]["ID"]!)
            self.showcountryPicker(Type: indexMain!)
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "8" {
            let indexMain = Int(self.arrayOverview[textField.tag]["ID"]!)
            self.showcountryPicker(Type: indexMain!)
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "1" {
            
            self.datePickerTapped()
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "2" {
//            let indexMain = Int(self.arrayOverview[textField.tag]["ID"]!)
            
//            self.showcountryPicker(Type: indexMain!)
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "200" {
            
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "3" {
            
            if self.otherUserObj.otp_id.count > 1 {
                return true
            }
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "4" {
            
            if self.otherUserObj.otp_id.count > 1 {
                return false
            }
            return true
        }else if self.arrayOverview[textField.tag]["ID"] == "7" {
            self.getStateList()
            return false
        }else if self.arrayOverview[textField.tag]["ID"] == "6" {
            
            if SharedManager.shared.userEditObj.state.count == 0 && self.chooseState.id.count == 0{
                SharedManager.shared.showAlert(message: "Choose state first".localized(), view: self)
                return false
            }
            
            if self.chooseState.id.count > 0 {
                self.getCityList()
            }else {
                self.getStateList(isReload: false)
            }
            
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.arrayOverview[textField.tag]["Text"] = textField.text!
        if let cellText = self.tbleViewOverView.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as? EditProfileWorkTextCell {
            cellText.txtFieldMain.text = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
}


extension EditProfileOverViewVC : PickerviewDelegate {
    
    func showcountryPicker(Type : Int){
        
        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        
        cuntryPicker.isMultipleItem = false
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = Type
        
        var arrayData = [String]()
        
        if Type == 8 { // Country
            for indexObj in self.countryArray {
                arrayData.append(indexObj.name)
            }
        }else  if Type == 2 { // Gender
            arrayData.append("Male".localized())
            arrayData.append("Female".localized())
        }else  if Type == 101 || Type == 102 { // DOB Policy
            arrayData.append("Public".localized())
            arrayData.append("Friends".localized())
            arrayData.append("Private".localized())
        }else if Type == 6 { // City
            for indexObj in self.cityArray {
                arrayData.append(indexObj.name)
            }
        }else {
            for indexObj in self.stateArray {
                arrayData.append(indexObj.name)
            }
        }
        
        cuntryPicker.arrayMain = arrayData
        
        self.present(cuntryPicker, animated: true) {
            
        }
    }
    
    
    func pickerChooseView(text: String , type : Int )
    {
        for indexObj in 0..<self.arrayOverview.count {
            if self.arrayOverview[indexObj]["ID"] == String(type) {
                self.arrayOverview[indexObj]["Text"] = text
                if let cellText = self.tbleViewOverView.cellForRow(at: IndexPath.init(row: indexObj, section: 0)) as?  EditProfileWorkTextCell {
                    cellText.txtFieldMain.text = text
                    
                }
                break
                
            }
        }
        
        
        if type == 8 {
            
            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                    self.chooseCity = StateModel.init()
                    self.chooseState = StateModel.init()
                    SharedManager.shared.userEditObj.city = ""
                    SharedManager.shared.userEditObj.state = ""
                    
                    for indexObj in 0..<self.arrayOverview.count {
                        if self.arrayOverview[indexObj]["ID"] == "7" {
                            self.arrayOverview[indexObj]["Text"] = ""
                            
                        }
                        
                        if self.arrayOverview[indexObj]["ID"] == "6" {
                            self.arrayOverview[indexObj]["Text"] = ""
                            
                        }
                    }
                }
            }
        }else if type == 6 { // city
            self.chooseCity.name = text
        }else {
            
            for indexObj in self.stateArray {
                if indexObj.name == text {
                    self.chooseState = indexObj
                    self.chooseCity = StateModel.init()
                    SharedManager.shared.userEditObj.city = ""
                    
                    for indexObj in 0..<self.arrayOverview.count {
                        if self.arrayOverview[indexObj]["ID"] == "6" {
                            self.arrayOverview[indexObj]["Text"] = ""
                            
                        }
                    }
                }
            }

        }
        
        self.tbleViewOverView.reloadData()
        
    }
    
    
    func datePickerTapped(isEndDate : Bool = false) {
                
        let dateMain = DatePickerDialog.init(textColor: UIColor.black , buttonColor: UIColor.themeBlueColor, font: UIFont.boldSystemFont(ofSize: 12.0), locale: Locale.current, showCancelButton: true)
        dateMain.show("Date Of Birth".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: Date().dateByAddingYears(-15), minimumDate: nil, maximumDate: Date().dateByAddingYears(-15), datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                
                let cellText = self.tbleViewOverView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! EditProfileWorkTextCell
                cellText.txtFieldMain.text = formatter.string(from: dt)
                cellText.txtFieldMain.text = cellText.txtFieldMain.text!.changeDateString(inputformat: "yyyy-MM-dd", outputformat: "EEE dd, yyyy")
                self.arrayOverview[0]["Text"] =  cellText.txtFieldMain.text!
            }
        }
        
        
//        if #available(iOS 13.4, *) {
//            DatePickerDialog().datePicker.preferredDatePickerStyle = .compact
//        } else {
//            // Fallback on earlier versions
//        }
//        DatePickerDialog().show("Date Of Birth".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), maximumDate : Date(), datePickerMode: .date) {
//            (date) -> Void in
//            if let dt = date {
//                
//                
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd"
//
//                self.arrayOverview[0]["Text"] = formatter.string(from: dt)
//                let cellText = self.tbleViewOverView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! EditProfileWorkTextCell
//                cellText.txtFieldMain.text = formatter.string(from: dt)
//                
//            }
//        }
    }
    
    
    func getStateList(isReload : Bool = true){
        
        self.stateArray.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/states_of_country","token": userToken ,"country_id": self.chooseCountry.id]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.stateArray.append(StateModel.init(fromDictionary: indexObj))
                    }
                    if isReload {
                        self.showcountryPicker(Type: 7)
                    }else {
                        for indexObj in self.stateArray {
                            if indexObj.name.lowercased() == SharedManager.shared.userEditObj.state.lowercased() {
                                self.chooseState = indexObj
                                break
                            }
                        }
                        
                        if self.chooseState.id.count > 0 {
                            self.getCityList()
                        }
                    }
                    
                }
            }
            
            
        }, param: parameters)
    }
    
    func getCityList(){
        
        if self.chooseState.id.count > 0 {
            
            self.cityArray.removeAll()
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let userToken = SharedManager.shared.userToken()
            let parameters = ["action": "meta/cities_of_state","token": userToken ,"state_id": self.chooseState.id]
            RequestManager.fetchDataGet(Completion: { (response) in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                
                switch response {
                    
                case .failure(let error):
                    
SwiftMessages.apiServiceError(error: error)                case .success(let res):
                    
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    }else if res is [[String : Any]] {
                        let array = res as! [[String : Any]]
                        
                        for indexObj in array {
                            self.cityArray.append(StateModel.init(fromDictionary: indexObj))
                        }
                        self.showcountryPicker(Type: 6)
                    }
                }
            }, param: parameters)
        }
    }
}
