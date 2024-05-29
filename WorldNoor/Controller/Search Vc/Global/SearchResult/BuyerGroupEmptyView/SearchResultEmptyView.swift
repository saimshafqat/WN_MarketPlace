//
//  BuyerGroupEmptyView.swift
//  SweetSpot
//
//  Created by Asher Azeem on 10/25/22.
//

import UIKit


@objc(SearchResultEmptyView)

class SearchResultEmptyView: SSBaseCollectionReusableView {
    
    class func customInit() -> SearchResultEmptyView? {
        return .loadNib()
    }
    
}
