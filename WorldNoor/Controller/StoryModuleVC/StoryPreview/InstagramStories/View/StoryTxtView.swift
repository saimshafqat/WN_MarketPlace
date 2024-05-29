//
//  StoryTxtView.swift
//  kalam
//
//  Created by Raza najam on 12/17/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class StoryTxtView: UIView {
    
    @IBOutlet weak var  txtView:UITextView!
    @IBOutlet weak var  readMoreBtn:UIButton!
    @IBOutlet weak var  readMoreAboveBtn:UIButton!

    
    override class func awakeFromNib() {
        
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
