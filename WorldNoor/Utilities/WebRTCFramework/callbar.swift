//
//  callbar.swift
//  kalam
//
//  Created by apple on 3/19/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit

class callbar: UIView {
    
    
    
    @IBOutlet weak var callername: UILabel!
    
    @IBAction func btntapped(_ sender: Any) {
        CallMinimiser.sharedInstance.hideCallBar()
    }
}
