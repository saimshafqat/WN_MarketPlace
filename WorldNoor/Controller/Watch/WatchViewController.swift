//
//  WatchViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class WatchViewController: WatchBaseViewController {
    
    override func setupViewModel() -> WatchBaseViewModel? {
        return WatchViewModel()
    }
    
    override func screenTitle() -> String {
        return "watch".localized()
    }
}
