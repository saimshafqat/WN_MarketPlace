//
//  PostAdsCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class PostAdsCollectionCell: ConfigableCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var bannerView: GADBannerView?
    
    // MARK: - Properties -
    var indexPath: IndexPath!
    var retriedAdRequest: Int = 0
    var retriedAdRequesThreshold = 3
    var loadedBanners: [IndexPath: Bool] = [:]
    var parentView : UIViewController!
    
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        self.indexPath = indexPath
        if loadedBanners[indexPath] != true {
            retriedAdRequest = 1
            setupBannerAds()
        }
    }
    
    func setupBannerAds()  {
#if DEBUG
      AppLogger.log(tag: .debug, "We are on debugging mode.")
      bannerView?.adUnitID = "ca-app-pub-3940256099942544/6300978111"
#else
        AppLogger.log(tag: .debug, "We are on production mode.")
        bannerView?.adUnitID = "ca-app-pub-1417085788581438/6669811322"
#endif
        bannerView?.rotateViewForLanguage()
        bannerView?.rootViewController = UIApplication.topViewController()
        bannerView?.delegate = self
        bannerView?.load(GADRequest())
    }
}

// MARK: - Google Ads Banner Delegate -
extension PostAdsCollectionCell: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        AppLogger.log(tag: .success, "bannerViewDidReceiveAd ===>")
        loadedBanners[indexPath] = true
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        AppLogger.log(tag: .error, "didFailToReceiveAdWithError ===>")
        LogClass.debugLog(error.localizedDescription)
        if retriedAdRequest <= retriedAdRequesThreshold {
            setupBannerAds()
            retriedAdRequest += 1
        }
    }
}
