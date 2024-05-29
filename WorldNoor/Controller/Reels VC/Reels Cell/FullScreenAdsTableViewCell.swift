import Foundation
import UIKit
import GoogleMobileAds

class FullScreenAdsTableViewCell: UITableViewCell {
    
    // MARK: - Properties -
    @IBOutlet weak var fullScreenAdView: GADBannerView!
    
    private var bannerAd: GADBannerView?
    private var retriedAdRequest: Int = 0
    
    func setupBannerAds()  {
        fullScreenAdView?.adUnitID = "ca-app-pub-1417085788581438/6669811322"
        fullScreenAdView?.rotateViewForLanguage()
        fullScreenAdView?.rootViewController = UIApplication.topViewController()
        fullScreenAdView?.delegate = self
        fullScreenAdView?.load(GADRequest())
    }
    
    func displayCellContent() {
        setupBannerAds()
    }
}
// MARK: - Google Ads Banner Delegate -
extension FullScreenAdsTableViewCell: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        if retriedAdRequest <= 5 {
            setupBannerAds()
            retriedAdRequest += 1
        }
    }
}
