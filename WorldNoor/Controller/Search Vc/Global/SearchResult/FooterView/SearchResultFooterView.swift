//
//  SearchResultFooterView.swift
//  WorldNoor
//
//  Created by Asher Azeem on 22/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol SearchResultFooterDelegate {
    func seeAllTapped(at section: SectionInfo, indexPath: IndexPath?)
}


@objc(SearchResultFooterView)
class SearchResultFooterView: SSBaseCollectionReusableView {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var seeAllBtn: UIButton!
    
    // MARK: - Property -
    var searchResultFooterDelegate: SearchResultFooterDelegate?
    var sectionInfo: SectionInfo?
    var indexPath: IndexPath?
    
    // MARK: - IBActions -
    @IBAction func onClickViewMore(_ sender: UIButton) {
        if let sectionInfo {
            searchResultFooterDelegate?.seeAllTapped(at: sectionInfo, indexPath: indexPath)
        }
    }
    
    // MARK: - Methods -
    func configureView(obj: AnyObject?, parentObj: AnyObject?, indexPath: IndexPath) {
        if let itemSection = obj as? SectionInfo {
            sectionInfo = itemSection
            self.indexPath = indexPath
            if let dataSource = parentObj as? SSSectionedDataSource {
                setSpacerView(dataSource, at: indexPath)
            }
        }
    }
    
    func setSpacerViewVisibility(shouldHide: Bool) {
        spacerView.isHidden = shouldHide
    }

    func setSpacerView(_ dataSource: SSSectionedDataSource, at thisIndex: IndexPath) {
        if dataSource.sections.count > 0 {
            let currentSection = dataSource.section(at: thisIndex.section)
            if currentSection != nil {
                let nextSectionIndex = thisIndex.section + 1
                if dataSource.sections.count > nextSectionIndex {
                    let nextSection = dataSource.section(at: nextSectionIndex) as? SectionInfo
                    if nextSection != nil {
                        if nextSection?.sectionIdentifier as? String == SectionIdentifier.PostSearch.rawValue {
                            setSpacerViewVisibility(shouldHide: true)
                        } else {
                            setSpacerViewVisibility(shouldHide: false)
                        }
                    }
                }
            }
        }
    }
}
