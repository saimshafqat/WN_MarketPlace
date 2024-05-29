//
//  MemoryViewModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

final class MemoryViewModel : PostBaseViewModel {
                     
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .memories(params)
    }
    
    override func visibilityMemorySharing() -> Bool {
        return true
    }
}
