//
//  ExtensionSSSectionDataSource.swift
//  WorldNoor
//
//  Created by Asher Azeem on 28/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension SSSectionedDataSource {
    
    // 1- configure section with identifier
    func configureSection(_ identifier: SectionIdentifier, object: [AnyObject]?, sortOrder: Int) {
        var section = section(withIdentifier: identifier.type)
        if section == nil {
            section = customSection(object, identifier: identifier, sortOrder: sortOrder)
            appendSection(section)
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.sortingSection()
            }
            // Start the animation
            animator.startAnimation()
        }
    }
    
    // make section
    func customSection(_ item: [AnyObject]?, identifier: SectionIdentifier, sortOrder: Int = 0) -> SSSection? {
        return SectionInfo.section(withItems: item, header: nil, identifier: identifier.type, sortId: sortOrder)
    }
    
    // will sort section after update
    func sortingSection() {
        let sections = sections as? [SectionInfo]
        guard sections?.count ?? 0 > 1 else { return }
        if let sections {
            let sortedList = sections.sorted(by: {$0.sortId < $1.sortId})
            for (newIndex, item) in sortedList.enumerated() {
                print(newIndex, item)
                let oldIndex = sections.firstIndex(where: {$0 === item})
                if oldIndex != nil && oldIndex != newIndex {
                    moveSection(at: oldIndex ?? 0, to: newIndex)
                    if compare(sortedList, sections) {
                        break
                    }
                }
            }
        }
    }
    
    // it will compare section if both list will be same it will return true otherwise will return false and then we don't need to continue process
    func compare(_ sorted: [SectionInfo], _ unsorted: [SectionInfo]) -> Bool {
        return unsorted.count == sorted.count && sorted == unsorted.sorted(by: {$0.sortId < $1.sortId})
    }
    
}

