//
//  PostShimmerCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 15/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation


class PostShimmerCell: PostBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet var shimmerView : ShimmerView!
    
    @IBOutlet var shimmerViewUserImage : ShimmerView!
    @IBOutlet var shimmerViewUserName : ShimmerView!
    @IBOutlet var shimmerViewTime : ShimmerView!
    @IBOutlet var shimmerViewText : ShimmerView!
    
    @IBOutlet var shimmerViewShare1 : ShimmerView!
//    @IBOutlet var shimmerViewShare2 : ShimmerView!
//    @IBOutlet var shimmerViewShare3 : ShimmerView!
//    @IBOutlet var shimmerViewShare4 : ShimmerView!
    
    
    func startAnimation(){
        
        self.shimmerView.startAnimating()
        self.shimmerViewUserImage.startAnimating()
        self.shimmerViewTime.startAnimating()
        self.shimmerViewUserName.startAnimating()
        self.shimmerViewText.startAnimating()
        
        self.shimmerViewShare1.startAnimating()
//        self.shimmerViewShare2.startAnimating()
//        self.shimmerViewShare3.startAnimating()
//        self.shimmerViewShare4.startAnimating()
    }
    
    func stopAnimation(){
        
        self.shimmerView.stopAnimating()
        self.shimmerViewUserImage.stopAnimating()
        self.shimmerViewTime.stopAnimating()
        self.shimmerViewUserName.stopAnimating()
        self.shimmerViewText.stopAnimating()
        
        self.shimmerViewShare1.stopAnimating()
//        self.shimmerViewShare2.stopAnimating()
//        self.shimmerViewShare3.stopAnimating()
//        self.shimmerViewShare4.stopAnimating()
    }
}



class PostShimmerAdCell: PostBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet var shimmerView : ShimmerView!
    
    
    func startAnimation(){
        
        self.shimmerView.startAnimating()
    }
    
    func stopAnimation(){
        
        self.shimmerView.stopAnimating()
    }
    
    override func awakeFromNib() {
        startAnimation()
    }
    
}



class PostLoadMoreCell: PostBaseCollectionCell {
    
    // MARK: - IBOutlets -
    
    @IBOutlet var loaderview : UIActivityIndicatorView!
    
 
    
}
