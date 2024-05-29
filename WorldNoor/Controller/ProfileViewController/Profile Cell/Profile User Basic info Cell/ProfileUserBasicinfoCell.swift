//
//  ProfileUserBasicinfoCell.swift
//  WorldNoor
//
//  Created by apple on 1/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileUserBasicinfoCell : UITableViewCell {
    
    @IBOutlet var lblInfo : UILabel!
    @IBOutlet var lblDetailInfo : UILabel!
    @IBOutlet var imgViewMain : UIImageView!
    
    @IBOutlet var btnEdit : UIButton!
      
    override class func awakeFromNib() {
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
}
