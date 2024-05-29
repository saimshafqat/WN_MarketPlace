//
//  ProfileLifeEventCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ProfileLifeEventCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var eventDescriptionLabel: UILabel?
    @IBOutlet weak var deleteBtn: UIButton?
    @IBOutlet weak var btnEventTitle: UIButton?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
