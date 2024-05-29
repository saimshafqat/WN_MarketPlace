//
//  FeedHeaderView.swift
//  WorldNoor
//
//  Created by Raza najam on 4/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import MobileCoreServices
import FittedSheets
import SDWebImage

class FeedHeaderView: UIView {
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var cstHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var cstHeight: NSLayoutConstraint!
    @IBOutlet weak var cstCreatePostHeight: NSLayoutConstraint!
    
    var pageNumber: Int = 1
    var isWatch : Bool = false
    var parentControl:FeedViewController?
    var videoClipArray:[FeedVideoModel] = [FeedVideoModel]()
    let feedModel = FeedVideoModel.init()
    var sheet = SheetViewController()
    var selectedLangTag = -1
    var startingPoint = ""
    var isNextVideoExist = true
    var isAPICall = false
    
    var isExpended = false
    //    var videoClipModelArray:[VideoClipModel] = [VideoClipModel]()
    
    var watchArray: [FeedData] = [FeedData]()
    let audioSettings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 128000
    ]
    
    func manageFeedHeader() {
        
        self.Loader.startAnimating()
        if isWatch {
            
            self.watchArray.removeAll()
            self.pageNumber = 1
            callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
            return
        }
        
        
        if SharedManager.shared.checkLanguageAlignment() {
            self.videoCollectionView.rotateViewForLanguage()
        }
        
        self.videoCollectionView.register(UINib.init(nibName: "VideoClipUploadCollectionCell", bundle: nil), forCellWithReuseIdentifier: "VideoClipUploadCollectionCell")
        self.videoCollectionView.register(UINib.init(nibName: "StoryEndCell", bundle: nil), forCellWithReuseIdentifier: "StoryEndCell")
        // reel create reel cell
        self.videoCollectionView.register(UINib.init(nibName: "CreateReelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateReelCollectionViewCell")
        
        self.isAPICall = true
        //        self.videoClipModelArray.removeAll()
        var param = ["action": "stories/stories_for_all_users",
                     "token": SharedManager.shared.userToken()]
        param["starting_point_id"] = self.startingPoint
        
        
        if self.videoClipArray.count == 0 {
//            SharedManager.shared.showOnWindow()
//            Loader.startLoading()
        }
        self.callingStoriesService(action: "stories/stories_for_all_users", param: param)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableWithNewdata), name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil)
    }
    
    @objc func reloadTableWithNewdata() {
        
        self.isExpended = false
        if FeedCallBManager.shared.videoClipArray.count > 0 {
            self.startingPoint = FeedCallBManager.shared.videoClipArray.last!.videoID
            self.videoClipArray = FeedCallBManager.shared.videoClipArray
            
            if SharedManager.shared.createStory != nil {
                //                self.videoClipArray.removeAll()
                
                self.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
                SharedManager.shared.createStory = nil
            }
          
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timerMain in
                self.videoCollectionView.reloadData()
            }
            //            self.videoCollectionView.reloadData()
        }
        
    }
    
    func resetAndReload() {
        
        self.isNextVideoExist = true
        self.startingPoint = ""
        
        //        self.viewLoader.isHidden = false
        self.Loader.startAnimating()
        
        
        if isWatch {
            
            self.watchArray.removeAll()
            self.pageNumber = 1
            callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
            
            return
        }
        
        FeedCallBManager.shared.videoClipArray.removeAll() // Waseem
        //        self.videoClipModelArray.removeAll()
        self.videoClipArray.removeAll()
        
        self.manageFeedHeader()
    }
    
//    @IBAction func addVideoBtn(_ sender: Any) {
        
        //        self.labelRotateCell(viewMain: self.videoSelectionView)
        //        if self.videoSelectionView.isHidden {
        //            self.videoSelectionView.isHidden = false
        //        }else {
        //            self.videoSelectionView.isHidden = true
        //        }
//    }
    
    
    func changeView() {
        
        if isWatch {
            if self.watchArray.count == 0 {
                
//                SharedManager.shared.showOnWindow()
//                Loader.startLoading()
                callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
                self.videoCollectionView.reloadData()
            } else {
                self.videoCollectionView.reloadData()
            }
        } else {
            self.videoCollectionView.reloadData()
        }
    }
    
    @IBAction func recordBtnClicked(_ sender: Any) {
        SharedManager.shared.isVideoPickerFromHeader = true
        VideoHelper.startMediaBrowser(delegate: self.parentControl!, sourceType: .camera, someMedia: [(kUTTypeMovie as String)])
    }
    
    @IBAction func browseBtnClicked(_ sender: Any) {
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        viewController.configure.mediaType = .video
        viewController.configure.maxSelectedAssets = 1
        self.parentControl!.present(viewController, animated: true) {
        }
    }
    
    func resetData() {
        FeedCallBManager.shared.videoClipArray.removeAll()
        self.videoClipArray.removeAll()
        //        self.videoClipModelArray.removeAll()
        self.startingPoint = ""
    }
    
    func callingStoriesService(action:String, param:[String:String]) {
        let apiResponseTimer = APIResponseTimer(startTime: .now())
        RequestManager.fetchDataPost(Completion: { response in
            let elapsedTime = apiResponseTimer.calculateElapsedTime()
            LogClass.debugLog("End Point \(param["action"]) ==> Response Time = \(elapsedTime)")
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    self.isNextVideoExist = false
                } else {
                    // if action == "UpdateVideo" {
                    //  self.updateVideoDataAfterProcessing(dict: res as! [String : Any])
                    // } else
                    if action == "stories" {
                        let arr = res as! [[String : Any]]
                        
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        } else {
                            let feedVideoObj:[FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            FeedCallBManager.shared.videoClipArray = feedVideoObj
                            //                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            self.videoCollectionView.reloadData()
                        }
                    } else if action == "stories/stories_for_all_users" {
                        let arr = res as! [[String : Any]]
                        
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        } else {
                            let feedVideoObj: [FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            
                            self.isAPICall = false
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            
                            if SharedManager.shared.createStory != nil {
                                
                                self.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
                                FeedCallBManager.shared.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
                                
                                SharedManager.shared.createStory = nil
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timerMain in
                                self.videoCollectionView.reloadData()
                            }
                            
                        }
                    }
                }
            }
        }, param:param)
    }
    
    func callingGetService(action:String, param:[String:String]) {
        
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isNextVideoExist = false
                    //                    self.videoAddBtn.isEnabled = true
                }else {
                    //                    self.videoCollectionView.isHidden = false
                    //                    self.viewLoading.isHidden = true
                    //                    if action == "UpdateVideo" {
                    //                        self.updateVideoDataAfterProcessing(dict: res as! [String : Any])
                    //                    }
                    //                    else
                    if action == "stories" {
                        //                        self.videoAddBtn.isEnabled = true
                        
                        let arr =  res as! [[String : Any]]
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        }else {
                            let feedVideoObj:[FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            //                            self.addVideoLbl.isHidden = true
                            //                            if feedVideoObj.count == 0 {
                            //                                self.addVideoLbl.isHidden = false
                            //                            }
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            self.videoCollectionView.reloadData()
                        }
                    }
                }
            }
        }, param:param)
    }
    
    func callingPostService(action:String, param:[String:String]) {
        
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    
                } else {
                    if action == "VideoClip" {
                        
                    } else if action == "DeleteVideo" {
                        
                    }
                }
            }
        }, param:param)
    }
}

extension FeedHeaderView:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: (self.videoCollectionView.frame.size.height / 3) * 2, height: self.videoCollectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.isWatch { // reel
            if section == 0 {
                return 1
            } else if section == 1 { // reels
                if self.watchArray.count > 0 {
                    self.Loader.stopAnimating()
                }
                return self.watchArray.count
            } else if section == 2 { // see more
                return 1
            }
            
        } else { // stories
            if section == 0 {
                return 1
            } else {
                if self.videoClipArray.count > 0 {
                    self.Loader.stopAnimating()
                }
                return self.videoClipArray.count
            }
        }
        return 0
        
        //-------------old logic--------
//        if section == 0 {
//            if self.isWatch {
//                if self.isWatch {
//                    if self.watchArray.count > 0 {
//                        self.Loader.stopAnimating()
//                    }
//                    return self.watchArray.count
//                }
//            }
//            return 1
//        } else {
//            if self.isWatch {
//
//                //                if self.pageNumber > 1 {
//                //                    if (self.pageNumber % 2) == 0{
//                return 1
//                //                    }
//                //                }
//                //                return 0
//            }
//        }
//
//        if self.videoClipArray.count > 0 {
//            self.Loader.stopAnimating()
//        }
//        return self.videoClipArray.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isWatch { // reels
            return 3
        } else { // stories
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // reel  //  watch = true in case of reel
        if isWatch && indexPath.section == 0 { // add reel
            guard let createReel = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateReelCollectionViewCell", for: indexPath) as? CreateReelCollectionViewCell else {
                return UICollectionViewCell()
            }
            createReel.btnUpload.addTarget(self, action: #selector(self.showCreateReelScreen), for: .touchUpInside)
            return createReel
        }
        
        if isWatch && indexPath.section == 2 { // see more reel
            
            guard let cellLoadMore = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryEndCell", for: indexPath) as? StoryEndCell else {
                return UICollectionViewCell()
            }
            
            cellLoadMore.lblTextMore.rotateViewForLanguage()
            cellLoadMore.lblTextMore.text = "See More Reels".localized()
            return cellLoadMore
            
        }

        if indexPath.section == 0 && !isWatch { // story upload
            
            guard let cellUpload = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipUploadCollectionCell", for: indexPath) as? VideoClipUploadCollectionCell else {
                return UICollectionViewCell()
            }
            
//            let fileName = "myImageToUpload.jpg"
            
//            if FileBasedManager.shared.loadImage(pathMain: fileName) == nil {
//                cellUpload.imgViewUser.loadImageWithPH(urlMain: (SharedManager.shared.userObj?.data.profile_image)!)
//            } else {
//                cellUpload.imgViewUser.image = FileBasedManager.shared.loadImage(pathMain: fileName)
//            }
//            cellUpload.lblText.rotateViewForLanguage()
            let fileName = "myImageToUpload.jpg"
            if FileBasedManager.shared.fileExist(nameFile: fileName).1 {
                LogClass.debugLog("fileExist ==> 1 ")
                cellUpload.imgViewUser.image = FileBasedManager.shared.loadImage(pathMain: fileName)
            }else {
                LogClass.debugLog("fileExist ==> Else ")
                cellUpload.imgViewUser.loadImageWithPH(urlMain: SharedManager.shared.userObj?.data.profile_image ?? "")
            }
            
            
            cellUpload.btnUpload.addTarget(self, action: #selector(self.showPopup), for: .touchUpInside)
            return cellUpload
        }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipCollectionCell", for: indexPath) as? VideoClipCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.viewCount.isHidden = true
        if self.isWatch {
            // reel
//            cell.viewMain = self
            let indexMain = indexPath.row
            if self.watchArray.count > indexMain {
                let feedObj:FeedData = self.watchArray[indexMain]
                cell.profileImageView.loadImageWithPH(urlMain:feedObj.profileImage!)
                
                self.labelRotateCell(viewMain: cell.profileImageView)
                
                cell.descriptionLbl.isHidden = true
                cell.thumbnailImageView.isHidden = false
                if feedObj.post != nil {
                    if feedObj.post!.count > 0 {
                        cell.thumbnailImageView.loadImageWithPH(urlMain:feedObj.post![0].thumbnail!)
                    }
                }
                
                cell.nameLbl.text = ""
                cell.lblviewCount.text = String(feedObj.video_post_views!)
                cell.viewCount.isHidden = false
                cell.profileImageView.isHidden = true
                cell.videoDeleteBtn.isHidden = true
            }
            
        } else { // story
            cell.profileImageView.isHidden = false
//            cell.viewMain = self
            
            let indexMain = indexPath.row
            if indexMain < self.videoClipArray.count {
                
                let feedObj:FeedVideoModel = self.videoClipArray[indexMain]
                if feedObj.snaps.count > 0 {
                    cell.profileImageView.sd_setImage(with: URL(string: feedObj.snaps[0].authorImage), placeholderImage: UIImage(named: "placeholder.png"))
                }
                self.labelRotateCell(viewMain: cell.profileImageView)
                //                cell.selectLangBtn.addTarget(self, action: #selector(selectLanguageForUploading), for: .touchUpInside)
                cell.manageData(feedObj: feedObj, indexPath: IndexPath.init(row: indexPath.row, section: 1))
                cell.videoDeleteBtn.addTarget(self, action: #selector(deleteVideoClipBtn), for: .touchUpInside)
                //                cell.nameLbl.text = feedObj.authorName
                
                if feedObj.user != nil {
                    cell.nameLbl.text = feedObj.user!.name
                }
                
                if feedObj.snaps.count > 0 {
                    
                    let storyObj = feedObj.snaps[0]
                    if (storyObj.postType == "post" ) {
                        cell.backgroundColor =  UIColor.init().hexStringToUIColor(hex: feedObj.colorcode)
                        cell.thumbnailImageView.isHidden = true
                        cell.descriptionLbl.isHidden = false
                        cell.descriptionLbl.text = storyObj.body
                        return cell
                        
                    }
                    else if storyObj.postType == "image" {
                        cell.descriptionLbl.isHidden = true
                        cell.thumbnailImageView.isHidden = false
                        cell.thumbnailImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        cell.thumbnailImageView.sd_setImage(with: URL(string: storyObj.videoUrl), placeholderImage: UIImage(named: "placeholder.png"))
                        return cell
                    }
                    else if(storyObj.postType == "video") {
                        cell.descriptionLbl.isHidden = true
                        cell.thumbnailImageView.isHidden = false
                        if feedObj.status == "toUpload" {
                            cell.thumbnailImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                            cell.thumbnailImageView.sd_setImage(with: URL(fileURLWithPath:storyObj.videoThumbnail), placeholderImage: UIImage(named: "placeholder.png"))
                            self.labelRotateCell(viewMain: cell.thumbnailImageView)
                        }else {
                            cell.thumbnailImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                            cell.thumbnailImageView.sd_setImage(with: URL(string: storyObj.videoThumbnail), placeholderImage: UIImage(named: "placeholder.png"))
                            self.labelRotateCell(viewMain: cell.thumbnailImageView)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    @objc func showPopup(sender : UIButton){
        self.parentControl?.PushViewWithStoryBoard(name: "StoryModuleVC", StoryBoard: "StoryModule")
    }
    
    @objc func showCreateReelScreen(sender : UIButton) {
        let vc = CreateReelViewController()
        self.parentControl?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.paggingAPICall(indexPathMain: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            
            

            if isWatch { // reel
                if self.watchArray.count > 0 {
                    let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
                    controller.items = self.watchArray
                    controller.currentIndex = indexPath.row
                    controller.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)

                }else if self.watchArray.count == 0 {
                    return
                }
                
                
            } else { // story
                
                if self.videoClipArray.count == 0 {
                    return
                }
                for indexObj in self.videoClipArray {
                    indexObj.lastPlayedSnapIndex = 0
                }
                
                if MediaManager.sharedInstance.player != nil {
                    self.playSelectedVideo(videoIndex: indexPath.row)
                } else {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.playSelectedVideo(videoIndex: indexPath.row)
                    }
                    
//                    self.btnPlay.isHidden = true
//                    self.imgviewPlay.isHidden = true
                    
                    MediaManager.sharedInstance.player?.callbackPH = {(indexRow , urlString) -> Void in
//                        LogClass.debugLog("callbackPH ===> 333")
//                        LogClass.debugLog(indexRow)
//                        LogClass.debugLog(urlString)
                        
//                        self.btnPlay.isHidden = false
//                        self.imgviewPlay.isHidden = false
                        
                        MediaManager.sharedInstance.player?.view.backgroundColor = UIColor.white
//                        self.imgviewPH.isHidden = true
                    }
                    
                
                    MediaManager.sharedInstance.playEmbeddedVideo(url: URL.init(string: "https://cdn.worldnoordev.com/files/wn263870a278791063870a278791363870a2787914_6033681.mp4")!, embeddedContentView:self.parentControl!.viewPlayer ,userinfo: ["isHideSound" : true])
                }
            }
        } else if indexPath.section == 2 { // in case of reel only see more reel
            let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
            controller.items = self.watchArray
            controller.currentIndex = 0
            controller.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)

            
        }
        
        

    }
    
    func paggingAPICall(indexPathMain : IndexPath){
        
        if !self.isAPICall {
            if isWatch {
                
            }else {
                self.isFeedReachEnd(indexPath: indexPathMain)
                self.isExpended = true
            }
        }
    }
    
    func playSelectedVideo(videoIndex:Int)  {
        
        FeedCallBManager.shared.videoClipArray.removeAll()
        
        for indexObj in 0..<self.videoClipArray.count {
            if indexObj > 0 && indexObj % 5 == 0 {
                let modelObj = FeedVideoModel.init()
                modelObj.postType = PostType.Ad.rawValue
                modelObj.postID = ""
                
                let snapObj = StoryObject.init()
                snapObj.postType = PostType.Ad.rawValue
                snapObj.postID = ""
                
                modelObj.snaps.append(snapObj)
                FeedCallBManager.shared.videoClipArray.append(modelObj)
                
            }
            
            FeedCallBManager.shared.videoClipArray.append(self.videoClipArray[indexObj])
        }
        let storyPreviewScene = IGStoryPreviewController.init(stories: FeedCallBManager.shared.videoClipArray, handPickedStoryIndex:  videoIndex)
        storyPreviewScene.modalPresentationStyle = .fullScreen
        let navigationView = UINavigationController.init(rootViewController: storyPreviewScene)
        navigationView.navigationBar.isHidden = true
        self.parentControl!.present(navigationView, animated: true, completion: nil)
        
//        UIApplication.topViewController()!.navigationController?.pushViewController(storyPreviewScene, animated: true)
    }
    
    //Manage pagging
    func isFeedReachEnd(indexPath:IndexPath){
        if  self.isNextVideoExist {
            let feedCurrentCount = self.videoClipArray.count
            if indexPath.row == feedCurrentCount-1 {
                let videoObj = self.videoClipArray[indexPath.row]
                self.startingPoint = videoObj.videoID
                
                DispatchQueue.main.async { () -> Void in
                    
                    self.manageFeedHeader()
                }
            }
        }
    }
    
    @objc func deleteVideoClipBtn(sender:UIButton) {
        self.parentControl!.ShowAlertWithCompletaionText(message: "Are you sure to remove this Post?".localized(), noButtonText: "No".localized(), yesButtonText: "Yes".localized()) { (pStatus) in
            if pStatus {
                
                let feedObj:FeedVideoModel = self.videoClipArray[sender.tag]
                let parameters:[String:String] = ["action": "post", "token": SharedManager.shared.userToken(), "post_id":String(feedObj.videoID), "_method":"DELETE"]
                self.callingPostService(action: "DeleteVideo", param: parameters)
                self.videoClipArray.remove(at: sender.tag)
                self.videoCollectionView.reloadData()
            }
        }
    }
}

extension FeedHeaderView:TLPhotosPickerViewControllerDelegate {
   
}

extension FeedHeaderView {
    
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        
        // var parameters = ["action": "newsfeed-videos" ,"token":SharedManager.shared.userToken()]
        var parameters = ["action": "getReels" ,"token":SharedManager.shared.userToken()]
        self.isAPICall = true
        parameters["page"] = String(self.pageNumber)
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICall = false
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                    } else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                }
                
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        if let isFeedData = feedObj.data {
            watchArray.append(contentsOf: isFeedData)
        }
        self.videoCollectionView.reloadData()
    }
}
