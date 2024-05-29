//
//  SavedReelsCollectionCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 02/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class SavedReelsCollectionCell : UICollectionViewCell {
    
    @IBOutlet private weak var lblviewCount: UILabel!
    @IBOutlet private weak var viewCount: UIView!
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    
    var currentIndexPath:IndexPath?
    var feedObj: FeedData!
    
    override func awakeFromNib() {
        
    }
    
    func manageData(feedObj: FeedData, indexPath: IndexPath) {
        
        self.currentIndexPath = indexPath
        self.feedObj = feedObj
        
        self.thumbnailImageView.isHidden = false
        if self.feedObj.post != nil {
            if self.feedObj.post!.count > 0 {
                self.thumbnailImageView.loadImageWithPH(urlMain:feedObj.post![0].thumbnail!)
            }
        }
        
        self.lblviewCount.text = String(self.feedObj.video_post_views!)
        self.viewCount.isHidden = false
        
        self.labelRotateCell(viewMain: self.lblviewCount)
        self.labelRotateCell(viewMain: self.thumbnailImageView)
        self.lblviewCount.rotateForTextAligment()
    }
}
