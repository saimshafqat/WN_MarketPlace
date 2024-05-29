//
//  NewCommentBottomImageCell.swift
//  WorldNoor
//
//  Created by apple on 9/21/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewCommentBottomImageCell : UITableViewCell {
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblComment : UILabel!
    @IBOutlet var lblReplyCount : UILabel!
    @IBOutlet var lblLikeCount : UILabel!
    
    @IBOutlet var imgViewUser : UIImageView!
    @IBOutlet var imgViewMain : UIImageView!
    
    @IBOutlet var viewVideo : UIView!
    
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var btnSpeaker : UIButton!
    @IBOutlet var btnReplyLike : UIButton!
    @IBOutlet var btnOriginal : UIButton!
    @IBOutlet var cstBottomSpace : NSLayoutConstraint!
    @IBOutlet var cstOriginalHeight : NSLayoutConstraint!
    
    @IBOutlet var cstTextTop : NSLayoutConstraint!
    
    var commentObj : Comment!
    
    
    func reloadComment(){
        self.lblUserName.dynamicCaption1Regular12()
        self.lblTime.dynamicCaption2Regular11()
        self.lblComment.dynamicCaption1Regular12()
        self.btnOriginal.titleLabel?.dynamicFootnoteRegular13()
        self.lblReplyCount.dynamicCaption1Regular12()
        
        self.lblTime.text = ""
        self.lblUserName.text = self.commentObj.author!.firstname! + " " + self.commentObj.author!.lastname!
        self.lblComment.text = commentObj.body!
        
        self.btnSpeaker.isHidden = self.lblComment.text!.count > 0 ? false : true
        self.cstTextTop.constant = self.lblComment.text!.count > 0 ? 5 : 0
        self.cstBottomSpace.constant = self.lblComment.text!.count > 0 ? 5 : 0
        self.lblTime.text = commentObj.commentTime
        
        self.lblReplyCount.text = String(self.commentObj.replyCount ?? 0)
        self.lblLikeCount.text = String(self.commentObj.likeCommentCount ?? 0)
//        self.lblDislikeCount.text = String(self.commentObj.disLikeCommentCount ?? 0)
        
        self.btnReplyLike.isSelected = self.commentObj.isLiked ?? false
//        self.btnReplyDisLike.isSelected = self.commentObj.isDisliked ?? false
        
        
        self.btnOriginal.isHidden = true
        self.cstOriginalHeight.constant = 0.0
//        self.cstBottomSpace.constant = 45.0
        
        if commentObj.original_body != nil && commentObj.body != nil  {
            self.btnOriginal.isHidden = false
            if commentObj.original_body! == commentObj.body! {
                self.btnOriginal.isHidden = true
//                self.cstBottomSpace.constant = 15.0
            }else {
                self.cstOriginalHeight.constant = 30.0
            }
        }
        self.updateConstraints()
        self.layoutSubviews()
        self.imgViewUser.loadImageWithPH(urlMain: self.commentObj.author!.profileImage!)
        self.viewVideo.isHidden = true
        if self.commentObj.commentFile?.first?.fileType == FeedType.image.rawValue {
            self.imgViewMain.loadImageWithPH(urlMain: (self.commentObj.commentFile?.first?.url)!)
        }else if self.commentObj.commentFile?.first?.fileType == FeedType.video.rawValue {
            self.viewVideo.isHidden = false
            self.imgViewMain.loadImageWithPH(urlMain: (self.commentObj.commentFile?.first?.thumbnail_url)!)
        }
    }
    
    
    @IBAction func previewAction(sender : UIButton){
        let valueMain = [String :Any]()
        
        let postObj = FeedData.init(valueDict: valueMain)
        
        
        postObj.postType = commentObj.commentFile?.first?.fileType
        let postFile = PostFile.init()
        postFile.fileType = commentObj.commentFile?.first?.fileType

        postFile.filePath = commentObj.commentFile?.first?.url

        postObj.post = [PostFile]()
        postObj.post?.append(postFile)
        UIApplication.topViewController()?.showdetail(feedObj: postObj, currentIndex: 0)
    }
    
    @IBAction func likeReplay(sender : UIButton){
        if self.btnReplyLike.isSelected {
            self.btnReplyLike.isSelected = false
            if self.lblLikeCount.text!.count > 0 {
                let textMain = Int(self.lblLikeCount.text!)!
                self.lblLikeCount.text = (textMain > 0) ? (String(textMain - 1)) : "0"
            }
        }else {
            self.btnReplyLike.isSelected = true
            
            
            if self.lblLikeCount.text!.count > 0 {
                let textMain = Int(self.lblLikeCount.text!)!
                self.lblLikeCount.text = String(textMain + 1)
            }else {
                self.lblLikeCount.text = "1"
            }
            

        }
        
        
        let parameters = ["action": "comment/like_dislike","token": SharedManager.shared.userToken(), "type": "simple_like", "comment_id":String(self.commentObj!.commentID!)]
        UIApplication.topViewController()?.callingAPI(parameters: parameters)
    
    }
    
    @IBAction func disLikeReplay(sender : UIButton){
        

        
    }
    
    @IBAction func speakerAction(sender : UIButton){
        SpeechManager.shared.textToSpeech(message:self.lblComment.text!)

    }
}
