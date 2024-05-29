//
//  SavedReelLayoutHelper.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 01/05/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class SavedReelViewHelper: LayoutBaseHelper {
    
    var companySection: NSCollectionLayoutSection {
        let item = createItem(height: .estimated(120), width: .fractionalWidth(1.0))
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: .estimated(120), with: item, cellCount: 1)
        let section = makeSection(with: group)
        section.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
        return section
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let composition = UICollectionViewCompositionalLayout(section: companySection)
        return composition
    }
}
