//
//  ProfileUserHeadingCell.swift
//  WorldNoor
//
//  Created by apple on 1/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileUserHeadingCell : UITableViewCell {
    
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblEdit : UILabel!
    @IBOutlet var imgEdit : UIImageView!
    @IBOutlet var imgViewExpand : UIImageView!
    @IBOutlet var btnExpand : UIButton!
    
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnSeeAll : UIButton!
    @IBOutlet var viewEdit : UIView!
    @IBOutlet var viewSeeAll : UIView!
      
    override class func awakeFromNib() {
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
}
