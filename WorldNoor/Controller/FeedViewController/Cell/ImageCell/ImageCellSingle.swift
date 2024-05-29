//
//  FeedImageCell.swift
//  WorldNoor
//
//  Created by Raza najam on 9/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImageWebPCoder

class ImageCellSingle: FeedParentCell {
    @IBOutlet weak var topConnectorConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConnectorConst: NSLayoutConstraint!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    var imageSelectedClosure:((Int, Bool)->())?
    var feedObj:FeedData?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
        likeDislikeUpdated = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        if self.commentViewRef != nil {
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
        }
        self.feedObj = feedObj
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.topBar.sizeToFit()
        
        self.commentView.addSubview(self.commentViewRef)
        self.updateTableClosure = reloadClosure
        self.indexValue = indexValue
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageUI(feedObj: feedObj)
        self.manageCallbackhandler()
        self.headerViewRef.indexValue = indexValue
        self.headerViewRef.postSelected = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure
        self.commentViewRef.commentButtonHandler = didSelect
        self.labelRotateCell(viewMain: self.imgView)
        
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)
        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
        self.topConnectorConst.constant = 9
        self.bottomConnectorConst.constant = 6
        if self.headerViewRef.descriptionLbl.text == "" {
            self.topConnectorConst.constant = 0
            self.bottomConnectorConst.constant = 15
        }
        
    }
    
    func manageUI(feedObj:FeedData){
        if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            let filepath = postFile.filePath?.split(separator: ".")

            if filepath!.count > 0 {
                if filepath?.last == "webp" {
                    
                    let webPCoder = SDImageWebPCoder.shared
                        SDImageCodersManager.shared.addCoder(webPCoder)
                    guard let webpURL = URL(string: postFile.filePath!)  else {return}
                        DispatchQueue.main.async {
                            self.imgView.sd_setImage(with: webpURL)
                        }
                }else {
                    self.imgView.loadImageWithPH(urlMain: postFile.filePath ?? "")
                    
                }
            }else {
                
                self.imgView.loadImageWithPH(urlMain: postFile.filePath ?? "")
                
            }

            self.labelRotateCell(viewMain: self.imgView)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            self.imgView.isUserInteractionEnabled = true
            self.imgView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imageSelectedClosure?(self.indexValue.row, false)
    }
    
    @objc func micButtonClicked(sender:UIButton)    {
    }
}

extension ImageCellSingle:UITextViewDelegate   {
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

    }
    
    func handleEmptyText(){
        self.commentViewRef.textEmptyCallbackHandler =  { (isTextEmpty) in

        }
    }
}

extension ImageCellSingle:FeedCallBackProtocol {
    
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
