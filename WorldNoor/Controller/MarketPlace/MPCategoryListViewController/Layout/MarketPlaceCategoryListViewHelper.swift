//
//  MarketPlaceCollectionReusableView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MarketPlaceCategoryListViewHelper: LayoutBaseHelper {
    
    var dataSource: SSBaseDataSource?
    
    func categoryPeopleSection(isHeader: Bool) -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0)
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .absolute(50), with: item, cellCount: 1)
        let section = makeSection(with: group, hasHeader: isHeader, hasFooter: true, footerHeight: 0.8)
        section.contentInsets.leading = 8.0
        section.contentInsets.trailing = 8.0
        return section
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let identifier = (self.dataSource as? SSSectionedDataSource)?.section(at: sectionIndex).sectionIdentifier as? String ?? .emptyString
            if identifier == "Generic Categories" {
                return self.categoryPeopleSection(isHeader: false)
            } else {
                return self.categoryPeopleSection(isHeader: true)
            }
        }
        return layout
    }
}
