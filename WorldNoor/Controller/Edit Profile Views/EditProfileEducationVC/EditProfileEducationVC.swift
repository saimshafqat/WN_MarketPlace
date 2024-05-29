//
//  EditProfileEducationVC.swift
//  WorldNoor
//
//  Created by apple on 1/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftDate

class EditProfileEducationVC: UIViewController , UITextFieldDelegate , PickerviewDelegate{
    
    @IBOutlet var txtFieldCountry : UITextField!
    @IBOutlet var txtFieldViewCity : UITextField!
    @IBOutlet var txtFieldViewName : UITextField!
    @IBOutlet var txtFieldViewDegreeTitle : UITextField!
    @IBOutlet var txtFieldViewDate : UITextField!
    @IBOutlet var viewDelete : UIView!
    
    var parentview : ProfileViewController!
    var refreshParentView: (()->())?
    var countryArray = [CountryModel]()
    var chooseCountry = CountryModel.init()
    var type = -1
    var rowIndex = -1
    var editEducation : UserInstitutes!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.viewDelete.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.txtFieldCountry.text = ""
        self.txtFieldViewCity.text = ""
        self.txtFieldViewName.text = ""
        self.txtFieldViewDegreeTitle.text = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.txtFieldViewDate.text! = formatter.string(from: Date())
        
        
        
        self.chooseCountry = CountryModel.init()
        
        if self.type == 2 {
            self.viewDelete.isHidden = false
            self.getCountry()
            self.txtFieldViewDegreeTitle.text = self.editEducation.degree_title
            self.txtFieldViewName.text = self.editEducation.name
            self.txtFieldViewCity.text = self.editEducation.city_name
            self.txtFieldViewDate.text = self.editEducation.graduation_date.toDate()!.toFormat("YYYY-MM-dd")
        }
        
        
    }
    
    
    func getCountry(){
        if self.countryArray.count > 0 {
            for indexObj in self.countryArray {
                if indexObj.id == self.editEducation.country_id {
                    self.chooseCountry = indexObj
                    self.txtFieldCountry.text = indexObj.name
                    break
                }
            }
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
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                    for indexObj in self.countryArray {
                        if indexObj.id == self.editEducation.country_id {
                            self.chooseCountry = indexObj
                            self.txtFieldCountry.text = indexObj.name
                            break
                        }
                    }
                }
            }
        }, param: parameters)
    }
    
    func getcountryList()   {
        if self.countryArray.count > 0 {
            self.showcountryPicker(Type: 1)
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
                
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                    
                    self.showcountryPicker(Type: 1)
                }
            }
        }, param: parameters)
    }
    
    
    func showcountryPicker(Type : Int) {
        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        
        cuntryPicker.isMultipleItem = false
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = Type
        
        var arrayData = [String]()
        if Type == 1 {
            for indexObj in self.countryArray {
                arrayData.append(indexObj.name)
            }
        }
        cuntryPicker.arrayMain = arrayData
        self.present(cuntryPicker, animated: true) {

        }
    }
    
    
    func pickerChooseView(text: String , type : Int ) {
        if type == 1 {
            
            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                }
            }
            self.txtFieldCountry.text = text
            
        }
    }
    
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    @IBAction func deleteAction(sender : UIButton){
        let placeid = self.editEducation.id
        self.ShowAlertWithCompletaion(message: "Are you sure to delete this education?".localized()) { (status) in
            
            if status {
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "user/education/delete","token": userToken , "id" : placeid , "_method" : "DELETE"]
                
//                SharedManager.shared.showOnWindow()
                
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {

                        }else {
                            SharedManager.shared.userEditObj.institutes.remove(at: self.rowIndex)
                            self.refreshParentView?()
                            self.view.removeFromSuperview()
                            
                            self.refreshParentView?()
                            self.view.removeFromSuperview()
                            
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    @IBAction func submitAction(sender : UIButton){
        self.view.endEditing(true)
        if self.txtFieldViewName.text!.count == 0  {
            SharedManager.shared.showAlert(message: "Enter institute name".localized(), view: self)
            return
        }else if self.txtFieldViewDegreeTitle.text!.count == 0  {
            SharedManager.shared.showAlert(message: "Enter degree title".localized(), view: self)
            return
        }else if self.txtFieldViewCity.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Enter city name".localized(), view: self)
            return
        }else if self.txtFieldCountry.text!.count == 0  {
            SharedManager.shared.showAlert(message: "Enter country".localized(), view: self)
            return
        }
        let userToken = SharedManager.shared.userToken()
        var action = ""
        var placeID = ""
        if type == 2 {
            action = "user/education/update"
            placeID = self.editEducation.id
        }else {
            action = "user/education/create"
            placeID = ""
        }
        let parameters = ["action": action,"token": userToken , "country_id" : self.chooseCountry.id , "city" : self.txtFieldViewCity.text!, "degree_title" : self.txtFieldViewDegreeTitle.text!,"name" : self.txtFieldViewName.text! ,"id" : placeID , "graduation_date" : self.txtFieldViewDate.text!]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if res is [String : Any] {
                    
                    if self.type == 2 {
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].country_id = self.chooseCountry.id
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].city_name = self.txtFieldViewCity.text!
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].name = self.txtFieldViewName.text!
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].degree_title = self.txtFieldViewDegreeTitle.text!
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].graduation_date = self.txtFieldViewDate.text!
                        
                        SharedManager.shared.userEditObj.institutes[self.rowIndex].address = self.txtFieldViewCity.text! + ", " + self.txtFieldCountry.text!
                    } else {
                        SharedManager.shared.userEditObj.institutes.append(UserInstitutes.init(fromDictionary: res as! [String : Any]))
                    }
                    
                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }
            
        }, param:parameters)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
}


extension EditProfileEducationVC {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.txtFieldCountry {
            self.getcountryList()
            return false
        }else if textField == self.txtFieldViewDate {
            self.datePickerTapped()
            return false
        }
        
        return true
    }
    
    func datePickerTapped() {
        
        let dateMain = DatePickerDialog.init(textColor: UIColor.black , buttonColor: UIColor.themeBlueColor, font: UIFont.boldSystemFont(ofSize: 12.0), locale: Locale.current, showCancelButton: true)
        
        
        dateMain.show(self.txtFieldViewDate.placeholder!, doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: Date(), minimumDate: nil, maximumDate: Date(), datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {

                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.txtFieldViewDate.text! = formatter.string(from: dt)
                
                
            }
        }
        
        
//        if #available(iOS 13.4, *) {
//            DatePickerDialog().datePicker.preferredDatePickerStyle = .automatic
//        } else {
//            // Fallback on earlier versions
//        }
//        DatePickerDialog().show(self.txtFieldViewDate.placeholder!, doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), maximumDate : Date(), datePickerMode: .date) {
//            (date) -> Void in
//            if let dt = date {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd"
//                self.txtFieldViewDate.text! = formatter.string(from: dt)
//            }
//        }
    }
}
