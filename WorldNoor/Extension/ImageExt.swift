//
//  ImageExt.swift
//  WorldNoor
//
//  Created by Raza najam on 10/18/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Kingfisher
import SDWebImageWebPCoder

extension UIImageView {
    func round(radius: CGFloat? = nil, borderWidth: CGFloat? = nil, bordorColor: UIColor? = nil) {
        var cornor: CGFloat
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
    
    func roundWithClear(radius: CGFloat? = nil) {
        
        var cornor: CGFloat
        
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
    
    func roundWithClearColor(radius: CGFloat? = nil) {
        
        var cornor: CGFloat
        
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
}


extension UIImageView {
    
    func loadImage(urlMain: String, placeholder: String) {
        
        self.kf.indicatorType = .activity
        self.kf.indicator?.view.tintColor = .darkGray
        
        self.kf.setImage(
            with: URL(string: urlMain),
            placeholder: UIImage(named: placeholder),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in

        }
    }
    
    func loadImage(urlMain : String){
        
        self.loadImageWithPH(urlMain: urlMain)
//        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        self.sd_setImage(with: URL(string: urlMain), completed: nil)
    }
 
    
    func loadUserWithPH(urlMain : String) {
                
        self.kf.indicatorType = .activity
        self.kf.indicator?.view.tintColor = .darkGray
        
        self.kf.setImage(
            with: URL(string:urlMain),
            placeholder: UIImage(named: "profile_icon"),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in

        }

    }
    
    
    func loadVideoWithPH(urlMain : String) {
                
        self.kf.indicatorType = .activity
        self.kf.indicator?.view.tintColor = .darkGray
        
        self.kf.setImage(
            with: URL(string:urlMain),
            placeholder: UIImage(named: "PlaceHolderImage.png"),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in

        }

    }
    
    func loadImageWithPH(urlMain : String) {
        self.kf.indicatorType = .activity
        self.kf.indicator?.view.tintColor = .darkGray
        
        self.kf.setImage(
            with: URL(string:urlMain),
            placeholder: UIImage(named: "PlaceHolderImage.png"),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in

        }
    }

    //    func imageLoad(with urlString: String?, isPlaceHolder: Bool = true) {
    //        if let urlString {
    //            sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
    //
    //            let filepath = urlString.split(separator: ".")
    ////            LogClass.debugLog("filepath ===>")
    ////            LogClass.debugLog(filepath)
    //            if filepath.count > 0 {
    ////                LogClass.debugLog("filepath ===> 1")
    ////                LogClass.debugLog(filepath.last)
    //                if filepath.last == "webp" {
    ////                    LogClass.debugLog("filepath ===> 2")
    //                    sd_imageIndicator = SDWebImageActivityIndicator.gray
    //                    let webPCoder = SDImageWebPCoder.shared
    //                    SDImageCodersManager.shared.addCoder(webPCoder)
    //                    guard let webpURL = URL(string:urlString)  else {return}
    ////                    DispatchQueue.main.async { [self] in
    //                        sd_setImage(with: webpURL)
    ////                    }
    //                }else {
    ////                    LogClass.debugLog("filepath ===> 3")
    //                    if isPlaceHolder {
    ////                        LogClass.debugLog("filepath ===> 4")
    //                        sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "PlaceHolderImage.png"))
    //                    } else {
    ////                        LogClass.debugLog("filepath ===> 5")
    //                        sd_setImage(with: URL(string: urlString))
    //                    }
    //                }
    //            }else {
    ////                LogClass.debugLog("filepath ===> 3")
    //                if isPlaceHolder {
    ////                    LogClass.debugLog("filepath ===> 4")
    //                    sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "PlaceHolderImage.png"))
    //                } else {
    ////                    LogClass.debugLog("filepath ===> 5")
    //                    sd_setImage(with: URL(string: urlString))
    //                }
    //            }
    ////            backgroundColor = .clear
    //        }
    //    }
    
    func imageLoad(with urlString: String?, isPlaceHolder: Bool = true, placeHolderImage: UIImage? = nil) {
        if let urlString {
            if let cacheImage = SDImageCache.shared.imageFromCache(forKey: urlString) {
                if #available(iOS 15.0, *) {
                    cacheImage.prepareForDisplay { [weak self] img in
                        DispatchQueue.main.async {
                            self?.image = img
                        }
                    }
                } else {
                    DispatchQueue.main.async {[weak self] in
                        self?.image = cacheImage
                    }
                }
            } else {
                sd_imageIndicator = SDWebImageActivityIndicator.gray
                sd_imageIndicator?.indicatorView.tintColor = UIColor.blueColor.withAlphaComponent(0.7)
                let filepath = urlString.split(separator: ".")
                if filepath.count > 0 {
                    if filepath.last == "webp" {
                        sd_imageIndicator = SDWebImageActivityIndicator.gray
                        let webPCoder = SDImageWebPCoder.shared
                        SDImageCodersManager.shared.addCoder(webPCoder)
                        guard let webpURL = URL(string:urlString)  else {return}
                        sd_setImage(with: webpURL)
                    } else {
                        if isPlaceHolder {
                            sd_setImage(with: URL(string: urlString), placeholderImage: placeHolderImage == nil ? UIImage(named: "PlaceHolderImage.png") : placeHolderImage)
                        } else {
                            sd_setImage(with: URL(string: urlString))
                        }
                    }
                } else {
                    if isPlaceHolder {
                        sd_setImage(with: URL(string: urlString), placeholderImage: placeHolderImage == nil ? UIImage(named: "PlaceHolderImage.png") : placeHolderImage)
                    } else {
                        sd_setImage(with: URL(string: urlString))
                    }
                }
            }
        }
    }
}


extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> UIImage {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            if let data = holderImage.jpegData(compressionQuality: 1.0) {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
//                    return data
                    
                    return UIImage.init(data: data)!
                } else {
                    let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }
            
            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return self
    }
}

extension UIImage {
  
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: Double(size.width+5), height: Double(size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {
        let newHeight = size.height
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

import UIKit

extension UIImage {
    func saveToTemporaryDirectory() -> URL? {
        guard let data = self.jpegData(compressionQuality: 1.0) ?? self.pngData() else {
            return nil
        }
        
        let fileName = "\(UUID().uuidString).png" // Generate a unique filename
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to temporary directory: \(error.localizedDescription)")
            return nil
        }
    }
}

