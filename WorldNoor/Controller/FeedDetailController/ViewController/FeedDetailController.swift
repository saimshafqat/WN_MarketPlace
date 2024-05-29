//
//  FeedDetailController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage
import CommonKeyboard
//import IQKeyboardManagerSwift
import FittedSheets
import TLPhotoPicker
import Photos
import MediaPlayer
protocol ReflectPostDetailUpdateDelegate: AnyObject {
    func didReceiveNewDataFromPostDetail(feedData: FeedData, at indexPath: IndexPath)
}
protocol CommentHandlerDelegate {
    func handlingInstantCommentCallback(body:String, identifier:String, fileType:String, selectLang:Bool, videoUrl:String, isPosting:Bool)
    func handlingCommentCallback(res: NSDictionary)
    func seeMoreTapped(feedData: FeedData, indexPath: IndexPath)
}

class FeedDetailController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    var updateTableFromFeed:((IndexPath)->())?
    var feedDeletedFromDetailHandler:((IndexPath)->())?
    var feedHideAllFromDetailHandler:((IndexPath)->())?
    var commentDeletedFromDetailHandler:((IndexPath)->())?
    var indexPath:IndexPath? = nil
    var selectedIndexPath:IndexPath? = nil
    var feedArray:[FeedData] = []
    var feedObj: FeedData!
    var isTextInEditin:Bool = false
    let keyboardObserver = CommonKeyboardObserver()
    var audioRecorderObj:AudioRecorder? = nil
    var isNextCommentExist:Bool = true
    var selectedAssets = [PostCollectionViewObject]()
    var sheetController = SheetViewController()
    var videoView:VideoView?
    var videoViewToUpload:VideoView?
    var galleryView:GalleryView?
    var sharedView:SharedView?
    var editCommentObj:Comment?
    var selectedLangModel:LanguageModel?
    var isCommentCamera:Bool = true
    var isCommentReply:Bool = false
    var isReplyEdit:Bool = false
    var isAudioOrVideo:Bool = false
    var urlHash:String = ""
    var inReplyID:Int?
    var selectedReplyIndex:Int?
    var selectedCommentIndex:Int?
    var selectedCommentReplyIndex:Int?
    var feedUploadObj:FeedUpload? = nil
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    @IBOutlet weak var feedHeaderView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet var cstLeadinglbl : NSLayoutConstraint?
    @IBOutlet weak var feedDetailTableView: UITableView!
    @IBOutlet weak var feedContianerView: UIView!
    @IBOutlet weak var footerHeaderView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    //    @IBOutlet weak var DislikeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var editCommentView: UIView!
    
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var feedTableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioRecorderViewHConst: NSLayoutConstraint!
    @IBOutlet weak var feedCustomHeightConst: NSLayoutConstraint!
    @IBOutlet weak var commentEditViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var commetDropDownTrailingConst: NSLayoutConstraint!
    @IBOutlet weak var uploadViewBottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var prevCommentBtn: UIButton!
    @IBOutlet weak var commentGifBrowseBtn: UIButton!
    @IBOutlet weak var commentCameraBtn: UIButton!
    @IBOutlet weak var commentDropDownView: UIView!
    @IBOutlet weak var commentRecordBtn: UIButton!
    @IBOutlet weak var commentAttachmentBtn: UIButton!
    
    @IBOutlet weak var audioOptionView: UIView!
    @IBOutlet weak var playAudioBtn: UIButton!
    @IBOutlet weak var stopAudioBtn: UIButton!
    @IBOutlet weak var cancelAudioBtn: UIButton!
    //@IBOutlet weak var audioPlayerView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var commentPlayerTimeLbl: UILabel!
    @IBOutlet weak var audioTimerLbl: UILabel!
    @IBOutlet weak var prevAI: UIActivityIndicatorView!
    
    @IBOutlet var imgViewlikeSecond : UIImageView!
    @IBOutlet var imgViewlikeFirst : UIImageView!
    
    @IBOutlet weak var prevCommentHConst: NSLayoutConstraint!
    @IBOutlet weak var likeCounterBtn: UIButton!
    @IBOutlet weak var commentCounterBtn: UIButton!
    
    @IBOutlet weak var lbllikeCounter: UILabel!
    @IBOutlet weak var lblcommentCounter: UILabel!
    
    @IBOutlet weak var viewlike: UIImageView!
    
    
    @IBOutlet weak var shareCounterBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var uploadingView: FeedDetailUploadView!
    @IBOutlet weak var prevCommentView: UIView!
    @IBOutlet weak var editDescLbl: UILabel!
    @IBOutlet weak var audioLangBtn: UIButton!
    @IBOutlet weak var downloadPLbl: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    var pageNumber:Int = 0
    
    let viewModel = FeedDetailViewModel()
    var commentOptionState = -1
    var musicPlayer:MPMediaPickerController?
    var audioLbl:UILabel?
    var audioOrigBtn:UIButton?
    var xqAudioPlayer: XQAudioPlayer!
    
    var delegate: FeedsDelegate?
    var postDetailDelegate : ReflectPostDetailUpdateDelegate?
    var audioFileURLStr = ""
    
    var feedVideoWidth = Int()
    var feedVideoHeight = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.getDetail()
        self.manageUI()
        self.manageAudioRecorder()
        
        addLongPressGesture()
    }
    func didTapHashtag(_ hashtag: String) {
           let tagSection = HashTagVC.instantiate(fromAppStoryboard: .Shared)
           tagSection.Hashtags = hashtag
           navigationController?.pushViewController(tagSection, animated: true)
       }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let header = feedDetailTableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SharedManager.shared.postCreatedReload = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        commentTextView.delegate = self
        self.commentTextView.text = Const.textViewPlaceholder.localized()
        if self.feedObj!.commentCount! == 0{
            lblcommentCounter.text = ""
        }
        else{
            lblcommentCounter.text = String(self.feedObj!.commentCount!)
        }
        
        
        self.commentTextView.rotateForLanguage()
        self.feedDetailTableView.rotateViewForLanguage()
        
        self.view.labelRotateCell(viewMain: self.feedHeaderView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.commentDataUpdated),name: NSNotification.Name(Const.KCommentUpdatedNotif),object: nil)
        SocketSharedManager.sharedSocket.commentDelegate = self
        if SharedManager.shared.isNewPostExist {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.manageCallBackHandler()
        self.manageReplyHandler()
        if SharedManager.shared.isFromReply {
                    commentTextView.becomeFirstResponder()
            commentTextView.text = ""
            self.commentTextView.textColor = .black
                }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    func getDetail(){
        
        self.imgViewlikeFirst.image = UIImage.init(named: "NewIconLiked")
        self.imgViewlikeSecond.isHidden = true
        
        var parameters = ["action": "post/get-single-newsfeed-item/" + String(self.feedObj!.postID!) ,"token":SharedManager.shared.userToken() , "hash" : String(self.urlHash)]
        
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedSingleModel), Error>) in
            
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                        
                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                    
                }else {
                }
                
            case .success(let res):
                self.handleFeedResponse(feedObj: res)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj:FeedSingleModel){
        let isSaved = self.feedObj?.isSaved
        self.feedObj = feedObj.data?.post
        self.feedObj?.isSaved = isSaved ?? false
        if self.feedObj!.commentCount! == 0{
            lblcommentCounter.text = ""
        }
        else{
            lblcommentCounter.text = String(self.feedObj!.commentCount!)
        }
        
        self.manageUI()
        self.manageAudioRecorder()
        
        
        
        self.feedDetailTableView.setAndLayoutTableHeaderView(header: self.feedHeaderView)
        self.feedDetailTableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        SharedManager.shared.isFromReply = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Const.KCommentUpdatedNotif), object: nil)
        
        if  self.isMovingToParent {
            
        }
        if self.isBeingDismissed {
            
        }
        if  self.isMovingFromParent {
            self.resetAllTheOptions()
        }
    }
    
    func manageUI() {
        
        self.downloadPLbl.isHidden = true
        self.downloadBtn.isHidden = true
        self.manageLikeCounterOnFirstLoad()
        self.manageTable()
        self.manageKeyboard()
        self.manageTextView()
        //       self.feedTableBottomConstraint.constant = 130
        self.manageLikeDislikeCounter()
        self.prevAI.isHidden = true
        if (self.feedObj?.comments!.count)! < 3 {
            self.prevCommentHConst.constant = 0
            self.prevCommentView.isHidden = true
        } else {
            self.prevCommentHConst.constant = 30
            self.prevCommentView.isHidden = false
        }
        self.manageVideo()
        
        self.feedDetailTableView.reloadData()
    }
    
    @IBAction func closeUploadingVIewBtn(_ sender: Any) {
        self.uploadingView.isHidden = true
        self.videoViewToUpload?.removeFromSuperview()
        self.cameraBtn.isEnabled = true
        self.galleryBtn.isEnabled = true
        self.micBtn.isEnabled = true
        self.commentAttachmentBtn.isEnabled = true
        self.selectedLangModel = nil
        self.feedUploadObj = nil
        self.commentTextView.text = ""
        self.commentTextView.resignFirstResponder()
        
    }
    
    
    
    
    
    func manageLikeDislikeCounter(){
        self.cstLeadinglbl?.constant = 5
        let dict:NSMutableDictionary =  self.viewModel.manageCount(feedObj:self.feedObj!)
        self.likeCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .normal)
        self.likeCounterBtn.setTitle(dict.value(forKey: "like") as? String, for: .selected)
        if self.feedObj.likeCount ?? 0 == 1 && self.feedObj.isLiked == true {
            lbllikeCounter.text = "You"
        }
        else if self.feedObj.likeCount ?? 0 > 1 && self.feedObj.isLiked == true{
            let selfLikedCount = (self.feedObj.likeCount ?? 0) - 1
            lbllikeCounter.text = "You and \(selfLikedCount) others"
        }
        else{
            if feedObj.likeCount == 0 {
                lbllikeCounter.text = ""
            }
            else{
                lbllikeCounter.text = "\(feedObj.likeCount ?? 0)"
            }
            
        }
        
        
        self.commentCounterBtn.setTitle(dict["comment"] as? String, for: .normal)
        self.commentCounterBtn.setTitle(dict["comment"] as? String, for: .selected)
        self.shareCounterBtn.setTitle(dict["share"] as? String, for: .normal)
        self.shareCounterBtn.setTitle(dict["share"] as? String, for: .selected)
        
        self.imgViewlikeSecond.isHidden = true
        
        if self.feedObj!.reationsTypesMobile != nil {
            if self.feedObj!.reationsTypesMobile!.count >  1 {
                
                self.cstLeadinglbl?.constant = 20
            }
            
            var strImage = "NewIconLikeU"
            if self.feedObj!.reationsTypesMobile!.count > 0 {
                strImage = "NewIconLiked"
                self.imgViewlikeFirst.image = UIImage.init(named: "Img" + String(self.feedObj!.reationsTypesMobile![0].type!) + ".png")
                if self.feedObj!.reationsTypesMobile!.count > 1 {
                    self.imgViewlikeSecond.image = UIImage.init(named: "Img" + String(self.feedObj!.reationsTypesMobile![1].type!) + ".png")
                    self.imgViewlikeSecond.isHidden = false
                }
            }
            else {
                self.imgViewlikeFirst.image = UIImage(named: strImage)
            }
        }
        
    }
    
    func manageFeedLikeDislikeSheet(){
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        pagerController.feedObj = self.feedObj
        pagerController.parentView = self
        let sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        sheetController.extendBackgroundBehindHandle = true
        self.present(sheetController, animated: false, completion: nil)
    }
    
    @IBAction func commentOptionBtnClicked(_ btn: UIButton) {
        var offset = 0
        if self.commentOptionState == btn.tag {
            if self.commentDropDownView.isHidden {
                self.commentDropDownView.isHidden = false
            }else {
                self.commentDropDownView.isHidden = true
            }
        }else {
            self.commentDropDownView.isHidden = false
        }
        if btn.tag == 0 {
            self.commentCameraBtn.isHidden = false
            self.commentGifBrowseBtn.isHidden = true
            self.commentRecordBtn.isHidden = true
        }else if btn.tag == 1 {
            self.commentCameraBtn.isHidden = true
            self.commentGifBrowseBtn.isHidden = false
            self.commentRecordBtn.isHidden = true
        }else if btn.tag == 2 {
            self.commentDropDownView.isHidden = true
            self.didPressDocumentShare()
        }else if btn.tag == 3 {
            offset = -30
            self.commentCameraBtn.isHidden = true
            self.commentGifBrowseBtn.isHidden = true
            self.commentRecordBtn.isHidden = false
        }
        
        //      self?.currentIndex = currentIndex
        let frame = btn.superview!.convert(btn.frame, to: self.view)
        self.commentDropDownView.frame = CGRect(x: frame.origin.x  + CGFloat(offset), y: frame.origin.y - self.commentDropDownView.frame.size.height + 7 , width: self.commentDropDownView.frame.size.width, height: self.commentDropDownView.frame.size.height)
        
        self.commentOptionState = btn.tag
    }
    
    @IBAction func dropDownBtnClicked(_ sender: Any) {
        self.isAudioOrVideo = true
        if (sender as! UIButton).tag == 0 {
            self.isAudioOrVideo = false
        }
        let langController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "LanguageSelectionController") as! LanguageSelectionController
        langController.delegate = self
        self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(500)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    func manageTextView(){

    }
    func resetAllTheOptions(){
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.resetXQPlayer()
        }
        if self.videoView != nil {
            self.videoView!.resetVideoPlayer()
        }
        if self.galleryView != nil {
            self.galleryView?.resetVisibleCellVideo()
        }
        if self.sharedView != nil {
            self.sharedView?.resetAllOption()
        }
        SpeechManager.shared.stopSpeaking()
        for cell in self.feedDetailTableView.visibleCells {
            if cell is FeedDetailCommentCell {
                let feedCell:FeedDetailCommentCell = cell as! FeedDetailCommentCell
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
    
    func manageTable(){
        self.feedDetailTableView.keyboardDismissMode = .interactive
        self.feedDetailTableView.rowHeight = UITableView.automaticDimension
        self.feedDetailTableView.tableHeaderView?.layoutIfNeeded()
        let postView = Bundle.main.loadNibNamed(Const.PostView, owner: self, options: nil)?.first as! PostView
        postView.backBtn.isHidden = false
        postView.delegate = self
        postView.backBtn.addTarget(self, action: #selector(self.postViewBackBtn), for: .touchUpInside)
        postView.frame = CGRect(x: 0, y: 0, width: self.headerView.frame.size.width, height: self.headerView.frame.size.height)
        self.headerView.addSubview(postView)
        postView.manageHeaderData(feedObj: self.feedObj!)
        postView.btnUserProfile.addTarget(self, action: #selector(self.OpenMainProfileAction), for: .touchUpInside)
        postView.dropDownPostBtn.addTarget(self, action: #selector(dropDownReportingSheet), for: .touchUpInside)
        switch self.feedObj?.postType! {
        case FeedType.post.rawValue:
            if self.feedContianerView != nil {
                self.feedContianerView.removeFromSuperview()
            }
            
            postView.bottomAnchor.constraint(equalTo: self.footerHeaderView.topAnchor, constant: 10).isActive = true
        case FeedType.audio.rawValue:
            self.xqAudioPlayer = SharedManager.shared.getAudioPlayerView()
            self.xqAudioPlayer.frame = CGRect(x: 30, y: 0, width: self.feedContianerView.frame.size.width-60, height:self.xqAudioPlayer.frame.size.height)
            self.feedContianerView.addSubview(self.xqAudioPlayer)
            self.audioLbl = UILabel()
            self.audioLbl!.font = UIFont.systemFont(ofSize: 13)
            self.audioLbl!.numberOfLines = 0
            self.audioLbl!.textAlignment = NSTextAlignment.left
            self.getAudioText(audioLbl: self.audioLbl!)
            self.audioLbl!.frame = CGRect(x: self.xqAudioPlayer.frame.origin.x+7, y: self.xqAudioPlayer.frame.origin.y+54, width: self.xqAudioPlayer.frame.size.width, height: SharedManager.shared.heightForView(text: self.audioLbl!.text!, font: self.audioLbl!.font, width: self.xqAudioPlayer.frame.size.width))
            let button = UIButton(frame: CGRect(x: self.xqAudioPlayer.frame.origin.x + 5, y: self.audioLbl!.frame.origin.y + self.audioLbl!.frame.size.height, width: 100, height: 30))
            button.backgroundColor = .clear
            button.setTitle("View Orignal".localized(), for: .normal)
            button.setTitle("View Translated".localized(), for: .selected)
            button.setTitleColor(.systemBlue, for: .normal)
            button.setTitleColor(.systemBlue, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.addTarget(self, action: #selector(viewOrigTranslatedAudio), for: .touchUpInside)
            self.audioOrigBtn = button
            self.feedCustomHeightConst.constant = self.xqAudioPlayer.frame.size.height+self.audioLbl!.frame.size.height + 20 + 40
            self.feedContianerView.addSubview(self.audioLbl!)
            self.feedContianerView.addSubview(button)
            self.audioXQConfiguration()
        case FeedType.video.rawValue, FeedType.liveStream.rawValue:
            self.feedCustomHeightConst.constant = 400
            let cellHeight = calculateHeight(originalDimensions: (CGFloat((self.feedObj.post?.first?.videoWidth)!), CGFloat((self.feedObj.post?.first?.videoHeight)!)), cellWidth:  UIScreen.main.bounds.width)
            if cellHeight != 0{
                self.feedCustomHeightConst.constant =  cellHeight + 60
            }
            let videoView = Bundle.main.loadNibNamed(Const.VideoView, owner: self, options: nil)?.first as! VideoView
            self.feedContianerView.addSubview(videoView)
            videoView.frame = CGRect(x: 0, y: 0, width: self.feedContianerView.frame.size.width, height: self.feedContianerView.frame.size.height)
            videoView.isAppearFrom = "FeedDetail"
            videoView.isPartOf = "FeedDetail"
            videoView.mainIndex = self.indexPath ?? IndexPath(row: 0, section: 0)
            videoView.manageVideoData(feedObj: self.feedObj!, shouldPlay: true)
            self.videoView = videoView
        case FeedType.image.rawValue:
            self.feedCustomHeightConst.constant = 400
            let cellHeight = calculateHeight(originalDimensions: (CGFloat((self.feedObj.post?.first?.videoWidth)!), CGFloat((self.feedObj.post?.first?.videoHeight)!)), cellWidth:  UIScreen.main.bounds.width)
            if cellHeight != 0{
                self.feedCustomHeightConst.constant =  cellHeight + 60
            }
            let singleImageView = Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView
            singleImageView.frame = CGRect(x: 0, y: 0, width: self.feedContianerView.frame.size.width, height: self.feedContianerView.frame.size.height)
            self.feedContianerView.addSubview(singleImageView)
            singleImageView.manageImageData(feedObj: self.feedObj!)
            
            
            singleImageView.rotateViewForLanguage()
        case FeedType.gallery.rawValue:
            self.feedCustomHeightConst.constant = 230
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.feedCustomHeightConst.constant = 400
            }
          
            let galleryView = Bundle.main.loadNibNamed(Const.KGalleryView, owner: self, options: nil)?.first as! GalleryView
            galleryView.collectionWidth = self.feedContianerView.frame.size.width
            galleryView.isAppearFrom = "FeedDetail"
            galleryView.currentIndexPath = self.indexPath!
            galleryView.manageGalleryData(feedObj: self.feedObj!)
            galleryView.frame = CGRect(x: 0, y: 0, width: self.feedContianerView.frame.size.width, height: self.feedContianerView.frame.size.height)
            self.feedContianerView.addSubview(galleryView)
            self.galleryView = galleryView
            self.galleryView!.delegate = self
        case FeedType.shared.rawValue:
            let sharedView = Bundle.main.loadNibNamed(Const.KSharedView, owner: self, options: nil)?.first as! SharedView
            sharedView.manageData(feedObj: self.feedObj!)
            let sharedHeight = sharedView.getHeightOfView()
            self.feedContianerView.addSubview(sharedView)
            sharedView.indexValue = self.indexPath!
            sharedView.frame = CGRect(x: 0, y: 0, width: self.feedContianerView.frame.size.width, height:  self.feedCustomHeightConst.constant)
            self.feedCustomHeightConst.constant = sharedHeight + 20
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.feedCustomHeightConst.constant = sharedView.frame.size.height + 150
            }
            self.sharedView = sharedView
        case FeedType.file.rawValue:
            self.feedCustomHeightConst.constant = 131
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                self.feedCustomHeightConst.constant = 231
            }
            let attachmentView = Bundle.main.loadNibNamed(Const.KAttachmentView, owner: self, options: nil)?.first as! AttachmentView
            attachmentView.frame = CGRect(x: 0, y: 0, width: self.feedContianerView.frame.size.width, height: self.feedContianerView.frame.size.height)
            attachmentView.reloadView(feedObj: self.feedObj!)
            attachmentView.btnDownload.addTarget(self, action: #selector(self.downloadAttachment), for: .touchUpInside)
            self.feedContianerView.addSubview(attachmentView)
        default:
            LogClass.debugLog("no value")
        }
        //self.feedDetailTableView.setAndLayoutTableHeaderView(header: self.feedHeaderView)
    }
    
    func calculateHeight(originalDimensions: (width: CGFloat, height: CGFloat), cellWidth: CGFloat) -> CGFloat {
        // Calculate the corresponding height based on the aspect ratio
        let aspectRatio = originalDimensions.width / cellWidth
        var calculatedHeight = originalDimensions.height / aspectRatio
        
        // Calculate 65% of screen height
        let maxHeight = UIScreen.main.bounds.height * 0.65
        if calculatedHeight > maxHeight {
            calculatedHeight = maxHeight
        }
        if calculatedHeight.isNaN {
                return 0
            }
        return calculatedHeight
    }
    
    @objc func viewOrigTranslatedAudio(sender: UIButton!) {
        self.xqAudioPlayer.resetXQPlayer()
        if sender.isSelected {
            self.manageAudioToggle(isOrig: false)
        }else {
            self.manageAudioToggle(isOrig: true)
        }
        sender.isSelected = !sender.isSelected
    }
    
    @objc func OpenMainProfileAction(sender : UIButton){
        
        
        let userID = String(feedObj.authorID!)
        
        if Int(userID) == SharedManager.shared.getUserID() {
            self.tabBarController?.selectedIndex = 3
        }else {
            let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            vcProfile.otherUserID = String(self.feedObj!.authorID!)
            vcProfile.otherUserisFriend = "1"
            vcProfile.isNavPushAllow = true
            self.navigationController?.pushViewController(vcProfile, animated: true)
        }
    }
    
    @objc func postViewBackBtn(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func manageLikeCounterOnFirstLoad(){
        
        if self.feedObj!.isReaction != nil {
            if self.feedObj!.isReaction!.count == 0 {
                self.likeBtn.isSelected = false
                self.viewlike.image = UIImage.init(named: "NewIconLikeU")
            }else {
                self.likeBtn.isSelected = true
                self.viewlike.image = UIImage.init(named: "Img" + self.feedObj!.isReaction! + ".png")
            }
        }else {
            self.likeBtn.isSelected = false
            self.viewlike.image = UIImage.init(named: "NewIconLikeU")
        }
        
       
    }
    
    func setTopLikeView(_ obj: FeedData) {
        imgViewlikeFirst.image = .newIconLikeU
        imgViewlikeSecond.isHidden = true
        //        cstLeadinglbl?.constant = 5
        if let reationsTypesMobile = obj.reationsTypesMobile, !reationsTypesMobile.isEmpty {
            if reationsTypesMobile.count > 1 {
                cstLeadinglbl?.constant = 20
            }
            if let firstReactionType = reationsTypesMobile.first?.type {
                imgViewlikeFirst.image = UIImage(named: "Img\(firstReactionType).png")
                if reationsTypesMobile.count > 1, let secondReactionType = reationsTypesMobile[1].type {
                    imgViewlikeSecond.image = UIImage(named: "Img\(secondReactionType).png")
                    imgViewlikeSecond.isHidden = false
                }
            }
        }
    }
    
    func manageKeyboard(){
        self.commentTextView.ignoredCommonKeyboard = true
        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            var bottom = 0.0
            if info.isShowing {
                bottom = Double(-info.visibleHeight)
                if #available(iOS 11, *) {
                    let guide = weakSelf.view.safeAreaInsets
                    bottom = bottom + Double(guide.bottom)
                }
            }
            UIView.animate(info, animations: { [weak self] in
                self?.commentEditViewBottomConstraint.constant = CGFloat(bottom)
                if self?.view != nil {
                    self?.view.layoutIfNeeded()
                }
            })
        }
    }
    
    
    func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        self.likeBtn.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizer.State.began {
            
            if self.feedObj.isReaction != nil {
                if self.feedObj.isReaction!.count > 0 {
                    self.dislikeLike()
                    return
                }
            }
            
            let viewReaction = Bundle.main.loadNibNamed("ReactionView",
                                                        owner: self,
                                                        options: nil)?.first as! ReactionView
            viewReaction.earlyUpdateReactionCompletion = {[weak self] reactionImg, index in
                guard let self else { return }
                feedObj.isReaction = SharedManager.shared.arrayGifType[index.row]
                
                var isFound = false
                if feedObj.reationsTypesMobile != nil {
                    if feedObj.reationsTypesMobile?.count ?? 0 > 0  {
                        for obj in 0..<(self.feedObj?.reationsTypesMobile?.count ?? 0) {
                            if self.feedObj?.reationsTypesMobile?[obj].type == SharedManager.shared.arrayGifType[index.row] {
                                isFound = true
                                self.feedObj?.reationsTypesMobile![obj].count = (self.feedObj?.reationsTypesMobile![obj].count ?? 0) + 1
                            }
                        }
                    }
                }
                
                if !isFound {
                    var newreaction = ReactionModel.init(countP: 1, typeP: SharedManager.shared.arrayGifType[index.row])
                    
                    if self.feedObj?.reationsTypesMobile != nil {
                        self.feedObj?.reationsTypesMobile!.append(newreaction)
                    } else {
                        self.feedObj?.reationsTypesMobile = [newreaction]
                    }
                }
                
                if self.feedObj?.likeCount == nil {
                    self.feedObj?.likeCount = 1
                } else {
                    self.feedObj?.likeCount! = 1 + (self.feedObj?.likeCount)!
                }
                self.likeBtn.isSelected = true
                self.feedObj.isLiked = true
                let selfLiked = (self.feedObj?.likeCount! ?? 0) - 1
                if self.feedObj?.likeCount ?? 0 == 1{
                    lbllikeCounter.text = "You"
                }
                else{
                    lbllikeCounter.text = "You and \(selfLiked) others"
                }
                //                self.likeHeadingLabel.isHidden = true
                viewlike.image = UIImage(named: "Img\(reactionImg).png")
                
                if feedObj.likeCount == 1 {
                    self.imgViewlikeFirst.image = UIImage(named: "Img\(reactionImg).png")
                } else {
                    if self.imgViewlikeFirst.image == UIImage(named: "Img\(reactionImg)") {
                        LogClass.debugLog("First Image already have")
                    } else if self.imgViewlikeSecond.image == UIImage(named: "Img\(reactionImg)") {
                        LogClass.debugLog("Second Image already have")
                        self.imgViewlikeSecond.isHidden = false
                    } else {
                        self.imgViewlikeSecond.isHidden = false
                        self.imgViewlikeSecond.image = UIImage(named: "Img\(reactionImg).png")
                    }
                }
                self.setTopLikeView(self.feedObj!)
                SharedManager.shared.popover.dismiss()
                self.updateNewsFeedOnAnyReaction()
            }
            viewReaction.feedObj = self.feedObj
            
            
            if (UIScreen.main.bounds.size.width - 40) < 360 {
                viewReaction.frame = CGRect.init(x: 0, y: 0, width: (UIScreen.main.bounds.size.width - 40), height: 30)
            } else {
                viewReaction.frame = CGRect.init(x: 0, y: 0, width: 360, height: 30)
            }
            
            SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
            SharedManager.shared.popover.show(viewReaction, fromView: self.likeBtn)
            viewReaction.delegateReaction = self
            
        }
    }
    
    // MARK: Action Buttons.
    @IBAction func likeBtnClicked(_ sender: Any) {
        
        likeBtn.isUserInteractionEnabled = false
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(self.feedObj!.postID!)
        
        var dic = [String : Any]()
        dic["likesCount"] = String(self.feedObj!.likeCount!)
        dic["group_id"] = String(self.feedObj!.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_like_NOTIFICATION"
        
        if self.likeBtn.isSelected {
            self.likeBtn.isSelected = false
            self.viewlike.image = UIImage.init(named: "NewIconLikeU")
            self.feedObj.isLiked = false
        } else {
            self.likeBtn.isSelected = true
            self.feedObj.isLiked = true
            SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
        }
        
        if self.feedObj!.isReaction != nil {
            if self.feedObj!.isReaction!.count > 0 {
                self.dislikeLike()
                return
            }
        }
        self.likePost()
    }
    
    func likePost() {
        if NetworkReachability.isConnectedToNetwork() {
            self.imgViewlikeFirst.image = UIImage(named: "Img\("like").png")
            self.imgViewlikeSecond.image = UIImage(named: "Img\("like").png")
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription)
            return
        }
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react", "token": userToken,
                          "type": SharedManager.shared.arrayGifType[6],
                          "post_id":String(self.feedObj!.postID!)]
        let apiResponseTimer = APIResponseTimer(startTime: .now())
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                let elapsedTime = apiResponseTimer.calculateElapsedTime()
                LogClass.debugLog("End Point (action:react) ==> Response Time  == \(elapsedTime)")
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self.likeBtn.isUserInteractionEnabled = true
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        } else {
                            
                            self.feedObj.isReaction = SharedManager.shared.arrayGifType[6]
                            
                            var isFound = false
                            
                            if self.feedObj.reationsTypesMobile != nil {
                                if self.feedObj.reationsTypesMobile!.count > 0  {
                                    for obj in 0..<self.feedObj.reationsTypesMobile!.count {
                                        if self.feedObj.reationsTypesMobile![obj].type == SharedManager.shared.arrayGifType[6] {
                                            isFound = true
                                            self.feedObj.reationsTypesMobile![obj].count! = self.feedObj.reationsTypesMobile![obj].count! + 1
                                        }
                                    }
                                }
                            }
                            
                            if !isFound {
                                var newreaction = ReactionModel.init(countP: 1,
                                                                     typeP: SharedManager.shared.arrayGifType[6])
                                
                                if self.feedObj.reationsTypesMobile != nil {
                                    self.feedObj.reationsTypesMobile!.append(newreaction)
                                } else {
                                    self.feedObj.reationsTypesMobile = [newreaction]
                                }
                            }
                            
                            if self.feedObj.likeCount == nil {
                                self.feedObj.likeCount = 1
                            } else {
                                self.feedObj.likeCount! = 1 + self.feedObj.likeCount!
                            }
                            
                            self.feedObj = self.feedObj
                            self.updateNewsFeedOnAnyReaction()
                            self.manageUI()
                        }
                        self.likeBtn.isUserInteractionEnabled = true
                    }
                }
            }, param:parameters)
        }
    }
    
    @IBAction func disLikeBtnClicked(_ sender: Any) {
        
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(self.feedObj!.postID!)
        
        var dic = [String : Any]()
        dic["likesCount"] = String(self.feedObj!.likeCount!)
        dic["group_id"] = String(self.feedObj!.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_dislike_NOTIFICATION"
        
        self.manageLikeDislikeCounter()
        self.feedArray[self.indexPath!.row] = self.feedObj!
        self.updateTableFromFeed?(self.indexPath!)
        var parameters = ["action": "react","token": SharedManager.shared.userToken(), "type": "dislike_simple_dislike", "post_id":String(self.feedObj!.postID!)]
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        } else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        self.callingService(parameters: parameters, action: "like")
    }
    
    func manageCallBackHandler(){
        
        FeedCallBManager.shared.feedDetailgalleryCellIndexCallbackHandler = { (galleryIndexPath, isShared) in
            self.galleryView?.resetVisibleCellVideo()
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            fullScreen.collectionArray = (self.feedObj?.post)!
            if isShared {
                fullScreen.collectionArray = (self.feedObj?.sharedData!.post)!
            }
            fullScreen.isInfoViewShow = false
            fullScreen.movedIndexpath=galleryIndexPath.row
            fullScreen.modalTransitionStyle = .crossDissolve
            self.present(fullScreen, animated: true, completion: nil)
        }
        
        FeedCallBManager.shared.commentImageTappedDetailHandler = { [weak self] (indexValue) in
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            fullScreen.typeOfImage = "comment"
            fullScreen.commentObj = (self?.feedObj!.comments![indexValue.row])!.commentFile![0]
            fullScreen.modalTransitionStyle = .crossDissolve
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        FeedCallBManager.shared.updateVideoViewSeekTimeForNewsFeedHandler = { [weak self] (feedIndex, currentIndex, seekTime) in
            let feedObjUpdate:FeedData = self!.feedArray[feedIndex.row]
            let postObj = feedObjUpdate.post![currentIndex.row]
            postObj.videoSeekTime = seekTime
            feedObjUpdate.post![currentIndex.row] = postObj
            self!.feedArray[feedIndex.row] = feedObjUpdate
        }
        
        
        FeedDetailCallbackManager.shared.FeedDetailPreviewLinkHandler = { (link) in
            if link != "" {
                if let url = URL(string:link), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
        
        
        FeedDetailCallbackManager.shared.commentFileDownloadHandler = { [weak self] (commentFile) in
            self?.downloadCommentAttachment(commentFile: commentFile)
        }
        
        
        FeedCallBManager.shared.galleryCellIndexCallbackHandler = { [weak self] (currentIndex, galleryIndexPath, isGroup) in
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            
            let feedObj:FeedData = (self?.feedObj)!
            fullScreen.collectionArray = feedObj.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = galleryIndexPath.row
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = currentIndex
            self?.present(fullScreen, animated: false, completion: nil)
        }
        
    }
    
    func manageReplyHandler()   {
        FeedDetailCallbackManager.shared.refreshReplyHandler = { [weak self] (commentIndex) in
            self?.feedDetailTableView.reloadRows(at: [commentIndex], with: .none)
        }
        FeedDetailCallbackManager.shared.replyBtnClickedHandler = { [weak self] (commentIndex, replyIndex) in
            let commentObj:Comment = (self?.feedObj!.comments![commentIndex.row])!
            let replyComment:Comment = commentObj.replies![replyIndex.row]
            self?.inReplyID = commentObj.commentID
            self?.selectedReplyIndex = commentIndex.row
            let authorName = (replyComment.author?.firstname ?? "")+" "+(replyComment.author?.lastname ?? "")
            self?.editDescLbl.text = "Replying to".localized() + " " + authorName
            self?.isCommentReply = true
            self?.editCommentView.isHidden = false
            self?.commentTextView.text = ""
            self?.commentTextView.becomeFirstResponder()
            self?.editCommentObj = nil
            self?.cameraBtn.isEnabled = true
            self?.galleryBtn.isEnabled = true
            self?.micBtn.isEnabled = true
            self!.uploadViewBottomConst.constant = 38
        }
        
        FeedDetailCallbackManager.shared.commentImageTappedHandler = { [weak self] (commentIndex, replyIndex) in
            let commentObj:Comment = (self?.feedObj!.comments![commentIndex.row])!
            let replyComment:Comment = commentObj.replies![replyIndex.row]
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            fullScreen.typeOfImage = "comment"
            fullScreen.commentObj = replyComment.commentFile![0]
            fullScreen.modalTransitionStyle = .crossDissolve
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        FeedDetailCallbackManager.shared.commentReplySheetHandler = { [weak self] (commentIndex, replyIndex) in
            self?.selectedCommentIndex = commentIndex.row
            self?.selectedCommentReplyIndex = replyIndex.row
            let commentObj:Comment = (self?.feedObj!.comments![commentIndex.row])!
            let replyComment:Comment = commentObj.replies![replyIndex.row]
            let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
            self?.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            reportController.delegate = self
            reportController.isReply = true
            reportController.reportType = "Comment"
            reportController.currentIndex = commentIndex
            reportController.feedObj = self?.feedObj
            reportController.commentObj = replyComment
            self?.editCommentObj = replyComment
            self?.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self?.sheetController.extendBackgroundBehindHandle = true
            self?.sheetController.topCornersRadius = 20
            self?.present(self!.sheetController, animated: false, completion: nil)
        }
        
        FeedDetailCallbackManager.shared.replyLikeCounterHandler = { [weak self] (commentIndex, replyIndex) in
            
        }
    }
    
    @IBAction func commentBtnClicked(_ sender: Any) {
        self.commentTextView.becomeFirstResponder()
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(self.feedObj!.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        self.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: true, completion: nil)
    }
    
    @IBAction func likeCounterBtnClicked(_ sender: Any) {
        if self.feedObj?.likeCount != 0 {
            self.manageFeedLikeDislikeSheet()
        }
    }
    
    @IBAction func disLikeCounterBtnClicked(_ sender: Any) {
        if self.feedObj?.simple_dislike_count != 0 {
            self.manageFeedLikeDislikeSheet()
        }
    }
    
    func manageUploadingData(uploadObj: FeedUpload)  {
        var body = self.commentTextView.text ?? ""
        if body == "Write your comment.".localized() {
            body = ""
        }
        
        self.handlingInstantCommentCallback(body:body, identifier:uploadObj.identifier, fileType:uploadObj.type, isPosting:false)
        if uploadObj.type == "image" {
            self.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode,identifier: uploadObj.identifier, bodyString: body )
        }else if uploadObj.type == "video" {
            self.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
        }else if uploadObj.type == "GIF" {
            self.uploadFile(filePath: uploadObj.imageUrl, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier, bodyString: body )
        }else if uploadObj.type == "audio" {
            self.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
        }else if uploadObj.type == "attachment" {
            self.uploadFile(filePath: uploadObj.url, fileType: uploadObj.type, langID: uploadObj.languageCode, identifier: uploadObj.identifier,bodyString: body )
        }
        self.closeUploadingVIewBtn(UIButton.init())
    }
    
    @IBAction func sendCommentBtnClicked(_ sender: Any) {
        
        var myComment = self.commentTextView.text.trimmingCharacters(in: .whitespaces)
        if myComment == Const.textViewPlaceholder.localized() {
            myComment = ""
        }
        self.editCommentView.isHidden = true
        
        if self.feedUploadObj != nil {
            self.manageUploadingData(uploadObj:self.feedUploadObj!)
        } else if (self.editCommentView.isHidden) && (self.editCommentObj != nil) {
            
            let parameters = ["action": "comment",
                              "token": SharedManager.shared.userToken(),
                              "body": myComment,
                              "post_id":String(self.feedObj!.postID!),
                              "identifier": "",
                              "comment_id":String(self.editCommentObj!.commentID!)]
            
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            self.editCommentObj?.body = myComment
            
            if self.isReplyEdit {
                self.callingService(parameters: parameters, action: "ReplyEdit")
            }else {
                self.callingService(parameters: parameters, action: "commentEdit")
            }
        } else {
            if myComment != "" || self.audioFileURLStr != ""  {
                //                if self.audioRecorderObj?.filename != "" {
                //                    if self.audioLangBtn.titleLabel!.text == "Select Audio Language".localized() {
                //                        SharedManager.shared.showAlert(message: Const.languageSelectionAlert.localized(), view: self)
                //                        return
                //                    }
                //                }
                let identifierStr = SharedManager.shared.getIdentifierForMessage()
                self.handlingInstantCommentCallback(body: myComment, identifier: identifierStr, fileType:"")
                var parameters = ["action": "comment",
                                  "token": SharedManager.shared.userToken(),
                                  "body": myComment,
                                  "post_id":String(self.feedObj!.postID!),
                                  "identifier":identifierStr]
                
                if SharedManager.shared.isGroup == 1 {
                    parameters["group_id"] = SharedManager.shared.groupObj?.groupID
                } else if SharedManager.shared.isGroup == 2 {
                    parameters["page_id"] = SharedManager.shared.groupObj?.groupID
                }
                if self.isCommentReply {
                    parameters["in_reply_to_id"] = String(self.inReplyID!)
                }
                
                self.callingService(parameters: parameters, action: "comment")
                self.commentTextView.text = ""
                self.textViewDidChange(self.commentTextView)
                self.audioOptionView.isHidden = true
                self.resetAudioRecorderUI()
                
                //// MARK: Socket Event For Comment
                var dicMeta = [String : Any]()
                dicMeta["post_id"] = String(self.feedObj!.postID!)
                
                var dic = [String : Any]()
                dic["group_id"] = String(self.feedObj!.postID!)
                dic["meta"] = dicMeta
                dic["type"] = "new_comment_NOTIFICATION"
                SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
                
            }
        }
    }
    
    func callingService(parameters: [String:String], action: String)  {
        
        var paramDict = parameters
        var fileUrl = ""
        if self.audioFileURLStr != "" {
            fileUrl = self.audioFileURLStr
            self.audioFileURLStr = ""
            //            paramDict["recording_language_id"] =  self.selectedLangModel?.languageID
            self.selectedLangModel = nil
        }
        let apiResponseTimer = APIResponseTimer(startTime: .now())
        RequestManager.fetchDataMultipart(Completion: { response in
            let elapsedTime = apiResponseTimer.calculateElapsedTime()
            LogClass.debugLog("End Point (action:react) ==> Response Timee = \(elapsedTime)")
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error)
            case .success(let res):
                if (action == "comment") {
                    self.commentTextView.text = ""
                    if res is String {
                        
                    } else {
                        let dataDict = res as! NSDictionary
                        if let dict = dataDict["data"] {
                            self.handlingCommentCallback(res: dict as! NSDictionary)
                            SocketSharedManager.sharedSocket.emitFeedComment(dict: res as! NSDictionary)
                            //
                        }
                    }
                } else if (action == "getComments"){
                    let commentDict = res as! NSDictionary
                    self.manageLoadMoreComments(resp: commentDict)
                } else if (action == "commentEdit") {
                    if res is String {
                    } else {
                        self.updateEditComment()
                    }
                } else if (action == "ReplyEdit") {
                    if res is String {
                    } else {
                        self.updateEditComment(isComment: false)
                    }
                } else if(action == "like") {
                    LogClass.debugLog("liiii")
                }
            }
        }, param:paramDict, fileUrl: fileUrl)
    }
    
    @objc func dropDownReportingSheet(){
        
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        reportController.delegate = self
        reportController.reportType = "Post"
        reportController.currentIndex = self.indexPath ?? IndexPath(row: 0, section: 0)
        reportController.feedObj = self.feedObj
        openBottomSheet(reportController, sheetSize: [.fullScreen], animated: false)
    }
    
    @objc func dropDownReportingSheetComment(sender:UIButton){
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        self.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
        reportController.delegate = self
        reportController.reportType = "Comment"
        reportController.currentIndex = IndexPath(row: sender.tag, section: 0)
        reportController.feedObj = self.feedObj
        reportController.commentObj = self.feedObj?.comments![sender.tag]
        self.editCommentObj = reportController.feedObj?.comments![sender.tag]
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func closeEditCommentBtnClicked(_ sender: Any) {
        self.cameraBtn.isEnabled = true
        self.galleryBtn.isEnabled = true
        self.micBtn.isEnabled = true
        self.commentAttachmentBtn.isEnabled = true
        self.isCommentReply = false
        self.commentTextView.resignFirstResponder()
        self.editCommentView.isHidden = true
        self.commentTextView.text = Const.textViewPlaceholder.localized()
        self.commentTextView.textColor = UIColor.lightGray
        self.commentHeightContraint.constant = 38
        self.uploadViewBottomConst.constant = 0
    }
    
    func updateEditComment(isComment:Bool = true){
        if isComment {
            var counter = 0
            for comment in self.feedObj!.comments! {
                if comment.commentID == self.editCommentObj?.commentID {
                    break
                }
                counter = counter + 1
            }
            self.feedObj!.comments![counter] = self.editCommentObj!
            self.feedArray[self.indexPath!.row] = self.feedObj!
        }else {
            var counter = 0
            let commentObj:Comment = self.feedObj!.comments![self.selectedCommentIndex!]
            for comment in commentObj.replies! {
                if comment.commentID == self.editCommentObj?.commentID {
                    break
                }
                counter = counter + 1
            }
            commentObj.replies![counter] = self.editCommentObj!
            self.feedObj?.comments![self.selectedCommentIndex!] = commentObj
            self.feedArray[self.indexPath!.row] = self.feedObj!
        }
        self.feedDetailTableView.reloadData()
        self.editCommentObj = nil
        self.commentTextView.text = ""
        self.textViewDidChange(self.commentTextView)
        self.cameraBtn.isEnabled = true
        self.galleryBtn.isEnabled = true
        self.micBtn.isEnabled = true
        self.editCommentView.isHidden = true
        self.commentAttachmentBtn.isEnabled = true
        self.isReplyEdit = false
        self.commentTextView.resignFirstResponder()
    }
    
}

extension FeedDetailController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedObj?.comments == nil {
            return 0
        }
        return (self.feedObj?.comments?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let commentObj: Comment = (self.feedObj?.comments![indexPath.row])!
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCommentCell.identifier, for: indexPath) as? FeedDetailCommentCell {
            
            cell.manageData(commentObj: commentObj, currentIndex: indexPath, feedObj: self.feedObj!)
            cell.dropDownBtn.tag = indexPath.row
            cell.commentReplyBtn.tag = indexPath.row
            cell.dropDownBtn.addTarget(self, action: #selector(dropDownReportingSheetComment(sender:)), for: .touchUpInside)
            cell.likeCommentCounterBtn.tag = indexPath.row
            
            //            cell.dislikeCommentBtn.tag = indexPath.row
            cell.likeCommentCounterBtn.addTarget(self, action: #selector(commentLikeCounterBtn), for: .touchUpInside)
            //            cell.dislikeCommentCounterBtn.addTarget(self, action: #selector(commentDisLikeCounterBtn), for: .touchUpInside)
            cell.commentReplyBtn.addTarget(self, action: #selector(commentReplyBtnClicked), for: .touchUpInside)
            cell.parentview = self
            cell.btnUserProfile.tag = indexPath.row
            cell.btnUserProfile.addTarget(self, action: #selector(openProfileAction), for: .touchUpInside)
            
            cell.cellDelegate = self
            
            cell.layoutIfNeeded()
            return cell
        }
        return UITableViewCell()
    }
    
    
    @objc func openProfileAction(sender : UIButton){
        let commentObj:Comment = (self.feedObj?.comments![sender.tag])!
        
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = String(commentObj.userID!)
        vcProfile.otherUserisFriend = "1"
        //  vcProfile.isNavigationEnable = false
        vcProfile.isNavPushAllow = true
        self.navigationController?.pushViewController(vcProfile, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedObj!.comments != nil {
            if self.feedObj!.comments!.count > 0 {
                if indexPath.row > self.feedObj!.comments!.count-1 {
                    return
                }
                if cell is FeedDetailCommentCell {
                    let feedCell:FeedDetailCommentCell = cell as! FeedDetailCommentCell
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func commentReplyBtnClicked(sender:UIButton)   {
        let commentObj = self.feedObj?.comments![sender.tag]
        if commentObj != nil {
            self.inReplyID = commentObj?.commentID
            self.selectedReplyIndex = sender.tag
            let authorName = (commentObj?.author?.firstname ?? "")+" "+(commentObj?.author?.lastname ?? "")
            self.editDescLbl.text = "Replying to".localized() + " " + authorName
        }
        self.isCommentReply = true
        self.uploadViewBottomConst.constant = 38
        self.editCommentView.isHidden = false
        self.commentTextView.text = ""
        self.commentTextView.becomeFirstResponder()
        self.editCommentObj = nil
        self.cameraBtn.isEnabled = true
        self.galleryBtn.isEnabled = true
        self.micBtn.isEnabled = true
        self.commentAttachmentBtn.isEnabled = true
    }
    
    @objc func commentLikeCounterBtn(sender:UIButton)   {
        //        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        //        pagerController.commentObj = self.feedObj?.comments![sender.tag]
        //        pagerController.isComment = true
        //        let sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        //        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        //        sheetController.extendBackgroundBehindHandle = true
        //        self.present(sheetController, animated: false, completion: nil)
    }
    
    //    @objc func commentDisLikeCounterBtn(sender:UIButton){
    //        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
    //        pagerController.commentObj = self.feedObj?.comments![sender.tag]
    //        pagerController.isComment = true
    //        let sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
    //        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
    //        sheetController.extendBackgroundBehindHandle = true
    //        self.present(sheetController, animated: false, completion: nil)
    //    }
    
    //Manage pagging
    @IBAction func loadPreviousComment(_ sender: Any) {
        if  self.isNextCommentExist {
            let commentCurrentCount = self.feedObj?.comments?.count
            if commentCurrentCount! > 0 {
                self.prevAI.isHidden = false
                self.prevCommentBtn.isHidden = true
                self.prevAI.startAnimating()
                let commentObj:Comment = (self.feedObj?.comments![0])!
                var parameters = ["action": "getComments","token": SharedManager.shared.userToken(), "starting_point_id":String(commentObj.commentID!), "post_id":String(self.feedObj!.postID!)]
                if SharedManager.shared.isGroup == 1 {
                    parameters["group_id"] = SharedManager.shared.groupObj?.groupID
                }else if SharedManager.shared.isGroup == 2 {
                    parameters["page_id"] = SharedManager.shared.groupObj?.groupID
                }
                self.callingService(parameters: parameters, action: "getComments")
            }
        }
    }
    
    func manageLoadMoreComments(resp:NSDictionary){
        self.prevAI.stopAnimating()
        self.prevAI.isHidden = true
        let metaDict = resp["meta"]  as! NSDictionary
        let code:Int = metaDict["code"] as! Int
        if code == 200 {
            let dataArray:[NSDictionary] = resp["data"] as! [NSDictionary]
            let orignalCommentArray = self.feedObj?.comments
            var commentArray:[Comment] = []
            for dict in dataArray {
                let commentObj:Comment = Comment(dict: dict)
                commentArray.append(commentObj)
            }
            commentArray.append(contentsOf: orignalCommentArray!)
            self.feedObj?.comments = commentArray
            self.prevCommentBtn.isHidden = false
            self.prevCommentView.isHidden = false
            self.feedDetailTableView.setAndLayoutTableHeaderView(header: self.feedHeaderView)
            self.feedDetailTableView.reloadData()
            
        }else {
            self.isNextCommentExist = false
            self.prevCommentHConst.constant = 0
            self.prevCommentView.isHidden = true
            self.feedDetailTableView.setAndLayoutTableHeaderView(header: self.feedHeaderView)
            //          self.feedDetailTableView.tableFooterView?.removeFromSuperview()
        }
    }
    
    // Comment Handling Started
    @IBAction func commentDropDownOption(_ sender: Any) {
        self.commentDropDownView.isHidden = true
        let btn = sender as! UIButton
        if self.commentOptionState == 0 {
            if btn.tag == 0 {
                dismissKeyboard()
                SharedManager.shared.isVideoPickerFromHeader = false
                VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
            }else {
                self.showImageBrowse()
            }
        }else if self.commentOptionState == 1{
            if btn.tag == 0 {
                let gifObj = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "GifListController") as! GifListController
                gifObj.delegate = self
                gifObj.isMultiple = false
                gifObj.modalPresentationStyle = .fullScreen
                self.present(gifObj, animated: true, completion: nil)
            }else {
                self.showImageBrowse()
            }
        }else if self.commentOptionState == 3 {
            if btn.tag == 0 {
                //                self.audioOptionView.isHidden = false
                let audioRecorder = AppStoryboard.Shared.instance.instantiateViewController(withIdentifier: SharedAudioRecorderVC.className) as! SharedAudioRecorderVC
                
                audioRecorder.getAudioUrl = {[weak self] audioUrl in
                    
                    guard let self = self else { return }
                    self.audioFileURLStr = audioUrl.absoluteString
                    self.sendCommentBtnClicked(UIButton())
                }
                
                self.sheetController = SheetViewController(controller: audioRecorder, sizes: [.fixed(280)])
                self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
                self.sheetController.extendBackgroundBehindHandle = true
                self.sheetController.topCornersRadius = 20
                self.present(self.sheetController, animated: false, completion: nil)
                
            }else {
                self.openMusicAlbum()
            }
        }
    }
    
    func showImageBrowse()  {
        let viewController = TLPhotosPickerViewController()
        viewController.configure.maxSelectedAssets = 1
        viewController.delegate = self
        var arrayAsset = [TLPHAsset]()
        for indexObj in self.selectedAssets {
            if indexObj.isType == PostDataType.Image && indexObj.assetMain != nil {
                arrayAsset.append(indexObj.assetMain)
            }
        }
        viewController.selectedAssets = arrayAsset
        self.present(viewController, animated: true) {
            //            viewController.albumPopView.show(viewController.albumPopView.isHidden, duration: 0.1)
        }
    }
}

extension FeedDetailController:UITextViewDelegate   {
    
    func editCommentHandling() {
        self.editDescLbl.text = "Edit your comment".localized()
        self.cameraBtn.isEnabled = false
        self.galleryBtn.isEnabled = false
        self.commentAttachmentBtn.isEnabled = false
        self.micBtn.isEnabled = false
        self.editCommentView.isHidden = false
        self.commentTextView.becomeFirstResponder()
        self.commentTextView.text = self.editCommentObj?.body
        let newFrame = self.getHeightFrame(self.commentTextView)
        let someHeight = newFrame.size.height
        if someHeight < 100 {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightContraint.constant = someHeight + 10
        }else {
            self.commentHeightContraint.constant = 110
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //    if self.commentTextView.textColor == UIColor.lightGray {
        self.commentTextView.text = nil
        textView.text = ""
        textView.textColor = UIColor.black
        self.commentTextView.textColor = UIColor.black
        // }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.commentTextView.text = Const.textViewPlaceholder.localized()
            self.commentTextView.textColor = UIColor.lightGray
            //            self.editCommentView.isHidden = true
            //            self.editCommentObj = nil
            self.commentHeightContraint.constant = 38
        }
    }
    
    func textViewDidChange(_ textView: UITextView){
        let newFrame = self.getHeightFrame(textView)
        if newFrame.size.height < 100 {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightContraint.constant = newFrame.size.height + 10
        } else {
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func getHeightFrame(_ textView: UITextView) -> CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        return newFrame
    }
}

extension FeedDetailController:CommentHandlerDelegate   {
    
    func seeMoreTapped(feedData: FeedData, indexPath: IndexPath) {
        
        let newvalue = feedData.comments?[indexPath.row].isExpand ?? false
        self.feedObj.comments?[indexPath.row].isExpand = newvalue
        self.feedDetailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func commentDataUpdated(){
        self.feedDetailTableView.reloadRows(at: self.feedDetailTableView.indexPathsForVisibleRows!, with: .none)
    }
    
    func handlingInstantCommentCallback(body:String, identifier:String, fileType:String, selectLang:Bool = false, videoUrl:String = "", isPosting:Bool = false){
        if self.isCommentReply {
            let commentObj = self.feedObj?.comments![self.selectedReplyIndex!]
            let totalCounter =  commentObj?.replies?.count ?? 0
            let replyObj:Comment = Comment(original_body:body , body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(),isPosting:false, identifierStr:identifier, fileType: fileType, selectLanguage: selectLang, videoUrlToUpload: videoUrl)
            commentObj?.replies?.insert(replyObj, at: totalCounter)
            if let count = commentObj!.replyCount {
                commentObj?.replyCount = count + 1
            }else {
                commentObj?.replyCount = 1
            }
            self.feedObj?.comments![self.selectedReplyIndex!] = commentObj!
            self.feedArray[self.indexPath!.row] = self.feedObj!
            self.feedDetailTableView.reloadRows(at: [IndexPath(row: self.selectedReplyIndex!, section: 0)], with: UITableView.RowAnimation.none)
            self.feedDetailTableView.scrollToRow(at: IndexPath(row: self.selectedReplyIndex!, section: 0), at: .bottom, animated: false)
        }else {
            let commentObj:Comment = Comment(original_body:body ,body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(),isPosting:false, identifierStr:identifier, fileType: fileType, selectLanguage: selectLang, videoUrlToUpload: videoUrl)
            commentObj.replyCount = 0
            let totalCounter =  self.feedObj!.comments?.count ?? 0
            self.feedObj!.comments?.insert(commentObj, at: totalCounter)
            self.feedObj!.isPostingNow = false
            self.feedArray[self.indexPath!.row] = self.feedObj!
            self.feedDetailTableView.beginUpdates()
            self.feedDetailTableView.insertRows(at:[IndexPath(row: totalCounter, section: 0)], with:.automatic)
            self.feedDetailTableView.endUpdates()
            self.feedDetailTableView.scrollToRow(at: IndexPath(row: (self.feedObj?.comments!.count)! - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    func handlingCommentCallback(res: NSDictionary) {
        
        if self.isCommentReply {
            self.handlingCommentReplyCallback(res: res)
        } else {
            var indexToReplace = -1
            let feedObjUpdate: FeedData = self.feedArray[self.indexPath!.row]
            if feedObjUpdate.postID == res["post_id"] as? Int {
                let commentObj: Comment = Comment(dict: res)
                if res["identifier"] == nil {
                    let totalCommentCount = feedObjUpdate.comments?.count ?? 0
                    feedObjUpdate.comments?.insert(commentObj, at: totalCommentCount)
                    feedObjUpdate.isPostingNow = true
                    indexToReplace = totalCommentCount
                    
                    self.feedArray[self.indexPath!.row].commentCount = (feedObjUpdate.commentCount ?? 0) + 1
                    
                    if feedObjUpdate.commentCount! == 0{
                        lblcommentCounter.text = ""
                    }
                    else{
                        self.lblcommentCounter.text = String(feedObjUpdate.commentCount!)
                    }
                    
                    
                    // call delegate
                    self.delegate?.commentUpdated(feedUpdatedOBJ: feedObjUpdate, currentIndex: self.indexPath)
                    
                } else {
                    let identifier = res["identifier"] as! String
                    for counter in 0..<feedObjUpdate.comments!.count {
                        let commentIdentifier:Comment = feedObjUpdate.comments![counter] as Comment
                        if commentIdentifier.identifierStr != nil {
                            if identifier == commentIdentifier.identifierStr {
                                indexToReplace = counter
                                break
                            }
                        }
                    }
                    if indexToReplace != -1 {
                        feedObjUpdate.comments?[indexToReplace] = commentObj
                        feedObjUpdate.isPostingNow = true
                        self.feedArray[self.indexPath!.row].commentCount = (feedObjUpdate.commentCount ?? 0) + 1
                        
                        self.feedArray[self.indexPath!.row] = feedObjUpdate
                        
                        if feedObjUpdate.commentCount! == 0{
                            lblcommentCounter.text = ""
                        }
                        else{
                            self.lblcommentCounter.text = String(feedObjUpdate.commentCount!)
                        }
                        
                        
                        // call delegate
                        self.delegate?.commentUpdated(feedUpdatedOBJ: feedObjUpdate, currentIndex: self.indexPath)
                        
                    } else {
                        let totalCommentCount = feedObjUpdate.comments?.count ?? 0
                        feedObjUpdate.comments?.insert(commentObj, at: totalCommentCount)
                        feedObjUpdate.isPostingNow = true
                        self.feedArray[self.indexPath!.row] = feedObjUpdate
                        self.feedDetailTableView.beginUpdates()
                        self.feedDetailTableView.insertRows(at:[IndexPath(row: totalCommentCount, section: 0)], with:.automatic)
                        self.feedDetailTableView.endUpdates()
                    }
                }
                self.updateTableFromFeed?(self.indexPath!)
            }
            
            
            self.feedObj = self.feedArray[self.indexPath!.row]
            self.feedDetailTableView.reloadData()
            self.isCommentReply = false
            self.editCommentView.isHidden = true
            self.commentTextView.text = ""
            self.commentTextView.resignFirstResponder()
            if (self.feedObj?.comments!.count)! - 1 > 0 {
                self.feedDetailTableView.scrollToRow(at: IndexPath(row: (self.feedObj?.comments!.count)! - 1, section: 0), at: .bottom, animated: false)
            }
            self.updateNewsFeedOnAnyReaction()
        }
    }
    
    func handlingCommentReplyCallback(res: NSDictionary) {
        var indexToReplace = -1
        let feedObjUpdate:FeedData = self.feedArray[self.indexPath!.row]
        if feedObjUpdate.postID == res["post_id"] as? Int{
            let commentObj:Comment = Comment(dict: res)
            if res["identifier"] == nil{
                let totalCommentCount = feedObjUpdate.comments?.count ?? 0
                commentObj.replies?.insert(commentObj, at: totalCommentCount)
                feedObjUpdate.isPostingNow = true
                indexToReplace = totalCommentCount
            } else {
                let commentReply:Comment = feedObjUpdate.comments![self.selectedReplyIndex!]
                let identifier = res["identifier"] as! String
                for counter in 0 ..< commentReply.replies!.count {
                    let commentIdentifier:Comment = commentReply.replies![counter] as Comment
                    if commentIdentifier.identifierStr != nil {
                        if identifier == commentIdentifier.identifierStr {
                            indexToReplace = counter
                            break
                        }
                    }
                }
                if indexToReplace != -1 {
                    feedObjUpdate.comments![self.selectedReplyIndex!].replies?[indexToReplace] = commentObj
                    feedObjUpdate.isPostingNow = true
                    self.feedArray[self.indexPath!.row] = feedObjUpdate
                    
                }else {
                    let totalCommentCount = feedObjUpdate.comments?.count ?? 0
                    feedObjUpdate.comments?.insert(commentObj, at: totalCommentCount)
                    feedObjUpdate.isPostingNow = true
                    self.feedArray[self.indexPath!.row] = feedObjUpdate
                    self.feedDetailTableView.beginUpdates()
                    self.feedDetailTableView.insertRows(at:[IndexPath(row: totalCommentCount, section: 0)], with:.automatic)
                    self.feedDetailTableView.endUpdates()
                }
            }
            self.updateTableFromFeed?(self.indexPath!)
        }
        self.feedDetailTableView.scrollToRow(at: IndexPath(row: self.selectedReplyIndex!, section: 0), at: .bottom, animated: false)
        self.feedObj = self.feedArray[self.indexPath!.row]
        self.feedObj.commentCount = (self.feedObj.commentCount ?? 0) + 1
        self.lblcommentCounter.text = String(self.feedObj!.commentCount!)
        self.feedDetailTableView.reloadData()
        self.isCommentReply = false
        self.editCommentView.isHidden = true
        self.updateNewsFeedOnAnyReaction()
    }
}

extension FeedDetailController:feedCommentDelegate {
    func chatMessageDelete(res: NSArray) {
        
        
    }
    
    func chatMessageReceived(res: NSArray) {
        
    }
    func feedCommentReceivedFromSocket(res: NSDictionary){
        if res["new_comment"] != nil {
            self.handlingCommentCallback(res: res["new_comment"] as! NSDictionary)
        }
    }
}

extension FeedDetailController:AGAudioRecorderDelegate {
    
    func manageAudioRecorder(){
        self.audioOptionView.isHidden = true
        self.playAudioBtn.isSelected = false
        self.progressSlider.isHidden = true
        self.commentPlayerTimeLbl.isHidden = true
        self.recordBtn.isSelected = false
        self.stopAudioBtn.isSelected = false
        self.audioTimerLbl.text = "00:00"
        self.audioRecorderObj = AudioRecorder(withFileName: "TestingFile")
        self.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
        self.audioRecorderObj?.delegate = self
        self.progressSlider.minimumValue = 0.0
        self.progressSlider.value = 0.0
    }
    
    func resetAudioRecorderUI(){
        self.audioOptionView.isHidden = true
        self.playAudioBtn.isSelected = false
        self.progressSlider.isHidden = true
        self.commentPlayerTimeLbl.isHidden = true
        self.recordBtn.isSelected = false
        self.stopAudioBtn.isSelected = false
        self.audioTimerLbl.text = "00:00"
        self.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
        self.progressSlider.minimumValue = 0.0
        self.progressSlider.value = 0.0
    }
    
    @IBAction func micButtonClicked(sender:UIButton)    {
        self.commentDropDownView.isHidden = true
        self.audioRecorderViewHConst.constant = 68
        self.audioLangBtn.isHidden = true
        self.audioOptionView.isHidden = !self.audioOptionView.isHidden
    }
    
    
    func agPlayerTimerDelegate(timeLeft:String){
        self.commentPlayerTimeLbl.text = timeLeft
    }
    
    func agPlayerFinishedPlaying() {
        self.playAudioBtn.tag = 20
        self.audioRecorderObj?.resetSlider()
        self.playAudioBtn.setImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
    }
    
    func agAudioRecorder(_ recorder: AudioRecorder, withStates state: AGAudioRecorderState) {
        
    }
    
    func agAudioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
        self.audioTimerLbl.text = formattedString
    }
    
    @IBAction func progressValueChanged(_ sender: Any) {
        self.audioRecorderObj?.doHanldeProgressSliderTime(sender: sender as? UISlider)
    }
    
    @IBAction func audioRecordBtnClicked(_ sender: Any) {
        self.audioRecorderObj?.check_record_permission()
        if self.audioRecorderObj!.isAudioRecordingGranted {
            if self.recordBtn.isSelected {
                self.audioTimerLbl.isHidden = false
                self.audioPauseBtnClicked(UIButton())
                self.recordBtn.isSelected = false
                self.progressSlider.isHidden = true
                self.commentPlayerTimeLbl.isHidden = true
            }else {
                self.audioTimerLbl.isHidden = false
                self.audioRecorderObj?.filename = "TestingFile"
                self.audioRecorderObj?.doRecord()
                self.progressSlider.isHidden = true
                self.commentPlayerTimeLbl.isHidden = true
                self.playAudioBtn.isSelected = false
                self.recordBtn.isSelected = true
            }
            self.stopAudioBtn.isSelected = true
        }
    }
    
    @IBAction func audioPlayBtnClicked(_ sender: Any) {
        if self.playAudioBtn.isSelected == false {
            return
        }
        if (self.audioRecorderObj?.audioRecorder.isRecording)! {
            self.audioTimerLbl.isHidden = true
            self.playAudioBtn.setImage(UIImage(named: "play-gray"), for: UIControl.State.normal)
        }else {
            if self.playAudioBtn.isSelected {
                self.audioTimerLbl.isHidden = true
                if self.playAudioBtn.tag == 20 {
                    self.playAudioBtn.tag = 21
                    self.audioRecorderObj?.doPlay()
                    self.playAudioBtn.setImage(UIImage(named: "pause-blue"), for: UIControl.State.selected)
                    self.audioRecorderObj?.manageSliderTimer()
                }else {
                    self.audioRecorderObj?.resetSlider()
                    self.playAudioBtn.tag = 20
                    self.playAudioBtn.setImage(UIImage(named: "play-blue"), for: UIControl.State.selected)
                    self.audioRecorderObj?.doPausePlayer()
                }
            }
        }
    }
    
    @IBAction func audioStopBtnClicked(_ sender: Any) {
        if self.stopAudioBtn.isSelected {
            self.audioRecorderObj?.doStopRecording()
            self.stopAudioBtn.isSelected = false
            self.playAudioBtn.isSelected = true
            self.recordBtn.isSelected = false
            self.playAudioBtn.tag = 20
            self.audioTimerLbl.isHidden = true
            self.progressSlider.isHidden = false
            self.commentPlayerTimeLbl.isHidden = false
            self.audioRecorderObj?.configureSlider(slider: self.progressSlider)
            self.audioRecorderViewHConst.constant = 90
            self.audioLangBtn.isHidden = false
        }
    }
    
    @IBAction func audioCancelBtnClicked(_ sender: Any) {
        self.audioOptionView.isHidden = true
        self.audioRecorderObj?.doResetRecording()
        self.stopAudioBtn.isSelected = false
        self.playAudioBtn.isSelected = false
        self.recordBtn.isSelected = false
        self.audioTimerLbl.text = "00:00"
        self.audioTimerLbl.isHidden = false
        self.progressSlider.isHidden = true
        self.audioRecorderViewHConst.constant = 68
        self.audioLangBtn.isHidden = true
        
    }
    
    @IBAction func audioPauseBtnClicked(_ sender: Any) {
        self.audioRecorderObj?.doPauseAudio()
        self.progressSlider.isHidden = true
        self.commentPlayerTimeLbl.isHidden = true
    }
}

extension FeedDetailController:XQAudioPlayerDelegate {
    func manageAudioToggle(isOrig:Bool) {
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            let orignalLink = postFile.filePath
            let translatedLink = postFile.filetranslationlink
            if isOrig {
                self.getAudioText(audioLbl: self.audioLbl!, isShowOrig: true)
                self.xqAudioPlayer.config(urlString: orignalLink!)
            }else {
                self.getAudioText(audioLbl: self.audioLbl!, isShowOrig: false)
                self.xqAudioPlayer.config(urlString: translatedLink!)
            }
        }
    }
    
    func audioXQConfiguration() {
        self.audioOrigBtn?.isHidden = true
        if self.feedObj!.post!.count > 0 {
            let postFile:PostFile = self.feedObj!.post![0]
            if let convertedUrl = postFile.filetranslationlink {
                self.xqAudioPlayer.config(urlString: convertedUrl)
                self.audioOrigBtn?.isHidden = false
            }else {
                self.xqAudioPlayer.config(urlString:postFile.filePath ?? "")
            }
        }
        self.xqAudioPlayer.playingImage = UIImage(named:"icon_playing")
        self.xqAudioPlayer.pauseImage = UIImage(named:"icon_pause")
        self.xqAudioPlayer.delegate = self
        if self.xqAudioPlayer != nil {
            self.xqAudioPlayer.manageProgressUI()
        }
    }
    
    func getAudioText(audioLbl:UILabel, isShowOrig:Bool = false) {
        audioLbl.text = ""
        if self.feedObj!.post!.count > 0 {
            let postObj:PostFile = self.feedObj!.post![0]
            let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
            if let contentLangCode = postObj.orignalLanguageID {
                if langCode == contentLangCode || isShowOrig {
                    if let message = postObj.speechToText {
                        audioLbl.text = message
                    }
                }else {
                    if let message = postObj.SpeechToTextTranslated {
                        audioLbl.text = message
                    }
                }
            }
            if audioLbl.text != nil {
                let langDirection = SharedManager.shared.detectedLangauge(for: audioLbl.text!) ?? "left"
                (langDirection == "right") ? (audioLbl.textAlignment = NSTextAlignment.right): (audioLbl.textAlignment = NSTextAlignment.left)
            }
        }
    }
    
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

extension FeedDetailController:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let fileName = "myImageToUpload.jpg"
            FileBasedManager.shared.saveFileTemporarily(fileObj: pickedImage, name: fileName)
            self.feedUploadObj = self.uploadingView.handlingUploadFeedView(fileType: "image", selectLang: false, videoUrl: "", imgUrl:FileBasedManager.shared.getSavedImagePath(name: fileName), isPosting: false)
            self.manageViewToUploadVideo()
            
            picker.dismiss(animated: true, completion: nil)
        }else if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String,
                 let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            let thumbImage:UIImage = SharedManager.shared.videoSnapshot(filePathLocal: url)!
            FileBasedManager.shared.encodeVideo(videoURL: url) { (newUrl) in
                DispatchQueue.main.async {
                    self.manageViewToUploadVideo()
                    self.feedUploadObj = self.uploadingView.handlingUploadFeedView(fileType:"video", selectLang: true, videoUrl: newUrl!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        } else {
            
        }
    }
    
    func uploadFile(filePath:String, fileType:String, langID:String = "", identifier:String = "", bodyString:String = "")   {
        let feedObj = self.feedArray[self.indexPath!.row]
        var parameters = ["action": "comment",
                          "token": SharedManager.shared.userToken(),
                          "body": bodyString,
                          "post_id":String(feedObj.postID!),
                          "identifier":identifier,
                          "fileType":fileType, "fileUrl":filePath]
        if self.isCommentReply {
            self.isCommentReply = true
            parameters["in_reply_to_id"] = String(self.inReplyID!)
        }
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        }else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        if langID != "" {
            if fileType == "audio" {
                parameters["recording_language_id"] = langID
                parameters["file_language_id"] = langID
                
            }else {
                parameters["file_language_id"] = langID
            }
        }
        self.callingServiceToUpload(parameters: parameters, action: "comment", isReply: self.isCommentReply)
        
        //// MARK: Socket Event For Comment
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(feedObj.postID!)
        
        var dic = [String : Any]()
        dic["group_id"] = String(feedObj.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_comment_NOTIFICATION"
        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
    }
    
    func callingServiceToUpload(parameters:[String:String], action:String, isReply:Bool = false)  {
        RequestManager.fetchDataMultipart(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                
                if (action == "comment") {
                    if res is String {
                        // self.commentServiceCallbackHandler?(res as! String)
                    }else {
                        self.isCommentReply = isReply
                        let dataDict = res as! NSDictionary
                        self.handlingCommentCallback(res: dataDict.value(forKey: "data") as! NSDictionary)
                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
                    }
                }
            }
        }, param:parameters, fileUrl: "")
    }
}

extension FeedDetailController:TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                let newObj = PostCollectionViewObject.init()
                self.selectedAssets.append(newObj)
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        newObj.photoUrl = urlString
                        self!.manageViewToUploadVideo()
                        self!.feedUploadObj = self!.uploadingView.handlingUploadFeedView(fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
                    }
                }
            }else if indexObj.type == .livePhoto {
                let newObj = PostCollectionViewObject.init()
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        newObj.photoUrl = urlString
                        self!.manageViewToUploadVideo()
                        self!.feedUploadObj = self!.uploadingView.handlingUploadFeedView(fileType: "image", selectLang: false, videoUrl: "",imgUrl:newObj.photoUrl.path, isPosting: false)
                    }
                }
                newObj.isType = PostDataType.Image
                newObj.assetMain = indexObj
                self.selectedAssets.append(newObj)
            }
            else if indexObj.type == .video {
                let newObj = PostCollectionViewObject.init()
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {[weak self] (asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            newObj.videoURL = urlAsset.url
                            let thumbImage:UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                FileBasedManager.shared.encodeVideo(videoURL: newObj.videoURL as URL) { (newUrl) in
                                    DispatchQueue.main.async {
                                        newObj.videoURL = newUrl
                                        self!.manageViewToUploadVideo()
                                        self!.feedUploadObj = self!.uploadingView.handlingUploadFeedView(fileType:"video", selectLang: true, videoUrl: newObj.videoURL!.path, isPosting: true, imageObj: thumbImage, isImageObjExist: true)
                                    }
                                }
                            }
                        }
                    })
                }
                self.selectedAssets.append(newObj)
            }
        }
    }
    
    func manageViewToUploadVideo()   {
        micBtn.isEnabled = false
        galleryBtn.isEnabled = false
        cameraBtn.isEnabled = false
        uploadingView.isHidden = false
        commentAttachmentBtn.isEnabled = false
        audioCancelBtnClicked(UIButton.init())
    }
}

extension FeedDetailController:DismissReportSheetDelegate {
    
    func dismissReportWithMessage(message:String)   {
        
        SharedManager.shared.ShowsuccessAlert(message: message,AcceptButton: "OK".localized()) { status in
            self.getDetail()
        }
        //        SharedManager.shared.showAlert(message: message, view: self)
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(currentIndex: currentIndex)
            }
        }else if type == "Delete" || type == "Hide"  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let postId = self.feedObj.postID ?? -1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "post_deleted"), object: postId)
                self.feedDeletedFromDetailHandler?(self.indexPath!)
                self.navigationController?.popViewController(animated: true)
            }
        }else if type.contains("Hide all") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.feedHideAllFromDetailHandler?(self.indexPath!)
                self.navigationController?.popViewController(animated: true)
            }
        }else if type.contains("Block") {
            SharedManager.shared.showAlert(message: "User blocked successfully".localized(), view: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.feedHideAllFromDetailHandler?(self.indexPath!)
                self.navigationController?.popViewController(animated: true)
            }
        }else if type == "Edit" {
            // Perform Edit work here...
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let feedObj = self.feedObj
                let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
                createPost.modalPresentationStyle = .fullScreen
                let createPostController = createPost.viewControllers.first as! CreatePostViewController
                createPostController.isPostEdit = true
                createPostController.feedObj = feedObj
                SharedManager.shared.createPostSelection  = -1
                self.present(createPost, animated: false, completion: nil)                       }
        }
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        self.isReplyEdit = isReply
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
            }
        }else if type == "Delete" || type == "Hide"  {
            if isReply {
                let commentObj:Comment = self.feedObj!.comments![currentIndex.row]
                commentObj.replies?.remove(at: self.selectedCommentReplyIndex!)
                self.feedObj?.comments![self.selectedCommentIndex!] = commentObj
                self.feedArray[self.indexPath!.row] = self.feedObj!
                self.feedDetailTableView.reloadData()
            }else {
                if self.feedObj!.comments!.count > 0 {
                    self.feedObj!.comments?.remove(at: currentIndex.row)
                    self.feedArray[self.indexPath!.row] = self.feedObj!
                    self.feedDetailTableView.reloadData()
                    self.editCommentObj = nil
                    if currentIndex.row == 0 {
                        self.commentDeletedFromDetailHandler?(self.indexPath!)
                    }
                }
            }
        }else if type == "Edit" {
            self.editCommentHandling()
        }
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath){
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.isPost = ReportType.Post
        reportDetail.delegate = self
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        reportDetail.feedObj = self.feedObj
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments![currentIndex.row]
            reportDetail.isPost = ReportType.Comment
        }
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension FeedDetailController:DismissReportDetailSheetDelegate   {
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}

extension FeedDetailController:LanguageSelectionDelegate {
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        
    }
    func lanaguageSelected(langObj: LanguageModel) {
        self.sheetController.closeSheet()
        self.selectedLangModel = langObj
        
        if self.isAudioOrVideo {
            self.audioLangBtn.setTitle(" "+(self.selectedLangModel?.languageName)!, for: .normal)
        }else {
            self.feedUploadObj!.languageCode = langObj.languageID
            self.feedUploadObj!.languageName = langObj.languageName
            self.uploadingView.manageLanguage(uploadObj:self.feedUploadObj!)
        }
    }
}

extension FeedDetailController:GifImageSelectionDelegate  {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        if gifDict.count > 0 {
            for (_, gifObj) in gifDict {
                self.manageViewToUploadVideo()
                self.feedUploadObj =  self.uploadingView.handlingUploadFeedView(fileType: "GIF", selectLang: false, videoUrl: "",imgUrl:gifObj.url, isPosting: false)
            }
        }
    }
}


extension FeedDetailController:MPMediaPickerControllerDelegate  {
    
    func openMusicAlbum(){
        self.musicPlayer = MPMediaPickerController(mediaTypes: .anyAudio)
        self.musicPlayer!.delegate = self
        self.musicPlayer!.allowsPickingMultipleItems = false
        self.present(self.musicPlayer!, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)  {
        self.musicPlayer!.dismiss(animated: true, completion: {
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let item: MPMediaItem = mediaItemCollection.items[0]
            let pathURL: NSURL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            if pathURL == nil {
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                SharedManager.shared.showAlert(message: "Not able to get the audio file.".localized(), view: self)
                return
            }
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "myAudioFile"
            FileBasedManager.shared.saveAudioFileTemporarily(pathURL: pathURL!, name: title)
            FileBasedManager.shared.audioFileSavedInTemp = { fileUrl in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                self.manageViewToUploadVideo()
                self.feedUploadObj =  self.uploadingView.handlingUploadFeedView(fileType: "audio", selectLang: true, videoUrl: fileUrl.path, imgUrl:"", isPosting: false)
            }
        })
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)   {
        mediaPicker.dismiss(animated: true, completion: nil)
        //        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
    }
}

extension FeedDetailController: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
        let types = ["public.item"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = false
        } else {
            // Fallback on earlier versions
        }
        documentPicker.modalPresentationStyle = .formSheet
        if #available(iOS 13, *) {
            documentPicker.overrideUserInterfaceStyle = .dark
            documentPicker.shouldShowFileExtensions = true
        }
        self.present(documentPicker, animated: true) {
            
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}
        self.manageViewToUploadVideo()
        self.feedUploadObj =  self.uploadingView.handlingUploadFeedView(fileType: "attachment", selectLang: true, videoUrl: url.path, imgUrl:"", isPosting: false,  fileExt:url.pathExtension)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func downloadAttachment(sender : UIButton){
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            do {
                let imageData = try Data(contentsOf: URL.init(string: self.feedObj!.post!.first!.filePath!)!)
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.present(activityViewController, animated: true) {
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
            } catch {
                
            }
        }
    }
    
    func downloadCommentAttachment(commentFile:CommentFile){
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            do {
                let imageData = try Data(contentsOf: URL.init(string: commentFile.orignalUrl!)!)
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.present(activityViewController, animated: true) {
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
            } catch {
                
            }
        }
    }
}

// Handling Video Downloads...
extension FeedDetailController:GalleryViewScrollDelegate {
    func scrollPageChange(pageNumber: Int){
        //        self.manageVideoDownloadBtn(pageNumber: pageNumber)
    }
    
    func manageVideoDownloadBtn(pageNumber:Int) {
        self.downloadBtn.isHidden = true
        self.downloadPLbl.isHidden = true
        let postObj = self.feedObj!.post![pageNumber]
        self.pageNumber = pageNumber
        if postObj.fileType == FeedType.video.rawValue {
            if postObj.processingStatus == "done" {
                self.downloadBtn.isHidden = false
                self.manageDownloadHandler(id: postObj.fileID!)
            }
        }
    }
    
    func manageVideo()  {
        if self.feedObj!.postType == FeedType.video.rawValue {
            if self.feedObj!.post!.count > 0 {
                let postFile:PostFile = self.feedObj!.post![0]
                self.manageDownloadHandler(id: postFile.fileID!)
            }
        }
        else if self.feedObj!.postType == FeedType.gallery.rawValue {
            if self.feedObj!.post!.count > 0 {
                let postFile:PostFile = self.feedObj!.post![0]
                if postFile.fileType == FeedType.video.rawValue {
                    if postFile.processingStatus == "done" {
                        self.downloadBtn.isHidden = false
                        self.manageDownloadHandler(id: postFile.fileID!)
                    }
                }
            }
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
        if self.feedObj!.post!.count > 0 {
            var postFile:PostFile?
            if self.feedObj!.postType == FeedType.gallery.rawValue {
                postFile = self.feedObj!.post![self.pageNumber]
                if  self.galleryView != nil {
                    let cell = self.galleryView!.galleryCollectionView!.cellForItem(at: IndexPath(row: pageNumber, section: 0)) as! GalleryCollectionCell
                    if cell.videoView != nil {
                        if cell.videoView!.viewOgrinalLangBtn.isSelected  {
                            urlString = URL(string: postFile!.filePath ?? "")
                        }else {
                            if postFile!.convertedURL.count > 0 {
                                urlString = URL(string: postFile!.convertedURL)
                            }else
                            {
                                urlString = URL(string: postFile!.filePath ?? "")
                            }
                        }
                    }
                }
            }else {
                postFile = self.feedObj!.post![0]
                if postFile!.processingStatus == "done" {
                    if self.videoView!.viewOgrinalLangBtn.isSelected  {
                        urlString = URL(string: postFile!.filePath ?? "")
                    }else {
                        if postFile!.convertedURL.count > 0 {
                            urlString = URL(string: postFile!.convertedURL)
                        }else
                        {
                            urlString = URL(string: postFile!.filePath ?? "")
                        }
                    }
                }
            }
            let downloadObj = DownloadFeedManager.init()
            downloadObj.startDownload(downloadUrl: urlString!)
            FeedCallBManager.shared.feedDownloadDict[postFile!.fileID!] = downloadObj
            DispatchQueue.main.async {
                downloadObj.downloadPLbl = self.downloadPLbl
                self.downloadBtn.isHidden = true
                self.downloadPLbl.isHidden = false
            }
        }
    }
    
    
    @IBAction func showLikeSheetAction(sender : UIButton){
        let feedObj = self.feedObj
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        pagerController.feedObj = feedObj
        pagerController.parentView = self
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
        
    }
    func updateNewsFeedOnAnyReaction(){
        let dic: [String : Any] = [
            "feedObject": self.feedObj,
            "indexpath": self.selectedIndexPath
        ]
  //      self.postDetailDelegate?.didReceiveNewDataFromPostDetail(feedData: self.feedObj, at: <#T##IndexPath#>)
        NotificationCenter.default.post(name: .updateNewsFeedOnReactionChange, object: dic)
    }
    
    func dislikeLike() {
        if NetworkReachability.isConnectedToNetwork() {
            //            self.imgViewlikeFirst.image = UIImage(named: "NewIconLiked")
            //            self.imgViewlikeSecond.image = UIImage(named: "NewIconLikeU")
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription) 
            return
        }
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react", "token":userToken, "type": self.feedObj!.isReaction! , "post_id":String(self.feedObj!.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self.likeBtn.isUserInteractionEnabled = true
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SharedManager.shared.showAlert(message: res as! String, view: UIApplication.topViewController()!)
                        } else {
                            if self.feedObj!.reationsTypesMobile != nil {
                                if self.feedObj!.reationsTypesMobile!.count > 0  {
                                    for obj in 0..<self.feedObj!.reationsTypesMobile!.count {
                                        if self.feedObj!.reationsTypesMobile![obj].type == self.feedObj!.isReaction {
                                            self.feedObj!.reationsTypesMobile![obj].count! = self.feedObj!.reationsTypesMobile![obj].count! - 1
                                            if self.feedObj!.reationsTypesMobile![obj].count! == 0 {
                                                self.feedObj!.reationsTypesMobile!.remove(at: obj)
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                            
                            if self.feedObj!.likeCount == nil {
                                self.feedObj!.likeCount = 0
                            } else {
                                self.feedObj!.likeCount =  self.feedObj!.likeCount! - 1
                            }
                            self.feedObj!.isReaction = ""
                            self.manageUI()
                            self.updateNewsFeedOnAnyReaction()
                            //                    self.feedDetailTableView.reloadData()
                        }
                        self.likeBtn.isUserInteractionEnabled = true
                    }
                }
            }, param:parameters)
        }
    }
}




extension FeedDetailController : ReactionDelegateResponse {
    func reactionResponse(feedObj:FeedData){
        self.feedObj = feedObj
        
        self.manageUI()
        SharedManager.shared.popover.dismiss()
    }
}
extension FeedDetailController : PostViewDelegate{
   
    func didSelectHashtag(hashtag : String){
        if hashtag.isValidForUrl(){
            if let hashtagURL = URL(string: hashtag ?? "") {
                UIApplication.shared.open(hashtagURL, options: [:], completionHandler: nil)
                
            }
            return
        }
            let tagSection = HashTagVC.instantiate(fromAppStoryboard: .Shared)
            tagSection.Hashtags = hashtag
        tagSection.isFromReelScreen = true
        self.navigationController?.pushViewController(tagSection, animated: true)
        }
}
