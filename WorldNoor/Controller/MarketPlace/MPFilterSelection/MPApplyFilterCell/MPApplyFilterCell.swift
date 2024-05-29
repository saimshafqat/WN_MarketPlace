//
//  MPApplyFilterCell.swift
//  WorldNoor
//
//  Created by Ahmad on 21/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPApplyFilterCell: UITableViewCell {
    @IBOutlet weak var lblFilterTitle: UILabel?

    @IBOutlet weak var btnCheckBox: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFilterUI(_ item: Any) {
        if let item = item as? FilterCondition {
            lblFilterTitle?.text = item.name
        }else if let item = item as? SlotItem {
            lblFilterTitle?.text = item.name
        }
    }
}
