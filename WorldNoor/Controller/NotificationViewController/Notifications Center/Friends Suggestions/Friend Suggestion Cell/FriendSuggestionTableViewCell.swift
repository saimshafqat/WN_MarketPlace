//
//  FriendSuggestionTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 06/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class FriendSuggestionTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var addFriendButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var cancelFriendRequestButton: UIButton!
    
    private var friendSuggestion: SuggestedFriendModel?
    private var delegate: FriendSuggestionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(friendSuggestion: SuggestedFriendModel, delegate: FriendSuggestionsDelegate) {
        
        self.friendSuggestion = friendSuggestion
        self.delegate = delegate
        
        let userImage = friendSuggestion.profileImage
        DispatchQueue.main.async {
            self.userImageView.loadImageWithPH(urlMain: userImage)
        }
        
        nameLabel.text = friendSuggestion.firstname + " " + friendSuggestion.lastname

        if friendSuggestion.mutualFriendsCount == "0" {
            descriptionLabel.text = "No mutual friends".localized()
        } else {
            descriptionLabel.text = friendSuggestion.mutualFriendsCount + " " + "mutual friends".localized()
        }
        
        // handle add friend button
        if friendSuggestion.isFriendRequestSent { // firend request sent
            addFriendButton.isHidden = true
            removeButton.isHidden = true
            cancelFriendRequestButton.isHidden = false
        } else {
            addFriendButton.isHidden = false
            removeButton.isHidden = false
            cancelFriendRequestButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = UIImage(imageLiteralResourceName: "profile_icon")
    }
    
    @IBAction func addFriendTapped(_ sender: Any) {
        
        guard let friend = self.friendSuggestion else {
            return
        }
        
        addFriendButton.isHidden = true
        removeButton.isHidden = true
        cancelFriendRequestButton.isHidden = false
        delegate?.addFriendTapped(friendSuggestion: friend)
    }
    
    @IBAction func cancelFriendRequestTapped(_ sender: Any) {
        guard let friend = self.friendSuggestion else {
            return
        }
        
        addFriendButton.isHidden = false
        removeButton.isHidden = false
        cancelFriendRequestButton.isHidden = true
        delegate?.cancelFriendRequestTapped(friendSuggestion: friend)
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        guard let friend = self.friendSuggestion else {
            return
        }
        descriptionLabel.text = "Removed".localized()
        addFriendButton.isHidden = true
        removeButton.isHidden = true
        cancelFriendRequestButton.isHidden = true
        delegate?.removeFriendTapped(friendSuggestion: friend)
    }
}
