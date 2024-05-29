//
//  CreateGroupController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/30/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//


import Foundation
import UIKit

protocol CreatePageDelegate {
    func pageCreatedSuccessfullyDelegate()
}

protocol editPageDelegate {
    func pageEditedSucessfully(page: GroupValue)
}

class PageCreateController: UIViewController {
    
    @IBOutlet weak var grpNameField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var tfSlug: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    var catArray:[[String: Any]] = [[String:Any]]()
    var catNameArray:[String] = [String]()
    var selectedCatString = [String]()
    var selectedCatID = [String]()
    var selectedPrivacy = ""
    var selectedVisibility = ""
    var delegate: CreatePageDelegate!
    var editDelegate: editPageDelegate!
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
    
    var isCreate: Bool = true
    var pageValue: GroupValue!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view!.tag == 100 ) {
            self.view.removeFromSuperview()
            self.dismissVC(completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callingCategoryService()
        // Do any additional setup after loading the view.
        
        if !isCreate { // edit - add old values
            LogClass.debugLog("pageValue.name ===>")
            
            if pageValue.name.count == 0 {
                grpNameField.text = pageValue.groupName
            }else {
                grpNameField.text = pageValue.name
            }
            LogClass.debugLog(pageValue.name)
            LogClass.debugLog(pageValue.title)
            LogClass.debugLog(pageValue.groupName)
            
            
            
         
            
            for i in pageValue.categories {
                if (categoryField.text?.count ?? 0) > 0 {
                    categoryField.text = categoryField.text! + ", " + i
                } else {
                    categoryField.text = i
                }
            }
            
            selectedCatString = pageValue.categories
            tfSlug.text = pageValue.slug
            tfSlug.isEnabled = false
            descriptionField.text = pageValue.groupDesc
        }
    }
    
    @IBAction func createGroupButtonClicked(_ sender: Any) {
        let grpName = self.grpNameField.text!.trimmingCharacters(in: .whitespaces)
        
        if grpName == "" {
            SharedManager.shared.showAlert(message: "Please Enter valid page name".localized(), view: self)
            return
        } else if self.tfSlug.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Please Enter the page slug".localized(), view: self)
            return
        } else if self.selectedCatString.count == 0 {
            SharedManager.shared.showAlert(message: "Please select the category of page".localized(), view: self)
            return
        }
        
        saveSelectedCatID()
        if isCreate { // mean create
            self.callingCreatePageService()
        } else { // mean edit page
            self.callingEditPageService()
        }
    }
}

extension PageCreateController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.tfSlug {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            return (string == filtered)
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.grpNameField {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = textField.text!.components(separatedBy: cs).joined(separator: "")
            return (textField.text == filtered)
            
        } else if textField == self.categoryField {
            self.showPicker(arr: self.catNameArray, type: 0)
            return false
        }
        
        return true
    }
}

extension PageCreateController:PickerviewDelegate  {
    
    func pickerChooseMultiView(text: [String] , type : Int) {
        self.selectedCatString = text
        
        self.categoryField.text = ""
        for indexObj in self.selectedCatString {
            if self.categoryField.text!.count > 0 {
                self.categoryField.text = self.categoryField.text! + ", " + indexObj
            } else {
                self.categoryField.text = indexObj
            }
        }
        //        self.saveSelectedCatID()
    }
    
    func pickerChooseView(text: String, type: Int) {
    }
    
    func showPicker(arr:[String], type:Int){
        let picker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        picker.isMultipleItem = true
        picker.pickerDelegate = self
        picker.type = type
        picker.arrayMain = arr
        picker.selectedItems = selectedCatString
        self.present(picker, animated: true)
    }
    
    func callingCategoryService() {
        
        let parameters = ["action": "page/categories_meta",
                          "token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
                    self.catArray = res as! [[String : Any]]
                    for dict in self.catArray {
                        self.catNameArray.append(dict["name"] as! String)
                    }
                }
            }
        }, param:parameters)
    }
    
    func saveSelectedCatID() {
        
        for catObj in self.catArray {
            for indexObj in self.selectedCatString {
                if let catName = catObj["name"] as? String {
                    if indexObj == catName {
                        if let catID = catObj["id"] as? Int {
                            self.selectedCatID.append(String(catID))
                        }
                    }
                }
            }
        }
    }
    
    func callingCreatePageService() {
        var parameters = ["action": "page/create",
                          "page_title": self.grpNameField.text!,
                          "page_url": self.tfSlug.text!,
                          "token": SharedManager.shared.userToken()]
        
        if self.descriptionField.text!.trimmingCharacters(in: .whitespaces) != "" {
            parameters["description"] = self.descriptionField.text!
        }
        
        for indexObj in 0..<self.selectedCatID.count {
            parameters["page_category_ids[" + String(indexObj) + "]"] = String(self.selectedCatID[indexObj])
        }
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    self.delegate.pageCreatedSuccessfullyDelegate()
                    self.view.removeFromSuperview()
                }
            }
        }, param:parameters)
    }
    
    func callingEditPageService() {
        
        var parameters = ["action": "page/update",
                          "title":self.grpNameField.text!,
                          "page_id": pageValue.groupID,
                          "token": SharedManager.shared.userToken()]
        
        // description is optional
        parameters["description"] = self.descriptionField.text!
        
        for indexObj in 0..<self.selectedCatID.count {
            parameters["page_category_ids[" + String(indexObj) + "]"] = String(self.selectedCatID[indexObj])
        } // or category_ids the same
        
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
                } else {
                    
                    let pageOBJ = GroupValue.init(fromDictionary: res as! [String : Any])
                    self.editDelegate.pageEditedSucessfully(page: pageOBJ)
                    self.dismissVC(completion: nil)
                }
            }
        }, param:parameters)
    }
}
