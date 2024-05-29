//
//  NewSingleVideoCell.swift
//  WorldNoor
//
//  Created by apple on 11/8/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewSingleVideoCell : UITableViewCell {
    
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var btnImgView : UIButton!
    @IBOutlet var lblMain : UILabel!
    
    @IBOutlet var imgPlay : UIImageView!
    var postObj : FeedData!
    
    @IBAction func openImage(sender : UIButton){
        UIApplication.topViewController()?.showdetail(feedObj: postObj, currentIndex: 0)
    }
}
