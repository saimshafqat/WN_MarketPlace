//
//  AudioUtility.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 08/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import AVFoundation

class AudioUtility {
    
    static func getAudioDuration(from urlString: String, completion: @escaping (CMTime?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }

        let asset = AVURLAsset(url: url, options: ["AVURLAssetPreferPreciseDurationAndTimingKey": true])
        let keys: [String] = ["playable", "duration"]

        asset.loadValuesAsynchronously(forKeys: keys) {
            DispatchQueue.global(qos: .userInitiated).async {
                var error: NSError?
                for key in keys {
                    let status = asset.statusOfValue(forKey: key, error: &error)
                    if status == .failed {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                        return
                    }
                }
                
                if !asset.isPlayable {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "FileNotPlayable", code: 0, userInfo: nil))
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(asset.duration, nil)
                }
            }
        }
    }
}
