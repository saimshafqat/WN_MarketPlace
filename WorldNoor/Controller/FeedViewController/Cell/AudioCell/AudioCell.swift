//
//  AudioCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/10/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCell: FeedParentCell {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bgView: DesignableView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioTextLabel: UILabel!
    @IBOutlet weak var showOrigTransView: UIView!
    @IBOutlet weak var origTransBtn: UIButton!
    @IBOutlet weak var showOrignHeightConst: NSLayoutConstraint!
    var feedObj:FeedData?
    
    var xqAudioPlayer: XQAudioPlayer!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
        likeDislikeUpdated = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
        self.xqAudioPlayer = self.getAudioPlayerView()
//        self.commentViewRef.commentTextView.delegate = self
        self.audioTextLabel.dynamicFootnoteRegular13()
        self.origTransBtn.titleLabel?.dynamicFootnoteRegular13()
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        self.feedObj = feedObj
        if self.commentViewRef != nil {
            self.updateTableClosure = reloadClosure
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
            self.xqAudioPlayer.removeFromSuperview()
        }
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.topBar.sizeToFit()
        self.headerViewRef.indexValue = indexValue
        self.commentView.addSubview(self.commentViewRef)
        self.audioView.addSubview(self.xqAudioPlayer)
        self.xqAudioPlayer.frame = CGRect(x: 0, y: 0, width: self.audioView.frame.size.width, height: self.audioView.frame.size.height)
        self.indexValue = indexValue
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageCallbackhandler()
        self.audioConfigurations(feedObj:feedObj)
        self.headerViewRef.postSelected = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure

        self.commentViewRef.commentButtonHandler = didSelect
        self.origTransBtn.isSelected = false
    }
    
    func audioConfigurations(feedObj: FeedData) {
        // Change progress color
        self.origTransBtn.isHidden = true
        if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
            self.manageAudioText(postObj: postFile)
            if let convertedUrl = postFile.filetranslationlink {
                self.xqAudioPlayer.config(urlString: convertedUrl)
                self.showOrignHeightConst.constant = 30
                self.origTransBtn.isHidden = false
            }else {
                self.xqAudioPlayer.config(urlString:postFile.filePath ?? "")
                self.showOrignHeightConst.constant = 0
            }
        }
        self.xqAudioPlayer.manageProgressUI()
        self.xqAudioPlayer.delegate = self
    }
    
    func manageAudioToggle(isOrig:Bool) {
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            let orignalLink = postFile.filePath
            let translatedLink = postFile.filetranslationlink
            if isOrig {
                self.manageAudioText(postObj: postFile, isShowOrig: true)
                self.xqAudioPlayer.config(urlString: orignalLink!)
            }else {
                self.manageAudioText(postObj: postFile, isShowOrig: false)
                self.xqAudioPlayer.config(urlString: translatedLink!)
            }
        }
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)
//        self.commentViewRef.commentTextView.isScrollEnabled = false
        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
        if let commentCoun =  feedObj.commentCount  {
            if commentCoun > 0 {
                self.commentView.frame.size.height = 180
                self.commentViewRef.frame.size.height = 180
            }
        }
    }
    
    @objc func micButtonClicked(sender:UIButton)    {
//        self.commentViewRef.audioOptionView.isHidden = !self.commentViewRef.audioOptionView.isHidden
    }
    
    func manageAudioText(postObj:PostFile, isShowOrig:Bool = false) {
        let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
        if let contentLangCode = postObj.orignalLanguageID {
            if (langCode == contentLangCode) || isShowOrig {
                self.audioTextLabel.text = postObj.speechToText
            }else {
                self.audioTextLabel.text = postObj.SpeechToTextTranslated
            }
        }
        if self.audioTextLabel.text != nil {
            let langDirection = SharedManager.shared.detectedLangauge(for: self.audioTextLabel.text!) ?? "left"
            (langDirection == "right") ? (self.audioTextLabel.textAlignment = NSTextAlignment.right): (self.audioTextLabel.textAlignment = NSTextAlignment.left)
        }
    }
    
    @IBAction func origTransBtnClicked(_ sender: Any) {
        self.xqAudioPlayer.resetXQPlayer()
        if self.origTransBtn.isSelected {
            self.manageAudioToggle(isOrig: false)
        }else {
            self.manageAudioToggle(isOrig: true)
        }
        self.origTransBtn.isSelected = !self.origTransBtn.isSelected
    }
}

extension AudioCell:UITextViewDelegate   {
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
//            self.textChanged?("")
        }
    }
}

extension AudioCell:FeedCallBackProtocol {
    
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
            let commentObj:Comment = Comment(original_body:body , body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:false, identifierStr:"")
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
                
                
                guard let respDict = res as? NSDictionary else {
                    return
                }
                
                guard let dataDict = respDict.value(forKey: "data") as? NSDictionary else {
                 return
                }
                
                let commentObj: Comment = Comment(dict: dataDict)
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true

                self.feedArray[self.indexValue.row] = feedObjUpdate
                self.updateTableClosure?(self.indexValue)
            }
        }
    }
}

extension AudioCell:XQAudioPlayerDelegate {
    func playerDidUpdateDurationTime(player: XQAudioPlayer, durationTime: CMTime) {
        
    }
    
    /* Player did change time playing
     * You can get current time play of audio in here
     */
    func playerDidUpdateCurrentTimePlaying(player: XQAudioPlayer, currentTime: CMTime) {
        
    }
    
    // Player begin start
    func playerDidStart(player: XQAudioPlayer) {
        
    }
    
    // Player stoped
    func playerDidStoped(player: XQAudioPlayer) {
        
    }
    
    // Player did finish playing
    func playerDidFinishPlaying(player: XQAudioPlayer) {
        
    }
}
