//
//  ProfilePostViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class ProfilePostViewModel : ProfileBaseViewModel {
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .profileFeedView(params)
    }
}


