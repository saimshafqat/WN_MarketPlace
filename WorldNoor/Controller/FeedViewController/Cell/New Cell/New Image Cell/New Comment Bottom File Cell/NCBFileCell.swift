//
//  NCBFileCell.swift
//  WorldNoor
//
//  Created by apple on 9/30/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class NCBFileCell : UITableViewCell {
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblComment : UILabel!
    @IBOutlet var lblReplyCount : UILabel!
    @IBOutlet var lblLikeCount : UILabel!
//    @IBOutlet var lblDislikeCount : UILabel!
    @IBOutlet var lblFileName : UILabel!
    
    @IBOutlet var imgViewUser : UIImageView!
    @IBOutlet var imgViewFileIcon : UIImageView!
    
    
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var btnSpeaker : UIButton!
    @IBOutlet var btnReplyLike : UIButton!
//    @IBOutlet var btnReplyDisLike : UIButton!
    @IBOutlet var btnOriginal : UIButton!
    
    @IBOutlet var cstOriginalHeight : NSLayoutConstraint!
    
    var commentObj : Comment!
    var postObj : FeedData!
    
    
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
        self.lblTime.text = commentObj.commentTime
        

        
        self.lblReplyCount.text = String(self.commentObj.replyCount ?? 0)
        self.lblLikeCount.text = String(self.commentObj.likeCommentCount ?? 0)
//        self.lblDislikeCount.text = String(self.commentObj.disLikeCommentCount ?? 0)
        
        self.btnReplyLike.isSelected = self.commentObj.isLiked ?? false
//        self.btnReplyDisLike.isSelected = self.commentObj.isDisliked ?? false
        
        
        self.btnOriginal.isHidden = true
        self.cstOriginalHeight.constant = 0.0
        if commentObj.original_body != nil && commentObj.body != nil  {
            self.btnOriginal.isHidden = false
            if commentObj.original_body! == commentObj.body! {
                self.btnOriginal.isHidden = true
            }else {
                self.cstOriginalHeight.constant = 30.0
            }
        }
        self.updateConstraints()
        self.layoutSubviews()
        self.imgViewUser.loadImageWithPH(urlMain: self.commentObj.author!.profileImage!)
        
        
        
        let messagefile = self.commentObj.commentFile!.last!
        
        let urlmain = messagefile.url!.components(separatedBy: ".")
        
        
        self.lblFileName.text = messagefile.original_name
        
        if urlmain.last == "pdf" {
            self.imgViewFileIcon.image = UIImage.init(named: "PDFIcon.png")
        }else if urlmain.last == "doc" || urlmain.last == "docx"{
            self.imgViewFileIcon.image = UIImage.init(named: "WordFile.png")
        }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
            self.imgViewFileIcon.image = UIImage.init(named: "ExcelIcon.png")
        }else if  urlmain.last == "zip"{
            self.imgViewFileIcon.image = UIImage.init(named: "ZipIcon.png")
        }else if  urlmain.last == "pptx"{
            self.imgViewFileIcon.image = UIImage.init(named: "pptIcon.png")
        }else {
            self.imgViewFileIcon.image = UIImage.init(named: "PDFIcon.png")
        }
        
        

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
//            self.btnReplyDisLike.isSelected = false
            
            
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
    
    @IBAction func openfile(sender : UIButton){
        
        
        let messagefile = self.commentObj.commentFile!.last!
        
        
        
        if let url = URL(string: messagefile.url!) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func speakerAction(sender : UIButton){
        SpeechManager.shared.textToSpeech(message:self.lblComment.text!)
    }
}
