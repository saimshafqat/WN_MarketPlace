//
//  ProfileUserTextViewCell.swift
//  WorldNoor
//
//  Created by apple on 1/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileUserinfoCell : UITableViewCell {
    
    @IBOutlet var lblInfo : UILabel!
    @IBOutlet var btnAboutMe : UIButton!
    
    override class func awakeFromNib() {
        
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
