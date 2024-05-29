//
//  MarketPlaceCategoryListFooterView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MarketPlaceCategoryListFooterView)
class MarketPlaceCategoryListFooterView: SSBaseCollectionReusableView {

    @IBOutlet weak var heightConstriantView: NSLayoutConstraint?
    
    class func customInit() -> MarketPlaceCategoryListFooterView? {
        return .loadNib()
    }

    func configureView(height: CGFloat = 0.8) {
        heightConstriantView?.constant = height
    }
}
