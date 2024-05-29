//
//  GroupSegmentCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation


class GroupSegmentCell : UICollectionViewCell {
    @IBOutlet var lblHome : UILabel!
    @IBOutlet var lblPhotos : UILabel!
    @IBOutlet var lblVideos : UILabel!
    @IBOutlet var lblAbout : UILabel!
    
    @IBOutlet var viewHome : UIView!
    @IBOutlet var viewPhotos : UIView!
    @IBOutlet var viewVideos : UIView!
    @IBOutlet var viewAbout : UIView!
    
    @IBOutlet var btnHome : UIButton!
    @IBOutlet var btnPhotos : UIButton!
    @IBOutlet var btnVideos : UIButton!
    @IBOutlet var btnAbout : UIButton!
    
    
    var delegate: ProfileTabSelectionDelegate?
    
    @IBAction func HomeAction(sender : UIButton){
        self.selectOption(value: 1)
        self.delegate?.profileTabSelection(tabValue: 1)
    }
    
    func selectOption(value : Int){
        self.reloadDesfultValues()
        if value == 1 {
            self.viewHome.backgroundColor = UIColor.tabSelectionBG
            self.lblHome.textColor = UIColor.tabSelectionBG
        }else if value == 2 {
            self.viewPhotos.backgroundColor = UIColor.tabSelectionBG
            self.lblPhotos.textColor = UIColor.tabSelectionBG
        }else if value == 3 {
            self.viewVideos.backgroundColor = UIColor.tabSelectionBG
            self.lblVideos.textColor = UIColor.tabSelectionBG
        }else {
            self.viewAbout.backgroundColor = UIColor.tabSelectionBG
            self.lblAbout.textColor = UIColor.tabSelectionBG
        }
        
    }
    
    @IBAction func photsAction(sender : UIButton){
        self.selectOption(value: 2)
        
        self.delegate?.profileTabSelection(tabValue: 3)
    }
    
    @IBAction func videosAction(sender : UIButton){
        self.selectOption(value: 3)
        
        self.delegate?.profileTabSelection(tabValue: 4)
    }
    
    
    @IBAction func AboutAction(sender : UIButton){
        self.selectOption(value: 4)
        self.delegate?.profileTabSelection(tabValue: 2)
    }
    
    func reloadDesfultValues(){
        self.lblHome.textColor = UIColor.lightGray
        self.lblPhotos.textColor = UIColor.lightGray
        self.lblVideos.textColor = UIColor.lightGray
        self.lblAbout.textColor = UIColor.lightGray
        
        self.viewHome.backgroundColor = UIColor.lightGray
        self.viewPhotos.backgroundColor = UIColor.lightGray
        self.viewVideos.backgroundColor = UIColor.lightGray
        self.viewAbout.backgroundColor = UIColor.lightGray
    }
      
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
  
}
