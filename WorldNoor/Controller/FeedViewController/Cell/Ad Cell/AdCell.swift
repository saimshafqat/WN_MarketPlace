//
//  AdCell.swift
//  WorldNoor
//
//  Created by apple on 4/15/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdCell : FeedParentCell ,GADBannerViewDelegate {
    
    @IBOutlet var viewBG : UIView!
    
    @IBOutlet var lblLoading : UILabel!
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    var parentview : UIViewController!
    var indexMainLocal : IndexPath!
    
    
    var isload = false
    
    override func awakeFromNib() {
        bannerView.adUnitID = "ca-app-pub-1417085788581438/6669811322"
        
        
        self.bannerView.rotateViewForLanguage()

        bannerView.load(GADRequest())
        
        bannerView.delegate = self
        self.lblLoading.dynamicBodyRegular17()
    }
    
    
    func reloadData(parentview : UIViewController , indexMain : IndexPath){
        
      
        for indexObj in self.contentView.subviews {

        }

    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        
    }
}

