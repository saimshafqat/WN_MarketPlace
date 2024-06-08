//
//  MPProfileCoverPhotoTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileCoverPhotoTableViewCell: UITableViewCell {
    static let identifier = "MPProfileCoverPhotoTableViewCell"
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var listingsCountLabel: UILabel!
    @IBOutlet weak var listingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellData(){
        
    }
    
}
