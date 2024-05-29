//
//  PostGalleryCollectionCell1.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 11/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit


protocol PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int)
}

@objc(PostGalleryCollectionCell1)
class PostGalleryCollectionCell1: PostBaseCollectionCell {
    
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
    
    // MARK: - Properties
    var data : FeedData?
    var galleryDelegate: PostGalleryDelegate?
    
    var indexPAthMain : IndexPath! = IndexPath.init(row: 0, section: 0)
    
    // MARK: - Methods -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        self.data = isShared() ? (parentData as? FeedData)?.sharedData : (data as? FeedData)
        
        self.reloadData()
    }
    
    
    func reloadData(){
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
        
        if let post = data?.post {
            if post.count == 2 {
                self.viewTwo.isHidden = false
                self.viewTwoFirst.managePostData(postObj: post[0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewTwoSecond.managePostData(postObj: post[1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
            } else if post.count == 3 {
                self.viewThree.isHidden = false
                self.viewThirdFirst.managePostData(postObj: post[0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewThirdSecond.managePostData(postObj: post[1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewThirdThird.managePostData(postObj: post[2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
            } else {
                self.viewFour.isHidden = false
                self.viewFourFirst.managePostData(postObj: post[0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewFourSecond.managePostData(postObj: post[1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewFourThird.managePostData(postObj: post[2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                self.viewFourMore.isHidden = true
                self.viewFourFour.isHidden = false
                self.viewFourMore.backgroundColor = UIColor.clear
                if post.count == 4 {
                    self.viewFourFour.managePostData(postObj: post[3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                } else {
                    if post[3].fileType == FeedType.image.rawValue {
                        self.viewFourFour.isHidden = false
                        self.viewFourFour.managePostData(postObj: post[3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: self.indexPAthMain!, isAppearFrom: "")
                        self.lblCount.text = String(post.count - 4) + " +"
                        self.viewFourMore.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
                        self.bringSubviewToFront(self.viewFourMore)
                    } else {
                        self.viewFourFour.isHidden = true
                        self.viewFourMore.backgroundColor = UIColor.lightGray
                        self.lblCount.text = String(post.count - 3) + " +"
                    }
                    self.viewFourMore.isHidden = false
                }
            }
        }
        playVideo(with: data)
    }
    
    // MARK: - IBAction -
    @IBAction func previewAction(sender : UIButton){
        stopPlayer()
        if let postObj, let indexPath {
            galleryDelegate?.galleryPreview(with: postObj, at: indexPath, tag: sender.tag)
        }
    }
    
    // MARK: - Methods -
    
    func isShared() -> Bool{
         parentObj?.postType == FeedType.shared.rawValue
    }
    
    func stopPlayer() {
        let postObj = isShared() ? parentObj?.sharedData : self.postObj
        LogClass.debugLog(postObj?.post?.count ?? 0)
        if postObj?.post?.count == 2 {
            self.viewTwoFirst.stopPlayingAudio()
            self.viewTwoSecond.stopPlayingAudio()
        } else if postObj?.post?.count == 3 {
            self.viewThirdFirst.stopPlayingAudio()
            self.viewThirdSecond.stopPlayingAudio()
            self.viewThirdThird.stopPlayingAudio()
        } else {
            self.viewFourFour.stopPlayingAudio()
            self.viewFourFirst.stopPlayingAudio()
            self.viewFourSecond.stopPlayingAudio()
            self.viewFourThird.stopPlayingAudio()
        }
    }
    
    func playVideo(with feedDataObj: FeedData?) {
        let feedDataObj = isShared() ? parentObj?.sharedData : feedDataObj
        if feedDataObj?.post?.count ?? 0 == 2 {
            if feedDataObj?.post?[0].fileType == FeedType.video.rawValue {
                viewTwoFirst.currentIndex = self.indexPAthMain
                viewTwoFirst.addVideoView()
                
            } else if feedDataObj?.post![1].fileType == FeedType.video.rawValue {
                viewTwoSecond.currentIndex = self.indexPAthMain
                viewTwoSecond.addVideoView()
                
            }
        } else if feedDataObj?.post?.count ?? 0 == 3 {
            if feedDataObj?.post?[0].fileType == FeedType.video.rawValue {
                viewThirdFirst.currentIndex = self.indexPAthMain
                viewThirdFirst.addVideoView()
                
            } else if feedDataObj?.post?[1].fileType == FeedType.video.rawValue {
                viewThirdSecond.currentIndex = self.indexPAthMain
                viewThirdSecond.addVideoView()
                
            }else if feedDataObj?.post?[2].fileType == FeedType.video.rawValue {
                viewThirdThird.currentIndex = self.indexPAthMain
                viewThirdThird.addVideoView()
                
            }
        } else {
            if feedDataObj?.post?[0].fileType == FeedType.video.rawValue {
                viewFourFirst.currentIndex = self.indexPAthMain
                viewFourFirst.addVideoView()
                
            }else if feedDataObj?.post?[1].fileType == FeedType.video.rawValue {
                viewFourSecond.currentIndex = self.indexPAthMain
                viewFourSecond.addVideoView()
                
            }else if feedDataObj?.post?[2].fileType == FeedType.video.rawValue {
                viewFourThird.currentIndex = self.indexPAthMain
                viewFourThird.addVideoView()
                
            }else if feedDataObj?.post?[3].fileType == FeedType.video.rawValue {
                viewFourFour.currentIndex = self.indexPAthMain
                viewFourFour.addVideoView()
                
            }
        }
    }
}
