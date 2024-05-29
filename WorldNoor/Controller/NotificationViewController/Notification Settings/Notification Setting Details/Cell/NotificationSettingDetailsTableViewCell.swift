//
//  NotificationSettingDetailsTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 20/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NotificationSettingDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var typeNameLabel: UILabel!
    @IBOutlet private weak var typeSwitch: UISwitch!
    
    private var subType: NotificationSettingSubTypeModel?
    private weak var delegate: NotificationSettingDetailsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(subType: NotificationSettingSubTypeModel, delegate: NotificationSettingDetailsDelegate) {
        
        self.subType = subType
        self.delegate = delegate
        
        typeNameLabel.text = subType.localizedType
        
        if subType.status == "1" {
            self.typeSwitch.isOn = true
        } else {
            self.typeSwitch.isOn = false
        }
    }
    
    @IBAction func statusChanged(_ sender: UISwitch) {
        
        guard let type = self.subType else { return }
        if sender.isOn { // 1
            self.delegate?.subTypeStatusChanges(subType: type, status: 1)
        } else {
            self.delegate?.subTypeStatusChanges(subType: type, status: 0)
        }
    }
}
