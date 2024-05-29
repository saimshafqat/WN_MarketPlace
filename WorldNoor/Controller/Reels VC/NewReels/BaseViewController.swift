//
//  BaseViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var tableView: UITableView?
    
    public lazy var dataSource: SSBaseDataSource? = {
        let dataSrc = self.initilizeDataSource()
        return dataSrc
    }()

    public func configureView() {
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseTableCell)?.configureCell(cell, atIndex: indexPath, with: object)
            (cell as? SSBaseTableCell)?.layoutIfNeeded()
            (cell as? SSBaseCollectionCell)?.configureCell(cell, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
        }
        dataSource?.collectionView = collectionView
        dataSource?.tableView = tableView
        dataSource?.tableView?.sectionTopSpace()
        dataSource?.rowAnimation = .none
        dataSource?.reloadData()
    }
    
    public func initilizeDataSource() -> SSBaseDataSource? {
        return nil
    }
    
    public func fetchController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return nil
    }
    
}
