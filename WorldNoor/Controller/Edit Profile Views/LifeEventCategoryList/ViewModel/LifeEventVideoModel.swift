//
//  LifeEventVideoModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 02/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class LifeEventVideoModel: PostBaseViewModel {
    
    var lifeEventModel: UserLifeEventsModel?
    
     init(lifeEventModel: UserLifeEventsModel? = nil) {
        self.lifeEventModel = lifeEventModel
    }

    override func setCellForDataDic() -> [String : UICollectionViewCell.Type] {
        return [
            FeedType.image.rawValue: PostCollectionCell1.self,
            FeedType.video.rawValue: PostVideoCollectionCell.self,
            FeedType.gallery.rawValue: PostGalleryCollectionCell1.self,
        ]
    }
    
    override func serviceEndPoint(with params: [String : String]) -> APIEndPoints? {
        let params: [String: String] = [
            "post_id": lifeEventModel?.postId ?? .emptyString,
            "life_event_id": lifeEventModel?.lifeEventId ?? .emptyString
        ]
        return .getSingleLifeEvent(params)
    }
}

