//
//  GroupPostViewModel1.swift
//  WorldNoor
//
//  Created by Waseem Shah on 18/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class GroupPostViewModel1 : GroupBaseViewModel {
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .groupFeedAPI(params)
    }
}

