//
//  ExtensionSSBaseDataSource.swift
//  WorldNoor
//
//  Created by Asher Azeem on 23/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

extension SSBaseDataSource {
    
    // get index paths
    func getSectionIndexPaths(section : Int) -> [IndexPath] {
        let count = numberOfItems(inSection: section)
        let countInt = Int(count)
        return (0..<countInt).map { IndexPath(row: $0, section: section)}
    }
    
    func scrollToTopCV() {
        if tableView != nil {
            self.tableView?.setContentOffset(.zero, animated: true)
        }
        if collectionView != nil {
            self.collectionView?.setContentOffset(.zero, animated: true)
        }
    }
    
    func clearEmptyViewHasData() {
        if numberOfItems() > 0 && emptyView != nil {
            emptyView = nil
        }
    }
}

