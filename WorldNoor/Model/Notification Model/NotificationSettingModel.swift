//
//  NotificationSettingModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class NotificationSettingModel : ResponseModel {
    
    var name = ""
    var status = ""
    var subtypes = [NotificationSettingSubTypeModel]()
    
    var localizedTitle = ""
    
    override init() {
        super.init()
    }

    init(fromDictionary dictionary: [String:Any]) {
        super.init()

        self.name = self.ReturnValueCheck(value: dictionary["name"] as Any)
        self.status = self.ReturnValueCheck(value: dictionary["status"] as Any)
        
        self.subtypes.removeAll()

        if let indexArray = dictionary["subtypes"] as? [[String : Any]] {
            for objMain in indexArray {
                self.subtypes.append(NotificationSettingSubTypeModel.init(fromDictionary: objMain))
            }
        }
        
        self.localizedTitle = self.name
        guard let type = NotificationMainTypes(rawValue: self.name) else { return }
        switch type {
            
        case .contact:
            localizedTitle = "Contact".localized()
        case .page:
            localizedTitle = "Page".localized()
        case .group:
            localizedTitle = "Group".localized()
        case .post:
            localizedTitle = "Post".localized()
        case .comment:
            localizedTitle = "Comment".localized()
        case .story:
            localizedTitle = "Story".localized()
        case .user:
            localizedTitle = "User".localized()
        case .memory:
            localizedTitle = "Memory".localized()
        case .birthday:
            localizedTitle = "Birthday".localized()
        case .reel:
            localizedTitle = "Reel".localized()
        case .family:
            localizedTitle = "Family".localized()
        case .relationship:
            localizedTitle = "Relationship".localized()
        }
    }
}
