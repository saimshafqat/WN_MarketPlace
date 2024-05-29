//
//  SearchResultViewHelper.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class SearchResultViewHelper: LayoutBaseHelper {
    
    var dataSource:SSBaseDataSource?
        
    func peopleSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .estimated(80), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(80), with: [item])
        let section = makeSection(with: group, hasHeader: true, hasFooter: true, headerHeight: 50)
        return section
    }

    func postSection() -> NSCollectionLayoutSection {
        let item = createItem(height: .estimated(50), width: .fractionalWidth(1.0))
        let group = createGroup(with: item, height: .estimated(50), width: .fractionalWidth(1.0))
        let section = makeSection(with: group, hasFooter: true, headerHeight: 50)
        return section
    }
            
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let currentSection = (self.dataSource as? SSSectionedDataSource)?.section(at: sectionNumber)
            let identifier = currentSection?.sectionIdentifier as? String
            if (identifier == SectionIdentifier.PeopleSearch.type) || (identifier == SectionIdentifier.PageSearch.type) || (identifier == SectionIdentifier.GroupSearch.type) {
                return self.peopleSection()
            } else {
                return self.postSection()
            }
        }
    }
}
