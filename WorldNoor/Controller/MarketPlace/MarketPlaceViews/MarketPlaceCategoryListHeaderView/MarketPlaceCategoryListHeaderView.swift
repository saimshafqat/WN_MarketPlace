//
//  MarketPlaceCategoryListHeaderView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MarketPlaceCategoryListHeaderView)
class MarketPlaceCategoryListHeaderView: SSBaseCollectionReusableView {
    
    class func customInit() -> MarketPlaceCategoryListHeaderView? {
        return .loadNib()
    }
    
    // MARK: - Properties -
    @IBOutlet weak var categoryListName: UILabel!
    
    // MARK: - Methods -
    func configureView(section: SSSection?, sectionIndex: Int?) {
        categoryListName?.text = section?.header
    }
}
