//
//  CreatePostTypeTableCell.swift
//  WorldNoor
//
//  Created by Niks on 5/7/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class CreatePostTypeTableCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK: - Properties define.
    static let identifier = "CreatePostTypeTableCell"
    static let nib = UINib(nibName: "CreatePostTypeTableCell", bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
