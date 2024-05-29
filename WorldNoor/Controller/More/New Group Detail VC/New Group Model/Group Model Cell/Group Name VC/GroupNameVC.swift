//
//  GroupNameVC.swift
//  WorldNoor
//
//  Created by apple on 11/17/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//
import Foundation
import UIKit

class GroupNameVC : UITableViewCell {
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblTotalMembers : UILabel!

    @IBOutlet var btnMore : UIButton!
    
    var groupObj:GroupValue!
    
    func reloadName(){
        
        self.lblName.text = self.groupObj.groupName
        self.lblTotalMembers.text = self.groupObj.totalMember
    }
}
