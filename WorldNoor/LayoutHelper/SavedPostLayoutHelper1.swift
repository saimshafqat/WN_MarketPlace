//
//  SavedPostLayoutHelper1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

final class SavedPostLayoutHelper1 : LayoutBaseHelper {
    
    func createLayout() -> UICollectionViewLayout {
        let item = createItem(height: .estimated(50), width: .fractionalWidth(1.0))
        let group = createGroup(with: item, height: .estimated(50), width: .fractionalWidth(1.0))
        let section = createSection(with: group)
       // section.contentInsets.top = 6
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
