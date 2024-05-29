//
//  ProfileFriendStatusCell.swift
//  WorldNoor
//
//  Created by apple on 12/30/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileFriendStatusCell : UITableViewCell {
    
    @IBOutlet var btnMessage : UIButton!
    @IBOutlet var btnRequest : UIButton!
    @IBOutlet var btnMore : UIButton!
    
    @IBOutlet var imgViewRequest : UIImageView!
    
    @IBOutlet var viewMessage : UIView!
    @IBOutlet var viewRequest : UIView!
    @IBOutlet var viewMore : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
      
    }
    
}
