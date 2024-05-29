//
//  PageBaseHeaderCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 27/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class PageBaseHeaderCell : UICollectionViewCell {
    
    @IBOutlet var lblOverview : UILabel!
    @IBOutlet var lblPhotos : UILabel!
    @IBOutlet var lblVideos : UILabel!
    @IBOutlet var lblReviews : UILabel!
    @IBOutlet var lblFeed : UILabel!
    
    @IBOutlet var viewOverview : UIView!
    @IBOutlet var viewPhotos : UIView!
    @IBOutlet var viewVideos : UIView!
    @IBOutlet var viewReviews : UIView!
    @IBOutlet var viewFeed : UIView!
    
    @IBOutlet var btnOverview : UIButton!
    @IBOutlet var btnPhotos : UIButton!
    @IBOutlet var btnVideos : UIButton!
    @IBOutlet var btnReviews : UIButton!
    @IBOutlet var btnFeed : UIButton!
    
    
    var delegate: ProfileTabSelectionDelegate?
    
   
    
    func selectOverView(value : Int) {
        self.reloadDesfultValues()
        if value == 1 {
            self.viewOverview.backgroundColor = UIColor.tabSelectionBG
            self.lblOverview.textColor = UIColor.tabSelectionBG
        }else if value == 2 {
            self.viewPhotos.backgroundColor = UIColor.tabSelectionBG
            self.lblPhotos.textColor = UIColor.tabSelectionBG
        }else if value == 3 {
            self.viewVideos.backgroundColor = UIColor.tabSelectionBG
            self.lblVideos.textColor = UIColor.tabSelectionBG
        }else if value == 4 {
            self.viewReviews.backgroundColor = UIColor.tabSelectionBG
            self.lblReviews.textColor = UIColor.tabSelectionBG
        }else {
            self.viewFeed.backgroundColor = UIColor.tabSelectionBG
            self.lblFeed.textColor = UIColor.tabSelectionBG
        }
        
    }
    
    @IBAction func feedAction(sender : UIButton){
        self.reloadDesfultValues()
        self.viewFeed.backgroundColor = UIColor.tabSelectionBG
        self.lblFeed.textColor = UIColor.tabSelectionBG
        self.delegate?.profileTabSelection(tabValue: 0)
    }
    
    @IBAction func overviewAction(sender : UIButton) {
        self.selectOverView(value: 1)
        self.delegate?.profileTabSelection(tabValue: 1)
    }
    
    @IBAction func photsAction(sender : UIButton){
        self.selectOverView(value: 2)
        self.delegate?.profileTabSelection(tabValue: 2)
    }
    
    @IBAction func videosAction(sender : UIButton){
        self.selectOverView(value: 3)
        self.delegate?.profileTabSelection(tabValue: 3)
    }
    
    @IBAction func reviewsAction(sender : UIButton){
        self.selectOverView(value: 4)
        self.delegate?.profileTabSelection(tabValue: 4)
    }
    
    func reloadDesfultValues(){
        self.lblOverview.textColor = UIColor.lightGray
        self.lblPhotos.textColor = UIColor.lightGray
        self.lblVideos.textColor = UIColor.lightGray
        self.lblReviews.textColor = UIColor.lightGray
        self.lblFeed.textColor = UIColor.lightGray
        
        self.viewOverview.backgroundColor = UIColor.lightGray
        self.viewPhotos.backgroundColor = UIColor.lightGray
        self.viewVideos.backgroundColor = UIColor.lightGray
        self.viewReviews.backgroundColor = UIColor.lightGray
        self.viewFeed.backgroundColor = UIColor.lightGray
    }
      
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
