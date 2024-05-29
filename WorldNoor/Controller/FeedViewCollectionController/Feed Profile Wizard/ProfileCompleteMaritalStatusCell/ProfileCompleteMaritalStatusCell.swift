//
//  ProfileCompleteMaritalStatusCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 24/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

class ProfileCompleteMaritalStatusCell: UICollectionViewCell , PickerviewDelegate, UITextFieldDelegate {

//    @IBOutlet weak var selectedMaritalStatusLabel: UILabel!
    
    @IBOutlet weak var tfMain: UITextField!
    @IBOutlet weak var imgViewDrop: UIImageView!
    
    weak var delegate: ProfileWizardDelegate?
    
    var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    var arrayRelationStatus = [RelationshipStatus]()
    
    var statusType = 0
    var chooseStatus : Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func bindData(type : Int){
        statusType = type
        if type == 1 {
            imgViewDrop.isHidden = true
            self.tfMain.placeholder = "Company Name".localized()
        } else {
            imgViewDrop.isHidden = false
            self.tfMain.placeholder = "Marital status".localized()
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if self.statusType != 1 {
            if self.arrayRelationStatus.count == 0 {
                self.getRelationships()
            }else {
                self.showPicker()
            }
            
            return false
            
        }
        
        return true
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        
            self.delegate?.closeTapped(isSkipped: true)
        
        
    }
 
    
    
    @IBAction func skipTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        self.tfMain.resignFirstResponder()
        if self.statusType == 0 {
            
            if self.chooseStatus > 0 {
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "relationship-status-save",
                                  "token": userToken,
                                  "status_id" : String(self.chooseStatus),
                                  "privacy_status": "Public",
                                  "user_id" : String(SharedManager.shared.userObj!.data.id!),
                                  "selected_date": Date().dateString("dd-MM-YYYY")]
                
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else {
                            SharedManager.shared.userObj?.data.RelationAdded = true
                            SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
                            self.delegate?.closeTapped(isSkipped: false)
                        }
                    }
                }, param:parameters)
            }else {
                UIApplication.topViewController()!.ShowAlert(message: "Please choose relation first.".localized())
            }
        }else {
            if self.tfMain.text!.count > 0 {
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "user/works/create",
                                  "token": userToken,
                                  "company" : self.tfMain.text!,
                                  "employment_status": "1"]
                
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else {
                            SharedManager.shared.userObj?.data.workAdded = true
                            SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)

                            self.delegate?.closeTapped(isSkipped: false)
                        }
                    }
                }, param:parameters)
            }else {
                UIApplication.topViewController()!.ShowAlert(message: "Please enter company name.".localized())
            }
        }
       
        
    }
    
    func showPicker(){
        let cuntryPicker = UIApplication.topViewController()!.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        
        cuntryPicker.isMultipleItem = false
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = 0
        
        var arrayData = [String]()
        
        for indexObj in self.arrayRelationStatus {
            arrayData.append(indexObj.status)
        }
        
        cuntryPicker.arrayMain = arrayData
        UIApplication.topViewController()!.present(cuntryPicker, animated: true) {
            
        }
    }
    
    func getRelationships() {
        Loader.startLoading()
        apiService.relationStatusListRequest(endPoint: .relationStatusList([:]))
            .sink(receiveCompletion: { completion in
                
                Loader.stopLoading()
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully stored relationshipList")
                case .failure(let error):
                    LogClass.debugLog("Unable to store relationshipList.")
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("RelationshipList  Response ==> \(response)")
                self.arrayRelationStatus.removeAll()
                for relationStatus in response.data {
                    self.arrayRelationStatus.append(relationStatus)
                }
                print("Total Relationship Items \(self.arrayRelationStatus)")
                
                self.showPicker()
            })
            .store(in: &subscription)
    }
    
    func pickerChooseView(text: String , type : Int) {
        LogClass.debugLog("pickerChooseView ===>")
        LogClass.debugLog(text)
        self.tfMain.text = text
        
        for indexObj in self.arrayRelationStatus {
            if indexObj.status == text {
                self.chooseStatus = indexObj.id
                break
            }
        }
    }
    
    func pickerChooseMultiView(text: [String] , type : Int) {
        LogClass.debugLog("pickerChooseMultiView ===>")
    }
    
}
