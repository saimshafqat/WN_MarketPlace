//
//  HiddenFeedViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class HiddenFeedViewController: PostBaseViewController {
    
    override func reportingType() -> String {
        return "UnHidePost"
    }
    
    override func setupViewModel() -> PostBaseViewModel? {
        return HiddenFeedViewModel()
    }
    
    override func screenTitle() -> String {
        return Const.hiddenPosts.localized()
    }
}
