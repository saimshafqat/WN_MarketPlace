//
//  MPProfileListingTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileListingTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let identifier = "MPProfileListingTableViewCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Item] = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "MPProfileListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MPProfileListingCollectionViewCell.identifier)
    }
    
    func configure(with items: [Item]) {
           self.items = items
           collectionView.reloadData()
       }

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 100 // items.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPProfileListingCollectionViewCell", for: indexPath) as! MPProfileListingCollectionViewCell
           cell.backgroundColor = .red
           
           return cell
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionViewWidth = self.collectionView?.frame.width else { return .zero }
        let cellWidth = (collectionViewWidth - 20 ) / 3
        return CGSize(width: cellWidth , height: cellWidth+20)
    }
    
}
