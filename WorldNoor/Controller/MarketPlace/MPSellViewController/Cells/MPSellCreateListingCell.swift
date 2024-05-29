//
//  MPSellCreateListingCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 07/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol MPSellCreateListingDelegate {
    func createListingTapped()
}

@objc(MPSellCreateListingCell)
class MPSellCreateListingCell: SSBaseCollectionCell {
    
    // MARK: - Properties -
    @IBOutlet weak var userImageView: UIImageView?
    
    var mpSellCreateListingDelegate: MPSellCreateListingDelegate?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        
        userImageView?.roundTotally()
        userImageView?.loadImageWithPH(urlMain: SharedManager.shared.mpUserObj?.profile_image ?? "")
    }
    
    @IBAction func onClickCreateListingBtn(_ sender: UIButton) {
        mpSellCreateListingDelegate?.createListingTapped()
    }
}
