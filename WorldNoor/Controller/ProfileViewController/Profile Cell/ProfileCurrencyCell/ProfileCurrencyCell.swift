//
//  ProfileCurrencyCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 24/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ProfileCurrencyCell: UITableViewCell {

    // MARK: - IBOutlets -
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    // MARK: - Properties -
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
