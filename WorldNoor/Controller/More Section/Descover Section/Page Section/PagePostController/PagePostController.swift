//
//  PagePostController1.swift
//  WorldNoor
//
//  Created by Waseem Shah on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class PagePostController: PageBaseViewController {
    
    var groupObj: GroupValue?
    override func setupViewModel() -> PageBaseViewModel? {
        return PagePostViewModel()
    }
    
    override func screenTitle() -> String {
        return ""
    }
}

