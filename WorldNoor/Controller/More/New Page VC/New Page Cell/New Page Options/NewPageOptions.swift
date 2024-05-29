//
//  NewPageOptions.swift
//  WorldNoor
//
//  Created by apple on 10/20/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewPageOptionsCell : UITableViewCell {
 
    @IBOutlet var lblHome : UILabel!
    @IBOutlet var lblPhotos : UILabel!
    @IBOutlet var lblVideos : UILabel!
    @IBOutlet var lblReviews : UILabel!
    @IBOutlet var lblAbout : UILabel!
    
    @IBOutlet var viewHome : UIView!
    @IBOutlet var viewPhotos : UIView!
    @IBOutlet var viewVideos : UIView!
    @IBOutlet var viewReviews : UIView!
    @IBOutlet var viewAbout : UIView!
    
    @IBOutlet var btnHome : UIButton!
    @IBOutlet var btnPhotos : UIButton!
    @IBOutlet var btnVideos : UIButton!
    @IBOutlet var btnReviews : UIButton!
    @IBOutlet var btnAbout : UIButton!
    
    
    func reloadDesfultValues(){
        
        self.lblHome.textColor = UIColor.lightGray
        self.lblPhotos.textColor = UIColor.lightGray
        self.lblVideos.textColor = UIColor.lightGray
        self.lblReviews.textColor = UIColor.lightGray
        self.lblAbout.textColor = UIColor.lightGray
        
        self.viewHome.backgroundColor = UIColor.lightGray
        self.viewPhotos.backgroundColor = UIColor.lightGray
        self.viewVideos.backgroundColor = UIColor.lightGray
        self.viewReviews.backgroundColor = UIColor.lightGray
        self.viewAbout.backgroundColor = UIColor.lightGray
        
        self.viewHome.isHidden = true
        self.viewPhotos.isHidden = true
        self.viewVideos.isHidden = true
        self.viewReviews.isHidden = true
        self.viewAbout.isHidden = true
        
    }
    
    
    override func awakeFromNib() {
        self.selectOverView(value: 0)
    }
    func selectOverView(value : Int){
        self.reloadDesfultValues()
        if value == 1 {
            self.viewAbout.backgroundColor = UIColor.tabSelectionBG
            self.lblAbout.textColor = UIColor.tabSelectionBG
            self.viewAbout.isHidden = false
        }else if value == 2 {
            self.viewPhotos.backgroundColor = UIColor.tabSelectionBG
            self.lblPhotos.textColor = UIColor.tabSelectionBG
            self.viewPhotos.isHidden = false
        }else if value == 3 {
            self.viewVideos.backgroundColor = UIColor.tabSelectionBG
            self.lblVideos.textColor = UIColor.tabSelectionBG
            self.viewVideos.isHidden = false
        }else if value == 4 {
            self.viewReviews.backgroundColor = UIColor.tabSelectionBG
            self.lblReviews.textColor = UIColor.tabSelectionBG
            self.viewReviews.isHidden = false
        }else {
            self.viewHome.backgroundColor = UIColor.tabSelectionBG
            self.lblHome.textColor = UIColor.tabSelectionBG
            self.viewHome.isHidden = false
        }
    }
    
    
    @IBAction func HomeAction(sender : UIButton){
        self.selectOverView(value: 0)
        
//        self.delegate?.profileTabSelection(tabValue: 2)
    }
    
    @IBAction func aboutAction(sender : UIButton){
        self.selectOverView(value: 1)
        
//        self.delegate?.profileTabSelection(tabValue: 2)
    }
    
    @IBAction func photsAction(sender : UIButton){
        self.selectOverView(value: 2)
        
//        self.delegate?.profileTabSelection(tabValue: 2)
    }
    
    @IBAction func videosAction(sender : UIButton){
        self.selectOverView(value: 3)
        
//        self.delegate?.profileTabSelection(tabValue: 3)
    }
    
    
    @IBAction func reviewsAction(sender : UIButton){
        self.selectOverView(value: 4)
//        self.delegate?.profileTabSelection(tabValue: 4)
    }
}
