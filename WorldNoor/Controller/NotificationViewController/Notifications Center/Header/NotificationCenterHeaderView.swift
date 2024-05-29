//
//  NotificationCenterHeaderView.swift
//  WorldNoor
//
//  Created by Omnia Samy on 31/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NotificationCenterHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!
    
    func bind(title: String) {
        
        titleLabel.text = title
    }
}
