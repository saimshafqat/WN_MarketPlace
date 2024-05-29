//
//  MessageRequestTVCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 25/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class MessageRequestTVCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func manageViewData(friendSuggestion: FriendSuggestionModel) {
        
        let userImage = friendSuggestion.profile_image
        DispatchQueue.main.async {
            self.userImageView.loadImageWithPH(urlMain: userImage)
        }
        
        nameLabel.text = friendSuggestion.firstname + " " + friendSuggestion.lastname
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = UIImage(imageLiteralResourceName: "profile_icon")
    }
    
}
