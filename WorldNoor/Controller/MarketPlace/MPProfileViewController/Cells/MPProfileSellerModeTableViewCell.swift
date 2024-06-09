//
//  MPProfileSellerModeTableViewCell.swift
//  WorldNoor
//
//  Created by swift on 09/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileSellerModeTableViewCell: UITableViewCell {
    static let identifier = "MPProfileSellerModeTableViewCell"
    
    @IBOutlet weak var messageLbl: UILabel!
    var descriptionText = "This seller has turned mode on holiday mode and currently won't accept order or receive messages."
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure() {
        messageLbl.text = descriptionText
    }
    
}
