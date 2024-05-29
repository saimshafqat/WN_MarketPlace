//
//  RecentSearchCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

@objc(RecentSearchCell)
class RecentSearchCell: SSBaseTableCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var searchLbl: UILabel?
    @IBOutlet weak var bodyView: DesignableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyView.frame.size.height = bodyView.frame.size.height / 2.0
    }
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        super.configureCell(cell, atIndex: thisIndex, with: object)
        if let obj = object as? RecentSearchData {
            self.searchLbl?.text = obj.searchQuery
        }
    }
}
