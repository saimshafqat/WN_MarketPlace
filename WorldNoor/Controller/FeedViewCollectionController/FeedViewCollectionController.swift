//
//  FeedViewCollectionController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 03/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class FeedViewCollectionController: FeedPostBaseViewController {
        
    override func setupViewModel() -> FeedPostBaseViewModel? {
        return FeedViewCollectionModel()
    }
    
    override func screenTitle() -> String {
        return Const.FeedView.localized()
    }
}
