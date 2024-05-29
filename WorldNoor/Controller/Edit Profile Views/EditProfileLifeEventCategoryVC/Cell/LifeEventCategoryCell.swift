//
//  LifeEventCategoryCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class LifeEventCategoryCell: UICollectionViewCell {
    
    // MARK: - IBOutlet -
    @IBOutlet weak var lifeEventImage: UIImageView?
    @IBOutlet weak var lifeEventNameLabel: UILabel?
    
    // MARK: - Configure View -
    func configureView(item: Any, indexPath: IndexPath) {
        if let obj = item as? LifeEventCategoryModel {
            lifeEventNameLabel?.text = obj.name
            lifeEventImage?.imageLoad(with: obj.categoryImage)
            lifeEventImage?.backgroundColor = .clear
        }
    }
}
