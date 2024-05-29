//
//  ImagesViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 05/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class ImagesViewModel: PostBaseViewModel {
    
    override func setCellForDataDic() -> [String : UICollectionViewCell.Type] {
        return [
            FeedType.Ad.rawValue: PostAdsCollectionCell.self,
            FeedType.image.rawValue: PostCollectionCell1.self,
            FeedType.post.rawValue: PostCollectionCell1.self,
            FeedType.shared.rawValue: PostCollectionCell1.self
        ]
    }
    
    override func visibilityMemorySharing() -> Bool {
        return false
    }
    
    override func shouldAdsShow() -> Bool {
        return true
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        return .getImages(params)
    }
}
