//
//  MediaDimensionsManager.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 10/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class MediaDimensionsManager {
    
    static let shared = MediaDimensionsManager()
    
    private init() {
    }
    
    func dimensions(forMediaAt fileURL: URL) -> (width: CGFloat, height: CGFloat)? {
        if fileURL.pathExtension.lowercased() == "mp4" || fileURL.pathExtension.lowercased() == "mov" {
            return videoDimensions(url: fileURL)
        } else if fileURL.pathExtension.lowercased() == "jpg" || fileURL.pathExtension.lowercased() == "jpeg" || fileURL.pathExtension.lowercased() == "png" {
            return imageDimensions(url: fileURL)
        } else {
            // Handle unsupported media type or return nil
            return nil
        }
    }
    
    private func videoDimensions(url: URL) -> (width: CGFloat, height: CGFloat)? {
        let asset = AVURLAsset(url: url)
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else {
            // Handle error (e.g., invalid URL, missing track) or return nil
            return nil
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        let dimensions = CGSize(width: abs(size.width), height: abs(size.height))
        return (dimensions.width, dimensions.height)
    }

    private func imageDimensions(url: URL) -> (width: CGFloat, height: CGFloat)? {
        if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
           let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
           let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat {
            print("Width: \(pixelWidth), Height: \(pixelHeight)")
            return (pixelWidth, pixelHeight)
        }
        // Handle error (e.g., unable to get properties) or return nil
        return nil
    }
}
