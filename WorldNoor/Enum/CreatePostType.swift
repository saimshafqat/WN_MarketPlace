//
//  PostType.swift
//  WorldNoor
//
//  Created by Niks on 5/6/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

enum CreatePostType: String, CaseIterable {
    
    case photo = "Photo"
    case video = "Video"
    case audio = "Audio"
    case file = "File"
    case background = "Background"
    
    var image: UIImage? {
        switch self {
        case .photo:
            return UIImage(named: "ic_post_photo")
        case .video:
            return UIImage(named: "ic_post_video")
        case .audio:
            return UIImage(named: "ic_post_audio")
        case .file:
            return UIImage(named: "ic_post_file")
        case .background:
            return UIImage(named: "ic_post_background")
        }
    }
    
}
