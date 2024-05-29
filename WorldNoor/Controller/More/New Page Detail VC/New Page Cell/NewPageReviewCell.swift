//
//  NewPageReviewCell.swift
//  WorldNoor
//
//  Created by apple on 11/2/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class NewPageReviewCell : UITableViewCell {
    @IBOutlet var lblReview : UILabel!
    @IBOutlet var lblPositive : UILabel!
    @IBOutlet var lblNegative : UILabel!
    @IBOutlet var lblRecom : UILabel!
    @IBOutlet var lblTotalPersons : UILabel!
    @IBOutlet var lblPersons : UILabel!
    
    @IBOutlet var viewStar : CosmosView!
}



class NewPageAddReviewCell : UITableViewCell {
    @IBOutlet var txtViewComment : UITextView!
    
    @IBOutlet var ratingview : CosmosView!
    
    @IBOutlet var btnPost : UIButton!
    @IBOutlet var btnRecomnd : UIButton!
    @IBOutlet var viewRecomnd : UIView!
    
}
