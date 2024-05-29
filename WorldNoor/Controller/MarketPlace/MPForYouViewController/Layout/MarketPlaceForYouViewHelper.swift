//
//  MarketPlaceForYouViewHelper.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MarketPlaceForYouViewHelper: LayoutBaseHelper {
    
    var companySection: NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(250), with: item, cellCount: 2)
        group.interItemSpacing = .fixed(4.0)
        let section = makeSection(with: group, hasHeader: true, hasFooter: true, headerHeight: 50, footerHeight: 0.8)
        return section
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let composition = UICollectionViewCompositionalLayout(section: companySection)
        return composition
    }
}


class MarketPlaceProductDetailViewHelper: LayoutBaseHelper {
    
    var dataSource:SSBaseDataSource?

    func companySection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .estimated(80))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(80), with: item, cellCount: 1)
        group.interItemSpacing = .fixed(4.0)
        let section = makeSection(with: group, hasHeader: true, hasFooter: false, footerHeight: 0.0)
        return section
    }
    
    func similarAndRelatedProductSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(250), with: item, cellCount: 2)
        group.interItemSpacing = .fixed(4.0)
        let section = makeSection(with: group, hasHeader: true, hasFooter: false, footerHeight: 0.0)
        return section
    }
    
    func createSection(hasHeader: Bool = false) -> NSCollectionLayoutSection {
        let item = createItem(height: .estimated(50), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(50), with: [item])
        let section = makeSection(with: group, hasHeader: hasHeader, headerHeight: 50)
        return section
    }
    
    func productImageSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .estimated(50), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(50), with: [item])
        let section = makeSection(with: group)
        section.orthogonalScrollingBehavior = .paging
        return section
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let currentSection = (self.dataSource as? SSSectionedDataSource)?.section(at: sectionNumber)
            let identifier = currentSection?.sectionIdentifier as? String
            if identifier == SectionIdentifier.images.type {
                return self.productImageSection()
            } else if identifier == SectionIdentifier.similarProduct.type || identifier == SectionIdentifier.relatedProduct.type {
                return self.similarAndRelatedProductSection()
            } else if identifier == SectionIdentifier.productGroup.type {
                return self.companySection()
            } else {
                return self.createSection()
            }
        }
    }
}
