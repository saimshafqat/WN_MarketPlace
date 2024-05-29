//
//  LikeBarView.swift
//  WorldNoor
//
//  Created by Raza najam on 9/19/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import FittedSheets

class FeedCommentBarView: UIView {
    
    @IBOutlet weak var commentHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var likeCounterBtn: UIButton!
    @IBOutlet weak var commentCounterBtn: UIButton!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentCounter: UILabel!
    @IBOutlet weak var shareCounterBtn: UIButton!
    var pageNumber:Int = 0
    
    var sheetController = SheetViewController()
    var xqAudioPlayer: XQAudioPlayer!
    var feedObj:FeedData? = nil
    var audioRecorderObj:AudioRecorder? = nil
    var someChangeInTextView = ""
    var likeDislikeCallBack: ((Bool, Bool) -> Void)?
    var textEmptyCallbackHandler: ((Bool) -> Void)?
    var commentServiceCallbackHandler: ((Any) -> Void)?
    var commentSentInstantlyHandler: ((String) -> Void)?
    var commentButtonHandler: ((IndexPath) -> Void)?
    var singleImageView:SingleImageView? = nil
    var attachmentView:AttachmentView?
    var videoView:VideoView? = nil
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    var selectionHeaderType = ""
    var selectedLangModel:LanguageModel?
    let dropDown = MakeDropDown()
    var dropDownRowHeight: CGFloat = 35
    var selectedAssets = [PostCollectionViewObject]()
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var langSelectionType = ""
    var uploadView:FeedUploadingView?
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    var viewOgrinalLangBtn:Bool = false
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        self.audioRecorderObj = nil
    }
    
    func manageMyView(feedObj:FeedData) {
        self.feedObj = feedObj

        self.lanaguageModelArray = SharedManager.shared.lanaguageModelArray
        self.manageLikeDislikeUI()
        self.manageComment()
        self.manageCount()
        self.manageVideo()
        
        
        if let likeCounter = self.feedObj?.likeCount {
            var counterValue = ""
            if likeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = String(likeCounter)
            }
            self.likeCounter.text = counterValue
        }
        
        
        
        if let commentCount = self.feedObj?.commentCount {
            var counterValue = ""
            if commentCount == 0 {
                counterValue = ""
            }else {
                counterValue = " " + String(commentCount)
            }
            self.commentCounter.text = counterValue
        }
        
        
        self.likeBtn.isSelected = self.feedObj!.isLiked!
        self.labelRotateCell(viewMain: self.commentCounterBtn)
        self.labelRotateCell(viewMain: self.shareCounterBtn)
        self.labelRotateCell(viewMain: self.likeCounterBtn)
        
        self.commentCounterBtn.rotateForTextAligment()
        self.likeCounterBtn.rotateForTextAligment()
        self.shareCounterBtn.rotateForTextAligment()
        
        
        self.frame.size = CGSize.init(width: UIScreen.main.bounds.width - 20, height: self.frame.size.height)
    }
    
    func manageComment(){
        
//        self.reportBtn.isHidden = false
        self.singleImageView?.removeFromSuperview()
        self.attachmentView?.removeFromSuperview()
        self.videoView?.removeFromSuperview()

        self.layoutIfNeeded()
    }
    

    
    @IBAction func originalAction(sender : UIButton){
        

    }

    
    @IBAction func commentSpeakerBtnClicked(_ sender: Any) {

    }
    
    func manageCount(){

    }
    
    @IBAction func likeCounterBtnClicked(_ sender: Any) {
        if self.feedObj?.likeCount != 0 {
            FeedCallBManager.shared.likeCallBackManager?(self.currentIndex.row)
        }
    }
    
    @IBAction func disLikeCounterBtnClicked(_ sender: Any) {
        if self.feedObj?.simple_dislike_count != 0 {
            FeedCallBManager.shared.likeCallBackManager?(self.currentIndex.row)
        }
    }
    
    @IBAction func commentCounterBtnClicked(_ sender: Any) {
        
        
    }
    
    @IBAction func shareCounterBtnClicked(_ sender: Any) {
        
        if self.feedObj?.shareCount != 0 {
            FeedCallBManager.shared.likeCallBackManager?(self.currentIndex.row)
        }
    }
    
    @IBAction func cameraBtnClicked(_ sender: Any) {
        FeedCallBManager.shared.commentOptionBtnHandler?(self.currentIndex, sender as! UIButton)
    }
    
    @IBAction func galleryBtnClicked(_ sender: Any) {
        FeedCallBManager.shared.commentOptionBtnHandler?(self.currentIndex, sender as! UIButton)
    }
    

    
    func manageAudioRecorder(){
    }
    
    func manageLikeDislikeUI(){
        self.likeBtn.isSelected = self.feedObj?.isLiked ?? false
    }
    
    // MARK: Action Buttons.
    @IBAction func likeBtnClicked(_ sender: Any) {
        
        
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(self.feedObj!.postID!)
        
        var dic = [String : Any]()
        dic["likesCount"] = String(self.feedObj!.likeCount!)
        dic["group_id"] = String(self.feedObj!.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_like_NOTIFICATION"
        
        
        if self.likeBtn.isSelected {
            self.likeBtn.isSelected = false
            if self.likeCounter.text!.count > 0 {
                let textMain = Int(self.likeCounter.text!)!
//                self.imgViewlike.image = UIImage.init(named: "NewIconLikeU")
//                self.likeBtn.isSelected = true
                self.likeCounter.text = String(textMain - 1)
            }
        }else {
            self.likeBtn.isSelected = true
            SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
            
            if self.likeCounter.text!.count > 0 {
                let textMain = Int(self.likeCounter.text!)!
                self.likeCounter.text = String(textMain + 1)
            }else {
                self.likeCounter.text = "1"
            }
            
//            self.imgViewlike.image = UIImage.init(named: "NewIconLiked")
//            self.likeBtn.isSelected = true
        }
        
        self.feedObj!.isLiked = self.likeBtn.isSelected
        self.feedObj!.likeCount = Int(self.likeCounter.text!)!
        
        var parameters = ["action": "react","token": SharedManager.shared.userToken(), "type": "like_simple_like", "post_id":String(self.feedObj!.postID!)]
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        }else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        UIApplication.topViewController()?.callingAPI(parameters: parameters)
        
       
    }
    
    @IBAction func disLikeBtnClicked(_ sender: Any) {
        

    }
    
    @IBAction func commentBtnClicked(_ sender: Any) {

    }
    
    @IBAction func viewMoreBtnClicked(_ sender: Any) {
        self.commentButtonHandler?(currentIndex)
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(self.feedObj!.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        self.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        SharedManager.shared.feedRef!.present(self.sheetController, animated: true, completion: nil)
    }
    
    
    @IBAction func sendCommentBtnClicked(_ sender: Any) {

    }
    
    func callingService(parameters:[String:String], action:String)  {
        var fileUrl = ""
        var paramDict = parameters
        if self.audioRecorderObj?.filename != "" {
            fileUrl = (self.audioRecorderObj?.fileUrl().absoluteString)!
            self.audioRecorderObj?.filename = ""
            paramDict["recording_language_id"] =  self.selectedLangModel?.languageID
            self.selectedLangModel = nil
        }
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
                        self.commentServiceCallbackHandler?(res as! String)
                    }else {
                        self.commentServiceCallbackHandler?(res as! NSDictionary)
                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
                        NotificationCenter.default.post(name: Notification.Name(Const.KCommentUpdatedNotif), object: nil)
                    }
                }
            }
        }, param:paramDict, fileUrl: fileUrl)
    }
    
    @IBAction func progressValueChanged(_ sender: Any) {

    }
    
    @IBAction func reportBtnClicked(_ sender: Any) {

    }
    
    @IBAction func audioLangSelectionBtnClicked(_ sender: Any) {
    }
    
    func langSelectionView()    {

    }
    
    
    
    @objc func uploadLangSelectionBtn(){
    }
    
    @objc func closeUploadingView() {
    }
}

extension FeedCommentBarView:AGAudioRecorderDelegate {
    func agPlayerTimerDelegate(timeLeft:String){
    }
    
    func agPlayerFinishedPlaying() {
    }
    
    func agAudioRecorder(_ recorder: AudioRecorder, withStates state: AGAudioRecorderState) {
        
    }
    
    func agAudioRecorder(_ recorder: AudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {

    }
    
    @IBAction func audioRecordBtnClicked(_ sender: Any) {

    }
    
    @IBAction func audioPlayBtnClicked(_ sender: Any) {
    }
    
    @IBAction func audioStopBtnClicked(_ sender: Any) {
    }
    
    @IBAction func audioCancelBtnClicked(_ sender: Any) {
    }
    
    @IBAction func audioPauseBtnClicked(_ sender: Any) {
    }
}

extension FeedCommentBarView:XQAudioPlayerDelegate {
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


extension FeedCommentBarView:LanguageSelectionDelegate {
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        
    }
    func lanaguageSelected(langObj: LanguageModel) {
    }
}
// Handling Video Downloads...
extension FeedCommentBarView {
    func manageVideo()  {

    }

    
    @IBAction func downloadBtnClicked(_ sender: Any) {

    }
}
