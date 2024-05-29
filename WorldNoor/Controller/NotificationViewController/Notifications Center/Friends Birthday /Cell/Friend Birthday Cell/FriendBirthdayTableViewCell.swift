//
//  FriendBirthdayTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 04/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class FriendBirthdayTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var friendImageView: UIImageView!
    @IBOutlet private weak var friendNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private var friendBirthday: FriendBirthdayModel?
    private weak var delegate: friendsBirthdayDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind (friendBirthday: FriendBirthdayModel, type: BirthdayListSectionTypes, delegate: friendsBirthdayDelegate) {
        
        self.friendBirthday = friendBirthday
        self.delegate = delegate
        
        let userImage = friendBirthday.profileImage
        DispatchQueue.main.async {
            self.friendImageView.loadImageWithPH(urlMain: userImage)
        }
        
        friendNameLabel.text = friendBirthday.firstName + " " + friendBirthday.lastName
        
        if type == .today {
            dateLabel.text = "Today".localized() + ", " + friendBirthday.dateOfBirth.convertDateToBirthdayFormate(formatteType: .monthNumber)
        } else if type == .tomorrow {
            dateLabel.text = "Tomorrow".localized() + ", " + friendBirthday.dateOfBirth.convertDateToBirthdayFormate(formatteType: .monthNumber)
        } else {
            dateLabel.text = friendBirthday.dateOfBirth.convertDateToBirthdayFormate(formatteType: .dayMonthNumber)
        }
    }
    
    @IBAction func messageTapped(_ sender: Any) {
        
        guard let friend = self.friendBirthday else {
            return
        }
        delegate?.chatTapped(friendBirthday: friend)
    }
}
