//
//  GalleryNewView.swift
//  WorldNoor
//
//  Created by apple on 12/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
class GalleryNewView: ParentFeedView {
    
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    
    
    @IBOutlet weak var viewTwoFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewTwoSecond: GalleryCollectionCellView!
    
    @IBOutlet weak var viewThirdFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdThird: GalleryCollectionCellView!
    
    @IBOutlet weak var viewFourFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewFourSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewFourThird: GalleryCollectionCellView!
    @IBOutlet weak var viewFourFour: GalleryCollectionCellView!
    
    @IBOutlet weak var viewFourMore: UIView!
    @IBOutlet weak var lblCount: UILabel!
    
    
    var isAppearFrom = ""
    var feedDataObj:FeedData? = nil
    var currentIndexPath = IndexPath()
    
    
    var leftMargin : CGFloat = 0.0
    var rightMargin : CGFloat  = 0.0
    
    
    override func awakeFromNib() {
    }
    
    
    func manageGalleryData(feedObj:FeedData){
        self.feedDataObj = feedObj
        
        
        self.viewTwo.isHidden = true
        self.viewThree.isHidden = true
        self.viewFour.isHidden = true
        
        
        
        if self.feedDataObj!.post!.count == 2 {
            self.viewTwo.isHidden = false
            self.viewTwoFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewTwoSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            
        }else if self.feedDataObj!.post!.count == 3 {
            self.viewThree.isHidden = false
            
            self.viewThirdFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewThirdSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewThirdThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: self.isAppearFrom)
            
            
        }else {
            self.viewFour.isHidden = false
            
            
            self.viewFourFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewFourSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewFourThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewFourMore.isHidden = true
            self.viewFourFour.isHidden = false
            self.viewFourMore.backgroundColor = UIColor.clear
            if self.feedDataObj!.post!.count == 4 {
                self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: self.isAppearFrom)
            }else {
                
                if self.feedDataObj!.post![3].fileType == FeedType.image.rawValue {
                    self.viewFourFour.isHidden = false
                    self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: self.isAppearFrom)
                    
                    self.lblCount.text = String(self.feedDataObj!.post!.count - 4) + " +"
                    
                    self.viewFourMore.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
                    self.bringSubviewToFront(self.viewFourMore)


                }else {
                    self.viewFourFour.isHidden = true
                    self.viewFourMore.backgroundColor = UIColor.lightGray
                    self.lblCount.text = String(self.feedDataObj!.post!.count - 3) + " +"

                }
                
                
                self.viewFourMore.isHidden = false
            }
            
            
        }

    }
    
    
    @IBAction func openImage(sender : UIButton){
        if self.isAppearFrom == "SharedCell" {
            FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, self.currentIndexPath, true)
        }else if isAppearFrom == "SharedView" {
            FeedCallBManager.shared.feedDetailgalleryCellIndexCallbackHandler?(self.currentIndexPath, true)
        }else {
            
            FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, self.currentIndexPath, true)
            
        }
        
    }
}
