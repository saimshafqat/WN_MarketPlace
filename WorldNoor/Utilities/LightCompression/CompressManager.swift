//
//  CompressManager.swift
//  kalam
//
//  Created by Raza najam on 11/9/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CompressManager: NSObject {
    static let shared = CompressManager()

    func compressingVideoURLNEw(url:URL , onComplete:@escaping (URL?) -> Void ){
        let compressedURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressedAAAA" + UUID().uuidString + ".mp4")

        
                compressVideo(inputURL: url, outputURL: compressedURL) { (exportSession) in
                        guard let session = exportSession else {
                            return
                        }

                        switch session.status {
                        case .unknown:
                            break
                        case .waiting:
                            break
                        case .exporting:
                            break
                        case .completed:
                            guard let compressedData = NSData(contentsOf: compressedURL) else {
                                onComplete(nil)
                                return
                            }
                            onComplete(compressedURL)
                        case .failed:
                            onComplete(nil)
                            break
                        case .cancelled:
                            onComplete(nil)
                            break
                        }
                    }
               }
    

    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = false
        exportSession.exportAsynchronously { () -> Void in
            switch exportSession.status {
            case .failed:
                LogClass.debugLog("Compression failed: \(String(describing: exportSession.error))")
                // Handle error
            case .completed:
                LogClass.debugLog("Compression completed.")
                // Handle success
            default:
                break
            }
            handler(exportSession)
        }
    }
 

    func compressingVideoURL(url:URL , onComplete:@escaping (URL?) -> Void ){
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed" + UUID().uuidString + ".mp4")
        let videoCompressor = LightCompressor()
        let _: Compression = videoCompressor.compressVideo(
            source: url,
            destination: destinationPath as URL,
            quality: .very_low,
            isMinBitRateEnabled: false,
            keepOriginalResolution: false,
            progressQueue: .main,
            progressHandler: { progress in
                // progress
            },
            completion: {[weak self] result in
                guard self != nil else { return }
                
                switch result {
                case .onSuccess(let path):

                    guard let data = try? Data(contentsOf: path) else {
                        return onComplete(nil)
                        
                    }
                    
                    onComplete(path)
                    break
                
                case .onStart:
                    break
                
                case .onFailure(let error):
                    onComplete(nil)
                    break
                
                case .onCancelled:
                    onComplete(nil)
                    break
                }
            }
        )
    }
    
    
    func compressingVideo(url:URL, onComplete:@escaping (URL?) -> Void){
        let stringName = url.absoluteString.components(separatedBy: "/")
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(stringName.last! )
        let videoCompressor = LightCompressor()
        let compression: Compression = videoCompressor.compressVideo(
            source: url,
            destination: destinationPath as URL,
            quality: .very_high,
            isMinBitRateEnabled: false,
            keepOriginalResolution: false,
            progressQueue: .main,
            progressHandler: { progress in
                // progress
            },
            completion: {[weak self] result in
                guard self != nil else { return }
                
                switch result {
                case .onSuccess(let path):
                    onComplete(path)
                    break
                // success
                case .onStart: break
                // when compression starts
                
                case .onFailure(let error):
                    onComplete(nil)
                    break
                // failure error
                
                case .onCancelled:
                // if cancelled
                    onComplete(nil)
                    break
                }
            }
        )
    }
}
