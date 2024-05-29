//
//  MPSellLayout.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 07/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPSellLayout: LayoutBaseHelper {
    
    var dataSource:SSBaseDataSource?
    
    func tagSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .estimated(60))
        item.edgeSpacing = .none
        let group = makeHorizontalGroup(width: .estimated(150), height: .estimated(40), with: [item])
        let section = makeSection(with: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        return section
    }
    
    func overviewSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .estimated(100))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(100), with: item, cellCount: 2)
        group.interItemSpacing = .fixed(8.0)
        let section = makeSection(with: group, hasHeader: true, hasFooter: false, footerHeight: 0.0)
        section.contentInsets.leading = 8
        section.contentInsets.trailing = 8
        return section
    }
    
    func createListingViewSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .estimated(130))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(130), with: item, cellCount: 1)
        let section = makeSection(with: group, hasHeader: false, hasFooter: false, footerHeight: 0.0)
        section.contentInsets.leading = 8
        section.contentInsets.trailing = 8
        return section
    }


    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let currentSection = (self.dataSource as? SSSectionedDataSource)?.section(at: sectionNumber)
            let identifier = currentSection?.sectionIdentifier as? String
            if identifier == SectionIdentifier.MPSellTag.type {
                return self.tagSection()
            } else if identifier == SectionIdentifier.MPSellListCreating.type {
                return self.createListingViewSection()
            } else {
                return self.overviewSection()
            }
        }
    }
}

