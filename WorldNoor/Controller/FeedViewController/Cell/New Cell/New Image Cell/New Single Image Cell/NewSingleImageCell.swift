//
//  NewSingleImageCell.swift
//  WorldNoor
//
//  Created by apple on 8/16/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewSingleImageCell : UITableViewCell {
    
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var btnImgView : UIButton!
    
    var postObj : FeedData!
    
   
    @IBAction func openImage(sender : UIButton){
        UIApplication.topViewController()?.showdetail(feedObj: postObj, currentIndex: 0)
    }
    
    @IBAction func downloadImage(sender : UIButton){
        let postFile:PostFile = self.postObj.post![0]
        
        UIApplication.topViewController()!.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true, FeedObj: self.postObj)
    }
}
