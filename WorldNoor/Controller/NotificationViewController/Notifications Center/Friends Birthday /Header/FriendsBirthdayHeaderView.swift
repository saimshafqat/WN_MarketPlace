//
//  FriendsBirthdayHeaderView.swift
//  WorldNoor
//
//  Created by Omnia Samy on 06/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class FriendsBirthdayHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func bind(section: BirthdaySectionItem) {
        
        if section.type == .today || section.type == .upcoming {
            titleLabel.font = titleLabel.font.withSize(20)
        } else {
            titleLabel.font = titleLabel.font.withSize(15)
        }
        
        titleLabel.text = section.title
    }
}
