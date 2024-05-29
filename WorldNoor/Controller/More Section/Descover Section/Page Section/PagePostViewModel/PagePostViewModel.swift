//
//  PagePostViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class PagePostViewModel : PageBaseViewModel {
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .pageFeedAPI(params)
    }
}

