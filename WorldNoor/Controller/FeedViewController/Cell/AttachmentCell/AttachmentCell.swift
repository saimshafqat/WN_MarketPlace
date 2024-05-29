//
//  AttachmentCell.swift
//  WorldNoor
//
//  Created by Raza najam on 6/8/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class AttachmentCell: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bgView: DesignableView!
    @IBOutlet weak var audioTextLabel: UILabel!
    var feedObj:FeedData?
    var imageSelectedClosure:((Int, Bool)->())?
    
    var showShareOption:((Int)->())?
    
    @IBOutlet weak var imgviewFileIcon: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    
    @IBOutlet weak var btnDownload: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
//        self.commentViewRef.commentTextView.delegate = self
        
        self.audioTextLabel.dynamicFootnoteRegular13()
        self.lblFileName.dynamicBodyRegular17()
        self.btnDownload.titleLabel?.dynamicTitle3Bold20()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        if self.commentViewRef != nil {
            self.updateTableClosure = reloadClosure
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
        }
        self.feedObj = feedObj
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.topBar.sizeToFit()
        self.commentView.addSubview(self.commentViewRef)
        self.indexValue = indexValue
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageCallbackhandler()
        self.headerViewRef.indexValue = indexValue
        self.headerViewRef.updateSingleRow = reloadClosure

        self.headerViewRef.postSelected = didSelect
        self.commentViewRef.commentButtonHandler = didSelect
        
        
        if feedObj.postType == FeedType.file.rawValue {
            
            if feedObj.post!.count > 0 {
                 let urlmain = feedObj.post!.first!.filePath!.components(separatedBy: ".")
                            
                let name2 = feedObj.post?.first?.filePath!.components(separatedBy: "/")
                
                self.lblFileName.text = name2!.last!
                
                
                if urlmain.last == "pdf" {
                   self.imgviewFileIcon.image = UIImage.init(named: "PDFIcon.png")
               }else if urlmain.last == "doc" || urlmain.last == "docx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "WordFile.png")
               }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "ExcelIcon.png")
               }else if  urlmain.last == "zip"{
                   self.imgviewFileIcon.image = UIImage.init(named: "ZipIcon.png")
               }else if  urlmain.last == "pptx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "pptIcon.png")
               }else {
                   self.imgviewFileIcon.image = UIImage.init(named: "PDFIcon.png")
                           
                }
            }
           
            
        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.bgView.isUserInteractionEnabled = true
        self.bgView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)
//        self.commentViewRef.commentTextView.isScrollEnabled = false
        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
        
        if let commentCoun =  feedObj.commentCount  {
            if commentCoun > 0 {
                self.commentView.frame.size.height = 211
                self.commentViewRef.frame.size.height = 211
            }
        }
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imageSelectedClosure?(self.indexValue.row, false)
    }
    
    
    @objc func micButtonClicked(sender:UIButton)    {
//        self.commentViewRef.audioOptionView.isHidden = !self.commentViewRef.audioOptionView.isHidden
    }
    
    @IBAction func ShareOption(sender : UIButton){
        self.showShareOption?(self.indexValue.row)
    }
}

extension AttachmentCell:UITextViewDelegate   {
    // text change callback handler inside vm...
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView){
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < 100 {
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = newFrame.size.height
            textChanged?(textView.text)
        }else {
//            self.commentViewRef.commentTextView.isScrollEnabled = true
        }
    }
    
    func handleEmptyText(){
        self.commentViewRef.textEmptyCallbackHandler =  { (isTextEmpty) in
//            let fixedWidth = self.commentViewRef.commentTextView.frame.size.width
//            self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            let newSize = self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            var newFrame = self.commentViewRef.commentTextView.frame
//            newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = 50
            self.textChanged?("")
        }
    }
}

extension AttachmentCell:FeedCallBackProtocol {
    
    func manageCallbackhandler(){
        self.handlingLikeDislike()
        self.handleEmptyText()
        self.handlingCommentCallback()
        self.handlingInstantCommentCallback()
    }
    
    // Hanlding LikeDislikeCallBack...
    func handlingLikeDislike(){
        self.commentViewRef.likeDislikeCallBack =  { (isLike, value) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if isLike {
                if value {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! + 1
                    if feedObjUpdate.isDisliked! {
                        feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                    }
                }else {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                }
                feedObjUpdate.isLiked = value
                feedObjUpdate.isDisliked = false
            }else {
                if value {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! + 1
                    if feedObjUpdate.isLiked! {
                        feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                    }
                }else {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                }
                feedObjUpdate.isDisliked = value
                feedObjUpdate.isLiked = false
            }
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.commentViewRef.manageCount()
            //  self.updateTableClosure?(NSIndexPath(row: self.indexValue, section: 0) as IndexPath)
        }
    }
    
    // comment call back handler to update the comment instantly in feedobject
    func handlingInstantCommentCallback(){
        
        self.commentViewRef.commentSentInstantlyHandler = {(body) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            let commentObj:Comment = Comment(original_body:body ,body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:false, identifierStr:"")
            var commentCount:Int = 0
            if feedObjUpdate.comments!.count > 0 {
                commentCount = (feedObjUpdate.comments?.count)!
            }
            feedObjUpdate.comments?.insert(commentObj, at: commentCount)
            feedObjUpdate.isPostingNow = false
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.updateTableClosure?(self.indexValue)
        }
    }
    
    // comment callback handler after service call
    func handlingCommentCallback(){
        self.commentViewRef.commentServiceCallbackHandler = {(res) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if res is String {
                return
            }else if res is NSDictionary {
                var commentCount:Int = 0
                if feedObjUpdate.comments!.count > 0 {
                    commentCount = (feedObjUpdate.comments?.count)! - 1
                }
                let respDict:NSDictionary = res as! NSDictionary
                let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
                let commentObj:Comment = Comment(dict: dataDict)
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true
                self.feedArray[self.indexValue.row] = feedObjUpdate
                self.updateTableClosure?(self.indexValue)
            }
        }
    }
}
