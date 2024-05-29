//
//  EditProfileRelationshipVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 13/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class EditProfileRelationshipVC: RelationshipBaseVC {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var dateTextField: DatePickerTextField!
    @IBOutlet weak var dateFieldHeightConstraint: NSLayoutConstraint! // 50
    @IBOutlet weak var partnerView: DesignableView!
    @IBOutlet weak var dateView: DesignableView!
    
    // MARK: - Override -
    override func performRelationChangeDD() {
        self.partnerViewVisibility()
    }
    
    override func screenTitle() -> String {
        return "Relationship".localized()
    }
    
    override func editRelationshipObj() -> RelationshipModel? {
        return SharedManager.shared.userEditObj.relationshipArray[rowIndex]
    }
    
    // MARK: - Life Cycle -
    override func performOnAppear(with type: Int) {
        if self.type == 2 {
            dateTextField.text = relationEditStatus?.relationshipCreationDate
        }
        partnerViewVisibility()
        if relationshipArray.count == 0 {
            getRelationships()
        }
    }
    
    override func performRelationshipDeleteRequest() {
        let params: [String: String] = [
            "partnership_id": self.relationEditStatus?.partnerhip_id ?? .emptyString,
        ]
        self.apiService.deleteRelationStautsRequest(endPoint: .deleteRelationStauts(params))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Deleted RelationshipList")
                case .failure(let error):
                    LogClass.debugLog("Failed Delete RelationshipList.")
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
                }
            }, receiveValue: { response in
                LogClass.debugLog("Delete relationship response ==> \(response)")
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                SharedManager.shared.userEditObj.relationshipArray.removeAll(where: {$0.partnerhip_id == self.relationEditStatus?.partnerhip_id})
                self.dismiss(animated: true) {
                    self.refreshParentView?()
                }
            })
            .store(in: &self.subscription)
    }
    
    override func submitBtnValidation() -> String {
        if videoDropDown?.text?.count == 0 {
            return "Please fill relationship field"
        }
        if videoDropDown?.text != "Single".localized() {
            if dateTextField.text?.count == 0 {
                return "Please fill date field"
            }
            if partnerTextField.text?.count == 0 {
                return "Please fill partner field"
            }
        }
        return .emptyString
    }
    
    override func submitRequestParams() -> [String : String] {
        var params: [String: String] = [:]
        if type == 2 {
            // if change then should send changed id otherwise will send current status id
            let statusEditID = isRelationChange ? "\(relationshipStatus?.id ?? 0)" : relationEditStatus?.statusId ?? .emptyString
            params.updateValue(statusEditID, forKey: "status_id")
            params.updateValue("relationship-status-update", forKey: "action")
            if self.videoDropDown?.text != "Single".localized() {
                let userId = isPartnerChange ? "\(selectedPatnerList.first?.id ?? 0)" : relationEditStatus?.user?.id ?? .emptyString
                params.updateValue(userId, forKey: "user_id")
                params.updateValue(self.relationEditStatus?.partnerhip_id ?? .emptyString, forKey: "partnership_id")
                params.updateValue("\(dateTextField.text ?? .emptyString)", forKey: "selected_date")
            }
        } else {
            params.updateValue("\(relationshipStatus?.id ?? 0)", forKey: "status_id")
            params.updateValue("relationship-status-save", forKey: "action")
            if self.videoDropDown?.text != "Single".localized() {
                params.updateValue("\(selectedPatnerList.first?.id ?? 0)" , forKey: "user_id")
                params.updateValue("\(dateTextField.text ?? .emptyString)", forKey: "selected_date")
            }
        }
        return params
    }
    
    override func submitResponseSuccess(index: [String : Any]) {
        if self.type == 2 {
            SharedManager.shared.userEditObj.relationshipArray[self.rowIndex] = RelationshipModel(fromDictionary: index)
        } else {
            let newAddedUser = RelationshipModel(fromDictionary: index)
            SharedManager.shared.userEditObj.relationshipArray.append(newAddedUser)
        }
    }
    
    func partnerViewVisibility() {
        DispatchQueue.main.async {
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                let isCheck = self.videoDropDown?.text == "Single".localized()
                let newDateHeight: CGFloat =  isCheck ? 0 : 50
                let newPartnerHeight: CGFloat = isCheck ? 0 : 50
                let newSubmitTopAnchor: CGFloat = isCheck ? 0 : 50
                self.partnerView.isHidden = isCheck
                self.dateView.isHidden = isCheck
                self.dateFieldHeightConstraint.constant = newDateHeight
                self.partnerFieldHeightConstraint.constant = newPartnerHeight
                self.submitBtnTopConstraint.constant = newSubmitTopAnchor
                self.view.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }
    
    func getRelationships() {
        apiService.relationStatusListRequest(endPoint: .relationStatusList([:]))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully load relationshipList")
                case .failure(let error):
                    LogClass.debugLog("Unable to load relationshipList.")
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("RelationshipList response ==> \(response)")
                self.relationshipArray.removeAll()
                for relationStatus in response.data {
                    self.relationshipArray.append(relationStatus)
                }
                LogClass.debugLog("Relationship \(self.relationshipArray)")
            })
            .store(in: &subscription)
    }
    
    // MARK: - Method -
    override func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    override func deleteRelationshipRequest() {
        ShowAlertWithCompletaion(titleMsg: "Delete Relationship", message: "Are you sure you want to delete relationship?") { success in
            if success {
                let params: [String: String] = [
                    "partnership_id": self.relationEditStatus?.partnerhip_id ?? .emptyString,
                ]
                self.apiService.deleteRelationStautsRequest(endPoint: .deleteRelationStauts(params))
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Deleted RelationshipList")
                        case .failure(_):
                            LogClass.debugLog("Failed Delete RelationshipList.")
                        }
                    }, receiveValue: { response in
                        LogClass.debugLog("Delete relationship response ==> \(response)")
                        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                        SharedManager.shared.userEditObj.relationshipArray.removeAll(where: {$0.partnerhip_id == self.relationEditStatus?.partnerhip_id})
                        self.dismiss(animated: true) {
                            self.refreshParentView?()
                        }
                    })
                    .store(in: &self.subscription)
            }
        }
    }
    
    override func getUserFriendList() {
        let params: [String : String] = [:]
        apiService.getUserFriendsRequest(endPoint: .getUserFriend(params))
            .sink(receiveCompletion: { completion in
                Loader.stopLoading()
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully Family RelationshipList")
                case .failure(let error):
                    LogClass.debugLog("Unable RelationshipList.\(error.localizedDescription)")
                }
            }, receiveValue: { response in
                LogClass.debugLog("Family RelationshipList Token Response ==> \(response)")
                self.userFriendList.removeAll()
                for index in response.data {
                    self.userFriendList.append(index)
                }
            })
            .store(in: &subscription)
    }
    
    func showcountryPicker(Type : Int) {
        let controller = Pickerview.instantiate(fromAppStoryboard: .EditProfile)
        controller.isMultipleItem = false
        controller.isFromRelationship = true
        controller.type = Type
        self.selectedPatnerList.removeAll()
        controller.relationshipCompletion = { value, type in
            print("Value ==> \(value) and type ==> \(type)")
            let textarray = value.components(separatedBy: ",")
            for indexObj in textarray {
                for indexInner in self.userFriendList {
                    let name = (indexInner.firstname ?? .emptyString) + " " + ((indexInner.lastname ?? .emptyString))
                    if indexObj == name {
                        self.selectedPatnerList.append(indexInner)
                        self.partnerTextField.text = name
                    }
                }
            }
        }
        var arrayData = [String]()
        for indexObj in self.userFriendList {
            arrayData.append((indexObj.firstname ?? .emptyString) + " " + (indexObj.lastname ?? .emptyString))
        }
        var selectedRealtion = [String]()
        //        if otherUserID.count > 0 {
        //            for indexObj in 0..<otherUserObj.relationshipArray.count {
        //                let name = (otherUserObj.relationshipArray[indexObj].user?.firstname ?? .emptyString) + " " + (otherUserObj.relationshipArray[indexObj].user?.lastname ?? .emptyString)
        //                selectedRealtion.append(name)
        //            }
        //        } else {
        //            for indexObj in 0..<SharedManager.shared.userEditObj.relationshipArray.count {
        //                selectedRealtion.append((SharedManager.shared.userEditObj.relationshipArray[indexObj].user?.firstname ?? .emptyString) + " " + (SharedManager.shared.userEditObj.relationshipArray[indexObj].user?.lastname ?? .emptyString))
        //            }
        //        }
        var arr: [String] = userFriendList.map({$0.username ?? .emptyString})
        arr.removeAll()
        userFriendList.forEach { freind in
            arr.append((freind.firstname ?? .emptyString) + " " + (freind.lastname ?? .emptyString))
        }
        controller.arrayMain = arr
        controller.selectedItems = selectedRealtion
        present(controller, animated: true)
    }
    
    func onClickSubmit() {
        if videoDropDown?.text?.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please fill field".localized())
            return
        }
        if videoDropDown?.text != "Single" {
            if dateTextField.text?.count == 0 {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please fill field".localized())
                return
            }
            if partnerTextField.text?.count == 0 {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please fill field".localized())
                return
            }
        }
        var action = ""
        if type == 2 {
            action = "relationship-status-update"
        } else {
            action = "relationship-status-save"
        }
        var params: [String: String] = ["action": action, "status_id": "\(relationshipStatus?.id)"]
        if videoDropDown?.text != "Single" {
            if type == 2 {
                params.updateValue(relationEditStatus?.user?.id ?? .emptyString , forKey: "user_id")
                params.updateValue(self.relationEditStatus?.partnerhip_id ?? .emptyString, forKey: "partnership_id")
                params.updateValue("\(dateTextField.text ?? .emptyString)", forKey: "selected_date")
            } else {
                params.updateValue("\(selectedPatnerList.first?.id ?? 0)" , forKey: "user_id")
                params.updateValue("\(dateTextField.text ?? .emptyString)", forKey: "selected_date")
            }
        }
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
                } else if res is [[String : Any]] {
                    for index in res as? [[String: Any]] ?? [] {
                        if self.type == 2 {
                            SharedManager.shared.userEditObj.relationshipArray[self.rowIndex] = RelationshipModel(fromDictionary: index)
                        } else {
                            let newAddedUser = RelationshipModel(fromDictionary: index)
                            SharedManager.shared.userEditObj.relationshipArray.append(newAddedUser)
                        }
                    }
                    self.dismiss(animated: true) {
                        self.refreshParentView?()
                    }
                }
            }
        }, param:params)
    }
}
