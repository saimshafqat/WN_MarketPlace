//
//  FeedPostBaseViewModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 03/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//


import Foundation
import Combine
import UIKit
import CoreLocation
import UIScrollView_InfiniteScroll

class FeedPostBaseViewModel : NSObject {
    
    // MARK: - Properties -
    static let shared = FeedPostBaseViewModel()
    var feedArray: [FeedData] = []
    var groupObj:GroupValue?
    var isPage: Bool = false
    weak var parentView : UIViewController?
    var collectionView: CollectionEmptyView?
    private var layoutHelper = SavedPostLayoutHelper1()
    private var subscription: Set<AnyCancellable> = []
    private(set) var errorMessage: String?
    private var isAPICallInProgress = false
    var isLoading = false
    var isRefresh = false
    var isRoomSelected : PostHeaderType = .none
    private var apiService: APIService?
    var playerSoundValue : Bool = true
    var isFoundFriend : Bool = false
    var isReelsAdded : Bool = false
    var indexPathVideo : IndexPath!
    var isSkiedTap : Bool = false
    var locationHandler: LocationHandler?
    
    // MARK: - Dictionary
    private lazy var cellsTypeDic: [String: UICollectionViewCell.Type] = {
        let cells = self.setCellForDataDic()
        return cells
    }()
    
    //    private var profileWizardCurrentType: ProfileWizardCellType = .closeAll
    
    var arrayProfileWizard : [ProfileWizardCellType] = []
    
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
    // var reelTappedClosure: (([FeedData], IndexPath)->Void)?
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
            FeedType.file.rawValue: PostAttachmentCollectionCell.self,
        ]
    }
    
    func initialSetup(collectionView: CollectionEmptyView?,apiService: APIService?) {
        self.apiService = apiService
        self.setupCollectionView(collectionView)
        
        arrayProfileWizard.removeAll()
        
        if !SharedManager.shared.userObj!.data.isProfileCompleted! {
            self.checkProfileValidation()
        }
        
        
        self.arrayProfileWizard.append(.closeAll)
        self.collectionView?.reloadItems(at: [IndexPath.init(row: 1, section: 0)])

        showLoader()
        savedPostService(isRefresh: true)
        setNotificationObserver()
    }
    
    func checkProfileValidation() {
        
        if SharedManager.shared.userObj != nil {
            if SharedManager.shared.userObj?.data.profile_image == nil {
                self.arrayProfileWizard.append(.pictureCell1)
            }else if ((SharedManager.shared.userObj!.data.profile_image!).contains("icon-person.png")) {
                self.arrayProfileWizard.append(.pictureCell1)
            }
            self.checkPicture()
        }
    }
    
    func checkPicture() {
        if SharedManager.shared.userObj?.data.cover_image == nil || SharedManager.shared.userObj!.data.cover_image?.count == 0 {
            self.arrayProfileWizard.append(.pictureCell2)
        }
        self.checkDOB()
    }
    
    func checkDOB() {
        if SharedManager.shared.userObj?.data.dob == nil || SharedManager.shared.userObj?.data.dob?.count == 0 {
            self.arrayProfileWizard.append(.dobCell)
        }
        self.checkGender()
    }
    
    func checkGender() {
        if (SharedManager.shared.userObj?.data.gender == nil || SharedManager.shared.userObj?.data.gender?.count == 0) && (SharedManager.shared.userObj?.data.custom_gender == nil || SharedManager.shared.userObj?.data.custom_gender?.count == 0) {
            self.arrayProfileWizard.append(.genderCell)
        }
        self.checkEmailPhone()
    }
    
    func checkEmailPhone() {
        if SharedManager.shared.userObj?.data.email == nil || SharedManager.shared.userObj?.data.phone == nil || SharedManager.shared.userObj?.data.email!.count == 0 || SharedManager.shared.userObj?.data.phone?.count == 0 {
            self.arrayProfileWizard.append(.emailPhoneCell)
        }
        self.checkPlace()
        
    }
    
    func checkMartialStatus() {
        if SharedManager.shared.userObj?.data.RelationAdded != nil {
            if SharedManager.shared.userObj?.data.RelationAdded == false {
                self.arrayProfileWizard.append(.maritalStatusCell)
            }
        }
        self.checkWorkStatus()
    }
    
    func checkWorkStatus() {
        if SharedManager.shared.userObj?.data.workAdded == false {
            self.arrayProfileWizard.append(.workCell)
        }
        if self.arrayProfileWizard.count > 0 {
            self.arrayProfileWizard.append(.congratulationCell)
        }
    }
    
    func checkPlace(){
        if SharedManager.shared.userObj?.data.placesAdded == nil || SharedManager.shared.userObj?.data.placesAdded == false {
            self.arrayProfileWizard.append(.placeCell)
        }
        self.checkMartialStatus()
    }
    
    // collection view basic setup
    func setupCollectionView(_ collectionView: CollectionEmptyView?) {
        self.collectionView = collectionView
        guard self.collectionView != nil else { return }
        collectionView?.registerXibCell([
            .ProfileCompletePictureCell,
            .ProfileCompleteDOBCell,
            .ProfileCompleteGenderCell,
            .ProfileCompleteEmailPhoneCell,
            .ProfileCompletePlaceCell,
            .ProfileCompleteMaritalStatusCell,
            .ProfileEmptyCell,
            .ProfileCompleteCongratulationCell,
            .EmptyCell
        ])
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout = layoutHelper.createLayout()
        self.collectionView?.infiniteScrollDirection = .vertical
        self.collectionView?.addInfiniteScroll(handler: { _ in })
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
            (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
            self.isAPICallInProgress = false
            self.isLoading = false
            self.collectionView?.finishInfiniteScroll()
            return  // Skip the API call if it's already in progress
        }
        self.isAPICallInProgress = true
        var parameters: [String: String] = [:]
        
        if groupObj?.groupID != nil {
            parameters[isPage ? Const.ResponseKey.pageid : Const.ResponseKey.groupid] = self.groupObj?.groupID
        }
        
        if !isRefresh && isLastTrue {
            parameters[Const.ResponseKey.startingPointId] = lastPostID
        }
        
        parameters[Const.ResponseKey.newsfeedCount] = "10"
        
        guard let endPoint = serviceEndPoint(with: parameters) else { return }
        apiService?.savedPost(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                    self.collectionView?.finishInfiniteScroll()
                case .failure(let errorType):
                    Loader.stopLoading()
                    (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
                    self.isAPICallInProgress = false
                    self.isLoading = false
                    self.errorMessage = errorType.localizedDescription
                    self.collectionView?.finishInfiniteScroll()
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
                                               name: .updateNewsFeedOnReactionChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.removeNewsFeedObserver),
                                               name: .removeNewsFeedReactionObserver,
                                               object: nil)
    }
    
    @objc func newReactionRecived(_ notification: Notification) {
        // will handle for new reaction
        guard let dic = notification.object as? [String : Any]?  else { return }
        let userInfo = dic?["feedObject"] as? FeedData
        let indexpath = dic?["indexpath"] as? IndexPath
        let postID = userInfo?.postID
        let likesCount = userInfo?.likeCount
        let isReaction = userInfo?.isReaction
        // check feed data post id is equal then assign these data count
        let feedData = self.feedArray.filter({$0.postID == postID}).first
        feedData?.isReaction = isReaction
        feedData?.likeCount = likesCount
        feedData?.isLiked = userInfo?.isLiked
        feedData?.reationsTypesMobile = userInfo?.reationsTypesMobile
        feedData?.commentCount = userInfo?.commentCount
        feedData?.comments = userInfo?.comments
        if let indexpath {
            self.collectionView?.reloadItems(at: [indexpath])
        }
    }
    
    @objc func removeNewsFeedObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FeedPostBaseViewModel: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { playVideo() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVideo()
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
    
    func handleVideoPlayback(for indexPath: IndexPath, in collectionView: CollectionEmptyView) {

        let player = MediaManager.sharedInstance.player
        
        if player != nil {
            if indexPath.item != player!.indexPath?.item {
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
            indexPathVideo = indexPath
        } else {
            stopVideoPlaybackIfNeeded(player)
        }
    }
    
    private func playVideoIfNeeded(in cell: PostVideoCollectionCell, with player: EZPlayer?) {
        guard let _ = player else {
            cell.isPlayVideo = true
            cell.playPlayer()
            return
        }
        cell.isPlayVideo = true
        cell.playPlayer()
    }
    
    private func stopVideoPlaybackIfNeeded(_ player: EZPlayer?) {
        if player?.isPlaying == true {
            player?.stop()
            indexPathVideo = nil
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FeedPostBaseViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if self.isRoomSelected == .Rooms {
                return 3
            }
            return 4
        }
        if self.feedArray.isEmpty {
            return 3
        }
        feedArray.isEmpty ? (collectionView as? CollectionEmptyView)?.showEmptyState(with: "".localized()) : (collectionView as? CollectionEmptyView)?.hideEmptyState()
        return feedArray.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cellCreate = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCreateCell", for: indexPath) as? PostCreateCell
                cellCreate?.createPostDelegate = self
                return cellCreate ?? UICollectionViewCell()
                
            } else if indexPath.row == 1 { // profile wizard cells
                switch self.arrayProfileWizard[0] {
                case .pictureCell1:
                    let cellProfileOne = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompletePictureCell", for: indexPath) as? ProfileCompletePictureCell
                    cellProfileOne?.delegate = self
                    cellProfileOne?.bindData(dataType: 0)
                    return cellProfileOne ?? UICollectionViewCell()
                    
                case .pictureCell2:
                    let cellProfileOne = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompletePictureCell", for: indexPath) as? ProfileCompletePictureCell
                    cellProfileOne?.delegate = self
                    cellProfileOne?.bindData(dataType: 1)
                    return cellProfileOne ?? UICollectionViewCell()
                    
                case .dobCell:
                    let cellProfileTwo = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteDOBCell", for: indexPath) as? ProfileCompleteDOBCell
                    cellProfileTwo?.delegate = self
                    return cellProfileTwo ?? UICollectionViewCell()
                    
                case .genderCell:
                    let cellProfileThree = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteGenderCell", for: indexPath) as? ProfileCompleteGenderCell
                    cellProfileThree?.delegate = self
                    return cellProfileThree ?? UICollectionViewCell()
                    
                case .emailPhoneCell:
                    let cellProfileFour = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteEmailPhoneCell", for: indexPath) as? ProfileCompleteEmailPhoneCell
                    cellProfileFour?.bindData()
                    cellProfileFour?.delegate = self
                    return cellProfileFour ?? UICollectionViewCell()
                    
                case .placeCell:
                    let cellProfileFive = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompletePlaceCell", for: indexPath) as? ProfileCompletePlaceCell
                    cellProfileFive?.delegate = self
                    return cellProfileFive ?? UICollectionViewCell()
                case .maritalStatusCell:
                    let cellProfileSix = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteMaritalStatusCell", for: indexPath) as? ProfileCompleteMaritalStatusCell
                    cellProfileSix?.bindData(type: 0)
                    cellProfileSix?.delegate = self
                    return cellProfileSix ?? UICollectionViewCell()
                    
                case .workCell:
                    let cellProfileSix = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteMaritalStatusCell", for: indexPath) as? ProfileCompleteMaritalStatusCell
                    cellProfileSix?.bindData(type: 1)
                    cellProfileSix?.delegate = self
                    return cellProfileSix ?? UICollectionViewCell()
                case .congratulationCell:
                    let cellProfileEight = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCompleteCongratulationCell", for: indexPath) as? ProfileCompleteCongratulationCell
                    cellProfileEight?.delegate = self
                    return cellProfileEight ?? UICollectionViewCell()
                case .closeAll:
                    let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as? EmptyCell
                    return emptyCell ?? UICollectionViewCell()
                }
            } else if indexPath.row == 3 {
                let cellCreate = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionStoryCell", for: indexPath) as? PostCollectionStoryCell
                // cellCreate?.postCollectionStoryDelegate = self
                if self.isRoomSelected == .none {
                    cellCreate?.manageFeedHeader() // waseem
                    self.isRoomSelected = .Story
                }else if self.isRoomSelected == .Reels {
                    cellCreate?.isWatch = true
                    cellCreate?.changeView()
                }else if self.isRoomSelected == .Story {
                    cellCreate?.isWatch = false
                    cellCreate?.changeView()
                }
                return  cellCreate ?? UICollectionViewCell()
            } else {
                let cellSection = collectionView.dequeueReusableCell(withReuseIdentifier: "PostSectionCell", for: indexPath) as? PostSectionCell
                cellSection?.createPostDelegate = self
                return cellSection ?? UICollectionViewCell()
            }
        }
        
        if self.feedArray.count == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostShimmerAdCell", for: indexPath) as? PostShimmerAdCell
                cell?.startAnimation()
                cell?.shimmerView.isHidden = false
                return cell ?? UICollectionViewCell()
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostShimmerCell", for: indexPath) as? PostShimmerCell
            cell?.startAnimation()
            cell?.shimmerView.isHidden = false
            return cell ?? UICollectionViewCell()
        }
        
        let feedPost = feedArray[indexPath.row]
        let feedPostType = feedPost.postType ?? .emptyString
        
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
            var currentIdentifier = hasPreviewLink ? PostPreviewLinkCollectionCell.reuseIdentifier : !(cellType.reuseIdentifier.isEmpty) ? cellType.reuseIdentifier : PostCollectionCell1.reuseIdentifier

            if shouldAdsShow() {
                if (indexPath.item % 10 == 0) {
                    currentIdentifier = PostAdsCollectionCell.reuseIdentifier
                }
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: currentIdentifier, for: indexPath)
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
                    let item = isShared ? feedPost.sharedData: feedPost
                    if let item {
                        postVideoCell?.resetVideo(feedObjp: item)
                    }
                }
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Load more data if reaching the last cell
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
            self.isReelsAdded = false
            self.isFoundFriend = false
            feedArray.removeAll()
        }
        
        var arrayItems = newItems.filter { item in
            setCellForDataDic().keys.contains(item.postType ?? .emptyString)
        }
        
        if feedArray.count == 0 {
            // when do not have section and array is empty
            self.feedArray.append(contentsOf: arrayItems)
            (self.parentView as? FeedPostBaseViewController)?.refreshCompleted()
            self.isAPICallInProgress = false
            self.isLoading = false
            self.collectionView?.reloadData()
            self.refreshParentViewController()
        } else {
            self.collectionView?.performBatchUpdates({
                // add firend suggestion
                if !isFoundFriend {
                    if self.feedArray.count > 0 {
                        let mainDataFriend = [String : Any]()
                        let newFeedFriend = FeedData.init(valueDict: mainDataFriend)
                        newFeedFriend.postType = FeedType.friendSuggestion.rawValue
                        newFeedFriend.cellHeight = 250.0
                        newFeedFriend.cellHeightExpand = 250.0
                        arrayItems.insert(newFeedFriend, at: 3)
                        self.isFoundFriend = true
                    }
                }
                if !self.isReelsAdded {
                    if self.feedArray.count > 0 {
                        let mainData = [String: Any]()
                        let newFeedReels = FeedData(valueDict: mainData)
                        newFeedReels.postType = FeedType.reelsFeed.rawValue
                        arrayItems.insert(newFeedReels, at: 8)
                        self.isReelsAdded = true
                    }
                }
                let startIndex = self.feedArray.count
                self.feedArray.append(contentsOf: arrayItems)
                let sectionIndex = 1
                let indexPaths: [IndexPath] = Array(startIndex..<self.feedArray.count).compactMap({
                    return IndexPath(item: $0, section: sectionIndex)
                })
                self.collectionView?.insertItems(at: indexPaths)
            }, completion: { finished in
                self.collectionView?.finishInfiniteScroll()
                self.refreshParentViewController()
            })
        }
    }
    
    private func updateCollectionView(isRefresh: Bool) {
        UIView.performWithoutAnimation {
            refreshParentViewController()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
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
extension FeedPostBaseViewModel: PostBaseCellDelegate {
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
extension FeedPostBaseViewModel: PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        
        postDownloadClosure?(obj)
    }
    
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        postTappedClosure?(obj)
    }
}

// MARK: - PostGalleryDelegate
extension FeedPostBaseViewModel: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        postGalleryPreviewClosure?(obj, indexpath, tag)
    }
}

// MARK: - PostVideoDelegate
extension FeedPostBaseViewModel: PostVideoDelegate , PostCreateDelegate{
    
    func tappedCreatePost(TypeChoose : Int) {
        switch TypeChoose {
        case 101:
            storyChoose()
        case 102:
            reelsChoose()
        case 103:
            roomsChoose()
        case 1:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        case 2:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        case 3:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        case 4:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        case 5:
            openLiveTapped()
        case 6:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        case 7:
            headerOptionBtn1Clicked(senderTag: TypeChoose)
        default:
            LogClass.debugLog(TypeChoose)
        }
    }
    
    func storyChoose(){
        if let cellCollection = self.collectionView?.cellForItem(at: IndexPath.init(row: 2, section: 0)) as? PostCollectionStoryCell {
            cellCollection.isWatch = false
            cellCollection.changeView()
        }
        self.isRoomSelected = .Story
        perform(#selector(reloadCollection), with: nil, afterDelay: 0.1)
    }
    
    func reelsChoose(){
        if let cellCollection = self.collectionView?.cellForItem(at: IndexPath.init(row: 2, section: 0)) as? PostCollectionStoryCell {
            cellCollection.isWatch = true
            cellCollection.changeView()
        }
        self.isRoomSelected = .Reels
        
        perform(#selector(reloadCollection), with: nil, afterDelay: 0.1)
    }
    
    @objc func reloadCollection(){
        self.collectionView?.reloadData()
    }
    
    func roomsChoose(){
        self.isRoomSelected = .Rooms
        self.collectionView?.reloadData()
    }
    
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        postDownloadClosure?(obj)
    }
    
    func headerOptionBtn1Clicked(senderTag : Int) {
        if senderTag == 1 {
            SharedManager.shared.createPostSelection = 4
        }else if senderTag == 2 {
            SharedManager.shared.createPostSelection = 0
        }else if senderTag == 3 {
            SharedManager.shared.createPostSelection = 6
        }else if senderTag == 4 {
            SharedManager.shared.createPostSelection = 0
        }else if senderTag == 7 {
            SharedManager.shared.createPostSelection = 5
        }
        let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as! UINavigationController
        createPost.modalPresentationStyle = .fullScreen
        self.parentView?.present(createPost, animated: false, completion: nil)
    }
    
    func openLiveTapped() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (authStatus) {
        case .restricted, .denied:
            self.showAlert(title: "Unable to access the Camera",
                           message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
        case .authorized ,.notDetermined:
            let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "GoLiveController") as! GoLiveController
            self.parentView!.present(goLive, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        })
        alert.addAction(settingsAction)
        self.parentView?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User location service update //
    func callServiceUpdateLocation(loc: CLLocation) {
        
        let hasLocationUpdated = UserDefaultsUtility.get(with: .hasLocationUpdated) as? Bool ?? false
        if !(hasLocationUpdated) {
            let lat = String(loc.coordinate.latitude)
            let lng = String(loc.coordinate.longitude)
            if !(lat.isEmpty) && !(lng.isEmpty) {
                let param = ["lat": lat,"long": lng]
                self.apiService?.updateUserLocationRequest(endPoint: .updateUserLocation(param))
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Completed Successfully")
                        case .failure(let errorType):
                            LogClass.debugLog(errorType)
                        }
                    }, receiveValue: { response in
                        LogClass.debugLog(response)
                        UserDefaultsUtility.save(with: .hasLocationUpdated, value: true)
                    })
                    .store(in: &self.subscription)
            }
        }
    }
}

extension FeedPostBaseViewModel: ProfileWizardDelegate {
    
    func closeTapped(isSkipped : Bool = false) {
        if self.arrayProfileWizard.count > 1 {
            self.arrayProfileWizard.remove(at: 0)
        }
        if isSkipped {
            if !(self.isSkiedTap) {
                self.isSkiedTap = true
                // remove congratulation cell if user does skip
                if self.arrayProfileWizard.contains(.congratulationCell) {
                    if let index = self.arrayProfileWizard.lastIndex(of: .congratulationCell) {
                        self.arrayProfileWizard.remove(at: index)
                    }
                }
            }
        }
        self.collectionView?.reloadItems(at: [IndexPath.init(row: 1, section: 0)])
    }
}

protocol ProfileWizardDelegate: AnyObject {
    
    func closeTapped(isSkipped : Bool)
    
}

enum ProfileWizardCellType {
    case pictureCell1
    case pictureCell2
    case dobCell
    case genderCell
    case emailPhoneCell
    case placeCell
    case maritalStatusCell
    
    case workCell
    case congratulationCell
    case closeAll
}

