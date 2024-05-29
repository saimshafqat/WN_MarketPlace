//
//  GroupPostController1.swift
//  WorldNoor
//
//  Created by Waseem Shah on 18/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class GroupPostController1: GroupBaseViewController {
    
    var groupObj: GroupValue?
    override func setupViewModel() -> GroupBaseViewModel? {
        return GroupPostViewModel1()
    }
    
    override func screenTitle() -> String {
        return ""
    }
}
