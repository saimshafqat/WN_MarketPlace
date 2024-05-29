//
//  FeedBackInfoTableCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(FeedBackInfoTableCell)
class FeedBackInfoTableCell: FeedBackBaseTableCell {

    @IBOutlet weak var detailLabel: UILabel?
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        super.configureCell(cell, atIndex: thisIndex, with: object)
        detailLabel?.text = "What kings of issues did you experience while watching this video?".localized()
        setupAlignments()
    }
    
    func setupAlignments() {
        detailLabel?.textAlignment = SharedManager.shared.checkLanguageAlignment() ? .right : .left
        nameLabel?.textAlignment = SharedManager.shared.checkLanguageAlignment() ? .right : .left
    }
}


