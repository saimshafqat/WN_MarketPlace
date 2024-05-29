//
//  StoryEndCell.swift
//  WorldNoor
//
//  Created by Lucky on 02/09/2022.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import UIKit

class StoryEndCell: UICollectionViewCell
{
    @IBOutlet var lblTextMore : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTextMore.dynamicCaption1Bold12()
    }
    
}
