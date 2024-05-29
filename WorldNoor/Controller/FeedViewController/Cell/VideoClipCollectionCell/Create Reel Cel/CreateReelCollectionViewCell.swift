//
//  CreateReelCollectionViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 02/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class CreateReelCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var imgViewUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let fileName = "myImageToUpload.jpg"
        self.lblText.dynamicCaption2Bold11()
        self.lblText.numberOfLines = 0
        self.lblText.rotateViewForLanguage()
        self.imgViewUser.image = FileBasedManager.shared.loadImage(pathMain: fileName)
        self.labelRotateCell(viewMain: self.imgViewUser)
    }
}
