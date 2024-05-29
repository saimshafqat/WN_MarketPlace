//
//  SearchResultViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 18/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

enum SearchAllRequest {
    case searchUser
    case searchPage
    case searchGroup
    case searchPost
    
    var endPoint: String {
        switch self {
        case .searchUser:
           // return "search/users"
            return "search/users/v2"
        case .searchPage:
            return "search/pages"
        case .searchGroup:
            return "search/groups"
        case .searchPost:
            // return "search/posts"
            return "search/posts/v2"
        }
    }
}

protocol SearchResultDelegate {
    func seeAllTapped(at section: SectionInfo, indexPath: IndexPath?, with query: String)
    func sectionItemNavigation(with dataSource: SSSectionedDataSource?, indexPath: IndexPath)
    func connectToMessage(at indexPath: IndexPath, sender: UIButton, searchUser: SearchUserModel?)
    func moveToPostDetail(postObj: FeedData)
    func moveToProfileDetai(postObj: FeedData)
    func moveToHashTag(with value: String)
}

class SearchResultViewController: UIViewController {
    
    // MARK: - IBOutlets -
    private var arrayUser = [SearchUserModel]()
    private var arrayGroups = [GroupValue]()
    private var arrayPages = [GroupValue]()
    private var arrayPosts = [FeedData]()
    private var bag = Set<AnyCancellable>()
    
    private var viewHelper = SearchResultViewHelper()
    var searchResultDelegate: SearchResultDelegate?
    
    private var isAPICall = false
    private var playerSoundValue = true
    private var islandscapeTap = true
    private var query: String = .emptyString
    
    private var workItemReference: DispatchWorkItem?
    private var indexPathVideo : IndexPath!
    private let dispatchGroup = DispatchGroup()
    private let apiEndPoints: [SearchAllRequest] = [
        .searchUser, .searchPage, .searchGroup, .searchPost
    ]
    
    var requestOperationTrack: [SearchAllRequest] = []
    
    // MARK: - Completion -
    var keyboardScrollCompletion: (() -> Void)? = nil
    
    // MARK: - Lazy Properties -
    lazy var dataSource: SSSectionedDataSource? = {
        let ds = SSSectionedDataSource(sections: [])
        ds?.emptyView = defaultGroupSearchEmptyView
        return ds
    }()
    
    // MARK: - Lazy Properties -
    lazy var defaultGroupSearchEmptyView: MyNetworkUpdateView? = {
        let emptyView = MyNetworkUpdateView.customInit()
        emptyView?.setupView(text: "No groups found")
        emptyView?.emptyText?.textColor = .darkGray
        return emptyView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
        
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addObserver()
        emptyGroupView()
        configureView()
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
    }
    
    // MARK: - Methods -
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if dataSource?.emptyView != nil {
            dataSource?.emptyView.frame = emptyViewFrameCenter()
        }
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.minY + 130)
    }
    
    func emptyViewFrameCenter() -> CGRect {
        let frame =  CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        return frame
    }
    
    // it will show empty view
    func emptyGroupView() {
        let section = Int(self.dataSource?.numberOfSections() ?? 0)
        if section == 0 {
            if dataSource?.emptyView != nil {
                dataSource?.emptyView = nil
            }
            if query.count > 0 {
                defaultGroupSearchEmptyView?.setupView(text: "We couldn't find anything to show for \(query)")
                dataSource?.emptyView = defaultGroupSearchEmptyView
            } else {
                if dataSource?.emptyView != nil {
                    dataSource?.emptyView = nil
                }
            }
        }
    }
    
    // MARK: - Methods -
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.islandscapeTap {
            LogClass.debugLog("Release player 4")
            MediaManager.sharedInstance.player?.pause()
            MediaManager.sharedInstance.releasePlayer()
        }
        
        for currentCell in dataSource?.collectionView.visibleCells ?? [] {
            if let videoCell = currentCell as? PostVideoCollectionCell {
                if self.islandscapeTap {
                    videoCell.stopPlayer()
                }
            }
            if let galleryCell = currentCell as? PostGalleryCollectionCell1 {
                galleryCell.stopPlayer()
            }
            
            if let audioCell = currentCell as? PostAudioCollectionCell1 {
                audioCell.stopPlayer()
            }
        }
    }
    
    func addObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(landscapeNotification(_:)), name: .landscape, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleDeletePostNotofication(_:)), name: .postDeleted, object: nil)
        NotificationCenter.default.publisher(for: .landscape)
            .sink { notification in
                self.landscapeNotification(notification)
            }
            .store(in: &bag)
        NotificationCenter.default.publisher(for: .postDeleted)
            .sink { notification in
                self.handleDeletePostNotofication(notification)
            }.store(in: &bag)
    }
    
    func landscapeNotification(_ notification: Notification) {
        if let infoUser = notification.userInfo!["isLandscape"] as? Bool {
            self.islandscapeTap = infoUser
        }
    }
    
    func handleDeletePostNotofication(_ notification: Notification) {
        if let postId = notification.object as? Int {
            self.deletePost(postID: postId, currentIndex: nil)
        }
    }
    
    func setupCollectionView() {
        collectionView?.register(header: SearchResultHeaderView.self)
        collectionView?.register(foorter: SearchResultFooterView.self)
        collectionView?.delegate = self
        viewHelper.dataSource = self.dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
    }
    
    func resetData() {
        requestOperationTrack.removeAll()
        arrayUser.removeAll()
        arrayPages.removeAll()
        arrayGroups.removeAll()
        arrayPosts.removeAll()
        dataSource?.removeAllSections()
    }
    
    func initialSearchRequest(with query: String) {
        // cancel requests
        for index in apiEndPoints {
            RequestManager.cancelSearchRequest(index.endPoint)
        }
        
        // call service
        for index in apiEndPoints {
            searchRequest(with: index, query: query)
        }
    }
    
    func searchRequest(with action: SearchAllRequest, query: String) {
        dispatchGroup.enter()
        self.query = query
        activityIndicator.startAnimating()
        collectionView.backgroundColor = .black.withAlphaComponent(0.20)
        let parameters = ["action": action.endPoint, "token": SharedManager.shared.userToken(), "query": query]
        LogClass.debugLog("parameters ===>")
        LogClass.debugLog(parameters)
        
        RequestManager.fetchDataGet(Completion: { [weak self] response in
            guard let self else { return }
            self.requestOperationTrack.append(action)
            switch response {
            case .failure(let error):
                activityIndicator.stopAnimating()
                collectionView.backgroundColor = .white.withAlphaComponent(1.0)
                if error.localizedDescription != "cancelled" {
                    DispatchQueue.main.async {
                        if let errorMessage = (error as? ErrorModel)?.meta?.message {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: errorMessage)
                        } else {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: Const.networkProblemMessage.localized())
                        }
                    }
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let _ = res as? [String: Any] {
                } else {
                    if let responseArray = res as? [[String: Any]] {
                        switch action {
                        case .searchUser:
                            for indexContact in responseArray {
                                arrayUser.append(SearchUserModel(fromDictionary: indexContact))
                            }
                        case .searchPage:
                            for indexContact in responseArray {
                                arrayPages.append(GroupValue(fromDictionary: indexContact))
                            }
                        case .searchGroup:
                            for indexContact in responseArray {
                                arrayGroups.append(GroupValue(fromDictionaryGroup: indexContact))
                            }
                        case .searchPost:
                            for indexContact in responseArray {
                                arrayPosts.append(FeedData(valueDictMain: indexContact))
                            }
                        }
                    }
                }
                self.updateSection()
                if self.arrayPosts.count > 0 || self.arrayUser.count > 0 || self.arrayPages.count > 0 || self.arrayGroups.count > 0 {
                    activityIndicator.stopAnimating()
                    collectionView.backgroundColor = .white.withAlphaComponent(1.0)
                }
                self.dispatchGroup.leave()
            }
        }, param: parameters)
    }
    
    func configureView() {
        dataSource?.cellCreationBlock = { object, parentView, index in
            let currentSection = self.dataSource?.section(at: index?.section ?? 0)
            var clazzInstance: SSBaseCollectionCell.Type
            let currentValue = currentSection?.sectionIdentifier as? String
            if currentValue == SectionIdentifier.PeopleSearch.type {
                clazzInstance = PeopleSearchCollectionCell.self
            } else if currentValue == SectionIdentifier.PageSearch.type {
                clazzInstance = PageSearchCollectionCell.self
            } else if currentValue == SectionIdentifier.GroupSearch.type {
                clazzInstance = GroupSearchCollectionCell.self
            } else {
                let feedPost = currentSection?.item(at: UInt(index?.item ?? 0)) as? FeedData
                if feedPost?.postType == FeedType.video.rawValue || feedPost?.postType == FeedType.liveStream.rawValue{
                    clazzInstance = PostVideoCollectionCell.self
                } else if feedPost?.postType == FeedType.gallery.rawValue {
                    clazzInstance = PostGalleryCollectionCell1.self
                } else if feedPost?.postType == FeedType.audio.rawValue {
                    clazzInstance = PostAudioCollectionCell1.self
                } else {
                    let feedPostType = feedPost?.postType ?? .emptyString
                    let feedSharedPostType = feedPost?.sharedData?.postType ?? .emptyString
                    let isShared = (feedPostType == FeedType.shared.rawValue)
                    let isPostType = isShared ? (feedSharedPostType == FeedType.post.rawValue) : feedPostType == FeedType.post.rawValue
                    // shared Post then check their type if their type is post then should go to further process
                    let hasLink = isShared ? (feedPost?.sharedData?.previewLink?.count ?? 0 > 0) : feedPost?.previewLink?.count ?? 0 > 0
                    let hasLinkImage = isShared ? (feedPost?.sharedData?.linkImage?.count ?? 0 > 0) : (feedPost?.linkImage?.count ?? 0 > 0)
                    let hasYoutubeLink = isShared ? (feedPost?.sharedData?.previewLink ?? .emptyString).contains("youtube") : (feedPost?.previewLink ?? .emptyString).contains("youtube")
                    let hasPreviewLink = (isPostType && hasLinkImage) || (isPostType && hasYoutubeLink) || (isPostType && hasLink)
                    if hasPreviewLink {
                        clazzInstance = PostPreviewLinkCollectionCell.self
                    } else {
                        clazzInstance = PostCollectionCell1.self
                    }
                }
            }
            return clazzInstance.init(for: parentView as? UICollectionView, indexPath: index)
        }
        
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            let currentSection = self.dataSource?.section(at: indexPath?.section ?? 0)
            let currentValue = currentSection?.sectionIdentifier as? String
            if currentValue == SectionIdentifier.PeopleSearch.type ||  currentValue == SectionIdentifier.PageSearch.type || currentValue == SectionIdentifier.GroupSearch.type {
                (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
                (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
                if let peopleSearchCell = cell as? PeopleSearchCollectionCell {
                    peopleSearchCell.peopleSearchDelegate = self
                }
            } else {
                let feedPost = self.dataSource?.item(at: indexPath) as? FeedData
                let feedPostType = feedPost?.postType ?? .emptyString
                let isShared = (feedPostType == FeedType.shared.rawValue)
                (cell as? ConfigableCollectionCell)?.displayCellContent(data: isShared ? feedPost?.sharedData: feedPost, parentData: feedPost, at: indexPath ?? IndexPath())
                (cell as? ConfigableCollectionCell)?.layoutIfNeeded()
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
                        if let feedPost {
                            postVideoCell?.resetVideo(feedObjp: feedPost)
                        }
                    }
                }
            }
        }
        
        dataSource?.collectionSupplementaryCreationBlock = { kind, parentView, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return SearchResultHeaderView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            } else {
                return SearchResultFooterView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            }
        }
        
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
            let section = self.dataSource?.section(at: indexPath?.section ?? 0) as? SectionInfo
            if kind == UICollectionView.elementKindSectionHeader {
                (view as? SearchResultHeaderView)?.configureView(obj: section, parentObj:  nil, indexPath: indexPath ?? IndexPath())
            } else {
                (view as? SearchResultFooterView)?.configureView(obj: section, parentObj:  self.dataSource, indexPath: indexPath ?? IndexPath())
                (view as? SearchResultFooterView)?.searchResultFooterDelegate = self
            }
        }
        dataSource?.rowAnimation = .automatic
        dataSource?.collectionView = collectionView
    }
    
    func updateSection() {
        if arrayUser.count > 0 {
            dataSource?.configureSection(.PeopleSearch, object: arrayUser, sortOrder: 0)
        }
        
        if arrayPages.count > 0 {
            dataSource?.configureSection(.PageSearch, object: arrayPages, sortOrder: 1)
        }
        
        if arrayGroups.count > 0 {
            dataSource?.configureSection(.GroupSearch, object: arrayGroups, sortOrder: 2)
        }
        
        if arrayPosts.count > 0 {
            dataSource?.configureSection(.PostSearch, object: arrayPosts, sortOrder: 3)
        }
        
        self.emptyViewState()
        
        // check recent search
        if self.requestOperationTrack.count == self.apiEndPoints.count {
            RecentSearchRequestUtility.shared.recentUserCallRequest()
        }
    }
    
    func emptyViewState() {
        if self.arrayPosts.count == 0 && self.arrayUser.count == 0 && self.arrayPages.count == 0 && self.arrayGroups.count == 0 && self.query.count > 0 && self.requestOperationTrack.count == apiEndPoints.count {
            activityIndicator.stopAnimating()
            collectionView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            self.emptyGroupView()
        } else {
            self.dataSource?.emptyView = nil
        }
    }
    
    func navigateToProfile(_ postObj: FeedData) {
        searchResultDelegate?.moveToProfileDetai(postObj: postObj)
    }
    
    func navigateToPostDetail(_ postObj: FeedData) {
        searchResultDelegate?.moveToPostDetail(postObj: postObj)
    }
    
    func updateTextChange(query: String) {
        //        LogClass.debugLog(query)
        //        workItemReference?.cancel()
        //        let searchWorkItem = DispatchWorkItem {
        //            self.getSearchAPI(with: query)
        //        }
        //        workItemReference = searchWorkItem
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: searchWorkItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .landscape, object: nil)
        NotificationCenter.default.removeObserver(self, name: .postDeleted, object: nil)
    }
}

// MARK: - UICollectionViewDelegate -

extension SearchResultViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchResultDelegate?.sectionItemNavigation(with: dataSource, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //  guard feedArray.count > 0 && indexPath.row <= feedArray.count - 1 else { return }
        guard indexPath.item < arrayPosts.count else { return }
        if let audioCell = cell as? PostAudioCollectionCell1 {
            audioCell.stopPlayer()
        } else if let videoCell = cell as? PostVideoCollectionCell {
            videoCell.pauseAudioTapped(UIButton())
        }
    }
}

// MARK: - UIScrollViewDelegate -
extension SearchResultViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        keyboardScrollCompletion?()
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
            cellVideo.playVideo(with: arrayPosts[indexPath.item])
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
        DispatchQueue.main.async {
            cell.isPlayVideo = true
            cell.playPlayer()
        }
        
    }
    
    private func stopVideoPlaybackIfNeeded(_ player: EZPlayer?) {
        if player?.isPlaying == true {
            player?.stop()
            indexPathVideo = nil
        }
    }
}


// MARK: - UIScrollViewDelegate -
extension SearchResultViewController: PeopleSearchDelegate {
    func connectTapped(at indexPath: IndexPath, sender: LoadingButton, searchUser: SearchUserModel?) {
        if let searchUser {
            if searchUser.is_my_friend == "1" {
                sender.stopLoading()
                searchResultDelegate?.connectToMessage(at: indexPath, sender: sender, searchUser: searchUser)
            } else if searchUser.already_sent_friend_req == "1" {
                presentAlert(title: "Cancel Friend Request?", message: .emptyString, options: "Cancel Request", "Close") { index, field  in
                    if index == 0 {
                        self.friendFollowRequest(at: indexPath, sender: sender, searchUser: searchUser)
                    } else {
                        sender.stopLoading()
                    }
                }
            } else {
                self.friendFollowRequest(at: indexPath, sender: sender, searchUser: searchUser)
            }
        }
    }
    
    func friendFollowRequest(at indexPath: IndexPath, sender: LoadingButton, searchUser: SearchUserModel) {
        let hasAlreaddySentReq = searchUser.already_sent_friend_req == "1"
        let action = hasAlreaddySentReq ? "user/cancel_friend_request" : "user/send_friend_request"
        sender.startLoading()
        let params = ["action": action, "user_id": searchUser.user_id]
        RequestManager.fetchDataPost(Completion: { (response) in
            sender.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel {
                    if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: errorMessage)
                    }
                } else {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: Const.networkProblemMessage.localized())
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let _ = res as? [String:Any] {
                    searchUser.already_sent_friend_req = hasAlreaddySentReq ? "0" : "1"
                    self.dataSource?.reloadCells(atIndexPaths: [indexPath])
                } else if let _ = res as? String {
                    searchUser.already_sent_friend_req = hasAlreaddySentReq ? "0" : "1"
                    self.dataSource?.reloadCells(atIndexPaths: [indexPath])
                }
            }
        }, param: params)
    }
}

// MARK: - SearchResultFooterDelegate -
extension SearchResultViewController: SearchResultFooterDelegate {
    func seeAllTapped(at section: SectionInfo, indexPath: IndexPath?) {
        searchResultDelegate?.seeAllTapped(at: section, indexPath: indexPath, with: self.query)
    }
}

// MARK: - PostBaseCellDelegate
extension SearchResultViewController: PostBaseCellDelegate {
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
        let reportController = ReportingViewController.instantiate(fromAppStoryboard: .TabBar)
        reportController.currentIndex = indexPath
        reportController.feedObj = feedData
        reportController.delegate = self
        reportController.feedsDelegate = self
        reportController.reportType = "Post"
        openBottomSheet(reportController, sheetSize: [.fixed(500)], animated: false)
    }
    
    func tappedUserInfo(with feedData: FeedData, at indexPath: IndexPath) {
        navigateToProfile(feedData)
    }
    func tappedShowPostDetail(with feedData: FeedData, at indexPath: IndexPath) {
        navigateToPostDetail(feedData)
    }
    
    func tappedHide(with feedData: FeedData, at indexPath: IndexPath) {
        self.deleteItem(at: indexPath)
    }
    
    func tappedHashTag(with hashTag: String, at indexPath: IndexPath) {
        self.searchResultDelegate?.moveToHashTag(with: hashTag)
    }
    
    // MARK: - Sharing View
    func tappedShare(with feedData: FeedData, at indexPath: IndexPath) {
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedData.postID ?? 0)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        openBottomSheet(navigationObj, sheetSize: [.fixed(550), .fullScreen])
    }
    
    func tappedComment(with feedData: FeedData, at indexPath: IndexPath) {
        navigateToPostDetail(feedData)
    }
    func tappedLiked(with feedData: FeedData, at indexPath: IndexPath) {
        // likeClosure?(feedData)
    }
    func tappedLikesDetail(with feedData: FeedData, at indexPath: IndexPath) {
        let controller = WNPagerViewController.instantiate(fromAppStoryboard: .TabBar)
        controller.feedObj = feedData
        controller.parentView = self
        let navController = UINavigationController(rootViewController: controller)
        openBottomSheet(navController, sheetSize: [.fixed(400), .fixed(250), .fullScreen], animated: false)
    }
    
    func tappedKalamSend(with feedData: FeedData, at indexPath: IndexPath) {
        let urlString = PostSendURL.strID(feedData.strID ?? .emptyString)
        LogClass.debugLog("\(urlString.detail)")
        OpenLink(webUrl: urlString.detail)
    }
}

// MARK: - PostVideoImageTextDelegate
extension SearchResultViewController: PostDelegate {
    func tappedPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        if let filePath = obj.post?.first?.filePath {
            downloadFile(filePath: filePath, isImage: true, isShare: true , FeedObj: obj)
        }
    }
    func tappedPost(with obj: FeedData, at indexpath: IndexPath) {
        showdetail(feedObj: obj)
    }
}

// MARK: - PostGalleryDelegate
extension SearchResultViewController: PostGalleryDelegate {
    func galleryPreview(with obj: FeedData, at indexpath: IndexPath, tag: Int) {
        showdetail(feedObj: obj, currentIndex: tag)
    }
}

// MARK: - PostVideoDelegate
extension SearchResultViewController: PostVideoDelegate {
    func tappedvideoPostDownload(with obj: FeedData, at indexpath: IndexPath) {
        if let filePath = obj.post?.first?.filePath {
            downloadFile(filePath: filePath, isImage: true, isShare: true , FeedObj: obj)
        }
    }
}

extension SearchResultViewController: DismissReportSheetDelegate {
    
    func dismissUnSavedWith(msg: String, indexPath: IndexPath) {
        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: msg)
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(isPost: false, currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            let feedObj = dataSource?.item(at: currentIndex) as? FeedData
            if let commentCount = feedObj?.comments?.count, commentCount > 0 {
                feedObj?.comments?.removeLast()
                dataSource?.reloadCells(atIndexPaths: [currentIndex])
            }
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        if type == PostTypes.Report.type {
            showReportDetailSheet(currentIndex: currentIndex)
        } else if type == PostTypes.Delete.type || type == PostTypes.Hide.type {
            deleteItem(at: currentIndex)
        } else if type.contains(PostTypes.HideAll.type) {
        } else if type.contains(PostTypes.Block.type) {
            deleteItem(at: currentIndex)
        } else if type == PostTypes.UnSave.type {
        } else if type == PostTypes.Edit.type {
            let createPost = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "CreatePostNavigation") as? UINavigationController
            createPost?.modalPresentationStyle = .fullScreen
            let createPostController = createPost?.viewControllers.first as? CreatePostViewController
            createPostController?.isPostEdit = true
            createPostController?.feedObj = dataSource?.item(at: currentIndex) as? FeedData
            SharedManager.shared.createPostSelection = -1
            if let createPost {
                present(createPost, animated: false, completion: nil)
            }
        }
    }
    
    func deleteItem(at index: IndexPath) {
        LogClass.debugLog("deleteItem ===>")
        LogClass.debugLog(index)
        self.arrayPosts.remove(at: index.item)
        self.dataSource?.removeItem(at: index)
    }
    
    func showReportDetailSheet(isPost:Bool = true, currentIndex:IndexPath) {
        let reportDetail = ReportDetailController.instantiate(fromAppStoryboard: .TabBar)
        reportDetail.isPost = ReportType.Post
        reportDetail.feedObj = dataSource?.item(at: currentIndex) as? FeedData
        if !isPost {
            reportDetail.commentObj = reportDetail.feedObj?.comments?.first
            reportDetail.isPost = ReportType.Comment
        }
        reportDetail.delegate = self
        openBottomSheet(reportDetail, sheetSize: [.fullScreen])
    }
}

extension SearchResultViewController: DismissReportDetailSheetDelegate {
    
    func dismissReport(message:String) {
        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: message)
    }
}

extension SearchResultViewController: FeedsDelegate {
    
    func deletePost(postID: Int, currentIndex: IndexPath?) {
        if let currentIndex {
            deleteItem(at: currentIndex)
        }
    }
    
    func deleteAllPostsFromAuther(autherID: Int, currentIndex: IndexPath?) {
        LogClass.debugLog(autherID)
        let section = dataSource?.section(withIdentifier: SectionIdentifier.PostSearch.rawValue) as? SectionInfo
        if section != nil {
            let items = (section?.items as? [FeedData])?.filter({$0.authorID == autherID}) ?? []
            for item in items {
                let indexPath = dataSource?.indexPath(forItem: item)
                if let indexPath {
                    deleteItem(at: indexPath)
                }
            }
        }
    }
    
    func commentUpdated(feedUpdatedOBJ: FeedData, currentIndex: IndexPath?) {
        if let currentIndex {
            LogClass.debugLog(feedUpdatedOBJ)
            self.arrayPosts[currentIndex.item].commentCount = feedUpdatedOBJ.commentCount
            self.dataSource?.reloadCells(atIndexPaths: [currentIndex])
        }
    }
}
