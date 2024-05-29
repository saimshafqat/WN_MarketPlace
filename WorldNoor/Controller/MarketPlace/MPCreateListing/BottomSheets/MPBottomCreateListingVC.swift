//
//  MPBottomCreateListingVC.swift
//  WorldNoor
//
//  Created by Awais on 01/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPBottomCreateListingVC: UIViewController {

    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    
    // MARK: - Properties -
    lazy var dataSource: SSArrayDataSource? = {
        let ds = SSArrayDataSource(items: [
            Item(name: "Items", iconImage: UIImage(named: "mp_items")),
            Item(name: "Vehicles", iconImage: UIImage(named: "mp_car")),
            Item(name: "Properties for sale or rent", iconImage: UIImage(named: "mp_home"))
        ])
        return ds
    }()

    var viewHelper = MPBottomCreateListingViewHelper()
    
    var itemSelected : ((Item) -> ())?

    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHelper.dataSource = dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
        collectionView?.delegate = self
        configureView()
    }
    
    func configureView() {
        dataSource?.cellClass = MPBottomCreateListingCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
        }
        
        dataSource?.rowAnimation = .none
        dataSource?.collectionView = collectionView
    }
    
    
}

extension MPBottomCreateListingVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = dataSource?.item(at: indexPath) as? Item {
            if let itemSelected = itemSelected {
                itemSelected(item)
            }
        }
    }
}
