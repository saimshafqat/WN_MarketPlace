//
//  LinkDetector.swift
//  WorldNoor
//
//  Created by Raza najam on 08/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import ActiveLabel
class LinkDetector {
    
    static func lblHandling(lblNewBody:ActiveLabel) {
        lblNewBody.enabledTypes = [.url]
        lblNewBody.customize { label in
            label.URLColor = UIColor(red: 1/255, green: 30/255, blue: 92/255.0, alpha: 1)
        }
        lblNewBody.handleURLTap { url in
            let urlStr = url.absoluteString
            LogClass.debugLog(urlStr)
            if urlStr.hasPrefix("https://") || urlStr.hasPrefix("http://") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                if let url = URL(string: "https://" + urlStr) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

