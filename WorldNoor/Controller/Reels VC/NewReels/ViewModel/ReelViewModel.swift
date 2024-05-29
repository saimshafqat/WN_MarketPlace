//
//  ReelViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 17/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ReelViewModel {

    
    func successMsg(_ msg: String) {
        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: msg)
    }
    
    func failureMsg() {
        
    }
    
    func moveToHashTag(with text: String) -> HashTagVC {
        let controller = HashTagVC.instantiate(fromAppStoryboard: .Shared)
        controller.Hashtags = text
        controller.isFromReelScreen = true
        return controller
    }
}
