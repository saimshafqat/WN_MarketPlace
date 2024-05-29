//
//  FeedViewCollectionModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 03/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

final class FeedViewCollectionModel : FeedPostBaseViewModel {
                     
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .feedView(params)
    }
    
    override func visibilityMemorySharing() -> Bool {
        return true
    }
}

