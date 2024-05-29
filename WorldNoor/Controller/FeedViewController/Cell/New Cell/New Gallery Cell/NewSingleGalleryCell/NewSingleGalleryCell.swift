//
//  NewSingleGalleryCell.swift
//  WorldNoor
//
//  Created by apple on 11/11/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewSingleGalleryCell : UITableViewCell{
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    
    
    @IBOutlet weak var viewTwoFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewTwoSecond: GalleryCollectionCellView!
    
    @IBOutlet weak var btnTwoFirst: UIButton!
    @IBOutlet weak var btnTwoSecond: UIButton!
    
    @IBOutlet weak var viewThirdFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdThird: GalleryCollectionCellView!
    
    @IBOutlet weak var btnThirdFirst: UIButton!
    @IBOutlet weak var btnThirdSecond: UIButton!
    @IBOutlet weak var btnThirdThird: UIButton!
    
    @IBOutlet weak var viewFourFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewFourSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewFourThird: GalleryCollectionCellView!
    @IBOutlet weak var viewFourFour: GalleryCollectionCellView!
    
    @IBOutlet weak var btnFourFirst: UIButton!
    @IBOutlet weak var btnFourSecond: UIButton!
    @IBOutlet weak var btnFourThird: UIButton!
    @IBOutlet weak var btnFourFour: UIButton!
    
    @IBOutlet weak var viewFourMore: UIView!
    @IBOutlet weak var lblCount: UILabel!
    
    var feedDataObj:FeedData? = nil
    
    var mainIndexPath:IndexPath!
    
    func stopPlayer(){
        if self.feedDataObj!.post!.count == 2 {
            self.viewTwoFirst.stopPlayingAudio()
            self.viewTwoSecond.stopPlayingAudio()
        }else if self.feedDataObj!.post!.count == 3 {
            self.viewThirdFirst.stopPlayingAudio()
            self.viewThirdSecond.stopPlayingAudio()
            self.viewThirdThird.stopPlayingAudio()
        }else {
            self.viewFourFour.stopPlayingAudio()
            self.viewFourFirst.stopPlayingAudio()
            self.viewFourSecond.stopPlayingAudio()
            self.viewFourThird.stopPlayingAudio()
        }        
    }
    
    func playVideo(){
        if self.feedDataObj!.post!.count == 2 {
            if self.feedDataObj!.post![0].fileType == FeedType.video.rawValue {
                viewTwoFirst.addVideoView()
            }else if self.feedDataObj!.post![1].fileType == FeedType.video.rawValue {
                viewTwoSecond.addVideoView()
            }
        }else if self.feedDataObj!.post!.count == 3 {
            if self.feedDataObj!.post![0].fileType == FeedType.video.rawValue {
                viewThirdFirst.addVideoView()
            }else if self.feedDataObj!.post![1].fileType == FeedType.video.rawValue {
                viewThirdSecond.addVideoView()
            }else if self.feedDataObj!.post![2].fileType == FeedType.video.rawValue {
                viewThirdThird.addVideoView()
            }
        }else {
            if self.feedDataObj!.post![0].fileType == FeedType.video.rawValue {
                viewFourFirst.addVideoView()
            }else if self.feedDataObj!.post![1].fileType == FeedType.video.rawValue {
                viewFourSecond.addVideoView()
            }else if self.feedDataObj!.post![2].fileType == FeedType.video.rawValue {
                viewFourThird.addVideoView()
            }else if self.feedDataObj!.post![3].fileType == FeedType.video.rawValue {
                viewFourFour.addVideoView()
            }
        }
    }
    
    func manageCellData(feedObj:FeedData) {
        self.feedDataObj = feedObj
        self.viewTwo.isHidden = true
        self.viewThree.isHidden = true
        self.viewFour.isHidden = true
        self.btnTwoFirst.isHidden = false
        self.btnTwoSecond.isHidden = false
        self.btnThirdSecond.isHidden = false
        self.btnThirdFirst.isHidden = false
        self.btnThirdThird.isHidden = false
        self.btnFourFirst.isHidden = false
        self.btnFourFour.isHidden = false
        self.btnFourThird.isHidden = false
        self.btnFourSecond.isHidden = false
        
        if self.feedDataObj!.post!.count == 2 {
            self.viewTwo.isHidden = false
            
            
            self.viewTwoFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: "")
            self.viewTwoSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: "")
        }else if self.feedDataObj!.post!.count == 3 {
            self.viewThree.isHidden = false
                        
            self.viewThirdFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: "")
            self.viewThirdSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: "")
            self.viewThirdThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: "")
        }else {
            self.viewFour.isHidden = false
            self.viewFourFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: "")
            self.viewFourSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: "")
            self.viewFourThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: "")
            self.viewFourMore.isHidden = true
            self.viewFourFour.isHidden = false
            self.viewFourMore.backgroundColor = UIColor.clear
            
            if self.feedDataObj!.post!.count == 4 {
                self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: self.mainIndexPath, currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: "")
            }else {
                
                if self.feedDataObj!.post![3].fileType == FeedType.image.rawValue {
                    self.viewFourFour.isHidden = false
                    self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: "")
                    
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
    
    
    
    @IBAction func previewAction(sender : UIButton){
        self.stopPlayer()
        UIApplication.topViewController()?.showdetail(feedObj: self.feedDataObj!, currentIndex: sender.tag)
    }
}
