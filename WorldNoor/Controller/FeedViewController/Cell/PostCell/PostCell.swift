//
//  PostCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/11/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class PostCell: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bgView: DesignableView!
    var feedObj:FeedData?

    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
        likeDislikeUpdated = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
//        self.commentViewRef.commentTextView.delegate = self
//        self.commentViewRef.micBtn.addTarget(self, action: #selector(self.micButtonClicked), for: UIControl.Event.touchUpInside)
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
        self.headerViewRef.postSelected = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure
        self.commentViewRef.commentButtonHandler = didSelect
        
        
        
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
    
//    @objc func micButtonClicked(sender:UIButton)    {
//        self.commentViewRef.audioOptionView.isHidden = !self.commentViewRef.audioOptionView.isHidden
//    }
}

extension PostCell:UITextViewDelegate   {
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
//            self.commentViewRef.commentHeightContraint.constant = newFrame.size.height + 5
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
//            self.commentViewRef.commentHeightContraint.constant = 43
//            self.textChanged?("")
        }
    }
}

extension PostCell:FeedCallBackProtocol {
    
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
        }
    }
    
    func manageLikeDislikeCounter(feedObj:FeedData){
        
        
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
                let respDict:NSDictionary = res as! NSDictionary
                let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
                let commentObj:Comment = Comment(dict: dataDict)
                var commentCount:Int = 0
                if feedObjUpdate.comments!.count > 0 {
                    commentCount = (feedObjUpdate.comments?.count)! - 1
                }
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true
                self.feedArray[self.indexValue.row] = feedObjUpdate
                self.updateTableClosure?(self.indexValue)
            }
        }
    }
}
