//
//  SavedPostViewModel1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

final class SavedPostViewModel1 : PostBaseViewModel {
        
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .savedPost(params)
    }
}
