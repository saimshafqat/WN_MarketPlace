//
//  ProfileWorkDetailInfoCell.swift
//  WorldNoor
//
//  Created by apple on 1/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileWorkDetailInfoCell : UITableViewCell {
    
    @IBOutlet var lblCompanyName : UILabel!
    @IBOutlet var lblDesignation : UILabel!
    @IBOutlet var lblTime : UILabel!    
    @IBOutlet var lblEdit : UILabel!
    
    @IBOutlet var viewEdit : UIView!
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
