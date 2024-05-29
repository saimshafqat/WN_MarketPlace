//
//  CreateGroupController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/30/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

/*
 (self.parentView as ProfileViewController).editProfileLocationVc.reloadView(type: Int(self.arrayBottom[sender.tag]["id"]!)!)
 UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileLocationVc.view)
 */

import Foundation
import UIKit
let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


protocol CreateGroupDelegate {
    func groupCreatedSuccessfullyDelegate()
}

class CreateGroupController: UIViewController {
    @IBOutlet weak var grpNameField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var privacyField: UITextField!
    @IBOutlet weak var visibilityField: UITextField!
    var catArray:[[String: Any]] = [[String:Any]]()
    var catNameArray:[String] = [String]()
    var selectedCatString = ""
    var selectedCatID = ""
    var selectedPrivacy = ""
    var selectedVisibility = ""
    var delegate:CreateGroupDelegate!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callingCategoryService()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissMe(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func createGroupButtonClicked(_ sender: Any) {
        let grpName = self.grpNameField.text!.trimmingCharacters(in: .whitespaces)
        if grpName == "" {
            SharedManager.shared.showAlert(message: "Please Enter valid group name".localized(), view: self)
            return
        }
        else if self.selectedCatString == "" {
            SharedManager.shared.showAlert(message: "Please select the category of group".localized(), view: self)
            return
        }else if(self.selectedPrivacy == ""){
            SharedManager.shared.showAlert(message: "Please select the privacy of group".localized(), view: self)
            return
        }
//        else if(self.selectedVisibility == ""){
//            SharedManager.shared.showAlert(message: "Please select the visibility of group", view: self)
//            return
//        }
        self.callingCreateGroupService()
    }
}

extension CreateGroupController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.grpNameField {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = textField.text!.components(separatedBy: cs).joined(separator: "")
            return (textField.text == filtered)
            
        }
        else if textField == self.categoryField {
            self.showPicker(arr: self.catNameArray, type: 0)
            return false
        }else if textField == self.privacyField {
            self.showPicker(arr: ["Public".localized(),"Private".localized()], type: 1)
            //            self.datePickerTapped()
            return false
        }
        else if textField == self.visibilityField {
            self.showPicker(arr: ["Visible Publicly".localized(), "Not Visible Publicly".localized()], type: 2)
            return false
        }
        
        return true
    }
}

extension CreateGroupController:PickerviewDelegate  {
    func pickerChooseMultiView(text: [String] , type : Int)
    {
        
    }
    func pickerChooseView(text: String, type: Int) {
        if type == 0 {
            self.selectedCatString = text
            self.categoryField.text = text
            self.saveSelectedCatID()
        }else if type == 1 {
            self.privacyField.text = text
            self.selectedPrivacy = "0"
            if text == "Private".localized() {
                self.selectedPrivacy = "1"
            }
        }else {
            self.visibilityField.text = text
            self.selectedVisibility = "0"
            if text == "Not Visible Publicly".localized() {
                self.selectedPrivacy = "1"
            }
        }
    }
    
    func showPicker(arr:[String], type:Int){
        let picker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        picker.isMultipleItem = false
        picker.pickerDelegate = self
        picker.type = type
        picker.arrayMain = arr
        self.present(picker, animated: true)
    }
    
    func callingCategoryService(){
        let parameters = ["action": "group/categories", "token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    self.catArray = res as! [[String : Any]]
                    for dict in self.catArray {
                        self.catNameArray.append(dict["name"] as! String)
                    }
                }
            }
        }, param:parameters)
    }

    func callingCreateGroupService(){
        let parameters = ["action": "group/create","group_name":self.grpNameField.text!,
                          "group_category_id":self.selectedCatID,
                          "group_privacy":self.selectedPrivacy,
                          "group_visibility": self.selectedVisibility,
                          "token": SharedManager.shared.userToken()]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//        SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    self.delegate.groupCreatedSuccessfullyDelegate()
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
    
    func saveSelectedCatID() {
        var counter = 0
        for name in self.catNameArray {
            if name == self.categoryField.text {
                break
            }
            counter = counter + 1
        }
        let dict = self.catArray[counter]
        if let catID = dict["id"] as? Int {
            self.selectedCatID = String(catID)
        }
    }
}
