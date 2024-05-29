//
//  ProfileDetailInfoCell.swift
//  WorldNoor
//
//  Created by apple on 1/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ProfileDetailInfoCell : UITableViewCell {
    
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblinfo : UILabel!
    @IBOutlet var lblEdit : UILabel!
    
    @IBOutlet var imgViewMain : UIImageView!
    
    @IBOutlet var btnEdit : UIButton!
    
    @IBOutlet var viewEdit : UIView!
      
    override class func awakeFromNib() {
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
}
