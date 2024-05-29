//
//  VideoPreLoadUtility.swift
//  WorldNoor
//
//  Created by Asher Azeem on 17/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage

final class VideoPreLoadUtility {
    
    static var shared = VideoPreLoadUtility()
    
    // MARK: - Properties
    let backgroundQueue = OperationQueue()
    
    // MARK: - enable methods
    public static func enable(at items: Any) {
        guard let items = items as? [FeedData] else { return }
        shared.uploadVideosCache(with: shared.extractURLs(from: items, keyPath: \.filePath))
        shared.uploadImageCache(with: shared.extractURLs(from: items, keyPath: \.thumbnail))
    }
    
    private func extractURLs(from items: [FeedData], keyPath: KeyPath<PostFile, String?>) -> [URL] {
        return items
            .filter { $0.postType == FeedType.video.rawValue }
            .compactMap { $0.post?.first }
            .compactMap { $0[keyPath: keyPath] }
            .compactMap { URL(string: $0) }
    }
    
    private func uploadVideosCache(with urls: [URL]) {
        VideoPreloadManager.shared.set(waiting: urls)
    }
    
    private func uploadImageCache(with urls: [URL]) {
        for url in urls {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) {_,_,_,_,_,_ in }
        }
    }
}
