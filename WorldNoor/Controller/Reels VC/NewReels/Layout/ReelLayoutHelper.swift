//
//  ReelLayoutHelper.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

final class ReelLayoutHelper : LayoutBaseHelper {
    
//    func createLayout() -> UICollectionViewLayout {
//        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
//        let group = createGroup(with: item, height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
//        let section = createSection(with: group)
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
    
    
    func createLayout() -> UICollectionViewLayout {
        // Create an item with fractional sizes
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        // Create a group with fractional sizes
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitems: [item]
        )

        // Create a section with the group
        let section = NSCollectionLayoutSection(group: group)

        // Create the compositional layout with the section
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }

    
}
