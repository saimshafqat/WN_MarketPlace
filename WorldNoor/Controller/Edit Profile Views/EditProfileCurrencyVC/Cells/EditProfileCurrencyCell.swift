//
//  EditProfileCurrencyCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class EditProfileCurrencyCell: UITableViewCell {
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencySelectedImage: UIImageView!
    
    func configureView(item: Any?, indexPath: IndexPath)  {
        if let obj = item as? Currency {
            currencyLabel.text = obj.name + " - " + obj.symbol
            currencySelectedImage.isHidden = ("\(obj.id)" != SharedManager.shared.userEditObj.currency?.id)
        }
    }
}
