//
//  CreateLifeEventImageVideoModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 29/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class CreateLifeEventImageVideoModel {
    var postType: PostDataType
    var image: UIImage?
    var thumbnailImage: UIImage?
    var videoURL: URL?
    var compressURL: URL?
    
    init(postType: PostDataType, image: UIImage? = nil, thumbnailImage: UIImage? = nil, videoURL: URL? = nil, compressURL: URL? = nil) {
        self.postType = postType
        self.image = image
        self.thumbnailImage = thumbnailImage
        self.videoURL = videoURL
        self.compressURL = compressURL
    }
}
