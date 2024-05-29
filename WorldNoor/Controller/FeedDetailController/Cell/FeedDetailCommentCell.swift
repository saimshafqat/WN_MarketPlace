//
//  FeedDetailCommentCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/22/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import ActiveLabel

class FeedDetailCommentCell: FeedParentCell {
    
    @IBOutlet weak var replyTableHConst: NSLayoutConstraint!
    @IBOutlet weak var topCst: NSLayoutConstraint!
    @IBOutlet weak var commentImgHeightConst: NSLayoutConstraint!
    @IBOutlet weak var descBottomToAudioView: NSLayoutConstraint!
    @IBOutlet weak var commentTimeLbl: UILabel!
    @IBOutlet weak var userImageView: DesignableImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: ActiveLabel!
    @IBOutlet weak var descNameView: UIView!
    @IBOutlet weak var postingLbl: UILabel!
    @IBOutlet weak var commentDescView: UIView!
    @IBOutlet weak var audioCommentHeightConst: NSLayoutConstraint!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var imgVideoView: UIView!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var likeCommentBtn: UIButton!
    @IBOutlet weak var likeCommentCounterBtn: UIButton!
    @IBOutlet weak var replyTableView: FeedBaseTableView!
    @IBOutlet weak var previousReplyBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentReplyBtn: UIButton!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var cellSeparationView: UIView!
    @IBOutlet weak var downloadPLbl: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var btnOriginal: UIButton!
    
    @IBOutlet var lblShowMore : UILabel!
    @IBOutlet var btnShowMore : UIButton!
    
    var isNextCommentExist:Bool = true
    var descLblWidth:CGFloat = 0.0
    var activityView: UIActivityIndicatorView!
    var prevCommentBtn:UIButton!
    var commentObj: Comment?
    var singleImageView:SingleImageView? = nil
    var attachmentView:AttachmentView? = nil
    var videoView:VideoView? = nil
    var xqAudioPlayer: XQAudioPlayer!
    var feedObj: FeedData?
    
    var parentview:UIViewController?
    var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    var cellDelegate: CommentHandlerDelegate?
    
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
    
    
    func manageData(commentObj: Comment, currentIndex: IndexPath, feedObj: FeedData) {
        self.topCst.constant = 0.0
        self.feedObj = feedObj
        self.currentIndex = currentIndex
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
            self.dropDownBtn.isUserInteractionEnabled = true
        }else {
            self.commentDescView.isHidden = true
            self.dropDownBtn.isUserInteractionEnabled = false
        }
        self.manageComment(commentObj: commentObj)
        self.manageLikeCounterOnFirstLoad()
        self.manageLikeDislikeCounter()
        self.manageTableView()
        
        
        self.labelRotateCell(viewMain: self.nameLbl)
        self.nameLbl.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.commentTimeLbl)
        self.commentTimeLbl.rotateForTextAligment()
        
        
        self.labelRotateCell(viewMain: self.descriptionLbl)
        self.descriptionLbl.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.postingLbl)
        self.postingLbl.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.likeCommentCounterBtn)
        self.likeCommentCounterBtn.rotateForTextAligment()
        
        self.labelRotateCell(viewMain: self.commentReplyBtn)
        self.commentReplyBtn.rotateForTextAligment()
        // handle show more or show less
        if (self.commentObj?.isExpand ?? false) {
            self.descriptionLbl.numberOfLines = 0
            btnShowMore.setTitle("Show less".localized(), for: .normal)
//            self.lblShowMore.text = "Show Less".localized()
        } else {
            self.descriptionLbl.numberOfLines = 3
            btnShowMore.setTitle("Show more".localized(), for: .normal)
//            self.lblShowMore.text = "Show More".localized()
            self.descriptionLbl.lineBreakMode = .byTruncatingTail
        }
        
        
        self.btnShowMore.isHidden = true
//        self.lblShowMore.isHidden = true
        self.descriptionLbl.sizeToFit()
        if self.descriptionLbl.text!.count > 0 {
            if self.descriptionLbl.isTruncated || (self.commentObj?.isExpand ?? false) {
                self.btnShowMore.isHidden = false
                self.lblShowMore.isHidden = false
            }
        }
    }
    
    func setArabicLang() {
        let langCode = SharedManager.shared.detectedLangaugeCode(for: self.descriptionLbl.text!)
        if langCode == "ar" {
            self.descriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.descriptionLbl.font!.pointSize)
        }else {
            self.descriptionLbl.font = UIFont.systemFont(ofSize: self.descriptionLbl.font!.pointSize)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.btnShowMore.isHidden = true
        self.lblShowMore.isHidden = true
    }
    
    @IBAction func originalAction(sender : UIButton) {
        
        if self.commentObj?.original_body == nil {
            self.descriptionLbl.text = "Loading..."
            self.getTranslation()
        } else if self.commentObj!.original_body?.count == 0 {
            self.descriptionLbl.text = "Loading..."
            self.getTranslation()
        } else {
            if sender.isSelected {
                self.descriptionLbl.text = self.commentObj?.body
            } else {
                self.descriptionLbl.text = self.commentObj?.original_body
            }
        }
        
        sender.isSelected = !sender.isSelected
        
        //
        let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text ?? "")
        self.descriptionLbl.textAlignment = NSTextAlignment.left
        if langDirection == "right" {
            self.descriptionLbl.textAlignment = NSTextAlignment.right
        }
        
        self.setArabicLang()
    }
    
    @IBAction func showMoreAction(_ sender: UIButton) {
        
        if let commentObj = (self.feedObj?.comments![currentIndex.row]) {
            self.feedObj?.comments?[currentIndex.row].isExpand = !(commentObj.isExpand)
            cellDelegate?.seeMoreTapped(feedData: feedObj!, indexPath: currentIndex)
        }
    }
    
    
    func getTranslation() {
        
        self.btnOriginal.isHidden = true
        var parameters = ["action": "comment/translation/" + String(self.commentObj!.commentID!)]
        
        RequestManager.fetchDataGet(Completion: { response in
            self.btnOriginal.isHidden = false
            switch response {
            case .failure(let error):
                
                
                if error is String {
                    //                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
                }
            case .success(let res):
                LogClass.debugLog(res)
                
                if res is Int {
                } else if res is String {
                } else {
                    if let dataMain = res as? [String : Any] {
                    } else if let dataMain = res as? [[String : Any]] {
                        
                        let mainData = dataMain[0]
                        if let stringValue = mainData["body"] as? String{
                            self.commentObj?.original_body = stringValue
                            if self.btnOriginal.isSelected {
                                self.descriptionLbl.text = self.commentObj!.original_body
                            } else {
                                self.descriptionLbl.text = self.commentObj!.body
                            }
                            let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text ?? "")
                            self.descriptionLbl.textAlignment = NSTextAlignment.left
                            if langDirection == "right" {
                                self.descriptionLbl.textAlignment = NSTextAlignment.right
                            }
                            
                            self.setArabicLang()
                        }
                    }
                }
            }
        }, param:parameters)
        
        
    }
    
    
    func manageTableView()  {
        self.replyTableView.reloadData()
        self.cellSeparationView.isHidden = false
        if (self.commentObj?.replies) != nil    {
            if (self.commentObj?.replies!.count)! > 0  {
                self.cellSeparationView.isHidden = true
            }
        }
        self.calculateHeight()
    }
    
    func manageLikeDislikeCounter() {
        let dict:NSMutableDictionary =  FeedDetailCallbackManager.shared.manageCommentCount(commentObj:self.commentObj!)
        self.likeCommentCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .normal)
        self.likeCommentCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .selected)
    }
    
    func manageLikeCounterOnFirstLoad(){
        self.likeCommentBtn.isSelected = false
        if self.commentObj!.isLiked != nil {
            if self.commentObj!.isLiked! {
                self.likeCommentBtn.isSelected = true
            }
        }
        if self.commentObj!.isDisliked != nil {
            if self.commentObj!.isDisliked! {
                self.likeCommentBtn.isSelected = false
            }
        }
    }
    
    func manageComment(commentObj:Comment)  {
        self.commentImgHeightConst.constant = 0
        self.singleImageView?.removeFromSuperview()
        self.attachmentView?.removeFromSuperview()
        
        self.videoView?.removeFromSuperview()
        self.descriptionLbl.text = commentObj.body!
        self.downloadPLbl.isHidden = true
        self.downloadBtn.isHidden = true
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
        self.audioCommentHeightConst.constant = 1
        self.attachmentView = Bundle.main.loadNibNamed(Const.KAttachmentView, owner: self, options: nil)?.first as? AttachmentView
        self.imgVideoView.addSubview(self.attachmentView!)
        self.commentImgHeightConst.constant = 100
        self.attachmentView?.frame = CGRect(x: 0, y: 0, width: self.imgVideoView.frame.size.width, height: self.imgVideoView.frame.size.height)
        self.attachmentView?.manageaAttachment(commentFileObj:commentFObj)
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        FeedCallBManager.shared.commentImageTappedDetailHandler?(self.currentIndex)
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
        self.topCst.constant = 50.0
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
        if self.likeCommentBtn.isSelected {
            self.likeCommentBtn.isSelected = false
        }else {
            self.likeCommentBtn.isSelected = true
        }
        FeedDetailCallbackManager.shared.handlingLikeDislike(isLike: true, value: self.likeCommentBtn.isSelected, commentObj:self.commentObj!, commentIndex: self.currentIndex)
        self.manageLikeDislikeCounter()
        self.feedObj?.comments![self.currentIndex.row] = self.commentObj!
        let parameters = ["action": "comment/like_dislike","token": SharedManager.shared.userToken(), "type": "simple_like", "comment_id":String(self.commentObj!.commentID!)]
        self.callingService(parameters: parameters)
    }
    
    @IBAction func disLikeBtnClicked(_ sender: Any) {
        
    }
    
    func callingService(parameters:[String:String], action:String = "") {
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if action == "getComments" {
                    if let dictArray = res as? [NSDictionary] {
                        self.manageLoadMoreComments(dataArray: dictArray)
                    }else {
                        self.isNextCommentExist = false
                        self.replyTableView.reloadData()
                    }
                }
            }
        }, param: parameters)
    }
}

extension FeedDetailCommentCell:XQAudioPlayerDelegate {
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

extension FeedDetailCommentCell:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.commentObj?.replies) != nil    {
            return (self.commentObj?.replies!.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let commentObj:Comment = (self.commentObj?.replies![indexPath.row])!
        if let cell = tableView.dequeueReusableCell(withIdentifier: FeedReplyCommentCell.identifier, for: indexPath) as? FeedReplyCommentCell {
            cell.manageData(commentObj: commentObj,
                            mainIndex: self.currentIndex,
                            currentIndex:indexPath,
                            feedObj: self.feedObj!)
            cell.dropDownBtn.tag = indexPath.row
            cell.likeCommentCounterBtn.tag = indexPath.row
            self.descLblWidth = cell.descriptionLbl.frame.size.width
            cell.btnUserProfile.tag = indexPath.row
            cell.btnUserProfile.addTarget(self, action: #selector(self.openProfileActionInner), for: .touchUpInside)
            cell.layoutIfNeeded()
            return cell
        }
        return UITableViewCell()
    }
    
    
    @objc func openProfileActionInner(sender : UIButton){
        let commentObj:Comment = (self.commentObj?.replies![sender.tag])!
        
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = String(commentObj.userID!)
        vcProfile.otherUserisFriend = "1"
        vcProfile.isNavPushAllow = true
        self.parentview?.navigationController!.pushViewController(vcProfile, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.commentObj?.replies) != nil    {
            if self.commentObj!.replyCount! >= 3 && self.isNextCommentExist {
                if self.commentObj?.replyCount == self.commentObj?.replies?.count {
                    self.isNextCommentExist = false
                    return 0
                }
                return 35
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        //      headerView.backgroundColor = UIColor.themeBlueColor
        self.prevCommentBtn = UIButton()
        self.activityView = UIActivityIndicatorView()
        prevCommentBtn.frame = CGRect(x: 5, y: 0, width: headerView.frame.width-10, height: headerView.frame.height)
        prevCommentBtn.setTitle("View Previous replies...".localized(), for: .normal)
        prevCommentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        prevCommentBtn.contentHorizontalAlignment = .left
        prevCommentBtn.setTitleColor(UIColor.black, for: .normal)
        prevCommentBtn.addTarget(self, action: #selector(previousRepliesBtn), for: .touchUpInside)
        headerView.addSubview(prevCommentBtn)
        headerView.addSubview(activityView)
        activityView.center = headerView.center
        activityView.isHidden = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateTableView(){
        DispatchQueue.main.async {
            //This code will run in the main thread:
            var frame = self.replyTableView.frame
            frame.size.height = self.replyTableView.contentSize.height
            self.replyTableView.frame = frame
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.commentObj!.replies != nil {
            if self.commentObj!.replies!.count > 0 {
                if indexPath.row > self.commentObj!.replies!.count-1 {
                    return
                }
                if cell is FeedReplyCommentCell {
                    let feedCell:FeedReplyCommentCell = cell as! FeedReplyCommentCell
                    if  let xqPlayer = feedCell.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    if let videoObj = feedCell.videoView {
                        if videoObj.playerController != nil {
                            videoObj.resetVideoPlayer()
                        }
                    }
                }
            }
        }
    }
    
    //Manage pagging
    @objc func previousRepliesBtn(_ sender: Any) {
        if  self.isNextCommentExist {
            let commentCurrentCount = self.feedObj?.comments?.count
            if commentCurrentCount! > 0 {
                self.prevCommentBtn.isHidden = true
                self.activityView.startAnimating()
                let commentObj:Comment = (self.commentObj!.replies![0])
                let parameters = ["action": "getComments","token": SharedManager.shared.userToken(), "starting_point_id":String(commentObj.commentID!), "post_id":String(self.feedObj!.postID!), "in_reply_to_id":String(self.commentObj!.commentID!)]
                self.callingService(parameters: parameters, action: "getComments")
            }
        }
    }
    
    func manageLoadMoreComments(dataArray:[NSDictionary]){
        self.activityView.stopAnimating()
        self.activityView.isHidden = true
        let orignalCommentArray:[Comment] = self.commentObj!.replies!
        var commentArray:[Comment] = []
        for dict in dataArray {
            let commentObj:Comment = Comment(dict: dict)
            commentArray.append(commentObj)
        }
        commentArray.append(contentsOf: orignalCommentArray)
        self.feedObj?.comments![self.currentIndex.row].replies = commentArray
        self.commentObj?.replies = commentArray
        if dataArray.count < 5 {
            self.isNextCommentExist = false
        }
        self.replyTableView.reloadData()
        FeedDetailCallbackManager.shared.refreshReplyHandler?(self.currentIndex)
    }
    
    func calculateHeight()  {
        let textView = UITextView()
        textView.font = UIFont(name: "HelveticaNeue", size: 14)!
        textView.frame = CGRect(x: 0, y: 0, width: self.descLblWidth, height: 10)
        
        var replyH:CGFloat = 0.0
        if (self.commentObj?.replies) != nil    {
            for comment in self.commentObj!.replies! {
                textView.text = comment.body
                
                let textViewFont = UIFont(name: "HelveticaNeue", size: 14)!
                let tvWidth = descriptionLbl.frame.size.width
                var someHeight = textView.heightForText(comment.body ?? "", font: textViewFont, width: self.descLblWidth)
                
                if textView.text == "" {
                    someHeight = 0
                }
                replyH = getTableCellWidgetsHeigh() + replyH + someHeight
                if comment.audioUrl == nil || comment.audioUrl == "" {
                    replyH = replyH + 1
                }else {
                    replyH = replyH + 40
                }
                if let commentFileObj = comment.commentFile {
                    if commentFileObj.count > 0 {
                        replyH = replyH + 140
                    }
                }
            }
            
            if self.commentObj!.replyCount! >= 3 {
                if self.commentObj?.replyCount != self.commentObj?.replies?.count {
                    replyH = replyH + 37 + 10
                }
            }
            
            self.replyTableHConst.constant = replyH
            self.layoutIfNeeded()
        }
    }
    
    func getCellHeight(forRowAt indexPath: IndexPath) -> CGFloat? {
        guard let cell = replyTableView.cellForRow(at: indexPath) else {
            return nil
        }
        return cell.frame.height
    }
    
    private func getTableCellWidgetsHeigh() -> CGFloat {
        let topSpace = 5
        let contentViewHeight = 100
        let spaceBetweenItems = 10
        let widgetsControlHeight = 37
        let bottomSpace = 20
        
        let finalHeight = topSpace + Int(contentViewHeight) + spaceBetweenItems + widgetsControlHeight + bottomSpace
        return CGFloat(finalHeight)
    }
}

// Handling Video Downloads...
extension FeedDetailCommentCell {
    
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
