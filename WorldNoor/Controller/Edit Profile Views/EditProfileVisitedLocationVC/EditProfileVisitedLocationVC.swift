//
//  EditProfileVisitedLocationVC.swift
//  WorldNoor
//
//  Created by apple on 1/17/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class EditProfileVisitedLocationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtFieldCountry : UITextField!
    @IBOutlet weak var txtFieldState: UITextField?
    @IBOutlet var txtFieldViewCity : UITextField!
    @IBOutlet var txtFieldViewPlace : UITextField!
    @IBOutlet var viewDelete : UIView!
    
    var parentview : ProfileViewController!
    var refreshParentView: (()->())?
    
    var countryArray = [CountryModel]()
    var stateArray = [StateModel]()
    var cityArray = [StateModel]()
    
    var chooseCountry = CountryModel.init()
    var chooseState = StateModel.init()
    var chooseCity = StateModel.init()
    
    
    var type = -1
    
    var rowIndex = -1
    
    var editPlace : UserPlaces!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDelete.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.txtFieldCountry.text = ""
        self.txtFieldState?.text = ""
        self.txtFieldViewCity.text = ""
        self.txtFieldViewPlace.text = ""
        self.chooseCountry = CountryModel.init()
        
        if self.type == 2 {
            self.viewDelete.isHidden = false
            self.getCountry()
            self.txtFieldViewPlace.text = self.editPlace.place
            self.txtFieldViewCity.text = self.editPlace.city
            self.txtFieldState?.text =  self.editPlace.state
        }
    }
    
    func getCountry() {
        
        if self.countryArray.count > 0 {
            for indexObj in self.countryArray {
                if indexObj.id == self.editPlace.country_id {
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
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                    for indexObj in self.countryArray {
                        if indexObj.id == self.editPlace.country_id {
                            self.chooseCountry = indexObj
                            self.txtFieldCountry.text = indexObj.name
                            break
                        }
                    }
                }
            }
        }, param: parameters)
    }
    
    func getcountryList() {
        
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
    
    //    func showcountryPicker(Type : Int) {
    //
    //        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
    //
    //        cuntryPicker.isMultipleItem = false
    //        cuntryPicker.pickerDelegate = self
    //        cuntryPicker.type = Type
    //
    //        var arrayData = [String]()
    //
    //        if Type == 1 {
    //            for indexObj in self.countryArray {
    //                arrayData.append(indexObj.name)
    //            }
    //        }
    //
    //        cuntryPicker.arrayMain = arrayData
    //        self.present(cuntryPicker, animated: true) {
    //        }
    //    }
    //
    //    func pickerChooseView(text: String , type : Int) {
    //
    //        if type == 1 {
    //            for indexObj in self.countryArray {
    //                if indexObj.name == text {
    //                    self.chooseCountry = indexObj
    //                }
    //            }
    //            self.txtFieldCountry.text = text
    //        }
    //    }
    
    func reloadView(type : Int, rowIndexP : Int) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    @IBAction func submitAction(sender : UIButton) {
        self.view.endEditing(true)
        
        if self.txtFieldCountry.text!.count == 0  {
            SharedManager.shared.showAlert(message: "Enter country".localized(), view: self)
            return
        } else if self.txtFieldState?.text?.count ?? 0 == 0 {
            SharedManager.shared.showAlert(message: "Enter State name".localized(), view: self)
            return
        } else if self.txtFieldViewCity.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Enter city name".localized(), view: self)
            return
        } else if self.txtFieldViewPlace.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Enter place information".localized(), view: self)
            return
        }
        
        let userToken = SharedManager.shared.userToken()
        
        var action = ""
        var placeID = ""
        
        if type == 2 {
            action = "user/places/update"
            placeID = self.editPlace.id
        } else {
            action = "user/places/create"
            placeID = ""
        }
        
        let parameters = ["action": action,
                          "token": userToken,
                          "country_id" : self.chooseCountry.id,
                          "state_id": self.chooseState.id, //self.txtFieldState.text!,
                          "city" : self.txtFieldViewCity.text!,
                          "place" : self.txtFieldViewPlace.text!,
                          "id" : placeID]
        
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
                    
                    //                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    
                    if self.type == 2 {
                        let cityText = self.txtFieldViewCity.text ?? .emptyString
                        let stateText = self.txtFieldState?.text ?? .emptyString
                        let country = self.txtFieldCountry.text ?? .emptyString
                        SharedManager.shared.userEditObj.places[self.rowIndex].country_id = self.chooseCountry.id
                        SharedManager.shared.userEditObj.places[self.rowIndex].city = cityText
                        SharedManager.shared.userEditObj.places[self.rowIndex].place = self.txtFieldViewPlace.text!
                        SharedManager.shared.userEditObj.places[self.rowIndex].state = stateText
                        let address = cityText + ", " + stateText + ", " + country
                        SharedManager.shared.userEditObj.places[self.rowIndex].address = address
                    } else {
                        SharedManager.shared.userEditObj.places.append(UserPlaces.init(fromDictionary: res as! [String : Any]))
                    }
                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
    
    @IBAction func deleteAction(sender : UIButton) {
        
        let placeid = self.editPlace.id
        self.ShowAlertWithCompletaion(message: "Are you sure to delete this education?".localized()) { (status) in
            if status {
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "user/places/delete","token": userToken , "id" : placeid , "_method" : "DELETE"]
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                        } else {
                            SharedManager.shared.userEditObj.places.remove(at: self.rowIndex)
                            self.refreshParentView?()
                            self.view.removeFromSuperview()
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
}

extension EditProfileVisitedLocationVC {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.txtFieldCountry {
            self.getcountryList()
            return false
            
        } else if textField == self.txtFieldState {
            if self.chooseCountry.id.isEmpty {
                SharedManager.shared.showAlert(message: "Choose Country first".localized(), view: self)
                return false
            }
            self.getStateList()
            return false
            
        } else if textField == self.txtFieldViewCity {
            if self.chooseState.id.isEmpty {
                SharedManager.shared.showAlert(message: "Choose state first".localized(), view: self)
                return false
            }
            
            if self.chooseState.id.count > 0 {
                self.getCityList()
            } else {
                self.getStateList(isReload: false)
            }
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileVisitedLocationVC {
    
    func getStateList(isReload : Bool = true) {
        self.stateArray.removeAll()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/states_of_country",
                          "token": userToken ,
                          "country_id": self.chooseCountry.id]
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.stateArray.append(StateModel.init(fromDictionary: indexObj))
                    }
                    
                    if isReload {
                        self.showcountryPicker(Type: 7)
                    } else {
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
    
    func getCityList() {
        
        if self.chooseState.id.count > 0 {
            
            self.cityArray.removeAll()
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let userToken = SharedManager.shared.userToken()
            let parameters = ["action": "meta/cities_of_state",
                              "token": userToken,
                              "state_id": self.chooseState.id]
            RequestManager.fetchDataGet(Completion: { (response) in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    
SwiftMessages.apiServiceError(error: error)                case .success(let res):
                    
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is [[String : Any]] {
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

extension EditProfileVisitedLocationVC: PickerviewDelegate {
    
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
        } else if Type == 6 { // City
            for indexObj in self.cityArray {
                arrayData.append(indexObj.name)
            }
        } else if Type == 7 { //state
            for indexObj in self.stateArray {
                arrayData.append(indexObj.name)
            }
        }
        
        cuntryPicker.arrayMain = arrayData
        self.present(cuntryPicker, animated: true) {
        }
    }
    
    func pickerChooseView(text: String , type : Int ) {
        
        //        for indexObj in 0..<self.arrayOverview.count {
        //
        //            if self.arrayOverview[indexObj]["ID"] == String(type) {
        //                self.arrayOverview[indexObj]["Text"] = text
        //                if let cellText = self.tbleViewOverView.cellForRow(at: IndexPath.init(row: indexObj, section: 0)) as?  EditProfileWorkTextCell {
        //                    cellText.txtFieldMain.text = text
        //
        //                }
        //                break
        //            }
        //        }
        if type == 1 {
            
            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                    self.chooseCity = StateModel.init()
                    self.chooseState = StateModel.init()
                    self.txtFieldState?.text = ""
                    self.txtFieldViewCity.text = ""
                    
                    self.txtFieldCountry.text = text
                }
            }
        } else if type == 6 { // city
            self.chooseCity.name = text
            self.txtFieldViewCity.text = text
            
        } else {
            
            for indexObj in self.stateArray {
                if indexObj.name == text {
                    self.chooseState = indexObj
                    self.txtFieldState?.text = text
                    
                    self.chooseCity = StateModel.init()
                    self.txtFieldViewCity.text = ""
                    
                    //                    for indexObj in 0..<self.arrayOverview.count {
                    //                        if self.arrayOverview[indexObj]["ID"] == "6" {
                    //                            self.arrayOverview[indexObj]["Text"] = ""
                    //
                    //                        }
                    //                    }
                }
            }
        }
    }
}
