//
//  PostBaseViewModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import Combine

class PostBaseViewModel : NSObject {
    
    // MARK: - Properties -
    var feedArray: [FeedData] = []
    var groupObj:GroupValue?
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
    
    var postBaseCellDelegate: PostBaseCellDelegate?
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
    var showHashTagClosue: ((String) -> ())?
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
            FeedType.file.rawValue: PostAttachmentCollectionCell.self
        ]
    }
    
    func initialSetup(collectionView: UICollectionView?, apiService: APIService?) {
        self.apiService = apiService
        self.setupCollectionView(collectionView)

        self.isAPICallInProgress = false
        
        self.feedArray.removeAll()
        
        self.collectionView?.reloadData()
        setNotificationObserver()
        
        updateCollectionView(isRefresh: false)
    }
    
    func setupCollectionView(_ collectionView: UICollectionView?) {
        self.collectionView = collectionView
        guard self.collectionView != nil else { return }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout = layoutHelper.createLayout()
    }
    

    // call service
    func savedPostService(lastPostID: String = .emptyString, isLastTrue: Bool = false, isRefresh: Bool = false) {
        
        
        
        
        guard !isAPICallInProgress else {
            return  // Skip the API call if it's already in progress
        }
        self.isAPICallInProgress = true
        if isRefresh {
            self.feedArray.removeAll()
        }
        let userToken = SharedManager.shared.userToken()
        
        var parameters: [String: String] = ["token": userToken]
        if groupObj?.groupID != nil {
            parameters[isPage ? Const.ResponseKey.pageid : Const.ResponseKey.groupid] = self.groupObj?.groupID
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
                    self.updateCollectionView(isRefresh: isRefresh)
                case .failure(let errorType):
                    self.isAPICallInProgress = true
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

extension PostBaseViewModel: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        LogClass.debugLog("  ==== > indexPath 1")
        if !decelerate { playVideo() }
    }
    
    func playVideo() {
        LogClass.debugLog("  ==== > indexPath 2")
        var visibleRect = CGRect()
        guard let collectionView else { return }
        LogClass.debugLog("  ==== > indexPath 3")
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
                playVideoIfNeeded(in: cellVideo, with: player)
                cellVideo.imgviewPH?.isHidden = false
            } else if let cellVideo = collectionView.cellForItem(at: indexPath) as? PostGalleryCollectionCell1 {
                if indexPath.row <= self.feedArray.count - 1 {
                    cellVideo.playVideo(with: feedArray[indexPath.item])
                }
                
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
        
        guard let collectionView else { return }
        
        LogClass.debugLog("player!.indexPath  ===>")
        LogClass.debugLog(player)
        LogClass.debugLog(player?.indexPath)
        
        if player != nil {
//            if let cellVideo = collectionView.cellForItem(at: player!.indexPath!) as? PostGalleryCollectionCell1 {
//                LogClass.debugLog("stopVideoPlaybackIfNeeded ===> stopVideoPlaybackIfNeeded")
//                cellVideo.reloadData()
                
//            }
        }
        
        if player?.isPlaying == true {
            player?.stop()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PostBaseViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if !self.isAPICallInProgress && self.feedArray.count == 0{
            return 3
        }

        feedArray.isEmpty ? (collectionView as? CollectionEmptyView)?.showEmptyState(with: Const.noPostFound.localized()) : (collectionView as? CollectionEmptyView)?.hideEmptyState()
        return feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPath)
        (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: visibilityMemorySharing())
        if let postBaseCell = cell as? PostBaseCollectionCell {
            postBaseCell.postBaseCellDelegate = self
        }
        if let postCell = cell as? PostCollectionCell1 {
            postCell.postDelegate = self
        }
        if let postGallery = cell as? PostGalleryCollectionCell1 {
            postGallery.indexPAthMain = indexPath
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if feedArray.count > 0 {
            if indexPath.item == feedArray.count - 1 && !isLoading {
                isLoading = true
                loadMoreData(indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item < feedArray.count else { return }
        if let audioCell = cell as? PostAudioCollectionCell1 {
            audioCell.stopPlayer()
        } else if let videoCell = cell as? PostVideoCollectionCell {
            videoCell.pauseAudioTapped(UIButton())
        } else if let videoCell = cell as? PostGalleryCollectionCell1 {
            videoCell.reloadData()
        }
    }
    
    // MARK: - Load More Data -
    func loadMoreData(_ indexPath: IndexPath) {
        // Save the current scroll position
        let postObj = self.feedArray[indexPath.item] as FeedData
        if ((UIApplication.topViewController()?.isKind(of: SavedPostController1.self)) != nil) {
            savedPostService(lastPostID: String(postObj.userSavedId ?? 0), isLastTrue: true, isRefresh: false)
        } else {
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
extension PostBaseViewModel: PostBaseCellDelegate {
    func speechFinished(with feedData: FeedData, at indexPath: IndexPath) {

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
    func tappedShowPostDetail(with feedData: FeedData, at indexPath: IndexPath) {
        showDetailClosure?(feedData)
    }
    
    func tappedHashTag(with hashTag: String, at indexPath: IndexPath) {
        showHashTagClosue?(hashTag)
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
extension PostBaseViewModel: PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        postTappedClosure?(obj)
    }
}

// MARK: - PostGalleryDelegate
extension PostBaseViewModel: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        postGalleryPreviewClosure?(obj, indexpath, tag)
    }
}

// MARK: - PostVideoDelegate
extension PostBaseViewModel: PostVideoDelegate {
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
}
