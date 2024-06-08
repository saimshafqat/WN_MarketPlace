//
//  MPProfileListingHeaderTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileListingHeaderTableViewCell: UITableViewCell {
    static let identifier = "MPProfileListingHeaderTableViewCell"
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func shareBtn_Action(_ sender: Any) {
    }
    
    
    @IBAction func filterBtn_Action(_ sender: Any) {
    }
    
    @IBAction func clearBtn_Action(_ sender: Any) {
    }
    
}
