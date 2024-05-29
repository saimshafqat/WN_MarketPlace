//
//  Tags VC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 06/04/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Accelerate
import SDWebImage
import Speech
import FittedSheets
import TLPhotoPicker
import Photos
import MediaPlayer

class TagsVC : UIViewController, UINavigationControllerDelegate {
//    let LEVEL_LOWPASS_TRIG:Float32 = 0.30
//    var speechSynthesizer = AVSpeechSynthesizer()
//    let audioEngine = AVAudioEngine()
//    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
//    let request = SFSpeechAudioBufferRecognitionRequest()
//    var recognitionTask: SFSpeechRecognitionTask?
//    var isRecording = false
//    var isCommentCamera:Bool = true
//    var averagePowerForChannel0:Float = 0.0
    var currentIndex = IndexPath()
//    var selectedLangID = ""
//    var selectedLangModel:LanguageModel?
    var sheetController = SheetViewController()
//    var selectionHeaderType = ""
//    var commentOptionState = -1
//    var musicPlayer:MPMediaPickerController?
    
    
//    var isPostSearch = false
//    var searchPost = ""
    
    @IBOutlet weak var lblEmpty: UILabel!
    
    @IBOutlet weak var lblTagMain: UILabel!
    @IBOutlet weak var lblTagDescription: UILabel!
    
    @IBOutlet weak var lblTags: UILabel!
    
//    @IBOutlet weak var commentGifBrowseBtn: UIButton!
//    @IBOutlet weak var commentCameraBtn: UIButton!
//    @IBOutlet weak var commentRecordBtn: UIButton!
    
//    @IBOutlet weak var switchBtn: UISwitch!
//    @IBOutlet weak var dropDownBtn: DesignableButton!
//    @IBOutlet weak var commentDropDownView: UIView!
//    @IBOutlet weak var langView: UIView!
    @IBOutlet weak var saveTableView: UITableView!
//    @IBOutlet weak var searchField: DesignableTextField!
    
//    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
//    let dropDown = MakeDropDown()
//    var dropDownRowHeight: CGFloat = 35
//    var selectedAssets = [PostCollectionViewObject]()
    
    fileprivate let viewModel = TagsViewModell()
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    
    var Hashtags = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblEmpty.isHidden = true
//        if !self.isPostSearch {
//            self.title = "Saved Posts".localized()
//        }
        self.lblTagMain.text = ""
        self.lblTagDescription.text = ""
        
        ManageTableView()
//        setUpDropDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SharedManager.shared.feedRef = self
        ManageTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callBackHandling()
        SharedManager.shared.isGroup = 0
//        IQKeyboardManager.shared.enableAutoToolbar = true
//        IQKeyboardManager.shared.enable = true
        if SharedManager.shared.isNewPostExist {
            SharedManager.shared.isNewPostExist = false
            self.handleRefresh()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    func ManageTableView()    {

            self.viewModel.initializeMe(action:"hashtag")
        
        self.viewModel.parentView = self
        saveTableView.dataSource = viewModel
        saveTableView.delegate = viewModel
        saveTableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.identifier)
        saveTableView.register(VideoCell.nib, forCellReuseIdentifier: VideoCell.identifier)
        saveTableView.register(UINib.init(nibName: "NewVideoFeedCell", bundle: nil), forCellReuseIdentifier: "NewVideoFeedCell")
        saveTableView.register(UINib.init(nibName: "NewAudioFeedCell", bundle: nil), forCellReuseIdentifier: "NewAudioFeedCell")
        saveTableView.register(UINib.init(nibName: "NewGalleryFeedCell", bundle: nil), forCellReuseIdentifier: "NewGalleryFeedCell")
        saveTableView.register(UINib.init(nibName: "NewAttachmentFeedCell", bundle: nil), forCellReuseIdentifier: "NewAttachmentFeedCell")
        saveTableView.register(UINib.init(nibName: "NewSharedFeedCell", bundle: nil), forCellReuseIdentifier: "NewSharedFeedCell")
        saveTableView.register(UINib.init(nibName: "NewTextFeedCell", bundle: nil), forCellReuseIdentifier: "NewTextFeedCell")
        saveTableView.register(UINib.init(nibName: "AdCell", bundle: nil), forCellReuseIdentifier: "AdCell")
        
        saveTableView.register(AudioCell.nib, forCellReuseIdentifier: AudioCell.identifier)
        saveTableView.register(SkeletonCell.nib, forCellReuseIdentifier: SkeletonCell.identifier)
        saveTableView.register(GalleryCell.nib, forCellReuseIdentifier: GalleryCell.identifier)
        saveTableView.register(ImageCellSingle.nib, forCellReuseIdentifier: ImageCellSingle.identifier)
        saveTableView.register(UINib.init(nibName: "NewImageFeedCell", bundle: nil), forCellReuseIdentifier: "NewImageFeedCell")
        saveTableView.register(SharedCell.nib, forCellReuseIdentifier: SharedCell.identifier)
        saveTableView.register(AttachmentCell.nib, forCellReuseIdentifier: AttachmentCell.identifier)
        
        saveTableView.estimatedRowHeight = 500
        saveTableView.rowHeight = UITableView.automaticDimension
        self.viewModel.refreshControl.addTarget(viewModel, action: #selector(self.viewModel.refresh(sender:)), for: UIControl.Event.valueChanged)
        saveTableView.addSubview(self.viewModel.refreshControl)
    }
    
    func manageFeedLikeDislikeSheet(currentIndex:Int){
        let feedObj = self.viewModel.feedArray[currentIndex]
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        pagerController.parentView = self
        pagerController.feedObj = feedObj
        self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    func callBackHandling(){
        
        self.viewModel.feedScrollHandler = { () in
//            self.commentDropDownView.isHidden = true
        }
        
        self.viewModel.reloadTableViewClosure = { () in
            self.saveTableView.reloadData()
        }
        
        self.viewModel.didSelectTableClosure = { [weak self](indexValue) in

        }
        
        self.viewModel.reloadSpecificRow = { (indexValue) in
            
            self.saveTableView.reloadRows(at: [indexValue], with: UITableView.RowAnimation.none)
        }
        self.viewModel.reloadVisibleRows = { (indexValue) in
            self.saveTableView.reloadRows(at: self.saveTableView.indexPathsForVisibleRows!, with: UITableView.RowAnimation.none)
        }
        self.viewModel.hideFooterClosure = { () in
            self.saveTableView.tableFooterView?.removeFromSuperview()
        }
        self.viewModel.showAlertMessageClosure = { (message) in
            SharedManager.shared.showAlert(message: message, view: self)
        }
        self.viewModel.reloadTableViewWithNoneClosure = { () in
            self.saveTableView.reloadData()
        }
        
        self.viewModel.showShareOption = { (indexValue) in
            let feedObj = self.viewModel.feedArray[indexValue] as FeedData
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // your code here
                do {
                    let imageData = try Data(contentsOf: URL.init(string: (feedObj.post?.first!.filePath)!)!)
                    let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                    self.present(activityViewController, animated: true) {
//                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                        Loader.stopLoading()
                    }
                } catch {
                    // LogClass.debugLog("Unable to load data: \(error)")
                }
                
            }
        }
        self.viewModel.presentImageFullScreenClosure = { (indexValue, isGroup) in
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            var feedObj:FeedData?
            if isGroup {
                feedObj = self.viewModel.feedArray[indexValue] as FeedData
                feedObj = feedObj?.sharedData
            }else {
                feedObj = self.viewModel.feedArray[indexValue] as FeedData
            }
            fullScreen.collectionArray = feedObj!.post!
            fullScreen.modalTransitionStyle = .crossDissolve
            self.present(fullScreen, animated: true, completion: nil)
        }
        
        FeedCallBManager.shared.commentImageTappedHandler = { [weak self] (indexValue) in
            let fullScreen = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.FullScreenController) as! FullScreenController
            fullScreen.typeOfImage = "comment"
            let feedObj = self!.viewModel.feedArray[indexValue.row] as FeedData
            var commentCount:Int = 0
            if feedObj.comments!.count > 0 {
                commentCount = (feedObj.comments?.count)! - 1
            }
            fullScreen.commentObj = (feedObj.comments![commentCount]).commentFile![0]
            fullScreen.modalTransitionStyle = .crossDissolve
            self!.present(fullScreen, animated: false, completion: nil)
        }
        
        
        FeedCallBManager.shared.likeCallBackManager = { (currentIndex) in
            self.manageFeedLikeDislikeSheet(currentIndex: currentIndex)
        }
        
        FeedCallBManager.shared.speakerHandler = { [weak self] (currentIndex, isComment) in
            FeedCallBManager.shared.manageSpeakerForVisibleCell(tableCellArr: self!.saveTableView.visibleCells, currentIndex:currentIndex, feedArray: self!.viewModel.feedArray, isComment: isComment)
        }
        FeedCallBManager.shared.dropDownFeedHanlder = { [weak self] (currentIndex) in
            let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
            reportController.delegate = self
            reportController.reportType = "Saved"
            reportController.currentIndex = currentIndex
            reportController.feedObj = self!.viewModel.feedArray[currentIndex.row] as FeedData
//            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            self!.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            self!.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self!.sheetController.extendBackgroundBehindHandle = true
            self!.sheetController.topCornersRadius = 20
            self!.present(self!.sheetController, animated: false, completion: nil)
        }
        


        
        FeedCallBManager.shared.updateVideoViewSeekTimeForNewsFeedHandler = { [weak self] (feedIndex, currentIndex, seekTime) in
            let feedObjUpdate:FeedData = self!.viewModel.feedArray[feedIndex.row]
            let postObj = feedObjUpdate.post![currentIndex.row]
            postObj.videoSeekTime = seekTime
            feedObjUpdate.post![currentIndex.row] = postObj
            self!.viewModel.feedArray[feedIndex.row] = feedObjUpdate
        }
        
        FeedCallBManager.shared.showMessageAlertyHandler = {[weak self] (message) in
            SharedManager.shared.showAlert(message: message, view: self!)
        }
        
        FeedCallBManager.shared.userProfileHandler = {[weak self] (userID) in
            if Int(userID) == SharedManager.shared.getUserID() {
                self?.tabBarController?.selectedIndex = 3
            }else {
                let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
                vcProfile.isNavPushAllow = true
                self?.navigationController?.pushViewController(vcProfile, animated: true)
            }
        }
        
        //MARK: - Uploading handelrs
        FeedCallBManager.shared.uploadingCloseHandler = {[weak self] (currentIndex) in
            self!.saveTableView.reloadRows(at: [currentIndex], with: UITableView.RowAnimation.none)
        }

        FeedCallBManager.shared.downloadFileHandler  = { [weak self] (currentIndex, commentFile) in
        }
    }
    
    func handleRefresh(){
        DispatchQueue.main.async {
            self.saveTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        }
        viewModel.refreshControl.beginRefreshingManually()
        viewModel.refresh(sender: UIButton())
    }
    

    
}



extension TagsVC:DismissReportSheetDelegate {
    
    func dismissReportWithMessage(message:String)   {
        SharedManager.shared.ShowsuccessAlert(message: message,AcceptButton: "OK".localized()) { status in
            self.sheetController.closeSheet()
        }
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
            }
            //self.perform(#selector(showReportDetailSheet), with: nil, afterDelay: 0.5)
        }else if type == "Delete" || type == "Hide"  {
            let feedObj = self.viewModel.feedArray[currentIndex.row]
            if feedObj.comments!.count > 0 {
                var commentCount:Int = 0
                if feedObj.comments!.count > 0 {
                    commentCount = (feedObj.comments?.count)! - 1
                }
                FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.saveTableView.visibleCells)
                feedObj.comments?.remove(at: commentCount)
                self.viewModel.feedArray[currentIndex.row] = feedObj
                self.saveTableView.reloadRows(at: [currentIndex], with: .none)
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        self.sheetController.closeSheet()
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(currentIndex: currentIndex)
            }
        }else if type == "Delete" || type == "Hide" {
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: self.saveTableView.visibleCells)
            self.viewModel.feedArray.remove(at: currentIndex.row)
            self.saveTableView.deleteRows(at: [currentIndex], with: .fade)
            self.saveTableView.reloadData()
        }else if type.contains("Hide all") {
            self.handleRefresh()
        }else if type.contains("Block") {
            self.handleRefresh()
        }else if type == "UnSave" {
            self.viewModel.feedArray.remove(at: currentIndex.row)
            self.saveTableView.deleteRows(at: [currentIndex], with: .fade)
            self.saveTableView.reloadData()
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
        reportDetail.feedObj = self.viewModel.feedArray[currentIndex.row] as FeedData
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments![0]
            reportDetail.isPost = ReportType.Comment
        }
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension TagsVC:DismissReportDetailSheetDelegate   {
    func dismissReport(message:String) {
        // LogClass.debugLog(message)
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}

