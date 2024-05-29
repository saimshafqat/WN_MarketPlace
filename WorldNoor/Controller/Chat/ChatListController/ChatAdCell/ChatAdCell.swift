//
//  ChatAdCell.swift
//  WorldNoor
//
//  Created by Awais on 02/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ChatAdCell: UITableViewCell, GADBannerViewDelegate {
    
    @IBOutlet var viewBG : UIView!
    @IBOutlet var lblLoading : UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    var parentview : UIViewController!
    var indexMainLocal : IndexPath!
    
    
    var isload = false
    
    override func awakeFromNib() {
        bannerView.adUnitID = "ca-app-pub-1417085788581438/6669811322"
        //        bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111" // Testing
        bannerView.rotateViewForLanguage()
        bannerView.delegate = self
        bannerView.load(GADRequest())
        lblLoading.dynamicBodyRegular17()
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
