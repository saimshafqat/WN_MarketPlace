//
//  GroupNameCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class GroupNameCell : UICollectionViewCell {
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblTotalMembers : UILabel!

    @IBOutlet var btnMore : UIButton!
    
    var groupObj:GroupValue!
    
    func reloadName(){
        
        self.lblName.text = self.groupObj.groupName
        self.lblTotalMembers.text = self.groupObj.totalMember
    }
}
