//
//  NotificationSettingsTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

enum NotificationMainTypes: String {
    
    case contact = "contact"
    case page = "page"
    case group = "group"
    case post = "post"
    case comment = "comment"
    case story = "story"
    case user = "user"
    case memory = "memory"
    case birthday = "birthday"
    case reel = "reel"
    case family = "family"
    case relationship = "relationship"
}

class NotificationSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var typeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(setting: NotificationSettingModel) {
        
        typeImageView.image = UIImage()
        typeNameLabel.text = setting.localizedTitle
        
        guard let type = NotificationMainTypes(rawValue: setting.name) else { return }
        switch type {
            
        case .contact:
            typeImageView.image = UIImage(named: "settings_contact")
        case .page:
            typeImageView.image = UIImage(named: "settings_page")
        case .group:
            typeImageView.image = UIImage(named: "settings_group")
        case .post:
            typeImageView.image = UIImage(named: "settings_post")
        case .comment:
            typeImageView.image = UIImage(named: "settings_comment")
        case .story:
            typeImageView.image = UIImage(named: "settings_story")
        case .user:
            typeImageView.image = UIImage(named: "settings_user")
        case .memory:
            typeImageView.image = UIImage(named: "settings_memories")
        case .birthday:
            typeImageView.image = UIImage(named: "settings_birthday")
        case .reel:
            typeImageView.image = UIImage(named: "settings_reel")
        case .family:
            typeImageView.image = UIImage(named: "settings_family")
        case .relationship:
            typeImageView.image = UIImage(named: "settings_relationship")
        }
    }
}
