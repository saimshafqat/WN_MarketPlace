//
//  CustomPageControl.swift
//  WorldNoor
//
//  Created by Raza najam on 11/20/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class CustomPageControl: UIPageControl {
    let scale: CGFloat = 2.0
    var activeImage:UIImage = UIImage(named: "pagerAF.png")!
    var inactiveImage:UIImage = UIImage(named: "pagerAF.png")!
    var postArray:[PostFile]? = nil
    
    func setCurrentPage(page:Int) {
        super.currentPage = page
        
            self.updateDots()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
        self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        
    }
    

    func updateDots() {
        var i = 0
        for view in self.subviews {

            if let imageView = self.imageForSubview(view) {
                self.manageImageForPage(val: i)
                if i == self.currentPage {
                    imageView.image = self.activeImage
                } else {
                    imageView.image = self.inactiveImage
                }
                i = i + 1
            } else {
                self.manageImageForPage(val: i)
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                view.clipsToBounds = false
                

                    view.addSubview(UIImageView(image:dotImage))
                
                view.backgroundColor = UIColor.red
                i = i + 1
            }
            view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }
    }
    
    func manageImageForPage(val:Int){
        if self.postArray!.count >= val  {
            let postVal:PostFile = self.postArray![val]
            if postVal.fileType == FeedType.image.rawValue {
                self.activeImage = UIImage(named: "pagerAImg.png")!
                self.inactiveImage = UIImage(named: "pagerAImgF.png")!
            }else if postVal.fileType == FeedType.video.rawValue {
                self.activeImage = UIImage(named: "pagerVideo.png")!
                self.inactiveImage = UIImage(named: "pagerVideoF.png")!
            }else if postVal.fileType == FeedType.audio.rawValue {
                self.activeImage = UIImage(named: "pagerAA.png")!
                self.inactiveImage = UIImage(named: "pagerAF.png")!
            }else if postVal.fileType == FeedType.file.rawValue {
                self.activeImage = UIImage(named: "Attachment.png")!
                self.inactiveImage = UIImage(named: "AttachmentF.png")!
            }
        }
    }
    
    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        return dot
    }
}
