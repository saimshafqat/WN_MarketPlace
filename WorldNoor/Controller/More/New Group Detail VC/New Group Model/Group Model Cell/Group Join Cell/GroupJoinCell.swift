//
//  GroupJoinCell.swift
//  WorldNoor
//
//  Created by apple on 11/18/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class GroupJoinCell : UITableViewCell {
    
    @IBOutlet var btnJoin : UIButton!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblJoin : UILabel!
    @IBOutlet var lblTotalMembers : UILabel!
    
    var groupObj:GroupValue!
    
    func reloadName(){
        
        self.lblName.text = self.groupObj.groupName
        self.lblTotalMembers.text = self.groupObj.totalMember
    }
    
    
}
