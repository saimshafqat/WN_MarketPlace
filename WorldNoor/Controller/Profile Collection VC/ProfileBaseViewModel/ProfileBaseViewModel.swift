//
//  ProfileBaseViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import Combine
import UIKit

class ProfileBaseViewModel : NSObject {
    
    // MARK: - Properties -
    static let shared = ProfileBaseViewModel()
    var feedArray: [FeedData] = []
    var isPage: Bool = false
    weak var parentView : UIViewController?
    var collectionView: UICollectionView?
    private var layoutHelper = SavedPostLayoutHelper1()
    private var subscription: Set<AnyCancellable> = []
    private(set) var errorMessage: String?
    private var isAPICallInProgress = false
    var isLoading = false
    var isRefresh = false
    private var apiService: APIService?
    var playerSoundValue : Bool = true
    var indexPathVideo : IndexPath!
    var selectedTab = selectedUserTab.timeline
    
    var otherUserID = ""
    var otherUserisFriend = ""
    var otherUserSearchObj : SearchUserModel!
    var otherUserObj = UserProfile.init()
    
    
    // MARK: - Dictionary
    private lazy var cellsTypeDic: [String: UICollectionViewCell.Type] = {
        let cells = self.setCellForDataDic()
        return cells
    }()
    
    //    private var profileWizardCurrentType: ProfileWizardCellType = .closeAll
        
    
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
    var kalamSendClosure: ((FeedData)->Void)?
    var postImageClosure: ((FeedData)->())?
    var postImageDownloadClosure: ((FeedData)->Void)?
    var postDownloadClosure: ((FeedData)->Void)?
    var postTappedClosure: ((FeedData)->Void)?
    var postGalleryPreviewClosure: ((FeedData, IndexPath, Int) -> Void)?
    var showToastCompletion: (() -> Void)?
    var notificationBadgeHandler:(() ->())?
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
            FeedType.friendSuggestion.rawValue : PostMakeFriendsCell.self,
            FeedType.reelsFeed.rawValue : PostReelsCell.self,
            FeedType.Shimmer.rawValue: PostShimmerCell.self,
            FeedType.ShimmerAd.rawValue: PostShimmerAdCell.self,
            FeedType.LoadMoreData.rawValue: PostLoadMoreCell.self,
            FeedType.file.rawValue: PostAttachmentCollectionCell.self,
        ]
    }
    
    
    
    func initialSetup(collectionView: UICollectionView?,apiService: APIService?) {
        self.apiService = apiService
        self.setupCollectionView(collectionView)
        
        LogClass.debugLog(
            "UIApplication.topViewController() ===>")
        LogClass.debugLog(UIApplication.topViewController())
        
      
    }
    
    
    
    func reloadData(){
        
        self.getUsernfo()
        if ((UIApplication.topViewController()! as? ProfilePostController) != nil) {
            self.otherUserID = (UIApplication.topViewController()! as? ProfilePostController)!.otherUserID
            self.otherUserisFriend = (UIApplication.topViewController()! as? ProfilePostController)!.otherUserisFriend
            self.otherUserSearchObj = (UIApplication.topViewController()! as? ProfilePostController)!.otherUserSearchObj
            self.otherUserObj = (UIApplication.topViewController()! as? ProfilePostController)!.otherUserObj
            
            
            
            self.collectionView?.reloadItems(at: [IndexPath.init(row: 1, section: 0)])
            // api service
            
                showLoader()
                savedPostService(isRefresh: true)
        
        }
       
        
        setNotificationObserver()
    }
    
    func getUsernfo() {
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "profile/about","token": userToken]
        if self.otherUserID.count > 0 {
            parameters["user_id"] = self.otherUserID
        }

        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [String : Any] {
                    if self.otherUserID.count > 0 {
                        self.otherUserObj = UserProfile.init(fromDictionary: res as! [String : Any])
                        if self.otherUserID.count == 0 {
                            var userObj = SharedManager.shared.userObj
                            userObj?.data.profile_image = self.otherUserObj.profileImage
                        }
                    }else {
                        let userObj = UserProfile.init(fromDictionary: res as! [String : Any])
                        if String(SharedManager.shared.userObj!.data.id!) == userObj.id {
                            SharedClass.shared.saveXDataApp()
                        }
                        SharedManager.shared.userEditObj = UserProfile.init(fromDictionary: res as! [String : Any])
                    }
                }
//                if UIApplication.topViewController()!.tabBarController?.selectedIndex == 3 {
//                    self.viewModel.selectedTab = selectedUserTab.timeline
//                    self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
//                } else {
//                    self.viewModel.selectedTab = selectedUserTab.timeline
//                    self.viewModel.profileTabSelection(tabValue: selectedUserTab.timeline.rawValue)
//                }
                
                
                if SharedManager.shared.userEditObj.places.count > 0 {
                    SharedManager.shared.userObj?.data.placesAdded = true
                }
                
                self.otherUserisFriend = self.otherUserObj.is_friend
                self.otherUserSearchObj = nil
                self.collectionView?.reloadData()
            }
        }, param:parameters)
    }
    
   
    
    func setupCollectionView(_ collectionView: UICollectionView?) {
        self.collectionView = collectionView
        guard self.collectionView != nil else { return }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout = layoutHelper.createLayout()
    }
    
    // show loader
    func showLoader() {
        if self.feedArray.isEmpty {
            // Loader.startLoading()
        }
    }
    
    // call service
    func savedPostService(lastPostID: String = .emptyString, isLastTrue: Bool = false, isRefresh: Bool = false) {
        guard !isAPICallInProgress else {
            Loader.stopLoading()
            return  // Skip the API call if it's already in progress
        }
        self.isAPICallInProgress = true
        var parameters: [String: String] = [:]
        if let parentNEw = parentView as? PostBaseViewController, parentNEw.isPostSearch {
            parameters[Const.ResponseKey.query] = parentNEw.searchPost
        }
        if !isRefresh && isLastTrue {
            parameters[Const.ResponseKey.startingPointId] = lastPostID
        }
        
        if self.otherUserID.count > 0 {
            parameters["user_id"] = self.otherUserID
        }
        
        
        guard let endPoint = serviceEndPoint(with: parameters) else { return }
        apiService?.savedPost(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                case .failure(let errorType):
                    Loader.stopLoading()
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                    self.isAPICallInProgress = false
                    self.isLoading = false
                    self.errorMessage = errorType.localizedDescription
                }
            }, receiveValue: { feedModel in
                Loader.stopLoading()
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
        return true
    }
    
    // MARK: - Notification -
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.newReactionRecived),
                                               name: .reactionCountUpdated,
                                               object: nil)
    }
    
    @objc func newReactionRecived(_ notification: Notification) {
        // will handle for new reaction
        guard let userInfo = notification.userInfo as? [String : Any]  else { return }
        let postID = userInfo["post_id"] as? Int
        let likesCount = userInfo["likesCount"] as? Int
        let isReaction = userInfo["isReaction"] as? String
        // check feed data post id is equal then assign these data count
        let feedData = self.feedArray.filter({$0.postID == postID}).first
        feedData?.isReaction = isReaction
        feedData?.likeCount = likesCount
        reloadVisibleCells()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProfileBaseViewModel: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.height
        }
    }
    
    
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
    }
    
    private func handleVideoPlayback(for indexPath: IndexPath, in collectionView: UICollectionView) {
        
        let player = MediaManager.sharedInstance.player
        
        if player != nil{
            if indexPath.row != player!.indexPath?.row {
                stopVideoPlaybackIfNeeded(player)
            }
        }
            
        
        
        if let cellVideo = collectionView.cellForItem(at: indexPath) as? PostVideoCollectionCell {
            
            if !cellVideo.isPlayVideo {
                playVideoIfNeeded(in: cellVideo, with: player)
                indexPathVideo  = indexPath
            }
            
        } else if let cellVideo = collectionView.cellForItem(at: indexPath) as? PostGalleryCollectionCell1 {
            cellVideo.playVideo(with: feedArray[indexPath.item])
            indexPathVideo  = indexPath
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
        DispatchQueue.main.async {
            cell.isPlayVideo = true
            cell.playPlayer()
        }
        
    }
    
    private func stopVideoPlaybackIfNeeded(_ player: EZPlayer?) {
        if player?.isPlaying == true {
            player?.stop()
            indexPathVideo  = nil
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ProfileBaseViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        
        if section == 0 {
//            if self.isRoomSelected == .Rooms {
//                return 3
//            }
            return 1
        }
//        
//        
//        if self.feedArray.isEmpty {
//            return 3
//        }
        
//        feedArray.isEmpty ? (collectionView as? CollectionEmptyView)?.showEmptyState(with: "".localized()) : (collectionView as? CollectionEmptyView)?.hideEmptyState()
        return feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        if indexPath.section == 0 {
            let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionImageHeaderCell", for: indexPath) as! ProfileCollectionImageHeaderCell
            
            cellImage.otherUserID = self.otherUserID
            cellImage.otherUserSearchObj = self.otherUserSearchObj
            cellImage.otherUserObj = self.otherUserObj            
            cellImage.reloadData()
            return cellImage
        }
        
        if self.feedArray.count == 0 {
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
        }
        
        let feedPost = feedArray[indexPath.row]
        let feedPostType = feedPost.postType ?? .emptyString
        
        if feedPostType == FeedType.LoadMoreData.rawValue {
            let cellFrind = collectionView.dequeueReusableCell(withReuseIdentifier: "PostLoadMoreCell", for: indexPath) as? PostLoadMoreCell
            cellFrind?.loaderview.startAnimating()
            return cellFrind ?? UICollectionViewCell()
        }
        
        if feedPostType == FeedType.friendSuggestion.rawValue {
            let cellFrind = collectionView.dequeueReusableCell(withReuseIdentifier: "PostMakeFriendsCell", for: indexPath) as? PostMakeFriendsCell
            cellFrind?.reloadData()
            return cellFrind ?? UICollectionViewCell()
        }
        
        if feedPostType == FeedType.reelsFeed.rawValue {
            let cellFrind = collectionView.dequeueReusableCell(withReuseIdentifier: "PostReelsCell", for: indexPath) as? PostReelsCell
            cellFrind?.reloadData()
            return cellFrind ?? UICollectionViewCell()
        }
        
        let feedSharedPostType = feedPost.sharedData?.postType ?? .emptyString
        
        let isShared = feedPostType == FeedType.shared.rawValue
        let isPostType = isShared ? (feedSharedPostType == FeedType.post.rawValue) : feedPostType == FeedType.post.rawValue
        let hasLink = isShared ? (feedPost.sharedData?.previewLink?.count ?? 0 > 0) : feedPost.previewLink?.count ?? 0 > 0
        let hasLinkImage = isShared ? (feedPost.sharedData?.linkImage?.count ?? 0 > 0) : (feedPost.linkImage?.count ?? 0 > 0)
        let hasYoutubeLink = isShared ? (feedPost.sharedData?.previewLink ?? .emptyString).contains("youtube") : (feedPost.previewLink ?? .emptyString).contains("youtube")
        let hasPreviewLink = (isPostType && hasLinkImage) || (isPostType && hasYoutubeLink) || (isPostType && hasLink)
        
        
        let cellType = cellsTypeDic[isShared ? feedSharedPostType : feedPostType]
                
        
        if let cellType {
            var currentIdentifier = hasPreviewLink ? PostPreviewLinkCollectionCell.reuseIdentifier : cellType.reuseIdentifier
            if shouldAdsShow() {
                if (indexPath.item % 10 == 0) {
                    currentIdentifier = PostAdsCollectionCell.reuseIdentifier
                }
            }
            
            let type = isShared ? feedSharedPostType : feedPostType
            let existingFeedTypeArray =  setCellForDataDic().keys.map({String($0)})
            if !existingFeedTypeArray.contains(where: {$0 == type}) {
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentIdentifier, for: indexPath)
            
            LogClass.debugLog("<========== currentIdentifier =======>")
            LogClass.debugLog(currentIdentifier)
            LogClass.debugLog(isPostType)
            LogClass.debugLog(cellType)
            // let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentIdentifier, for: indexPath)
            
            // send data according to share or post type
            
            LogClass.debugLog("<========== currentIdentifier =======> 1" )
          (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPath)
            (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: false)
            
            if let addCell = cell as? PostAdsCollectionCell {
                addCell.parentView = UIApplication.topViewController()
                addCell.setupBannerAds()
                return cell
            }
            
            if let postBaseCell = cell as? PostBaseCollectionCell {
                postBaseCell.postBaseCellDelegate = self
            }
            if let postCell = cell as? PostCollectionCell1 {
                postCell.postDelegate = self
            }
            if let postGallery = cell as? PostGalleryCollectionCell1 {
                postGallery.galleryDelegate = self
            }
        if cell.isKind(of: PostVideoCollectionCell.self) {
                let postVideoCell = cell as? PostVideoCollectionCell
                postVideoCell?.playerSoundValue = self.playerSoundValue
                postVideoCell?.collectionViewMain = self.collectionView
                postVideoCell?.videoPostDelegate = self
                postVideoCell?.isPlayVideo = false
         (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPath)
                
                (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: false)
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
                    postVideoCell?.playerSoundValue = self.playerSoundValue
                    postVideoCell?.collectionViewMain = self.collectionView
                    postVideoCell?.videoPostDelegate = self
                    postVideoCell?.isPlayVideo = false
                    postVideoCell?.imgviewPH?.isHidden = false
                    
                    if feedPostType == FeedType.video.rawValue {
                        postVideoCell?.resetVideo(feedObjp: feedPost)
                    }
                }
                return cell
            } else {
                return cell
            }
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == feedArray.count - 1 && !isLoading {
            isLoading = true
            loadMoreData(indexPath)
        }
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
        let postObj = self.feedArray[indexPath.item] as FeedData
        savedPostService(lastPostID: String(postObj.postID ?? 0), isLastTrue: true, isRefresh: false)
    }
    
    func dataLoadedSuccessfully(newItems: [FeedData], isRefresh: Bool) {
        guard !newItems.isEmpty else {
            return
        }
        
        if isRefresh {
            feedArray.removeAll()
        }
        
        var arrayItems = [FeedData]()
        for indexObj in newItems{
            if indexObj.postType == FeedType.image.rawValue ||
                indexObj.postType == FeedType.video.rawValue ||
                indexObj.postType == FeedType.audio.rawValue ||
                indexObj.postType == FeedType.file.rawValue ||
                indexObj.postType == FeedType.gallery.rawValue ||
                indexObj.postType == FeedType.gif.rawValue ||
                indexObj.postType == FeedType.liveStream.rawValue ||
                indexObj.postType == FeedType.post.rawValue ||
                indexObj.postType == FeedType.shared.rawValue {
                arrayItems.append(indexObj)
            }
        }
        
       
        
        
        if self.feedArray.last?.postType == FeedType.LoadMoreData.rawValue {
            self.feedArray.remove(at: self.feedArray.count - 1)
        }
        
        feedArray.append(contentsOf: arrayItems)
        
        let lodData = [String : Any]()
        let newlodData = FeedData.init(valueDict: lodData)
        newlodData.postType = FeedType.LoadMoreData.rawValue
        newlodData.cellHeight = 250.0
        newlodData.cellHeightExpand = 250.0
       
        newlodData.postType = FeedType.LoadMoreData.rawValue
        
        
        self.feedArray.append(newlodData)
        updateCollectionView(isRefresh: isRefresh)
    }
    
    private func updateCollectionView(isRefresh: Bool) {
        UIView.performWithoutAnimation {
            refreshParentViewController()
            self.collectionView?.reloadData()
        }
    }
    
    private func refreshParentViewController() {
        (parentView as? FeedPostBaseViewController)?.refreshCompleted()
        isLoading = false
        isAPICallInProgress = false
        
        for indexObj in self.collectionView!.visibleCells {
            if let videoCell = indexObj as? PostVideoCollectionCell {
                videoCell.isPlayVideo = false
            }
        }
        playVideo()
    }
}

// MARK: - PostBaseCellDelegate
extension ProfileBaseViewModel: PostBaseCellDelegate {
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
            // self.collectionView?.collectionViewLayout.invalidateLayout()
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
        let indexPost = feedData.postID
        let indexMain = self.feedArray.firstIndex(where: {$0.postID == indexPost})
        if let indexMain {
            self.feedArray.remove(at: indexMain)
            self.collectionView?.deleteItems(at: [IndexPath.init(row: indexMain, section: indexPath.section)])
        }
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
        kalamSendClosure?(feedData)
    }
}

// MARK: - PostVideoImageTextDelegate
extension ProfileBaseViewModel: PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        postTappedClosure?(obj)
    }
}

// MARK: - PostGalleryDelegate
extension ProfileBaseViewModel: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        postGalleryPreviewClosure?(obj, indexpath, tag)
    }
}

// MARK: - PostVideoDelegate
extension ProfileBaseViewModel: PostVideoDelegate {
    
    
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    
 
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            // Take the user to Settings app to possibly change permission.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        alert.addAction(settingsAction)
        
        self.parentView?.present(alert, animated: true, completion: nil)
    }
}

