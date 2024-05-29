//
//  PostCollectionStoryCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 21/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import SDWebImage

class PostCollectionStoryCell: ConfigableCollectionCell {
    
    @IBOutlet weak var videoCollectionView: UICollectionView?
    
   
    var pageNumber: Int = 1
    var isWatch : Bool = false
    
    var videoClipArray:[FeedVideoModel] = [FeedVideoModel]()
    let feedModel = FeedVideoModel.init()

    var startingPoint = ""
    var isNextVideoExist = true
    var isAPICall = false
    var watchArray: [FeedData] = [FeedData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoCollectionView?.registerXibCell([
            .VideoClipUploadCollectionCell,
            .StoryEndCell,
            .CreateReelCollectionViewCell
        ])
    }
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {

    }
    
    
    func manageFeedHeader() {
        
        if isWatch {
            watchArray.removeAll()
            FeedCallBManager.shared.watchArray.removeAll()
            self.pageNumber = 1
            callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
            return
        }
        
        
        if SharedManager.shared.checkLanguageAlignment() {
            videoCollectionView?.rotateViewForLanguage()
        }
                
        var param = ["action": Const.NetworkKey.userStories,
                     "token": SharedManager.shared.userToken()]
        param["starting_point_id"] = self.startingPoint
        
        self.callingStoriesService(action: Const.NetworkKey.userStories, param: param)
       
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableWithNewdata), name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "refreshView"))
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: NSNotification.Name(rawValue: "refreshView"), object: nil)
    }
    
    @objc func reloadTableWithNewdata() {
        if FeedCallBManager.shared.videoClipArray.count > 0 {
            self.startingPoint = FeedCallBManager.shared.videoClipArray.last?.videoID ?? .emptyString
            if SharedManager.shared.createStory !=  nil {
                self.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
            }
            if SharedManager.shared.createReel != nil{
                self.watchArray.insert(SharedManager.shared.createReel!, at: 0)
                SharedManager.shared.createReel = nil
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timerMain in
                self.videoCollectionView?.reloadData()
            }
        }
    }
    
    
    @objc func refreshView() {
        LogClass.debugLog("refreshView")
        self.watchArray.removeAll()
        self.videoClipArray.removeAll()
        resetAndReload()
    }
    
    
    func resetAndReload() {
        self.isNextVideoExist = true
        self.startingPoint = ""
        
        if isWatch {
            self.watchArray.removeAll()
            FeedCallBManager.shared.watchArray.removeAll()
            self.pageNumber = 1
            callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
            return
        }
        
        FeedCallBManager.shared.videoClipArray.removeAll() // Waseem
        self.videoClipArray.removeAll()
        
        self.manageFeedHeader()
    }

    func changeView() {
        
        if isWatch {
            if self.watchArray.count == 0 {
                
                callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
                self.videoCollectionView?.reloadData()
            } else {
                self.videoCollectionView?.reloadData()
            }
        } else {
            self.videoCollectionView?.reloadData()
        }
    }
    
    func resetData() {
        FeedCallBManager.shared.videoClipArray.removeAll()
        self.videoClipArray.removeAll()
        self.startingPoint = ""
    }
    
    func callingStoriesService(action:String, param:[String:String]) {
        if self.isAPICall{
            return
        }
        self.isAPICall = true
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
                AppLogger.log(tag: .debug, error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    self.isNextVideoExist = false
                } else {
                if action == "stories" {
                        let arr = res as? [[String : Any]] ?? []
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        } else {
                            let feedVideoObj = self.feedModel.getVideoModelArray(arr:arr)
                            FeedCallBManager.shared.videoClipArray = feedVideoObj
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            self.videoClipArray.enumerated().forEach { index, _ in
                                 if (index + 1) % 10 == 0 {
                                     let mainData = [String: Any]()
                                     let newFeed = FeedVideoModel(dict: mainData)
                                     newFeed.postType = FeedType.Ad.rawValue
                                     self.videoClipArray.insert(newFeed, at: index + 1)
                                 }
                             }
                            self.videoCollectionView?.reloadData()
                        }
                    } else if action == "stories/stories_for_all_users" {
                        let arr = res as? [[String : Any]] ?? []
                        
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        } else {
                            let feedVideoObj: [FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            
                            self.isAPICall = false
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            self.videoClipArray.enumerated().forEach { index, _ in
                                 if (index + 1) % 10 == 0 {
                                     let mainData = [String: Any]()
                                     let newFeed = FeedVideoModel(dict: mainData)
                                     newFeed.postType = FeedType.Ad.rawValue
                                     self.videoClipArray.insert(newFeed, at: index + 1)
                                     // Add the index path for the ad feed
                                 }
                             }
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timerMain in
                                self.videoCollectionView?.reloadData()
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
                break
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isNextVideoExist = false
                }else {
              if action == "stories" {
                        let arr =  res as? [[String : Any]] ?? []
                        if arr.count == 0 {
                            self.isNextVideoExist = false
                        }else {
                            let feedVideoObj:[FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            self.videoClipArray = FeedCallBManager.shared.videoClipArray
                            self.videoCollectionView?.reloadData()
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
                break
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
   

    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        var parameters = ["action": "getReels" ,"token":SharedManager.shared.userToken()]
        self.isAPICall = true
        parameters["page"] = String(self.pageNumber)
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICall = false
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as? ErrorModel
                    if err?.meta?.message == "Newsfeed not found" {
                    } else if err?.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
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
            FeedCallBManager.shared.watchArray = isFeedData
            watchArray = FeedCallBManager.shared.watchArray
            VideoPreLoadUtility.enable(at: isFeedData)
        }
        videoCollectionView?.reloadData()
    }
}

extension PostCollectionStoryCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = videoCollectionView?.frame.size.height ?? 0.0
        return CGSize.init(width: (height / 3) * 2, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.isWatch { // reel
            if section == 0 {
                return 1
            } else if section == 1 { // reels
                if self.watchArray.count == 0 {
                    return 5
                }
                return self.watchArray.count
            } else if section == 2 { // see more
                return 1
            }
            
        } else { // stories
            if section == 0 {
                return 1
            } else {
              
                if self.videoClipArray.count == 0 {
                    return 5
                }
                
                return self.videoClipArray.count
            }
        }
        return 0

    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isWatch { // reels
            return 3
        } else { // stories
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            
            let fileName = "myImageToUpload.jpg"
            if FileBasedManager.shared.fileExist(nameFile: fileName).1 {
                cellUpload.imgViewUser.image = FileBasedManager.shared.loadImage(pathMain: fileName)
            }else {
                cellUpload.imgViewUser.loadImageWithPH(urlMain: SharedManager.shared.userObj?.data.profile_image ?? "")
            }
            
      
            cellUpload.btnUpload.addTarget(self, action: #selector(self.showPopup), for: .touchUpInside)
            return cellUpload
        }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipCollectionCell", for: indexPath) as? VideoClipCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.viewShimmer.stopAnimating()
        if self.isWatch && self.watchArray.count == 0 {
            cell.viewShimmer.startAnimating()
            
        }else if self.videoClipArray.count == 0 {
            cell.viewShimmer.startAnimating()
        }
        
        
        cell.viewCount.isHidden = true
        if self.isWatch {
            
            let indexMain = indexPath.row
            if self.watchArray.count > indexMain {
                let feedObj:FeedData = self.watchArray[indexMain]
                    cell.profileImageView.loadImageWithPH(urlMain:feedObj.profileImage ?? .emptyString)
                
                self.labelRotateCell(viewMain: cell.profileImageView)
                
                cell.descriptionLbl.isHidden = true
                cell.thumbnailImageView.isHidden = false
                if feedObj.post != nil {
                    if feedObj.post?.count ?? 0 > 0 {
                        cell.thumbnailImageView.loadImageWithPH(urlMain:feedObj.post?[0].thumbnail ?? .emptyString)
                    }
                }
                cell.nameLbl.text = ""
                cell.lblviewCount.text = String(feedObj.video_post_views ?? 0)
                cell.viewCount.isHidden = false
                cell.profileImageView.isHidden = true
                cell.videoDeleteBtn.isHidden = true
                if(feedObj.authorID == SharedManager.shared.getUserID()) {
                    cell.videoDeleteBtn.isHidden = false
                    cell.videoDeleteBtn.tag = indexPath.row
                }
            }
            
        } else { // story
            cell.profileImageView.isHidden = false
            
            let indexMain = indexPath.row
            if indexMain < self.videoClipArray.count {
                
                let feedObj:FeedVideoModel = self.videoClipArray[indexMain]
                if feedObj.postType == FeedType.Ad.rawValue {
                    // Skip loading cell for this index
                    guard let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullScreenBannerAdCell", for: indexPath) as? FullScreenBannerAdCell else {
                        return UICollectionViewCell()
                    }
                    adCell.displayCellContent(data: nil, parentData: nil, at: indexPath)
                    return adCell
                }
                
                if feedObj.snaps.count > 0 {
                    cell.profileImageView.sd_setImage(with: URL(string: feedObj.snaps[0].authorImage), placeholderImage: UIImage(named: "placeholder.png"))
                }
                
                self.labelRotateCell(viewMain: cell.profileImageView)
                cell.manageData(feedObj: feedObj, indexPath: IndexPath.init(row: indexPath.row, section: 1))
                cell.videoDeleteBtn.addTarget(self, action: #selector(deleteVideoClipBtn), for: .touchUpInside)
                
                if let user = feedObj.user {
                    cell.nameLbl.text = user.name
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
            return cell // Ensure to return cell at the end of the closure
        }

        return cell
    }
    
    @objc func showPopup(sender : UIButton){
        
        UIApplication.topViewController()?.PushViewWithStoryBoard(name: "StoryModuleVC", StoryBoard: "StoryModule")
    }
    
    @objc func showCreateReelScreen(sender : UIButton) {
        let vc = CreateReelViewController()
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
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
                
                
                if self.watchArray.count == 0 {
                    return
                }
                
                let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
                controller.items = self.watchArray
                controller.currentIndex = indexPath.item
                controller.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
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
            }
        }
    }
    
    func playSelectedVideo(videoIndex:Int)  {
        
//        FeedCallBManager.shared.videoClipArray.removeAll()
//        
//        for indexObj in 0..<self.videoClipArray.count {
//            if indexObj > 0 && indexObj % 5 == 0 {
//                let modelObj = FeedVideoModel.init()
//                modelObj.postType = PostType.Ad.rawValue
//                modelObj.postID = ""
//                
//                let snapObj = StoryObject.init()
//                snapObj.postType = PostType.Ad.rawValue
//                snapObj.postID = ""
//                
//                modelObj.snaps.append(snapObj)
//                FeedCallBManager.shared.videoClipArray.append(modelObj)
//                
//            }
            
//            FeedCallBManager.shared.videoClipArray.append(self.videoClipArray[indexObj])
//        }
        
        
      //  FeedCallBManager.shared.videoClipArray.removeAll()
      //  FeedCallBManager.shared.videoClipArray = self.videoClipArray
//        var videoclipArr = self.videoClipArray
//       videoclipArr.enumerated().forEach { index, _ in
//            if (index + 1) % 10 == 0 {
//                let mainData = [String: Any]()
//                let newFeed = FeedVideoModel(dict: mainData)
//                newFeed.postType = FeedType.Ad.rawValue
//               videoclipArr.insert(newFeed, at: index + 1)
//                // Add the index path for the ad feed
//            }
//        }
        let storyPreviewScene = IGStoryPreviewController.init(stories: self.videoClipArray, handPickedStoryIndex:  videoIndex)
        storyPreviewScene.modalPresentationStyle = .fullScreen
        
        UIApplication.topViewController()?.present(storyPreviewScene, animated: true, completion: nil)
    }
    
    //Manage pagging
    func isFeedReachEnd(indexPath:IndexPath) {
        if  self.isNextVideoExist {
            let feedCurrentCount = self.videoClipArray.count
            if self.videoClipArray.count > 0 {
                if indexPath.row > feedCurrentCount - 7 {
                    let videoObj = self.videoClipArray[indexPath.row]
                    self.startingPoint = videoObj.videoID
                    DispatchQueue.main.async { () -> Void in
                        self.manageFeedHeader()
                    }
                }
            }
        }
    }
    
    @objc func deleteVideoClipBtn(sender:UIButton) {
        UIApplication.topViewController()?.ShowAlertWithCompletaionText(message: "Are you sure to remove this Post?".localized(), noButtonText: "No".localized(), yesButtonText: "Yes".localized()) { (pStatus) in
            if pStatus {
                var parameters:[String:String] = ["action": "post"]
                parameters["token"] =  SharedManager.shared.userToken()
                parameters["_method"] = "DELETE"
                if SharedManager.shared.isfromReel{
                    let feedObj:FeedData = self.watchArray[sender.tag]
                    parameters["post_id"] = String(feedObj.postID ?? 0)
                }
                else{
                    let feedObj:FeedVideoModel = self.videoClipArray[sender.tag]
                    parameters["post_id"] = String(feedObj.videoID)
                }
                self.callingPostService(action: "DeleteVideo", param: parameters)
                if SharedManager.shared.isfromReel{
                    self.watchArray.remove(at: sender.tag)
                    
                    FeedCallBManager.shared.watchArray.remove(at: sender.tag)
                    SharedManager.shared.isfromReel = false
                }
                else{
                    self.videoClipArray.remove(at: sender.tag)
                    FeedCallBManager.shared.videoClipArray.remove(at: sender.tag)
                }
                self.videoCollectionView?.reloadData()
            }
        }
    }
}
