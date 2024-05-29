//
//  MPGlobalSearchResultViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 10/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPGlobalSearchResultViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    
    // MARK: - Properties -
    lazy var dataSource: SSArrayDataSource? = {
        let ds = SSArrayDataSource(items: ["Asher", "Ahmad", "Yasir", "Kamrna", "Ali Ahmad"])
        return ds
    }()

    var viewHelper = MarketPlaceCategoryListViewHelper()

    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(foorter: MarketPlaceCategoryListFooterView.self)
        viewHelper.dataSource = dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
        collectionView?.delegate = self
        configureView()
    }
    
    func configureView() {
        dataSource?.cellClass = MarketPlaceCategoryListCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
        }
        dataSource?.collectionSupplementaryCreationBlock = { kind, parentView, indexPath in
            return MarketPlaceCategoryListFooterView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
        }
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
//            (view as? MarketPlaceCategoryListHeaderView)?.configureView(section: section, sectionIndex: indexPath?.section)
        }
        dataSource?.rowAnimation = .none
        dataSource?.collectionView = collectionView
    }
    
    
}

extension MPGlobalSearchResultViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
