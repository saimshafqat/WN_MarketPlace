//
//  WatchPostController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 12/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class WatchViewController: WatchBaseViewController {
    
    override func setupViewModel() -> WatchBaseViewModel? {
        return WatchViewModel()
    }
    
    override func screenTitle() -> String {
        return "watch".localized()
    }
}


