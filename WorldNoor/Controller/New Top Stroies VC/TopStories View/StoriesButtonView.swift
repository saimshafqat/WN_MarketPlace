//
//  TopStoriesView.swift
//  WorldNoor
//
//  Created by apple on 5/26/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class StoriesButtonView : UIView {
    
    var modelObj : FeedVideoModel!
        

    @IBOutlet weak var lblLikes: UILabel!
   
    @IBOutlet weak var lblcomments: UILabel!
    
    @IBOutlet weak var btnLikes: UIButton!
    
    @IBOutlet weak var btnComments: UIButton!
    override class func awakeFromNib() {
        
        
    }
    
    @IBAction func btnComments(_ sender: Any) {
    }
    @IBAction func btnLike(_ sender: Any) {
    }
    
    @IBAction func btnShare(_ sender: Any) {
    }
    
    func reloadData(){
        self.lblcomments.text = "0"
        self.lblLikes.text = "0"
    }
}
