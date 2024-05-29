//
//  SavedPostViewController1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//

import UIKit

class SavedPostController1: PostBaseViewController {
    
    override func setupViewModel() -> PostBaseViewModel? {
        return SavedPostViewModel1()
    }
    
    override func screenTitle() -> String {
        return Const.savedPost.localized()
    }
}
