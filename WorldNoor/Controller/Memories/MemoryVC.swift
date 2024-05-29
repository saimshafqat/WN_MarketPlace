//
//  SavedPostViewController1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//

import UIKit

class MemoryVC: PostBaseViewController {
        
    override func setupViewModel() -> PostBaseViewModel? {
        return MemoryViewModel()
    }
    
    override func screenTitle() -> String {
        return Const.Memories.localized()
    }
    
}
