//
//  PageBaseREviewCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 01/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class PageBaseReviewCell : UICollectionViewCell {
    @IBOutlet var lblReview : UILabel!
    @IBOutlet var lblPositive : UILabel!
    @IBOutlet var lblNegative : UILabel!
    @IBOutlet var lblRecom : UILabel!
    @IBOutlet var lblTotalPersons : UILabel!
    @IBOutlet var lblPersons : UILabel!
    
    @IBOutlet var viewStar : CosmosView!
}



class PageBaseAddReviewCell : UICollectionViewCell {
    @IBOutlet var txtViewComment : UITextView!
    
    @IBOutlet var ratingview : CosmosView!
    
    @IBOutlet var btnPost : UIButton!
    @IBOutlet var btnRecomnd : UIButton!
    @IBOutlet var viewRecomnd : UIView!
    
    var groupObj: GroupValue?
    
    var delegate: ProfileTabSelectionDelegate?
    
    @IBAction func RecomndAction(sender : UIButton){
        self.viewRecomnd.isHidden = !self.viewRecomnd.isHidden
        
    }

    
    @IBAction func PostAction(sender : UIButton){
        Loader.startLoading()
        var parameters = ["action": "post/create","token": SharedManager.shared.userToken(),"body":self.txtViewComment.text!, "privacy_option":"public"]
        
        parameters["page_id"] = self.groupObj!.groupID
        parameters["review_star_points"] = String(self.ratingview.rating)
        parameters["post_scope_id"] = "1"
        parameters["post_type"] = "page_review"
        
        if self.viewRecomnd.isHidden {
            parameters["recommend_page"] = "0"
        }else {
            parameters["recommend_page"] = "1"
        }
        
        var postObj = [PostCollectionViewObject]()
        CreateRequestManager.uploadMultipartCreateRequests( params: parameters as! [String : String],fileObjectArray: postObj,success: {
            (JSONResponse) -> Void in
            
            Loader.stopLoading()
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue {
                self.groupObj!.is_reviewd = true
                self.delegate?.profileTabSelection(tabValue: 101)
                
            }
        },failure: {(error) -> Void in
            
        }, isShowProgress: false)
        
    }

    
}
