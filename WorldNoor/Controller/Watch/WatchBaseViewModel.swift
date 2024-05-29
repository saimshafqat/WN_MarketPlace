//
//  WatchBaseViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 20/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import Combine
import UIKit
class WatchBaseViewModel : NSObject {
    
    // MARK: - Properties -
    static let shared = WatchBaseViewModel()
    var feedArray: [FeedData] = []
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
        

        self.collectionView?.register(UINib.init(nibName: "EmptyCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCell")
        
        
        
        self.collectionView?.reloadItems(at: [IndexPath.init(row: 1, section: 0)])

        showLoader()
        savedPostService(isRefresh: true)
        
        setNotificationObserver()
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
            
        }
    }
    
    // call service
    func savedPostService(lastPostID: String = .emptyString, isLastTrue: Bool = false, isRefresh: Bool = false) {
        guard !isAPICallInProgress else {

            return  // Skip the API call if it's already in progress
        }
        self.isAPICallInProgress = true
        var parameters: [String: String] = [:]
        
        if !isRefresh && isLastTrue {
            parameters[Const.ResponseKey.startingPointId] = lastPostID
        }
        
        if self.feedArray.count > 25 {
            parameters[Const.ResponseKey.newsfeedCount] = "10"
        }
        
        guard let endPoint = serviceEndPoint(with: parameters) else { return }
        apiService?.savedPost(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                case .failure(let errorType):
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                    self.isAPICallInProgress = false
                    self.isLoading = false
                    self.errorMessage = errorType.localizedDescription
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

extension WatchBaseViewModel: UIScrollViewDelegate {
    
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
extension WatchBaseViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.feedArray.isEmpty {
            return 3
        }
        
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
            
          (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost.sharedData: feedPost, parentData: feedPost, at: indexPath)
            (cell as? PostBaseCollectionCell)?.peopleDetailView?.manageMemoryView(isFrom: false)
            
            if let addCell = cell as? PostAdsCollectionCell {
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
            if
                indexObj.postType == FeedType.video.rawValue ||
                indexObj.postType == FeedType.liveStream.rawValue
               {
                arrayItems.append(indexObj)
            }
        }
        
//        if arrayItems.count > 0 {
//
//            var newItemss : [FeedData] =  [FeedData]()
//
//            if newItemss.count > 40 {
//                for _ in 0..<arrayItems.count {
//                    let numberRandome = Int.random(in: 0..<newItems.count)
//                    newItemss.remove(at: numberRandome)
//                }
//            }
//
//            newItemss.append(contentsOf: arrayItems)
//        }
        
        
        
        if self.feedArray.last?.postType == FeedType.LoadMoreData.rawValue {
            self.feedArray.remove(at: self.feedArray.count - 1)
        }
        
        feedArray.append(contentsOf: arrayItems)
        
        let mainDataFriend = [String : Any]()
        
        let loadMoreCell = FeedData.init(valueDict: mainDataFriend)
        loadMoreCell.postType = FeedType.LoadMoreData.rawValue
        
        
        self.feedArray.append(loadMoreCell)
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
extension WatchBaseViewModel: PostBaseCellDelegate {
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
extension WatchBaseViewModel: PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        postTappedClosure?(obj)
    }
}

// MARK: - PostGalleryDelegate
extension WatchBaseViewModel: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        postGalleryPreviewClosure?(obj, indexpath, tag)
    }
}

// MARK: - PostVideoDelegate
extension WatchBaseViewModel: PostVideoDelegate {
    
    
   
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
