//
//  NotificationPopUpHeaderView.swift
//  WorldNoor
//
//  Created by Omnia Samy on 31/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NotificationPopUpHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notificationImageView: UIImageView!
    @IBOutlet private weak var iconImageView: UIImageView!
        
    func bind(notification: NotificationModel) {
        
        titleLabel.text = notification.text
        titleLabel.textAlignment = .center
        
        let userImage = notification.sender.profileImageThumbnail
        DispatchQueue.main.async {
            self.notificationImageView.loadImageWithPH(urlMain: userImage)
        }
        
        // types
//        iconImageView.image =
    }
}
