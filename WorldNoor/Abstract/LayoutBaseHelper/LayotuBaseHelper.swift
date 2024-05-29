//
//  LayotuBaseHelper.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 27/05/2023.

import UIKit

class LayoutBaseHelper {
    
    func createItem(height: NSCollectionLayoutDimension, width: NSCollectionLayoutDimension) -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        return item
    }
    
    func createGroup(with item: NSCollectionLayoutItem, height: NSCollectionLayoutDimension, width: NSCollectionLayoutDimension) -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        return group
    }
    
    func createSection(with group: NSCollectionLayoutGroup, groupInterSpacing: CGFloat = 0.0) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = groupInterSpacing
        return section
    }
    
    func addFooter(_ section: NSCollectionLayoutSection, height: NSCollectionLayoutDimension) {
        section.boundarySupplementaryItems.append(contentsOf: [ NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: height), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)])
    }
    
    // cell division with specific height
    func desireCellDivision(with height: NSCollectionLayoutDimension, cellCount: Int, hasHeader: Bool = false, hasFooter: Bool = false, footerHeight: CGFloat = 50) -> NSCollectionLayoutSection {
        let item = createItem(height: .fractionalHeight(1.0), width: .fractionalWidth(1.0))
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 6, bottom: 4, trailing: 6)
        let group = makeHorizontalGroup(width: .fractionalWidth(1.0), height: height, with: item, cellCount: cellCount)
        let section = makeSection(with: group, hasHeader: hasHeader, hasFooter: hasFooter, footerHeight: footerHeight)
        section.contentInsets.leading = 8.0
        section.contentInsets.trailing = 8.0
        return section
    }
    
    func makeHorizontalGroup(width wSize: NSCollectionLayoutDimension, height hSize: NSCollectionLayoutDimension, with item: NSCollectionLayoutItem, cellCount: Int = 2) -> NSCollectionLayoutGroup {
        let groupSize = NSCollectionLayoutSize(widthDimension: wSize, heightDimension: hSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: cellCount)
        return group
    }
    
    // make Horizontal Group
    func makeHorizontalGroup(width wSize: NSCollectionLayoutDimension, height hSize: NSCollectionLayoutDimension, with items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        let groupSize = NSCollectionLayoutSize(widthDimension: wSize, heightDimension: hSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        return group
    }
    
    func makeSection(with group: NSCollectionLayoutGroup, hasHeader: Bool = false, hasFooter: Bool = false, headerHeight: CGFloat = 40, footerHeight: CGFloat = 50) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        if hasHeader {
            section.boundarySupplementaryItems = showHeader(with: .estimated(headerHeight))
        }
        if hasFooter {
            section.boundarySupplementaryItems.append(contentsOf: showFooter(with: .estimated(footerHeight)))
        }
        return section
    }
    
    // 1- Handle Header
    func showHeader(with height: NSCollectionLayoutDimension) -> [NSCollectionLayoutBoundarySupplementaryItem] {
        return [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: height), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
    }
    
    func showFooter(with height: NSCollectionLayoutDimension) -> [NSCollectionLayoutBoundarySupplementaryItem] {
        return [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(65)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        ]
    }
    
    func createHorizontalGroup(width wSize: NSCollectionLayoutDimension, height hSize: NSCollectionLayoutDimension, with item: NSCollectionLayoutItem, cellCount: Int = 2) -> NSCollectionLayoutGroup {
        let groupSize = NSCollectionLayoutSize(widthDimension: wSize, heightDimension: hSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: cellCount)
        return group
    }
}
