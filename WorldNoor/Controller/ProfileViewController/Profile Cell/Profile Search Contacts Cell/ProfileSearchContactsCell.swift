//
//  ProfileSearchContactsCell.swift
//  WorldNoor
//
//  Created by apple on 1/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileSearchContactsCell : UITableViewCell {
    
    @IBOutlet var txtFieldSearch : UITextField!
    @IBOutlet var btnFilter : UIButton!
    
    override class func awakeFromNib() {
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
