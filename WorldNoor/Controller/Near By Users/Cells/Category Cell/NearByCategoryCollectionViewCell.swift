//
//  NearByCategoryCollectionViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 03/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class NearByCategoryCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet private weak var titlelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titlelabel.textAlignment = .center
    }
    
    func bind(interests: NearByInterestModel) {
        titlelabel.text = interests.name
    }
}
