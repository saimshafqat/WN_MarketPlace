//
//  GalleryView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
protocol GalleryViewScrollDelegate {
    func scrollPageChange(pageNumber: Int)
}

class GalleryView: ParentFeedView {
    var delegate: GalleryViewScrollDelegate?

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
//    @IBOutlet weak var collectionPageControl: CustomPageControl!
    
    
    var leftMargin : CGFloat = 0.0
    var rightMargin : CGFloat  = 0.0
    
    
    @IBOutlet weak var collectionViewBottom: UICollectionView!
    
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    var collectionWidth:CGFloat = UIScreen.main.bounds.width
    
    override func awakeFromNib() {
        let nibName = UINib(nibName: Const.KGalleryCollectionCell, bundle:nil)
        self.galleryCollectionView.register(nibName, forCellWithReuseIdentifier: Const.KGalleryCollectionCell)
        
        self.collectionViewBottom.register(UINib.init(nibName: "BottomCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BottomCollectionCell")
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
    
//    @IBAction func pageChanged(_ sender: Any) {
////        let page = collectionPageControl.currentPage
//        var frame = self.galleryCollectionView.frame
//        frame.origin.x = frame.size.width * CGFloat(page)
//        frame.origin.y = 0
//        self.galleryCollectionView.scrollRectToVisible(frame, animated: true)
//        self.collectionPageControl.setCurrentPage(page:page)
//    }
    
    
    @IBAction func openImage(sender : UIButton){
        FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, IndexPath.init(row: sender.tag, section: 0), false)
    }
    
    
    @objc func pageControlMainThread (){
        
        self.loadEdge()
        self.collectionViewBottom.reloadData()
//        self.collectionPageControl.setCurrentPage(page: 0)
    }
}

extension GalleryView:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func resetCollectionCell(){
        self.feedDataObj = nil
        self.galleryCollectionView.reloadData()
    }
    
    func resetVisibleCellVideo(){
           for cell in self.galleryCollectionView.visibleCells {
               let galleryCell = cell as! GalleryCollectionCell
               galleryCell.stopPlayingVideo()
               galleryCell.stopPlayingAudio()
           }
       }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.feedDataObj != nil {
            return self.feedDataObj!.post!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 100 {
//            let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionCell", for: indexPath) as! BottomCollectionCell
            
            guard let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionCell", for: indexPath) as? BottomCollectionCell else {
               return UICollectionViewCell()
            }
            
            
            
            var cellShow = 0
            
            if self.galleryCollectionView.indexPathsForVisibleItems.count > 0 {
                cellShow = (self.galleryCollectionView.indexPathsForVisibleItems.first)!.row
            }
            
            
            if (self.feedDataObj != nil) {
                let postVal:PostFile = self.feedDataObj!.post![indexPath.row]
                if postVal.fileType == FeedType.image.rawValue {
                    
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAImg.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAImgF.png")!
                    }
                }else if postVal.fileType == FeedType.video.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerVideo.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerVideoF.png")!
                    }

                }else if postVal.fileType == FeedType.audio.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAA.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAF.png")!
                    }
                }else if postVal.fileType == FeedType.file.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "Attachment.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "AttachmentF.png")!
                    }
                }
                
            }
            

            return cellBottom
        }
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.KGalleryCollectionCell, for: indexPath) as! GalleryCollectionCell
        cell.managePostData(postObj:self.feedDataObj!.post![indexPath.row], mainIndex: currentIndexPath, currentIndex: indexPath, isAppearFrom: self.isAppearFrom)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
        if collectionView.tag == 100 {
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
            }
            return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        }else {
            let screenSize: CGRect = UIScreen.main.bounds
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: self.frame.size.width, height: 400)
            }
            if self.isAppearFrom == "SharedCell" {
                return CGSize(width: screenSize.width - 28, height: self.galleryCollectionView.bounds.height)
            }else if isAppearFrom == "SharedView" {
                return CGSize(width: screenSize.width - 18, height: self.galleryCollectionView.bounds.height)
            }
            return CGSize(width: screenSize.width, height: self.galleryCollectionView.bounds.height)
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        if let postCell = cell as? GalleryCollectionCell {
            postCell.stopPlayingVideo()
            postCell.stopPlayingAudio()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 100 {
            self.galleryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionViewBottom.reloadData()
            }
        }else {
            if self.isAppearFrom == "SharedCell" {
                FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, indexPath, true)
            }else if isAppearFrom == "SharedView" {
                FeedCallBManager.shared.feedDetailgalleryCellIndexCallbackHandler?(indexPath, true)
            }else {
                FeedCallBManager.shared.feedDetailgalleryCellIndexCallbackHandler?(indexPath, false)
            }
        }
            
            
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in self.galleryCollectionView.visibleCells {
            let indexPath = self.galleryCollectionView.indexPath(for: cell)
//            self.collectionPageControl.setCurrentPage(page: indexPath!.row)
            self.collectionViewBottom.reloadData()
            self.delegate?.scrollPageChange(pageNumber: indexPath!.row)
        }
    }
    
    func loadEdge()  {
        
        let CellCount = self.feedDataObj!.post!.count
        
        
        if (CGFloat(CellCount) * self.collectionViewBottom.frame.size.height) > self.collectionViewBottom.frame.size.width {
            leftMargin = 0.0
            rightMargin = 0.0
        }else {
            
            let CellWidth = self.collectionViewBottom.frame.size.height
            let CellSpacing = 0
            let totalCellWidth = Int(CellWidth) * CellCount
            let totalSpacingWidth = CellSpacing * (CellCount - 1)

            leftMargin = (self.collectionViewBottom.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 100 {
            return UIEdgeInsets(top: 0, left: self.leftMargin, bottom: 0, right: self.leftMargin)
        }


        return UIEdgeInsets.zero
    }
}
