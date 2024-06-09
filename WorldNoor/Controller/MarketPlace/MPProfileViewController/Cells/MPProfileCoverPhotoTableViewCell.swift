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
    @IBOutlet weak var profileBgView: UIView!
    var joinWorlNoorText = "Join Worldnoor in"
    override func awakeFromNib() {
        super.awakeFromNib()
        makeCircle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
    func makeCircle() {
        let size = min(profileBgView.layer.frame.width, profileBgView.layer.frame.height)
        profileBgView.layer.cornerRadius = size / 2
        profileBgView.clipsToBounds = true
    }
    
    func setupCellData(model: ListingUser?){
        nameLabel.text = "\(model?.firstname ?? "") \(model?.lastname ?? "")"
        followersCountLabel.text = "\(model?.totalFollowersCount ?? 0)"
        listingsCountLabel.text = "\(model?.totalListingsCount ?? 0)"
        joinedDateLabel.text = "\(joinWorlNoorText) \(model?.createdAt ?? 2024)"
        profileImageView.kf.setImage(
            with: URL(string: model?.profileImage ?? .emptyString),
            placeholder: UIImage(named: "placeholder.png"))
        
        coverPhotoImageView.kf.setImage(
            with: URL(string: model?.coverImage ?? .emptyString),
            placeholder: UIImage(named: "placeholder.png"))
    }
    
}
