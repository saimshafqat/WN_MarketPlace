//
//  NewPreviewCell.swift
//  WorldNoor
//
//  Created by apple on 9/20/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class NewPreviewCell : UITableViewCell {
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var imgViewPlay : UIImageView!
    
    @IBOutlet var btnRemove : UIButton!
    
    var feedObj : FeedData!
    var delegate : LikeCellDelegate!
    
    func reloadPreviewCell(feedObjP : FeedData){
        self.feedObj = feedObjP
        self.imgView.contentMode = .scaleAspectFill

        self.imgViewPlay.isHidden = true
        if self.feedObj.comments!.count > 0 {
            if let ObjFirst = self.feedObj.comments!.last {
                if ObjFirst.commentFile!.last!.fileType == FeedType.file.rawValue {
                    
                    let extensionName = ObjFirst.commentFile!.last!.url?.components(separatedBy: ".")

                    self.imgView.contentMode = .scaleAspectFit

                    if extensionName!.last == "pdf" {
                        self.imgView.image = UIImage.init(named: "PDFIcon")
                    }else {
                        self.imgView.image = UIImage.init(named: "pptIcon")
                    }
                }else if ObjFirst.commentFile!.last!.fileType == FeedType.gif.rawValue {
//                    self.imgView.sd_setImage(with: URL(string: ObjFirst.commentFile!.last!.url!), placeholderImage: UIImage(named: "placeholder.png"))
                    
                    self.imgView.loadImageWithPH(urlMain:ObjFirst.commentFile!.last!.url!)
                    
                }else if ObjFirst.commentFile!.last!.fileType == FeedType.image.rawValue {
                    self.imgView.image = ObjFirst.commentFile!.last!.assetObj?.getAssetThumbnail()
                }else if ObjFirst.commentFile!.last!.fileType == FeedType.video.rawValue {
                    self.imgView.image = SharedManager.shared.getImageFromAsset(asset: ObjFirst.commentFile!.last!.assetObj!)
                    self.imgViewPlay.isHidden = false
                    
                }
            }
        }
        
    }
    
    @IBAction func removeAttachment(sender : UIButton){
        if self.feedObj.comments!.count > 0 {
            if let ObjFirst = self.feedObj.comments!.last {
                if ObjFirst.commentID == 0 {
//                    self.feedObj.comments?.remove(at: 0)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1) , execute: {
                        self.feedObj.comments!.remove(at: self.feedObj.comments!.count - 1)
                        self.delegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
                    })
                    
                    
                }
            }
        }
    }
}
