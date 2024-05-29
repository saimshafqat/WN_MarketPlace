//
//  MoreSectionView.swift
//  WorldNoor
//
//  Created by Raza najam on 2/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class MoreSectionView: UIView {

    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collapseImageView: UIImageView!
    
    func manageViewData(name:String, imgNamed:String){
        self.titleLbl.text = name
        self.titleImageView.image = UIImage(named: imgNamed)
    }

}


