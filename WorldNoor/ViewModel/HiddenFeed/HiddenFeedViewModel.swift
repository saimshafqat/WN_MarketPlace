//
//  HiddenFeedViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class HiddenFeedViewModel : PostBaseViewModel {
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .hiddenFeedPost(params)
    }
    
}
