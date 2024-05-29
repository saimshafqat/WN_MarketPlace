//
//  PageBaseViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//


import Foundation
import Combine
import FTPopOverMenu
import FittedSheets

class PageBaseViewModel : NSObject {
    
    // MARK: - Properties -
    var feedArray: [FeedData] = []
    var feedImageArray: [FeedData] = []
    var groupObj: GroupValue?
    var arrayCell = [Int]()
    var isPage: Bool = true
    weak var parentView : UIViewController?
    var collectionView: UICollectionView?
    private var layoutHelper = SavedPostLayoutHelper1()
    private var subscription: Set<AnyCancellable> = []
    private(set) var errorMessage: String?
    private var isAPICallInProgress = false
    var isLoading = false
    var isRefresh = false
    var isMoreData = true
    private var apiService: APIService?
    var playerSoundValue : Bool = true
    var isNextFeedExist : Bool = true
    var postBaseCellDelegate: PostBaseCellDelegate?
    var indexStart = 0
    var categoryLikePageItem: CategoryLikePageModel?
    
    var sheetController = SheetViewController()
    var selectedTab: selectedUserTab = selectedUserTab.timeline
    // MARK: - Dictionary
    private lazy var cellsTypeDic: [String: UICollectionViewCell.Type] = {
        let cells = self.setCellForDataDic()
        return cells
    }()
    
    // MARK: - Closures -
    var didSelectTableClosure:((_ data: [FeedData]?, _ indexPath: IndexPath) -> Void)?
    var showAlertMessageClosure:((String)->())?
    var hideFooterClosure: (()->())?
    var moreClosure: ((FeedData, IndexPath)->())?
    var userInfoClosure: ((FeedData)->())?
    var showDetailClosure: ((FeedData)->())?
    var shareClosure: ((FeedData)->Void)?
    var commentClosure: ((FeedData, IndexPath)->Void)?
    var likeClosure: ((FeedData)->Void)?
    var likesDetailClosure: ((FeedData)->Void)?
    var postImageClosure: ((FeedData)->())?
    var postImageDownloadClosure: ((FeedData)->Void)?
    var postDownloadClosure: ((FeedData)->Void)?
    var postTappedClosure: ((FeedData)->Void)?
    var kamlamSendClosure: ((FeedData)->Void)?
    var postGalleryPreviewClosure: ((FeedData, IndexPath, Int) -> Void)?
    var showToastCompletion: (() -> Void)?
    var showHashTagClosue: ((String) -> ())?
    
    // MARK: - Methods -
    public func setCellForDataDic() ->  [String: UICollectionViewCell.Type] {
        return [
            FeedType.liveStream.rawValue: PostVideoCollectionCell.self,
            FeedType.video.rawValue: PostVideoCollectionCell.self,
            FeedType.image.rawValue: PostCollectionCell1.self,
            FeedType.gif.rawValue: PostCollectionCell1.self,
            FeedType.post.rawValue: PostCollectionCell1.self,
            FeedType.shared.rawValue: PostCollectionCell1.self,
            FeedType.gallery.rawValue: PostGalleryCollectionCell1.self,
            FeedType.audio.rawValue: PostAudioCollectionCell1.self,
            FeedType.Shimmer.rawValue: PostShimmerCell.self,
            FeedType.ShimmerAd.rawValue: PostShimmerAdCell.self,
            FeedType.file.rawValue: PostAttachmentCollectionCell.self,
            FeedType.pageReview.rawValue: PostCollectionCell1.self
        ]
    }
    
    func initialSetup(collectionView: UICollectionView?, apiService: APIService?) {
        self.apiService = apiService
        
       
        self.setupCollectionView(collectionView)
        // loader
        
        self.groupObj = (UIApplication.topViewController()! as? PagePostController)?.groupObj!
        self.reloadCell()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            callingGroupProfileService()
            
        }
                
        updateCollectionView(isRefresh: false)
    }
    
    func callingGroupProfileService()   {
        
        var parameters = ["action": "page/view", "token": SharedManager.shared.userToken()]
        
        if self.groupObj?.groupID.count == 0 {
            parameters["page_slug"] = self.groupObj?.slug
        }else {
            parameters["page_id"] = self.groupObj?.groupID
        }
        
        RequestManager.fetchDataGet(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                }else {
                    
                    let NewGroup2 = GroupValue.init(fromDictionary: res as! [String : Any])
                    let NewGroup = GroupValue.init(fromDictionaryGroup: res as! [String : Any])
                    
                    NewGroup.profilePicture = NewGroup2.profilePicture
                    NewGroup.name = NewGroup2.name
                    NewGroup.groupName = NewGroup2.groupName
                    NewGroup.groupImage = NewGroup2.groupImage
                    
                    self.groupObj = NewGroup
                    self.groupObj?.rating = NewGroup2.rating
                    self.groupObj?.positiveReviews = NewGroup2.positiveReviews
                    self.groupObj?.negativeReviews = NewGroup2.negativeReviews
                    self.groupObj?.recommendationReviews = NewGroup2.recommendationReviews
                    self.groupObj?.isLike = NewGroup.isLike
                    
//                    let NewGroup2 = GroupValue.init(fromDictionary: res as! [String : Any])
//                    let NewGroup = GroupValue.init(fromDictionary: res as! [String : Any])
//                    
//                    NewGroup.profilePicture = NewGroup2.profilePicture
//                    NewGroup.name = NewGroup2.name
//                    NewGroup.groupName = NewGroup2.groupName
//                    NewGroup.groupImage = NewGroup2.groupImage
//                    
//                    self.groupObj = NewGroup
//                    self.groupObj?.rating = NewGroup2.rating
//                    self.groupObj?.positiveReviews = NewGroup2.positiveReviews
//                    self.groupObj?.negativeReviews = NewGroup2.negativeReviews
//                    self.groupObj?.recommendationReviews = NewGroup2.recommendationReviews
//                    self.groupObj?.isLike = NewGroup.isLike
                    
                    self.savedPostService(isRefresh: true)
                }
            }
        }, param:parameters as! [String : String])
    }
    
    
    func setupCollectionView(_ collectionView: UICollectionView?) {
        self.collectionView = collectionView
        guard self.collectionView != nil else { return }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout = layoutHelper.createLayout()
    }
    
    
    // call service
    func savedPostService(lastPostID: String = .emptyString, isLastTrue: Bool = false, isRefresh: Bool = false, isReview: Bool = false) {
        
        guard !isAPICallInProgress else {
//            Loader.stopLoading()
            return  // Skip the API call if it's already in progress
        }
        self.isAPICallInProgress = true
        if isRefresh {
            self.feedArray.removeAll()
        }
        let userToken = SharedManager.shared.userToken()
        
        var parameters: [String: String] = ["token": userToken]
        if groupObj?.groupID != nil {
            parameters[Const.ResponseKey.pageid] = self.groupObj?.groupID
        }
        
        if isReview {
            parameters["post_type"] = "12"
        }
        if let parentNEw = parentView as? PostBaseViewController, parentNEw.isPostSearch {
            parameters[Const.ResponseKey.query] = parentNEw.searchPost
        }
        if !isRefresh && isLastTrue {
            parameters[Const.ResponseKey.startingPointId] = lastPostID
        }
        guard let endPoint = serviceEndPoint(with: parameters) else { return }
        apiService?.savedPost(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                Loader.stopLoading()
                switch completion {
                case .finished:
                    self.isAPICallInProgress = true
                    self.isLoading = false
                    self.isMoreData = false
                    self.updateCollectionView(isRefresh: isRefresh)
                case .failure(let errorType):
                    self.isAPICallInProgress = true
                    self.isMoreData = false
                    self.isLoading = false
                    self.errorMessage = errorType.localizedDescription

                    self.updateCollectionView(isRefresh: isRefresh)
                }
            }, receiveValue: { feedModel in
                self.dataLoadedSuccessfully(newItems: feedModel.data ?? [], isRefresh: isRefresh)
            })
            .store(in: &subscription)
    }
    
    func serviceEndPoint(with params: [String: String]) -> APIEndPoints? {
        return nil
    }
    
    func reloadVisibleCells() {
        guard self.collectionView != nil else { return }
        self.collectionView?.reloadItems(at: self.collectionView?.indexPathsForVisibleItems ?? [])
    }
    
    func visibilityMemorySharing() -> Bool {
        return false
    }
    
    func shouldAdsShow() -> Bool {
        return false
    }
    
  
}

extension PageBaseViewModel: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { playVideo() }
    }
    
    func playVideo() {
        
        var visibleRect = CGRect()

        guard let collectionView else { return }
        
        visibleRect.origin = collectionView.contentOffset
            visibleRect.size = collectionView.bounds.size

            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY + 50)

            guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }


        handleVideoPlayback(for: indexPath, in: collectionView)
        
//        guard let collectionView else { return }
//        if let indexPath = collectionView.indexPathForItem(at: collectionView.bounds.center) {
//            handleVideoPlayback(for: indexPath, in: collectionView)
//        }
    }
    
    private func handleVideoPlayback(for indexPath: IndexPath, in collectionView: UICollectionView) {
                
        let player = MediaManager.sharedInstance.player
        
        if player != nil{
            if indexPath.row != player!.indexPath?.row {
                stopVideoPlaybackIfNeeded(player)
            }
        }
            
        
        
        if let cellVideo = collectionView.cellForItem(at: indexPath) as? PostVideoCollectionCell {
            playVideoIfNeeded(in: cellVideo, with: player)
            cellVideo.imgviewPH?.isHidden = false
        } else if let cellVideo = collectionView.cellForItem(at: indexPath) as? PostGalleryCollectionCell1 {
            cellVideo.playVideo(with: feedArray[indexPath.item])
        } else {
            stopVideoPlaybackIfNeeded(player)
        }
    }
    
    private func playVideoIfNeeded(in cell: PostVideoCollectionCell, with player: EZPlayer?) {
        
        guard let player = player else {
            cell.isPlayVideo = true
            cell.playPlayer()
            return
        }
        if !(player.isPlaying) {
            DispatchQueue.main.async {
                cell.isPlayVideo = true
                cell.playPlayer()
            }
        }
    }
    
    private func stopVideoPlaybackIfNeeded(_ player: EZPlayer?) {
        if player?.isPlaying == true {
            player?.stop()
        }
    }
    
    
    func reloadCell(){
        self.arrayCell.removeAll()
        self.arrayCell.append(0)
        self.arrayCell.append(1)
        
        self.arrayCell.append(2)
        
        if self.selectedTab == .timeline {
            if self.groupObj!.isAdmin || self.groupObj!.isMember {
                self.arrayCell.append(3)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PageBaseViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if section == 0 {
            
            return self.arrayCell.count
        }
        
        if self.selectedTab == .aboutMe || self.selectedTab == .photos || self.selectedTab == .videos {
            return 1
        }
        
        if self.selectedTab == .myReels {
            if self.groupObj != nil {
                if (self.groupObj!.is_reviewd) {
                    self.indexStart = 1
                    return 1 + self.feedArray.count
                }
            }
            
            self.indexStart = 2
            return 2 + self.feedArray.count
        }
        
        
        if !self.isAPICallInProgress && self.feedArray.count == 0{
                return 3
        }
        
        
        if self.selectedTab == .timeline {
            (collectionView as? CollectionEmptyView)?.hideEmptyState()
            if self.feedArray.count == 0 {
                return 1
            }
            return feedArray.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        if indexPath.section == 0 {
            if self.arrayCell[indexPath.row] == 1 {
                let cellName = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseNameCell", for: indexPath) as! PageBaseNameCell
                
                cellName.groupObj = self.groupObj
                cellName.reloadName()
                if let categoryLikePageItem {
                    cellName.updateCatePageLike(categoryLikePageItem)
                }
                return cellName
                
            }else  if self.arrayCell[indexPath.row] == 2 {
                let cellUserTab = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseHeaderCell", for: indexPath) as! PageBaseHeaderCell
                cellUserTab.delegate = self
                cellUserTab.lblFeed.text = "Home".localized()
                cellUserTab.lblVideos.text = "Videos".localized()
                cellUserTab.lblOverview.text = "About".localized()
                cellUserTab.lblReviews.text = "Reviews".localized()
                cellUserTab.lblPhotos.text = "Photos".localized()
                
                return cellUserTab
            }else if self.arrayCell[indexPath.row] == 3 {
                
                    let cellCreate = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCreateCell", for: indexPath) as! GroupCreateCell

                cellCreate.btnText.tag = 5
                cellCreate.btnGallery.tag = 0
                
                cellCreate.btnText.addTarget(self, action: #selector(self.openCreatePost), for: .touchUpInside)
                cellCreate.btnGallery.addTarget(self, action: #selector(self.openCreatePost), for: .touchUpInside)
                    return cellCreate
            }
            let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseImageCell", for: indexPath) as! PageBaseImageCell
            
            cellImage.groupObj = self.groupObj
            cellImage.delegate = self
            cellImage.reloadData()
            
            return cellImage
        }

        
        
        if self.selectedTab == .myReels {
            
            
            if indexPath.row == 0 {
                let cellReview = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseReviewCell", for: indexPath) as! PageBaseReviewCell
                
                if Double(self.groupObj!.rating) != nil {
                    cellReview.viewStar.rating = Double(self.groupObj!.rating)!
                }else {
                    cellReview.viewStar.rating = 0.0
                }
                
                cellReview.lblReview.text = self.groupObj!.rating
                cellReview.lblPersons.text = self.groupObj!.totalReviews
                cellReview.lblTotalPersons.text = self.groupObj!.rating + "/5"
                cellReview.lblPositive.text = self.groupObj!.positiveReviews
                cellReview.lblNegative.text = self.groupObj!.negativeReviews
                cellReview.lblRecom.text = self.groupObj!.recommendationReviews
                return cellReview
            }
            
            if !self.groupObj!.is_reviewd {
                if indexPath.row == 1 {
                    let cellAddReview = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseAddReviewCell", for: indexPath) as! PageBaseAddReviewCell
                    cellAddReview.groupObj = self.groupObj
                    return cellAddReview
                }
            }
                
                
            LogClass.debugLog("indexPath.row ==>")
            LogClass.debugLog(feedArray.count)
            LogClass.debugLog(indexPath.row)
            LogClass.debugLog(indexStart)
            
                let indexPathMain = IndexPath.init(row: indexPath.row - indexStart, section: 1)
            
            let feedPost = feedArray[indexPathMain.row]
                let feedPostType = feedPost.postType ?? .emptyString
                let feedSharedPostType = feedPost.sharedData?.postType ?? .emptyString
                
                let isShared = feedPostType == FeedType.shared.rawValue
                let isPostType = isShared ? (feedSharedPostType == FeedType.post.rawValue) : feedPostType == FeedType.post.rawValue
                // shared Post then check their type if their type is post then should go to further process
                let hasLink = isShared ? (feedPost.sharedData?.previewLink?.count ?? 0 > 0) : feedPost.previewLink?.count ?? 0 > 0
                let hasLinkImage = isShared ? (feedPost.sharedData?.linkImage?.count ?? 0 > 0) : (feedPost.linkImage?.count ?? 0 > 0)
                let hasYoutubeLink = isShared ? (feedPost.sharedData?.previewLink ?? .emptyString).contains("youtube") : (feedPost.previewLink ?? .emptyString).contains("youtube")
                let hasPreviewLink = (isPostType && hasLinkImage) || (isPostType && hasYoutubeLink) || (isPostType && hasLink)
                
                let cellType = cellsTypeDic[isShared ? feedSharedPostType : feedPostType] ?? ConfigableCollectionCell.self
                var currentIdentifier = hasPreviewLink ? PostPreviewLinkCollectionCell.reuseIdentifier : cellType.reuseIdentifier
                if shouldAdsShow() {
                    if (indexPathMain.row % 10 == 0) {
                        currentIdentifier = PostAdsCollectionCell.reuseIdentifier
                    }
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentIdentifier, for: indexPathMain)
                // send data according to share or post type
                (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPathMain)
                (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: visibilityMemorySharing())
                if let postBaseCell = cell as? PostBaseCollectionCell {
                    postBaseCell.postBaseCellDelegate = self
                }
                if let postCell = cell as? PostCollectionCell1 {
                    postCell.postDelegate = self
                }
                if let postGallery = cell as? PostGalleryCollectionCell1 {
                    postGallery.galleryDelegate = self
                }
                if cell is PostVideoCollectionCell {
                    let postVideoCell = cell as? PostVideoCollectionCell
                    
                    postVideoCell?.imgviewPH?.isHidden = false
                    
                    postVideoCell?.playerSoundValue = self.playerSoundValue
                    postVideoCell?.collectionViewMain = self.collectionView
                    postVideoCell?.videoPostDelegate = self
                    postVideoCell?.isPlayVideo = false
                    if feedPostType == FeedType.video.rawValue {
                        postVideoCell?.resetVideo(feedObjp: feedPost)
                    }
                }
                return cell
            
            
            
           
        }
        if self.selectedTab == .photos ||  self.selectedTab == .videos {
            
            if self.feedImageArray.count == 0 && !self.isAPICallInProgress {
                
                let cellTab = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupEmptyCell", for: indexPath) as! GroupEmptyCell
                
                if self.selectedTab == .photos {
                    cellTab.lblInfo.text = "No image availalbe.".localized()
                }else {
                    cellTab.lblInfo.text = "No Video Found".localized()
                }
                
                cellTab.lblInfo.textAlignment = .center
                cellTab.viewBG.backgroundColor = UIColor.clear
                
                return cellTab
            }
            
            let cellTab = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupPhotoCell", for: indexPath) as! GroupPhotoCell
            
            
            cellTab.arrayImages.removeAll()
            if self.selectedTab == .photos {
                cellTab.isImage = true
                for indexInner in self.feedImageArray {
                    if indexInner.postType == FeedType.gallery.rawValue {
                        
                    }else {
                        if indexInner.post!.count > 0 {
                            cellTab.arrayImages.append(indexInner.post!.first?.filePath as Any)
                        }
                    }
                }
            }else {
                for indexInner in self.feedImageArray {
                    if indexInner.postType == FeedType.gallery.rawValue {
                        
                    }else {
                        if indexInner.post!.count > 0 {
                            cellTab.arrayImages.append(indexInner.post!.first?.thumbnail as Any)
                        }
                        
                    }
                }
                cellTab.isImage = false
            }
            
            cellTab.isAPICallInProgress =  self.isAPICallInProgress
            cellTab.delegate = self
            cellTab.viewWidth = UIApplication.topViewController()!.view.frame.size.width
            cellTab.reloadView()
            
            return cellTab
        }
        if self.selectedTab == .aboutMe {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageBaseInfoCell", for: indexPath) as! PageBaseInfoCell
            
            cell.groupObj = self.groupObj
            cell.reloadAbout()
            cell.reloadAbout()
                        
            return cell
        }
           
        if self.feedArray.count == 0 && !self.isAPICallInProgress{
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostShimmerAdCell", for: indexPath) as! PostShimmerAdCell
                
                cell.startAnimation()
                cell.shimmerView.isHidden = false
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostShimmerCell", for: indexPath) as! PostShimmerCell
            
            cell.startAnimation()
            cell.shimmerView.isHidden = false
            return cell
        }else if self.feedArray.count == 0 {
            let cellTab = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupEmptyCell", for: indexPath) as! GroupEmptyCell
            cellTab.lblInfo.text = "No post found".localized()
            
            cellTab.lblInfo.textAlignment = .center
            cellTab.viewBG.backgroundColor = UIColor.clear
            
            return cellTab
        }

        
        
    
        
        
        let feedPost = feedArray[indexPath.row]
        let feedPostType = feedPost.postType ?? .emptyString
        let feedSharedPostType = feedPost.sharedData?.postType ?? .emptyString
        
        let isShared = feedPostType == FeedType.shared.rawValue
        let isPostType = isShared ? (feedSharedPostType == FeedType.post.rawValue) : feedPostType == FeedType.post.rawValue
        // shared Post then check their type if their type is post then should go to further process
        let hasLink = isShared ? (feedPost.sharedData?.previewLink?.count ?? 0 > 0) : feedPost.previewLink?.count ?? 0 > 0
        let hasLinkImage = isShared ? (feedPost.sharedData?.linkImage?.count ?? 0 > 0) : (feedPost.linkImage?.count ?? 0 > 0)
        let hasYoutubeLink = isShared ? (feedPost.sharedData?.previewLink ?? .emptyString).contains("youtube") : (feedPost.previewLink ?? .emptyString).contains("youtube")
        let hasPreviewLink = (isPostType && hasLinkImage) || (isPostType && hasYoutubeLink) || (isPostType && hasLink)
        
        let cellType = cellsTypeDic[isShared ? feedSharedPostType : feedPostType] ?? ConfigableCollectionCell.self
        var currentIdentifier = hasPreviewLink ? PostPreviewLinkCollectionCell.reuseIdentifier : cellType.reuseIdentifier
        if shouldAdsShow() {
            if (indexPath.item % 10 == 0) {
                currentIdentifier = PostAdsCollectionCell.reuseIdentifier
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentIdentifier, for: indexPath)
        // send data according to share or post type
        (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPath)
        (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: visibilityMemorySharing())
        if let postBaseCell = cell as? PostBaseCollectionCell {
            postBaseCell.postBaseCellDelegate = self
        }
        if let postCell = cell as? PostCollectionCell1 {
            postCell.postDelegate = self
        }
        if let postGallery = cell as? PostGalleryCollectionCell1 {
            postGallery.galleryDelegate = self
        }
        if cell is PostVideoCollectionCell {
            let postVideoCell = cell as? PostVideoCollectionCell
            
            postVideoCell?.imgviewPH?.isHidden = false
            
            postVideoCell?.playerSoundValue = self.playerSoundValue
            postVideoCell?.collectionViewMain = self.collectionView
            postVideoCell?.videoPostDelegate = self
            postVideoCell?.isPlayVideo = false
            if feedPostType == FeedType.video.rawValue {
                postVideoCell?.resetVideo(feedObjp: feedPost)
            }
        }
        return cell
    }
    
    
    @objc func joinCall(sender : UIButton){
        if self.groupObj!.member_request == "pending" {
            return
        }
        var parameters = [ "token": SharedManager.shared.userToken()]
        
        parameters["group_id"] = self.groupObj!.groupID
        parameters["user_id"] = String(SharedManager.shared.getUserID())
        parameters["action"] = "group/members/join"
        Loader.startLoading()
        
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    if let resData = res as? [String : Any] {
                        
                        if (resData["status"] as! String) == "pending_approval" {
                            self.groupObj?.member_request = "pending"
                            self.groupObj?.isMember = false
                        }else {
                            self.groupObj?.member_request = ""
                            self.groupObj?.isMember = true
                        }
                    }else {
                        self.groupObj?.member_request = ""
                        self.groupObj?.isMember = true
                    }
                    
                    self.reloadCell()
                    self.collectionView?.reloadData()
                    
                    
                }
            }
        }, param:parameters)
    }
    
    @objc func openCreatePost(sender : UIButton){
        SharedManager.shared.createPostSelection = sender.tag
        
        
        SharedManager.shared.groupObj = self.groupObj
        SharedManager.shared.isGroup = 1
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        let imageView = UIImageView(image: UIApplication.topViewController()!.view.takeScreenshot())
        imageView.frame = UIScreen.main.bounds
        SharedManager.shared.createPostScreenShot = imageView
        UIApplication.topViewController()!.present(createPost, animated: false, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == feedArray.count - 1 && !isLoading {
            isLoading = true
            loadMoreData(indexPath)
        }
    }
    
 
    
   
    
    @objc func MoreActionforGroup(sender : UIButton){
        
        if self.groupObj!.isAdmin {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() , "Leave Group".localized() , "Invite Friends".localized() , "Delete Group".localized()  ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                }else if selectedIndex == 1 {
                    self.leaveGroup()
                }else if selectedIndex == 2 {
                    self.inviteGroup()
                }else {
                    self.deleteGroup()
                }
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }else if self.groupObj!.isMember {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() , "Leave Group".localized()   ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                }else {
                    self.leaveGroup()
                }
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }else {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Group".localized() ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                self.reportGroup()
            } dismiss: {
                // LogClass.debugLog("Cancel")
            }
        }
        
        
    }
    
    func reportGroup(){
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.groupObj = self.groupObj
        reportDetail.delegate = self
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        
        
        UIApplication.topViewController()!.present(self.sheetController, animated: true, completion: nil)
    }
    
    
  
    
    func leaveGroup(){
        let parameters = [
            "action": "group/members/leave",
            "group_id":self.groupObj!.groupID ,
            "user_id":String(SharedManager.shared.getUserID()),
            "token": SharedManager.shared.userToken()
        ]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
//                    if let obj = SharedManager.shared.userEditObj.groupArray.filter({$0.groupID == self.groupObj!.groupID}).first {
//                        let profileGroupModel = ProfileGroupPageModel(tabName: "group", item: obj)
//                        NotificationCenter.default.post(name: .CategoryLikePages, object: profileGroupModel)
////                        self.parentView.navigationController?.popViewController(animated: true)
                    ///
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
                    }
//                    }
                }
            }
        }, param:parameters as! [String : String])
    }
    
    
    func deleteGroup(){
        SharedManager.shared.ShowAlertWithCompletaion(title: "Delete Group".localized(), message: "Are you sure to delete this group?".localized(), isError: false, DismissButton: "Cancel".localized(), AcceptButton: "Yes".localized()) { (statusP) in

            if statusP {
                var parameters = [ "token": SharedManager.shared.userToken()]
                
                parameters["group_id"] = self.groupObj!.groupID
                parameters["action"] = "group/delete"
                
                
                RequestManager.fetchDataPost(Completion: { response in
                    switch response {
                    case .failure(let error):
                        if error is String {
                        }
                    case .success(let res):

                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {
                        }else {
                            
                            UIApplication.topViewController()!.navigationController?.popViewController(animated: true)
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    func inviteGroup(){
        let viewGroupInvite = UIApplication.topViewController()!.GetView(nameVC: "GroupInviteUsersVC", nameSB: "Kids") as! GroupInviteUsersVC
        viewGroupInvite.groupObj = self.groupObj
        UIApplication.topViewController()!.navigationController?.pushViewController(viewGroupInvite, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //  guard feedArray.count > 0 && indexPath.row <= feedArray.count - 1 else { return }
        guard indexPath.item < feedArray.count else { return }
        if let audioCell = cell as? PostAudioCollectionCell1 {
            audioCell.stopPlayer()
        } else if let videoCell = cell as? PostVideoCollectionCell {
            videoCell.pauseAudioTapped(UIButton())
        }
    }
    
    // MARK: - Load More Data -
    func loadMoreData(_ indexPath: IndexPath) {
        // Save the current scroll position
        
        if self.isMoreData  {
            let postObj = self.feedArray[indexPath.item] as FeedData
            savedPostService(lastPostID: String(postObj.postID ?? 0), isLastTrue: true, isRefresh: false)
        }
        
    }
    
    func dataLoadedSuccessfully(newItems: [FeedData], isRefresh: Bool) {
        guard !newItems.isEmpty else {
            return
        }
        if isRefresh {
            feedArray.removeAll()
        }
        var arrayItems = [FeedData]()
        for indexObj in newItems {
            if indexObj.postType == FeedType.image.rawValue ||
                indexObj.postType == FeedType.video.rawValue ||
                indexObj.postType == FeedType.audio.rawValue ||
                indexObj.postType == FeedType.file.rawValue ||
                indexObj.postType == FeedType.gallery.rawValue ||
                indexObj.postType == FeedType.gif.rawValue ||
                indexObj.postType == FeedType.liveStream.rawValue ||
                indexObj.postType == FeedType.post.rawValue ||
                indexObj.postType == FeedType.pageReview.rawValue ||
                indexObj.postType == FeedType.shared.rawValue {
                arrayItems.append(indexObj)
            }
        }
        feedArray.append(contentsOf: arrayItems)
        updateCollectionView(isRefresh: isRefresh)
    }
    
    private func updateCollectionView(isRefresh: Bool) {
        UIView.performWithoutAnimation {
            refreshParentViewController()
            self.collectionView?.reloadData()
        }
//        Loader.stopLoading()
    }
    
    private func refreshParentViewController() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            (parentView as? PostBaseViewController)?.refreshCompleted()
            isLoading = false
            isAPICallInProgress = false
            playVideo()
        }
    }
}

// MARK: - PostBaseCellDelegate
extension PageBaseViewModel: PostBaseCellDelegate {
    func speechFinished(with feedData: FeedData, at indexPath: IndexPath) {
        // collectionView?.reloadData()
    }
    
    // MARK: - Header Info
    func tappedSeeMore(with feedData: FeedData, at indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    func tappedTranslation(with feedData: FeedData, at indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    func tappedMore(with feedData: FeedData, at indexPath: IndexPath) {
        moreClosure?(feedData, indexPath)
    }
    func tappedUserInfo(with feedData: FeedData, at indexPath: IndexPath) {
        userInfoClosure?(feedData)
    }
    
    func tappedHashTag(with hashTag: String, at indexPath: IndexPath) {
        showHashTagClosue?(hashTag)
    }
    
    func tappedShowPostDetail(with feedData: FeedData, at indexPath: IndexPath) {
        showDetailClosure?(feedData)
    }
    
    func tappedHide(with feedData: FeedData, at indexPath: IndexPath) {

    }
    // MARK: - Sharing View
    func tappedShare(with feedData: FeedData, at indexPath: IndexPath) {
        shareClosure?(feedData)
    }
    func tappedComment(with feedData: FeedData, at indexPath: IndexPath) {
        commentClosure?(feedData, indexPath)
    }
    func tappedLiked(with feedData: FeedData, at indexPath: IndexPath) {
        likeClosure?(feedData)
    }
    func tappedLikesDetail(with feedData: FeedData, at indexPath: IndexPath) {
        likesDetailClosure?(feedData)
    }
    
    func tappedKalamSend(with feedData: FeedData, at indexPath: IndexPath) {
        // kalam send closure
        kamlamSendClosure?(feedData)
    }
}

// MARK: - PostVideoImageTextDelegate
extension PageBaseViewModel: PostDelegate , newPageDetailDelegate , editPageDelegate{
    
    func pageEditedSucessfully(page: GroupValue) {
        groupObj?.groupName = page.groupName
        groupObj?.name = page.groupName
        groupObj?.title = page.groupName
        groupObj?.slug = page.slug
        groupObj?.groupDesc = page.groupDesc
        groupObj?.categories = page.categories
        
        self.collectionView?.reloadData()
    }
    
    
    func editPage(pageID: Int) {
        var createPageVC = PageCreateController.init()
        createPageVC = UIApplication.topViewController()!.GetView(nameVC: "PageCreateController", nameSB: "Group") as! PageCreateController
        createPageVC.editDelegate = self
        createPageVC.isCreate = false
        createPageVC.pageValue = groupObj
        createPageVC.modalPresentationStyle = .overCurrentContext
        
        UIApplication.shared.keyWindow?.rootViewController?.present(createPageVC, animated: true)
    }
    
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        postTappedClosure?(obj)
    }
}

// MARK: - PostGalleryDelegate
extension PageBaseViewModel: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        postGalleryPreviewClosure?(obj, indexpath, tag)
    }
}

// MARK: - PostVideoDelegate
extension PageBaseViewModel: PostVideoDelegate {
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
}


extension PageBaseViewModel:DismissReportDetailSheetDelegate  , ProfileTabSelectionDelegate, ProfileImageSelectionDelegate {
    func profileTabSelection(tabValue : Int)
    {
        LogClass.debugLog("tabValue ===>")
        LogClass.debugLog(tabValue)
        LogClass.debugLog(self.isAPICallInProgress)
        
        self.feedImageArray.removeAll()
        
        switch tabValue {
        case 1:
            
            
            if self.selectedTab != .aboutMe {
                savedPostService(lastPostID: "", isLastTrue: true, isRefresh: false,isReview: false)
            }
            
            
            self.selectedTab = .aboutMe
            
            self.reloadCell()
            self.collectionView?.reloadData()
        case 2:
            self.selectedTab = .photos
            self.isMoreData = true
            self.reloadCell()
            self.collectionView?.reloadData()
            self.callingImageService(lastPostID: "", isLastTrue: true, isRefresh: true)
        case 3:
            self.selectedTab = .videos
            self.reloadCell()
            self.collectionView?.reloadData()
            self.isMoreData = true
            self.callingVideoService(lastPostID: "", isLastTrue: true, isRefresh: true)
        case 4:
            self.selectedTab = .myReels
            self.feedArray.removeAll()
            self.reloadCell()
            self.collectionView?.reloadData()
            savedPostService(lastPostID: "", isLastTrue: true, isRefresh: true,isReview: true)
            
        case 101:
            self.selectedTab = .myReels
            self.feedArray.removeAll()
            self.reloadCell()
            self.collectionView?.reloadData()
            savedPostService(lastPostID: "", isLastTrue: true, isRefresh: true,isReview: true)
        case 102:
            self.reloadCell()
            self.collectionView?.reloadData()
        default:
            self.selectedTab = .timeline
            self.isMoreData = true
            self.savedPostService(isRefresh: true)
            self.reloadCell()
            self.collectionView?.reloadData()
        }
    }
    
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        SharedManager.shared.showAlert(message: message, view: UIApplication.topViewController()!)
        }
    }
    
    func callingImageService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        self.isAPICallInProgress = true
        var parameters = ["action": "page/photos/more","page_id":self.groupObj!.groupID, "token": SharedManager.shared.userToken()]
        
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICallInProgress = false
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message?.contains("not found")) != nil)  {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
                self.isMoreData = false
                self.collectionView?.reloadData()
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        
        if let isFeedData = feedObj.data {
            if isFeedData.count == 0 {
                self.isNextFeedExist = false
            }else {
                if isRefresh {
                    self.feedImageArray.removeAll()
                }
                var newArray = [FeedData]()
                
                newArray.append(contentsOf: isFeedData)
                
                
                for indexObj in 0..<newArray.count {
                    let objectmain = newArray[indexObj]
                    self.feedImageArray.append(objectmain)
                }
            }
        }
        self.collectionView!.reloadData()
    }
    
    func ReloadNewPage(){
        
        let postObj:FeedData = self.feedImageArray.last!
        
        if self.isMoreData {
            if self.selectedTab == .photos {
                self.callingImageService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }else if self.selectedTab == .videos {
                self.callingVideoService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }
        }
        
    }
    
    func viewTranscript(tabValue : Int ){
        
    }
    
    func callingVideoService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        self.isAPICallInProgress = true
        var parameters = ["action": "page/videos/more","page_id":self.groupObj!.groupID, "token": SharedManager.shared.userToken()]
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICallInProgress = false
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message?.contains("not found")) != nil)  {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
                self.isMoreData = false
                self.collectionView?.reloadData()
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func profileImageSelection(tabValue : Int , isImage : Bool) {
        
        if isImage {
            
            
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            let valueempty = [String : Any]()
            var feedObj = FeedData.init(valueDict: valueempty)
            
            feedObj.postType = FeedType.image.rawValue
            
            var postFiles = [PostFile]()
            for indexObj in self.feedImageArray {
                for indexObjInner in indexObj.post! {
                    var postObj = PostFile.init()
                    postObj.fileType = FeedType.image.rawValue
                    postObj.filePath = indexObjInner.filePath!
                    postFiles.append(postObj)
                }
            }
            
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = tabValue
            fullScreen.isInfoViewShow = true
            fullScreen.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()!.present(fullScreen, animated: false, completion: nil)
            
            
        }else {
            
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var valueempty = [String : Any]()
            var feedObj = FeedData.init(valueDict: valueempty)
            
            feedObj.postType = FeedType.video.rawValue
            
            var postFiles = [PostFile]()
            for indexObj in self.feedImageArray {
                var postObj = PostFile.init()
                postObj.fileType = FeedType.video.rawValue
                postObj.filePath = indexObj.post?.first!.filePath
                postFiles.append(postObj)
            }
            
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = tabValue
            fullScreen.isInfoViewShow = true
            fullScreen.modalTransitionStyle = .crossDissolve
            UIApplication.topViewController()!.present(fullScreen, animated: false, completion: nil)
            
            
        }
    }
}



