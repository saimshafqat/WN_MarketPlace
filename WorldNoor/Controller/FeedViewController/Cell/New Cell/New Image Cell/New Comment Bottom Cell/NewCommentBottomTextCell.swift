//
//  NewCommentBottomCell.swift
//  WorldNoor
//
//  Created by apple on 9/13/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewCommentBottomTextCell : UITableViewCell {
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblComment : UILabel!
    
    @IBOutlet var imgViewUser : UIImageView!
    
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var btnSpeaker : UIButton!
    @IBOutlet var btnOriginal : UIButton!
    @IBOutlet var cstBottomSpace : NSLayoutConstraint!
    
    var commentObj : Comment!
    var postObj : FeedData!
    
    
    func reloadComment(){
        self.lblUserName.dynamicCaption1Regular12()
        self.lblTime.dynamicCaption2Regular11()
        self.lblComment.dynamicCaption1Regular12()
        self.btnOriginal.titleLabel?.dynamicFootnoteRegular13()
        
        self.lblTime.text = ""
        self.lblUserName.text = self.commentObj.author!.firstname! + " " + self.commentObj.author!.lastname!
        self.lblComment.text = commentObj.body!
        self.lblTime.text = commentObj.commentTime
        
        self.btnSpeaker.isHidden = self.lblComment.text!.count > 0 ? false : true
        self.btnOriginal.isHidden = true
        self.cstBottomSpace.constant = 45.0
        
        if commentObj.original_body != nil && commentObj.body != nil  {
            self.btnOriginal.isHidden = false
            if commentObj.original_body! == commentObj.body! {
                self.btnOriginal.isHidden = true
                self.cstBottomSpace.constant = 15.0
            }
        }
        self.updateConstraints()
        self.layoutSubviews()
        
        self.imgViewUser.loadImageWithPH(urlMain: self.commentObj.author!.profileImage!)
        
    }
    
    @IBAction func moreAction(sender : UIButton){
        
        
//        let commentObj:Comment = self.commentObj.
//        let replyComment:Comment = commentObj.replies![replyIndex.row]
//        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
//        self?.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
//        reportController.delegate = self
//        reportController.isReply = true
//        reportController.reportType = "Comment"
//        reportController.currentIndex = commentIndex
//        reportController.feedObj = self?.feedObj
//        reportController.commentObj = replyComment
//        self?.editCommentObj = replyComment
//        self?.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
//        self?.sheetController.extendBackgroundBehindHandle = true
//        self?.sheetController.topCornersRadius = 20
//        self?.present(self!.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func speakerAction(sender : UIButton){
        SpeechManager.shared.textToSpeech(message:self.lblComment.text!)
    }
}
