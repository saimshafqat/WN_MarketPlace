//
//  WatchPostViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 12/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//


import Foundation

class WatchViewModel: WatchBaseViewModel {
    
    override func setCellForDataDic() -> [String : UICollectionViewCell.Type] {
        return [
            FeedType.video.rawValue: PostVideoCollectionCell.self,
            FeedType.Ad.rawValue: PostAdsCollectionCell.self,
            FeedType.Shimmer.rawValue: PostShimmerCell.self,
            FeedType.ShimmerAd.rawValue: PostShimmerAdCell.self,
        ]
    }
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func shouldAdsShow() -> Bool {
        return true
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .newsFeedVideos(params)
    }
}

