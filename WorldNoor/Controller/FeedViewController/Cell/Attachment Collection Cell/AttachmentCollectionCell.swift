//
//  AttachmentCollectionCell.swift
//  WorldNoor
//
//  Created by apple on 6/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AttachmentCollectionCell : UICollectionViewCell  {
    @IBOutlet var webViewMain : WKWebView!
    @IBOutlet var activityView : UIActivityIndicatorView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    let myArray:[String] = ["5.jpg","6.jpg", "7.jpg","8.jpg"]
    

    
    override func awakeFromNib() {
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 6.0
    }
    
//    func manageImageData(feedObj:FeedData){
//           if feedObj.post!.count > 0 {
//               let postFile:PostFile = feedObj.post![0]
////               self.imageMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
////               self.imageMain.sd_setImage(with: URL(string: postFile.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
//           }
//       }
       
       func manageImageData(postObj:PostFile){
        
        
//        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.webView.frame.size.height))
//        self.view.addSubview(webView)
        
        self.activityView.isHidden = false
        let url = URL(string: postObj.filePath!)
        webViewMain.load(URLRequest(url: url!))
                
//           self.imageMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
//           self.imageMain.sd_setImage(with: URL(string: postObj.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
       }
       
//       func manageImageData(indexValue:Int){
//           self.imageMain.contentMode = .scaleAspectFit
//           self.imageMain.image = UIImage(named: myArray[indexValue])
          
//       }
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//
//        return imageMain
//    }
    
}

