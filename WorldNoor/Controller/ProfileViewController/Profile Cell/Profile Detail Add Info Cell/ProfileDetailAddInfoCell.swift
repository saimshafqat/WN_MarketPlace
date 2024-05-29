//
//  ProfileDetailAddInfoCell.swift
//  WorldNoor
//
//  Created by apple on 1/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ProfileDetailAddInfoCell : UITableViewCell {
    
    @IBOutlet var lblHeading : UILabel!

    
    @IBOutlet var imgViewMain : UIImageView!
    
    @IBOutlet var btnAdd : UIButton!
      
    override class func awakeFromNib() {
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
}
