//
//  MPProductDetailMeetupMapCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
protocol MPSellerDetailDelegate {
    func viewSellerDetailTapped(sender: UIButton, sellerId:Int)
}

@objc(MPProductDetailSellerInfoCell)
class MPProductDetailSellerInfoCell: SSBaseCollectionCell {
    
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var sellerId: Int?
    var mpSellerDetailDelegate: MPSellerDetailDelegate?
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MpProductDetailModel {
            nameLabel.text = obj.user.name
            joinedDateLabel.text = obj.user.posterJoinDate
            userImageView.loadImageWithPH(urlMain: obj.user.profileImage ?? .emptyString)
            sellerId = obj.user.userID ?? 0
        }
    }
    
    
    @IBAction func onClickFollowBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickSellerDetailBtn(_ sender: UIButton) {
        mpSellerDetailDelegate?.viewSellerDetailTapped(sender: sender, sellerId: sellerId ?? 0)
    }
    
}
