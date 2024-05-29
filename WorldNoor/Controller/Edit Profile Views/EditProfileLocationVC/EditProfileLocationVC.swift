//
//  EditProfileLocationVC.swift
//  WorldNoor
//
//  Created by apple on 1/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class EditProfileLocationVC: UIViewController , UITextFieldDelegate , PickerviewDelegate{

    @IBOutlet var txtFieldCountry : UITextField!
    @IBOutlet var txtFieldViewState : UITextField!
    
    @IBOutlet var lblCountry : UILabel!
    @IBOutlet var lblState : UILabel!
    @IBOutlet var lblHeading : UILabel!
    
    var refreshParentView: (()->())?
        
    var countryArray = [CountryModel]()
    var chooseCountry = CountryModel.init()

    var stateArray = [StateModel]()
    
    var type = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        txt
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblState.text = "State".localized()
        self.lblCountry.text = "Country".localized()
        if self.type == 1 {
            self.lblHeading.text = "Location".localized()
            self.txtFieldCountry.text = SharedManager.shared.userEditObj.country
            self.txtFieldViewState.text = SharedManager.shared.userEditObj.state
        }else if self.type == 2 {
            self.lblHeading.text = "Work Location".localized()
            self.txtFieldCountry.text = SharedManager.shared.userEditObj.country
            self.txtFieldViewState.text = SharedManager.shared.userEditObj.state
        }else if self.type == 3 {
            self.lblHeading.text = "From".localized()
        }
        
        self.getCountry()
    }
    
    
    func getCountry(){
        
        
        if self.countryArray.count > 0 {
            return
        }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
          let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/countries","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//             SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                     
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                    
                }
            }
            
            
        }, param: parameters)
    }
    func getcountryList(){
        
        if self.countryArray.count > 0 {
            self.showcountryPicker(Type: 1)
         return
        }
        
//         SharedManager.shared.showOnWindow()
        Loader.startLoading()
          let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/countries","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//             SharedManager.shared.hideLoadingHubFromKeyWindow()
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
                    
                    self.showcountryPicker(Type: 1)
                }
            }
        }, param: parameters)
    }
    
    func getStateList(){
           

           
        self.stateArray.removeAll()
//            SharedManager.shared.showOnWindow()
        Loader.startLoading()
             let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/states_of_country","token": userToken ,"country_id": self.chooseCountry.id]
           RequestManager.fetchDataGet(Completion: { (response) in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
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
                           self.stateArray.append(StateModel.init(fromDictionary: indexObj))
                       }
                       self.showcountryPicker(Type: 2)
                   }
               }
           }, param: parameters)
       }
       
    func showcountryPicker(Type : Int){
        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
               
        cuntryPicker.isMultipleItem = false
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = Type
        
        var arrayData = [String]()
        
        if Type == 1 {
            for indexObj in self.countryArray {
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
        if type == 1 {
            
            if self.txtFieldCountry.text == text {
                
            
            }else {
                self.txtFieldViewState.text = ""
                self.stateArray.removeAll()
            }

            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                }
            }
            self.txtFieldCountry.text = text
            
        }else {
            self.txtFieldViewState.text = text
        }
    }
    func reloadView(type : Int){
        self.type = type
    }
    @IBAction func submitAction(sender : UIButton){
        self.view.endEditing(true)
        
        
        var countryID = ""
        var stateID = ""
        
        for indexObj in self.countryArray {
            if txtFieldCountry.text! == indexObj.name {
                countryID = indexObj.id
            }
        }
        
        for indexObjState in self.stateArray {
            if txtFieldViewState.text! == indexObjState.name {
                stateID = indexObjState.id
            }
        }
        
        if self.txtFieldCountry.text!.count == 0 || self.txtFieldViewState.text!.count == 0 || countryID.count == 0 || stateID.count == 0 {
            SharedManager.shared.showAlert(message: "Enter country and state.".localized(), view: self)
            return
        }
                
        let userToken = SharedManager.shared.userToken()
        


        let parameters = ["action": "profile/update","token": userToken , "country_id" : countryID , "state_id" : stateID]
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
                    SharedManager.shared.showAlert(message: res as! String, view: self)
                } else if res is [String : Any] {

                    SharedManager.shared.userEditObj.country = self.txtFieldCountry.text!
                    SharedManager.shared.userEditObj.state = self.txtFieldViewState.text!
                    
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


extension EditProfileLocationVC {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtFieldCountry {
            self.getcountryList()
        }else {
            self.getStateList()
        }
        
        return false
    }
}
