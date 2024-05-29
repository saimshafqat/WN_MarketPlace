//
//  ReelTabTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 13/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol ReelDelegate: AnyObject {
    func reeltapped(reel: FeedData)
    func loadMoreReels(indexPath: IndexPath)
}

class ReelTabTableViewCell: UITableViewCell {

    @IBOutlet private weak var reelsCollectionView: UICollectionView!
    
    private weak var delegate: ReelDelegate?
    private var ReelsList: [FeedData]?
    
    var viewWidth : CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        reelsCollectionView.register(UINib.init(nibName: "SavedReelsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SavedReelsCollectionCell")
        reelsCollectionView.dataSource = self
        reelsCollectionView.delegate = self
    }

    func bind(delegate: ReelDelegate, ReelsList: [FeedData]) {
        self.delegate = delegate
        self.ReelsList = ReelsList
        reelsCollectionView.reloadData()
    }
}

extension ReelTabTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReelsList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: SavedReelsCollectionCell.className,
                                 for: indexPath) as? SavedReelsCollectionCell else {
            return UICollectionViewCell()
        }
        
        guard let reel = self.ReelsList?[indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.manageData(feedObj: reel, indexPath: indexPath)
        self.delegate?.loadMoreReels(indexPath: indexPath)
        return cell
    }
}

extension ReelTabTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (viewWidth / 3) - 8, height: 200)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {

        self.reelsCollectionView.layoutIfNeeded()
        let contentSize = self.reelsCollectionView.collectionViewLayout.collectionViewContentSize
        return CGSize(width: viewWidth / 3 , height: contentSize.height + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reel = self.ReelsList?[indexPath.row] else {
            return
        }
        delegate?.reeltapped(reel: reel)
    }
}
