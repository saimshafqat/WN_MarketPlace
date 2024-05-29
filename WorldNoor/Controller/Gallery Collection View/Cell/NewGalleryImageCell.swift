//
//  NewGalleryImageCell.swift
//  WorldNoor
//
//  Created by Lucky on 06/02/2020.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class NewGalleryImageCell : UICollectionViewCell , UIScrollViewDelegate {
    @IBOutlet var imageMain : UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    let myArray:[String] = ["5.jpg","6.jpg", "7.jpg","8.jpg"]
    

    
    override func awakeFromNib() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    func manageImageData(feedObj:FeedData){
           if feedObj.post!.count > 0 {
               let postFile:PostFile = feedObj.post![0]
               self.imageMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
               self.imageMain.sd_setImage(with: URL(string: postFile.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
           }
       }
       
       func manageImageData(postObj:PostFile){
           self.imageMain.sd_imageIndicator = SDWebImageActivityIndicator.gray
           self.imageMain.sd_setImage(with: URL(string: postObj.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
       }
       
       func manageImageData(indexValue:Int){
           self.imageMain.contentMode = .scaleAspectFit
           self.imageMain.image = UIImage(named: myArray[indexValue])
          
       }
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return imageMain
    }
    
}
