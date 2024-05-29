//
//  MPBottomCreateListingViewHelper.swift
//  WorldNoor
//
//  Created by Awais on 01/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

class MPBottomCreateListingViewHelper: LayoutBaseHelper {
    
    var dataSource: SSBaseDataSource?
    
    func createListingSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0)
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .absolute(50), with: item, cellCount: 1)
        let section = makeSection(with: group, footerHeight: 0.8)
        section.contentInsets.leading = 8.0
        section.contentInsets.trailing = 8.0
        return section
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let composition = UICollectionViewCompositionalLayout(section: createListingSection())
        return composition
    }
}
