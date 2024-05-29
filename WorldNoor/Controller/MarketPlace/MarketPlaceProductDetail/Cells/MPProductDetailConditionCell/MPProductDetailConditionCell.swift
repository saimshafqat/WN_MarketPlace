//
//  MPProductDetailMeetupMapCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MPProductDetailConditionCell)
class MPProductDetailConditionCell: SSBaseCollectionCell {
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MpProductDetailModel {
            conditionLabel.text = obj.condition
        }
    }
}
