//
//  FeedbackBaseTableCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(FeedBackBaseTableCell)
class FeedBackBaseTableCell: SSBaseTableCell {
    
    var indexPath: IndexPath?
    @IBOutlet weak var nameLabel: UILabel?

    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        self.indexPath = thisIndex
        if let obj = object as? FeedBAckOptions {
            nameLabel?.text = obj.text.localized()
        }
    }
}
