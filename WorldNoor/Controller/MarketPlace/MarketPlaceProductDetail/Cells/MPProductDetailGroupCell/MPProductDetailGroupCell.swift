//
//  MPProductDetailGroupCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
@objc(MPProductDetailGroupCell)
class MPProductDetailGroupCell: SSBaseCollectionCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MPProductDetailGroupModel {
            headingLabel.text = obj.name
            groupImageView.loadImage(urlMain: obj.coverPhotoPath)
            memberCountLabel.text = (obj.members == 1) ? "\(obj.members) member" : "\(obj.members) members"
        }
    }
    
    @IBAction func onClickJoinBtn(_ sender: UIButton) {
    }
}
