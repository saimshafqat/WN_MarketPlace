//
//  FilterNearByUsersViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 04/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

class FilterNearByUsersViewController: UIViewController {
    
    @IBOutlet private weak var ageSlider: UISlider!
    @IBOutlet private weak var distanceSlider: UISlider!
    
    @IBOutlet private weak var selectedGenderLabel: UILabel!
    @IBOutlet private weak var selectedRelationshipLabel: UILabel!
    @IBOutlet private weak var selectedEducationLabel: UILabel!
    @IBOutlet private weak var selectedInterestLabel: UILabel!
    
    var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    private var arrayInterest = [InterestModel]()
    private var arrayRelationStatus = [RelationshipStatus]()
    
    weak var delegate : FilterDelegate?
    
     var toAge: String?
     var toDistance: String?
     var selectedGender: String?
     var selectedRelationshipID: String?
     var selectInterestID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        setFilterSelectedValues()
    }

    func setFilterSelectedValues() {
//        if let age = self.toAge { self.ageSlider.value = Float(age) ?? 16 }
//        if let distance = self.toDistance { self.distanceSlider.value = Float(distance) ?? 1 }
        
//        selectedGenderLabel.text = selectedGender
//        selectedRelationshipLabel.text =
//        selectedEducationLabel.text =
//        selectedInterestLabel.text =
    }
    
    @IBAction func genderTapped(_ sender: Any) {
        
        let genderVC = GenderPopUpViewController()
        genderVC.delegate = self
        self.present(genderVC, animated: true)
    }
    
    @IBAction func relationShipTapped(_ sender: Any) {
      
        if arrayRelationStatus.isEmpty {
            self.getRelationships()
        } else {
            self.openRelationshipAlert()
        }
    }
    
    @IBAction func educationTapped(_ sender: Any) {
        print("education")
    }
    
    @IBAction func interestTapped(_ sender: Any) {
        
        if arrayInterest.isEmpty {
            self.getInterestes()
        } else {
            self.openInterestAlert()
        }
    }
    
    @IBAction func applyTapped(_ sender: Any) {
        
        self.toAge = String(ageSlider.value)
        self.toDistance = String(distanceSlider.value)
      
        delegate?.filterTapped(toAge: toAge,
                               toDistance: toDistance,
                               gender: self.selectedGender,
                               relationShipID: self.selectedRelationshipID,
                               InterestID: self.selectInterestID)
        self.dismiss(animated: true)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        
        ageSlider.value = 16  // minumum
        distanceSlider.value = 1 // minumum

        selectedGenderLabel.text = ""
        selectedRelationshipLabel.text = ""
        selectedEducationLabel.text = ""
        selectedInterestLabel.text = ""
        
        self.selectedGender = nil
        self.selectedRelationshipID = nil
        self.selectInterestID = nil
    }
}

extension FilterNearByUsersViewController {
    
    private func openInterestAlert() {
        
        var arrayName = [String]()
        for indexObj in self.arrayInterest {
            arrayName.append(indexObj.name)
        }
        
        let picker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        picker.isMultipleItem = false
        picker.pickerDelegate = self
        picker.type = 0
        picker.arrayMain = arrayName
        self.present(picker, animated: true)
    }
    
    private func openRelationshipAlert() {
        
        var arrayName = [String]()
        for indexObj in self.arrayRelationStatus {
            arrayName.append(indexObj.status)
        }
        
        let picker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        picker.isMultipleItem = false
        picker.pickerDelegate = self
        picker.type = 1
        picker.arrayMain = arrayName
        self.present(picker, animated: true)
    }
}

// api calls
extension FilterNearByUsersViewController {
    
    private func getInterestes() {
        
        Loader.startLoading()
        let parameters = ["action": "meta/interests",
                          "token": SharedManager.shared.userToken()]
        
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
                        self.arrayInterest.append(InterestModel.init(fromDictionary: indexObj))
                    }
                    self.openInterestAlert()
                }
            }
        }, param: parameters)
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
                Loader.stopLoading()
                LogClass.debugLog("RelationshipList  Response ==> \(response)")
                self.arrayRelationStatus.removeAll()
                for relationStatus in response.data {
                    self.arrayRelationStatus.append(relationStatus)
                }
                self.openRelationshipAlert()
                print("Total Relationship Items \(self.arrayRelationStatus)")
            }).store(in: &subscription)
    }
}

//------------gender-------------------
protocol GenderProtocol: AnyObject {
    func genderSelected(selectedGander: String)
}

extension FilterNearByUsersViewController: GenderProtocol {
    
    func genderSelected(selectedGander: String) {
        
        if selectedGander == "Male" {
            self.selectedGender = "M"
        } else if selectedGander == "Female" {
            self.selectedGender = "F"
        } else if selectedGander == "Other" {
            self.selectedGender = "Other"
        }
        self.selectedGenderLabel.text = selectedGander
    }
}

//---------------------interest -------------
extension FilterNearByUsersViewController : PickerviewDelegate {
    
    func pickerChooseView(text: String, type : Int) {
        
        if type == 0 {
            self.selectedInterestLabel.text = text
            
            for indexObj in self.arrayInterest {
                if indexObj.name == self.selectedInterestLabel.text {
                    self.selectInterestID = indexObj.id
                }
            }
        }
        
        if type == 1 {
            
            self.selectedRelationshipLabel.text = text
            
            for indexObj in self.arrayRelationStatus {
                if indexObj.status == self.selectedRelationshipLabel.text {
                    self.selectedRelationshipID = String(indexObj.id)
                }
            }
        }
    }
}
