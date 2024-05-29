//
//  ProfileContactCell.swift
//  WorldNoor
//
//  Created by apple on 1/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileContactCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblGroups : UILabel!
    
    @IBOutlet var btnDelete : UIButton!
    
    @IBOutlet var imgViewUser : UIImageView!
    
    @IBOutlet var viewDelete : UIView!
    
    override class func awakeFromNib() {
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
