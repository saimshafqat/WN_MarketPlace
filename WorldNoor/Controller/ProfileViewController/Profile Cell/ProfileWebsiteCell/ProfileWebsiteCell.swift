//
//  ProfileWebsiteCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 20/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ProfileWebsiteCell: UITableViewCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var txtLink: UITextView!
    
    // MARK: - Properties -
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

}
