//
//  FullScreenBannerAdCell.swift
//  WorldNoor
//
//  Created by ogouluser1 on 01/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import GoogleMobileAds
class FullScreenBannerAdCell: ConfigableCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var bannerView: GADBannerView?
    
    // MARK: - Properties -
    var indexPath: IndexPath!
    var retriedAdRequest: Int = 0
    var loadedBanners: [IndexPath: Bool] = [:]
    
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        self.indexPath = indexPath
        if loadedBanners[indexPath] != true {
            retriedAdRequest = 1
            setupBannerAds()
        }
    }
    
    func setupBannerAds()  {
        bannerView?.adUnitID = "ca-app-pub-1417085788581438/6669811322"
        bannerView?.rotateViewForLanguage()
        bannerView?.rootViewController = UIApplication.topViewController()
        bannerView?.delegate = self
        bannerView?.load(GADRequest())
    }
}

// MARK: - Google Ads Banner Delegate -
extension FullScreenBannerAdCell: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        loadedBanners[indexPath] = true
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        if retriedAdRequest <= 5 {
            setupBannerAds()
            retriedAdRequest += 1
        }
    }
}
