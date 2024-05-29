//
//  ProfilePostController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProfilePostController: ProfileBaseViewController {
    
    var otherUserID = ""
    var otherUserisFriend = ""
    var otherUserSearchObj : SearchUserModel!
    var otherUserObj = UserProfile.init()
    
    
    override func setupViewModel() -> ProfileBaseViewModel? {
        return ProfilePostViewModel()
    }
    
    override func screenTitle() -> String {
        return ""
    }
}


