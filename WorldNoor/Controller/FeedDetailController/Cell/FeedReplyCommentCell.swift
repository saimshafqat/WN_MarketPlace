//
//  FeedReplyCommentCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/22/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
class FeedReplyCommentCell: FeedParentCell{
    
    @IBOutlet weak var commentImgHeightConst: NSLayoutConstraint!
    @IBOutlet weak var commentTimeLbl: UILabel!
    @IBOutlet weak var userImageView: DesignableImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UITextView!
    @IBOutlet weak var descNameView: UIView!
    @IBOutlet weak var postingLbl: UILabel!
    @IBOutlet weak var btnOriginal: UIButton!
    @IBOutlet weak var commentDescView: UIView!
    @IBOutlet weak var audioCommentHeightConst: NSLayoutConstraint!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var imgVideoView: UIView!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var descHeightConst: NSLayoutConstraint!
    @IBOutlet weak var likeCommentBtn: UIButton!
    @IBOutlet weak var likeCommentCounterBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var downloadPLbl: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var attachmentView:AttachmentView? = nil
    var mainIndex:IndexPath = IndexPath(row: 0, section: 0)
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    var commentObj:Comment? = nil
    var singleImageView:SingleImageView? = nil
    var videoView:VideoView? = nil
    var xqAudioPlayer: XQAudioPlayer!
    var feedObj:FeedData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
        
        self.btnOriginal.setTitle("View Original".localized(), for: .selected)
        self.btnOriginal.setTitle("View Translated".localized(), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func manageData(commentObj:Comment, mainIndex:IndexPath, currentIndex:IndexPath, feedObj:FeedData){
        self.feedObj = feedObj
        self.currentIndex = currentIndex
        self.mainIndex = mainIndex
        self.commentObj = commentObj
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.removeFromSuperview()
        }
        let authorObj:Author = commentObj.author!
        self.nameLbl.text = authorObj.firstname!+" "+authorObj.lastname!
        
        self.userImageView.loadImageWithPH(urlMain:authorObj.profileImage ?? "")
        
        self.labelRotateCell(viewMain: self.userImageView)
        self.postingLbl.isHidden = true
        if let isPosting:Bool = commentObj.isPostingNow {
            self.postingLbl.isHidden = isPosting
        }
        self.commentDescView.isHidden = false
        if self.postingLbl.isHidden {
            self.commentDescView.isHidden = false
        }else {
            self.commentDescView.isHidden = true
        }
        self.manageComment(commentObj: commentObj)
        self.manageLikeCounterOnFirstLoad()
        self.manageLikeDislikeCounter()
        
        
        self.labelRotateCell(viewMain: self.descriptionLbl)
        self.descriptionLbl.rotateForLanguage()
 
        
        
    }
    
    func manageLikeDislikeCounter() {
        let dict:NSMutableDictionary =  FeedDetailCallbackManager.shared.manageCommentCount(commentObj:self.commentObj!)
        self.likeCommentCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .normal)
        self.likeCommentCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .selected)

    }
    
    func manageLikeCounterOnFirstLoad(){
        var strImageLiked = "NewIconLikeU"
        self.likeCommentBtn.isSelected = false
        if self.commentObj!.isLiked != nil {
            if self.commentObj!.isLiked! {
                strImageLiked = "NewIconLiked"
                self.likeCommentBtn.isSelected = true
            }
        }
        if self.commentObj!.isDisliked != nil {
            if self.commentObj!.isDisliked! {
                self.likeCommentBtn.isSelected = false
            }
        }
        self.likeCommentBtn.setImage(UIImage(named: strImageLiked), for: .normal)
    }
    
    func manageComment(commentObj:Comment)  {
        self.commentImgHeightConst.constant = 0
        self.singleImageView?.removeFromSuperview()
        self.videoView?.removeFromSuperview()
        self.attachmentView?.removeFromSuperview()
        self.downloadPLbl.isHidden = true
        self.downloadBtn.isHidden = true
        self.manageDescTextView(commentObj: commentObj)
        self.commentTimeLbl.text = commentObj.commentTime
        self.audioCommentHeightConst.constant = 40
        if commentObj.audioUrl == nil || commentObj.audioUrl == "" {
            self.audioCommentHeightConst.constant = 1
        }else {
            self.audioCommentHeightConst.constant = 40
            self.audioConfigurations(audioURL: commentObj.audioUrl!)
        }
        self.manageCommentFile(commentObj: commentObj)
    }
    
    
    @IBAction func originalAction(sender : UIButton){
        if sender.isSelected {
            self.descriptionLbl.text = self.commentObj?.body!
        }else {
            if self.commentObj?.original_body == nil {
                self.descriptionLbl.text = "Loading..."
                self.getTranslation()
            }else if self.commentObj!.original_body?.count == 0 {
                self.descriptionLbl.text = "Loading..."
                self.getTranslation()
            }else if self.commentObj?.original_body == nil {
                self.descriptionLbl.text = self.commentObj?.body!
            }else {
                self.descriptionLbl.text = self.commentObj?.original_body!
            }
            
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func getTranslation(){
        self.btnOriginal.isHidden = true
        var parameters = ["action": "comment/translation/" + String(self.commentObj!.commentID!)]
        RequestManager.fetchDataGet(Completion: { response in
            self.btnOriginal.isHidden = false
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                }else if res is String {
                }else {
                    if let dataMain = res as? [String : Any] {
                    }else if let dataMain = res as? [[String : Any]] {
                        
                        let mainData = dataMain[0]
                        if let stringValue = mainData["body"] as? String{
                            self.commentObj?.original_body = stringValue
                            if self.btnOriginal.isSelected {
                                self.descriptionLbl.text = self.commentObj!.original_body
                            }else {
                                self.descriptionLbl.text = self.commentObj!.body
                            }
                            let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text ?? "")
                            self.descriptionLbl.textAlignment = NSTextAlignment.left
                            if langDirection == "right" {
                                self.descriptionLbl.textAlignment = NSTextAlignment.right
                            }
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
    func manageDescTextView(commentObj:Comment) {
        self.descriptionLbl.text = commentObj.body!
        let descText = self.descriptionLbl.text.trimmingCharacters(in: .whitespaces)
        if descText != "" {
            if self.descriptionLbl.text != nil {
                let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text!) ?? "left"
                (langDirection == "right") ? (self.descriptionLbl.textAlignment = NSTextAlignment.right): (self.descriptionLbl.textAlignment = NSTextAlignment.left)
                let langCode = SharedManager.shared.detectedLangaugeCode(for: self.descriptionLbl.text!)
                if langCode == "ar" {
                    self.descriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.descriptionLbl.font!.pointSize)
                }else {
                    self.descriptionLbl.font = UIFont.systemFont(ofSize: self.descriptionLbl.font!.pointSize)
                }
            }
            let someHeight = self.descriptionLbl.getHeightFrame(self.descriptionLbl).height
            self.descHeightConst.constant = someHeight
        }else {
            self.descHeightConst.constant = 0
        }
    }
    
    func manageCommentFile(commentObj:Comment){
        if let commentFileObj = commentObj.commentFile {
            if commentFileObj.count > 0 {
                if commentObj.commentFile?.count == 1 {
                    let commentFileObj = commentObj.commentFile![0]
                    if commentFileObj.fileType == "image" {
                        self.addImageViewFunc(commentFObj: commentFileObj)
                    }else if commentFileObj.fileType == "video" {
                        self.addVideoView(commentFObj: commentFileObj)
                    }else if commentFileObj.fileType == "audio"{
                        if let audioStr = commentFileObj.orignalUrl{
                            self.audioCommentHeightConst.constant = 40
                            self.audioConfigurations(audioURL: audioStr)
                        }
                    }else if commentFileObj.fileType == "attachment"{
                        self.addAttachmentView(commentFObj: commentFileObj)
                    }
                }
            }
        }
    }
    
    func addAttachmentView(commentFObj:CommentFile) {
        self.attachmentView = Bundle.main.loadNibNamed(Const.KAttachmentView, owner: self, options: nil)?.first as? AttachmentView
        self.commentImgHeightConst.constant = 115
        self.attachmentView?.frame = CGRect(x: 0, y: 0, width: self.imgVideoView.frame.size.width, height: self.imgVideoView.frame.size.height)
        self.attachmentView?.manageaAttachment(commentFileObj:commentFObj)
        self.imgVideoView.addSubview(self.attachmentView!)
        self.attachmentView!.btnDownload.addTarget(self, action: #selector(self.downloadAttachment), for: .touchUpInside)
    }
    
    @objc func downloadAttachment(sender : UIButton){
        let commentCount:Int = (self.feedObj?.comments!.count)! - 1
        let commentObj:Comment = self.feedObj!.comments![commentCount]
        if let commentFileObj = commentObj.commentFile {
            if commentFileObj.count > 0 {
                if commentObj.commentFile?.count == 1 {
                    let commentFileObj = commentObj.commentFile![0]
                    FeedDetailCallbackManager.shared.commentFileDownloadHandler?(commentFileObj)
                }
            }
        }
        
    }
    
    func addImageViewFunc(commentFObj:CommentFile) {
        self.singleImageView = (Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView)
        self.singleImageView?.manageImageDataForFeedComment(commentFileObj: commentFObj)
        self.imgVideoView.addSubview(self.singleImageView!)
        self.commentImgHeightConst.constant = 140
        self.singleImageView?.frame = CGRect(x: 0, y: 0, width: self.imgVideoView.frame.size.width, height: self.imgVideoView.frame.size.height)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.singleImageView?.isUserInteractionEnabled = true
        self.singleImageView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        FeedDetailCallbackManager.shared.commentImageTappedHandler?(self.mainIndex, self.currentIndex)
    }
    
    func addVideoView(commentFObj:CommentFile) {
        self.videoView?.removeFromSuperview()
        self.videoView = (Bundle.main.loadNibNamed(Const.VideoView, owner: self, options: nil)?.first as! VideoView)
        self.imgVideoView.addSubview(self.videoView!)
        self.videoView?.manageVideoDataComment(comment: commentFObj, shouldPlay: true)
        self.commentImgHeightConst.constant = 140
        self.videoView?.frame =  CGRect(x: 0, y: 0, width: self.imgVideoView.frame.size.width, height: self.imgVideoView.frame.size.height)
        self.manageVideo()

    }
    
    func audioConfigurations(audioURL: String) {
       
        self.xqAudioPlayer.translatesAutoresizingMaskIntoConstraints = false
        self.audioView.addSubview(self.xqAudioPlayer)
        self.xqAudioPlayer.audioBgOvalView.cornerRadius = 22
        self.xqAudioPlayer.topAnchor.constraint(equalTo: self.audioView.topAnchor, constant: 0).isActive = true
        self.xqAudioPlayer.bottomAnchor.constraint(equalTo: self.audioView.bottomAnchor, constant: 0).isActive = true
        self.xqAudioPlayer.leadingAnchor.constraint(equalTo: self.audioView.leadingAnchor, constant: 0).isActive = true
        self.xqAudioPlayer.trailingAnchor.constraint(equalTo: self.audioView.trailingAnchor, constant: 0).isActive = true
        self.xqAudioPlayer.config(urlString: audioURL )
        self.xqAudioPlayer.audioBgOvalView.backgroundColor = UIColor.playerBgGray
        self.xqAudioPlayer.progressColor = UIColor.progressSliderColor
        self.xqAudioPlayer.progressBackgroundColor = UIColor.white
        self.xqAudioPlayer.playingImage = UIImage(named:"icon_playing")
        self.xqAudioPlayer.pauseImage = UIImage(named:"icon_pause")
        self.xqAudioPlayer.delegate = self
    }
    
    @IBAction func speakerBtnClicked(_ sender: Any) {
        if self.speakerBtn.isSelected {
            SpeechManager.shared.stopSpeaking()
        }
        else {
            SpeechManager.shared.textToSpeech(message: (self.commentObj?.body)!)
        }
        self.speakerBtn.isSelected = !self.speakerBtn.isSelected
//        SpeechManager.shared.isAppearFrom = "FeedDetail"
        FeedDetailCallbackManager.shared.speakerHandlerFeedDetail = {[weak self] (indexPath) in
            self?.speakerBtn.isSelected = false
        }
    }
    
    // MARK: Action Buttons.
    @IBAction func likeBtnClicked(_ sender: Any) {
        
        var likeImage = "NewIconLiked"
        if self.likeCommentBtn.isSelected {
            likeImage = "NewIconLikeU"
            self.likeCommentBtn.isSelected = false
        }
        else {
            self.likeCommentBtn.isSelected = true
        }
        self.likeCommentBtn.setImage(UIImage(named: likeImage), for: .normal)
        
        FeedDetailCallbackManager.shared.handlingLikeDislike(isLike: true, value: self.likeCommentBtn.isSelected, commentObj:self.commentObj!, commentIndex: self.currentIndex)
        self.manageLikeDislikeCounter()
        self.feedObj?.comments![self.mainIndex.row].replies![self.currentIndex.row] = self.commentObj!
        let parameters = ["action": "comment/like_dislike","token": SharedManager.shared.userToken(), "type": "simple_like", "comment_id":String(self.commentObj!.commentID!)]
        self.callingService(parameters: parameters)
    }
    
    @IBAction func disLikeBtnClicked(_ sender: Any) {

    }
    
    func callingService(parameters:[String:String]) {
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                LogClass.debugLog("")
            }
        }, param: parameters)
    }
    
    @IBAction func dropDownReportingSheetComment(sender:UIButton){
        FeedDetailCallbackManager.shared.commentReplySheetHandler?(self.mainIndex, self.currentIndex)
    }
    
    @IBAction func commentLikeCounterBtn(sender:UIButton)   {
        
        let replyIndex = IndexPath(row: sender.tag, section: 0)
        FeedDetailCallbackManager.shared.replyLikeCounterHandler?(self.mainIndex, self.currentIndex)
    }
    
    @IBAction func commentDisLikeCounterBtn(sender:UIButton)   {
        FeedDetailCallbackManager.shared.replyDisLikeCounterHandler?(self.mainIndex, self.currentIndex)
    }
    
    @IBAction func replyBtnClicked(_ sender: Any) {
        FeedDetailCallbackManager.shared.replyBtnClickedHandler?(self.mainIndex, self.currentIndex)
    }
}

extension FeedReplyCommentCell:XQAudioPlayerDelegate {
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

// Handling Video Downloads...
extension FeedReplyCommentCell {
    
    func manageVideo()  {
        let commentFileObj = self.commentObj?.commentFile![0]
        if ((commentFileObj?.url?.isValidForUrl())!) {
            self.manageDownloadHandler(id: (commentFileObj?.commentID!)!)
        }
    }
    
    func manageDownloadHandler(id:Int){
        self.downloadBtn.isHidden = false
        if let downloadObj = FeedCallBManager.shared.feedDownloadDict[id] {
            if downloadObj.progressStatus == "downloading" {
                self.downloadBtn.isHidden = true
                self.downloadPLbl.isHidden = false
                downloadObj.downloadPLbl = self.downloadPLbl
            }else if downloadObj.progressStatus == "saved" {
                FeedCallBManager.shared.feedDownloadDict.removeValue(forKey: id)
                self.downloadBtn.isHidden = false
                self.downloadPLbl.isHidden = true
            }else {
                self.downloadBtn.isHidden = false
                self.downloadPLbl.isHidden = true
            }
        }
    }
    
    @IBAction func downloadBtnClicked(_ sender: Any) {
        var urlString:URL?
        if self.commentObj!.commentFile!.count > 0 {
            var commentFile:CommentFile?
            commentFile = self.commentObj!.commentFile![0]
            if (commentFile!.url?.isValidForUrl())! {
                urlString = URL(string: commentFile!.url!)
            }
            let downloadObj = DownloadFeedManager.init()
            downloadObj.startDownload(downloadUrl: urlString!)
            FeedCallBManager.shared.feedDownloadDict[commentFile!.commentID!] = downloadObj
            DispatchQueue.main.async {
                downloadObj.downloadPLbl = self.downloadPLbl
                self.downloadBtn.isHidden = true
                self.downloadPLbl.isHidden = false
            }
        }
    }
}
