//
//  ProfileUserNameCell.swift
//  WorldNoor
//
//  Created by apple on 1/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileUserNameCell : UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
//    @IBOutlet var lblDesignation : UILabel!
    
    
    @IBOutlet var btnName : UIButton!
//    @IBOutlet var btnDesignation : UIButton!
    
    override class func awakeFromNib() {
        
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {    
        return String(describing: self)
    }
}
