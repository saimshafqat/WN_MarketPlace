//
//  EditProfileFamilyRelationshipVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 14/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class EditProfileFamilyRelationshipVC: RelationshipBaseVC {
    
    // MARK: - Life Cycle -
    override func screenTitle() -> String {
        return "Family".localized()
    }
    
    override func editRelationshipObj() -> RelationshipModel? {
        return SharedManager.shared.userEditObj.familyRelationshipArray[rowIndex]
    }
    
    override func performOnAppear(with type: Int) {
        if relationshipArray.count == 0 {
            getFamilyRelationships()
        }
    }
    
    override func performRelationshipDeleteRequest() {
        let params: [String: String] = ["partnership_id": self.relationEditStatus?.partnerhip_id ?? .emptyString]
        self.apiService.deleteFamilyRelationStausRequest(endPoint: .deleteFamilyRelationStaus(params))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully Family RelationshipList")
                case .failure(let error):
                    LogClass.debugLog("Unable Family RelationshipList.")
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("Family RelationshipList Token Response ==> \(response)")
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                SharedManager.shared.userEditObj.familyRelationshipArray.removeAll(where: {$0.partnerhip_id == self.relationEditStatus?.partnerhip_id})
                self.dismiss(animated: true) {
                    self.refreshParentView?()
                }
            })
            .store(in: &self.subscription)
    }
    
    override func submitBtnValidation() -> String {
        if videoDropDown?.text?.count == 0 {
            return "Please fill relationship field"
        } else if partnerTextField.text?.count == 0 {
            return "Please fill partner field"
        }
        return .emptyString
    }
    
    override func submitRequestParams() -> [String : String] {
        var params: [String: String] = [:]
        if type == 2 {
            let userId = isPartnerChange ? "\(selectedPatnerList.first?.id ?? 0)" : relationEditStatus?.user?.id ?? .emptyString
            params.updateValue(userId, forKey: "user_id")
            params.updateValue(self.relationEditStatus?.partnerhip_id ?? .emptyString, forKey: "partnership_id")
            let statusEditID = isRelationChange ? "\(relationshipStatus?.id ?? 0)" : relationEditStatus?.statusId ?? .emptyString
            params.updateValue(statusEditID, forKey: "status_id")
            params.updateValue("family-relationship-status-update", forKey: "action")
        } else {
            params.updateValue("\(selectedPatnerList.first?.id ?? 0)" , forKey: "user_id")
            params.updateValue("\(relationshipStatus?.id ?? 0)", forKey: "status_id")
            params.updateValue("family-relationship-status-save", forKey: "action")
        }
        return params
    }
    
    override func submitResponseSuccess(index: [String : Any]) {
        if self.type == 2 {
            SharedManager.shared.userEditObj.familyRelationshipArray[self.rowIndex] = RelationshipModel(fromDictionary: index)
        } else {
            SharedManager.shared.userEditObj.familyRelationshipArray.append(RelationshipModel(fromDictionary: index))
        }
    }
    
    func getFamilyRelationships() {
        apiService.familyRelationStatusListRequest(endPoint: .familyRelationStatusList([:]))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully Family RelationshipList")
                case .failure(let error):
                    LogClass.debugLog("Failure Family RelationshipList")
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("Family RelationshipList Response ==> \(response)")
                self.relationshipArray.removeAll()
                for relationStatus in response.data {
                    self.relationshipArray.append(relationStatus)
                }
                LogClass.debugLog(self.relationshipArray)
            })
            .store(in: &subscription)
    }
}
