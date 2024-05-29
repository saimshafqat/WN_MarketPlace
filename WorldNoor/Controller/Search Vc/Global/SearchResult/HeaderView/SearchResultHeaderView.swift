//
//  SearchResultHeaderView.swift
//  WorldNoor
//
//  Created by Asher Azeem on 20/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(SearchResultHeaderView)
class SearchResultHeaderView: SSBaseCollectionReusableView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headingLabel: UILabel?    
    // MARK: - Properties
    var sectionInfo: SectionInfo?
    var indexPath: IndexPath?
    
    // MARK: - Methods -
    func configureView(obj: AnyObject?, parentObj: AnyObject?, indexPath: IndexPath) {
        if let itemSection = obj as? SectionInfo {
            sectionInfo = itemSection
            self.indexPath = indexPath
            headingLabel?.text = itemSection.sectionIdentifier as? String
        }
    }
}
