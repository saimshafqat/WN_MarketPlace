//
//  ProfilePlaceDetailInfoCell.swift
//  WorldNoor
//
//  Created by apple on 1/15/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfilePlaceDetailInfoCell : UITableViewCell {
    
    @IBOutlet var lblCompanyName : UILabel!
    @IBOutlet var lblDesignation : UILabel!
    @IBOutlet var lblEdit : UILabel!
    
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var viewEdit : UIView!
    @IBOutlet var btnDelete : UIButton!
    
    override class func awakeFromNib() {
      }

      static var nib:UINib {
          return UINib(nibName: identifier, bundle: nil)
      }
    
      static var identifier: String {
          return String(describing: self)
      }
}
