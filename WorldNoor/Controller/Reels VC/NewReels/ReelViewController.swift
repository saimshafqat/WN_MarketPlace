//
//  ReelViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import FittedSheets
import Combine

class ReelViewController: BaseViewController {
    
    // MARK: - Properties -
    var items: [FeedData] = []
    var currentIndex: Int = 0
    private var bag = Set<AnyCancellable>()
    private var apiService = APITarget()
    private var isAPICall = false
    private var reelViewModel = ReelViewModel()
    var newCurrentIndex = 0
    var isFromSavedReel: Bool = false
    
    // MARK: - Lazy Properties -
    lazy var loadMoreHandler: LoadMoreHandler = {
        let loadMoreHandler = LoadMoreHandler(scrollView: collectionView!)
        if !self.isFromSavedReel {
            loadMoreHandler.currentPage = 2
        }
        return loadMoreHandler
    }()
    
    // MARK: - IBOutlets -
    @IBOutlet weak var muteImageView: UIImageView? {
        didSet {
            muteImageView?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var reelCamera: UIImageView? {
        didSet {
            reelCamera?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var reelUser: UIImageView? {
        didSet {
            reelUser?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var backImage: UIImageView? {
        didSet {
            backImage?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var reelLabel: UILabel? {
        didSet {
            reelLabel?.addShadow(with: .darkText)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Life cycle -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if collectionView != nil && items.count > 0 {
            DispatchQueue.main.async {
                self.collectionView?.scrollToItem(at: IndexPath(item: self.currentIndex , section: 0), at: .top, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppLogger.log(tag: .debug, "Watch Array Preload" ,items)
        collectionView?.collectionViewLayout = ReelLayoutHelper().createLayout()
        collectionView?.contentInsetAdjustmentBehavior = .never
        configureView()
        setObserver()
    }
    
    private func setObserver() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink {[weak self] notification in
                guard let self else { return }
                stopVideo()
            }.store(in: &bag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        do {
            try VideoCacheManager.cleanAllCache()
            SDImageCache.shared.clearMemory()
        } catch let error {
            AppLogger.log(tag: .error, error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppLogger.log(tag: .success, "This is success")
        if items.count > 0 {
            checkPreload(items)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppLogger.log(tag: .success, "View Disappear success")
        stopVideo()
    }
    
    override func initilizeDataSource() -> SSBaseDataSource? {
        let ds = SSArrayDataSource(items: items)
        return ds
    }
    
    override func configureView() {
        dataSource?.cellClass = ReelCollectionCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.setNeedsLayout()
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
            (cell as? ReelCollectionCell)?.reelCellDelegate = self
        }
        dataSource?.collectionView = collectionView
        dataSource?.rowAnimation = .none
    }
    
    // MARK: - IBActions -
    @IBAction func onClickBac(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onClickUser(_ sender: UIButton) {
        let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        controller.isNavPushAllow = true
        if let indexPath = dataSource?.collectionView.indexPathsForVisibleItems.first?.item {
            currentIndex = indexPath
        }
        controller.otherUserID = String(SharedManager.shared.getUserID())
        controller.otherUserisFriend = "1"
        stopVideo()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onClickCreateReel(_ sender: UIButton) {
        let vc = CreateReelViewController()
        stopVideo()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapMute(_ sender: UIButton) {
        let controller = GlobalSearchViewController.instantiate(fromAppStoryboard: .EditProfile)
        if let indexPath = dataSource?.collectionView.indexPathsForVisibleItems.first?.item {
            currentIndex = indexPath
        }
        stopVideo()
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onClickAddComment(_ sender: UIButton) {
        let controller = CommentTableViewController.instantiate(fromAppStoryboard: .Comment)
        let indexPath = dataSource?.collectionView.indexPathsForVisibleItems.first
        controller.feedObj = dataSource?.item(at: indexPath) as? FeedData
        controller.delegateReaction = self
        openBottomSheet(controller, sheetSize: [.fixed(400), .fixed(250), .fullScreen], animated: false)
    }
    
    func getVisibleCells() -> [ReelCollectionCell]? {
        dataSource?.collectionView.visibleCells.compactMap({$0 as? ReelCollectionCell})
    }
    
    // MARK: - Methods
    func stopVideo() {
        getVisibleCells()?.forEach({ reelCell in
            reelCell.playerView?.pause(reason: .hidden)
        })
    }
    
    func getReelRequest() {
        guard !isAPICall else { return }
        isAPICall = true
        let parameters = ["page": String(loadMoreHandler.currentPage)]
        apiService.newFeedVideosRequest(endPoint: .getReels(parameters))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Finished")
                case .failure(let error):
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
                }
            }, receiveValue: {[weak self] response in
                guard let self else { return }
                checkPreload(response.data ?? [])
                for (_ , resObj) in (response.data ?? []).enumerated() {
                    isAPICall = false
                    items.append(resObj)
                }
                (dataSource as? SSArrayDataSource)?.appendItems(response.data)
                if response.data?.count ?? 0 > 0 {
                    loadMoreHandler.dataLoadedSuccessfully()
                } else {
                    self.isAPICall = false
                    _ = !loadMoreHandler.canLoadMore()
                }
            })
            .store(in: &bag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        AppLogger.log(tag: .debug, "ReelViewcontroller has deinitilzied")
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ReelViewController {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let reelCell = cell as? ReelCollectionCell {
            reelCell.pause()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is ReelCollectionCell {
            let reelCell = cell as? ReelCollectionCell
            let feedItem = dataSource?.item(at: indexPath) as? FeedData
            if let feedItem, let postFile = feedItem.post?.first {
                reelCell?.setBasicProperties(of: postFile)
                reelCell?.setReelThumbnail(postFile)
                reelCell?.play()
            }
        }
        
        // when not coming saved from reel
        if !isFromSavedReel {
            let itemCount = items.count - 5
            if indexPath.item == itemCount {
                getReelRequest()
            } else if currentIndex > itemCount && currentIndex != newCurrentIndex {
                newCurrentIndex = currentIndex
                getReelRequest()
            }
        }
    }
    
    func checkPreload(_ feedData: [FeedData]) {
        VideoPreLoadUtility.enable(at: feedData)
    }
}

// MARK: - ReelCellDelegate -
extension ReelViewController: ReelCellDelegate {
    
    func reelHashTagTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, text: String) {
        navigationController?.pushViewController(reelViewModel.moveToHashTag(with: text), animated: true)
    }
    
    func reelMoreTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, with url: URL) {
        let controller = ReportingViewController.instantiate(fromAppStoryboard: .TabBar)
        controller.currentIndex = indexPath
        controller.feedObj = dataSource?.item(at: indexPath) as? FeedData
        controller.feedObj?.isSaved = isFromSavedReel
        controller.delegate = self
        controller.reportType = "Reel"
        openBottomSheet(controller, sheetSize: [.fixed(350)], animated: false)
    }
    
    func reelsUserTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, obj: FeedData?) {
        let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        if let authorId = obj?.authorID {
            let userID = String(authorId)
            if Int(userID) != SharedManager.shared.getUserID() {
                controller.otherUserID = userID
                controller.otherUserisFriend = "1"
            }
        }
        currentIndex = indexPath.item
        controller.isNavPushAllow = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func reelCommentTapped(at indexPath: IndexPath, playerView: VideoPlayerView?) {
        let controller = CommentTableViewController.instantiate(fromAppStoryboard: .Comment)
        controller.feedObj = dataSource?.item(at: indexPath) as? FeedData
        controller.delegateReaction = self
        openBottomSheet(controller, sheetSize: [.fixed(400), .fixed(250), .fullScreen], animated: false)
    }
    
    func reelSendTapped(at indexPath: IndexPath, playerView: VideoPlayerView?) {
        
    }
    
    func reelShareTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, with url: URL) {
        downloadFile(filePath: url.absoluteString, isImage: false, isShare: true , FeedObj: items[indexPath.item])
    }
}

extension ReelViewController: ReactionDelegateResponse {
    
    func reactionResponse(feedObj: FeedData) {
        if let indexPath = dataSource?.indexPath(forItem: feedObj) {
            AppLogger.log(tag: .success, "Index Path of reaction", indexPath)
            items[indexPath.item] = feedObj
            let cell = dataSource?.collectionView.cellForItem(at: indexPath) as? ReelCollectionCell
            cell?.showCommentCount(feedObj)
        }
    }
}

// MARK: - DismissReportSheetDelegate -
extension ReelViewController : DismissReportSheetDelegate {
    
    func dismissReportWithMessage(message:String)   {
        reelViewModel.successMsg(message)
    }
    
    func dimissReportSheetForCommentsClicked(type: String, currentIndex: IndexPath, isReply:Bool) {
        if type == "Copy" {
            SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: "link copied successfully.".localized())
        } else if type == "Report" {
            self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
        } else if type == "Rate" {
            let controller = ReelsFeedBackViewController.instantiate(sb: .Reel)
            controller.feedObj = dataSource?.item(at: currentIndex) as? FeedData
            controller.delegate = self
            openBottomSheet(controller, sheetSize: [.halfScreen], animated: false)
        } else {
            let controller = SavedReelViewController.instantiate(fromAppStoryboard: .Reel)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func dimissReportSheetClicked(type: String, currentIndex: IndexPath) {
        if type == "Report" {
            self.showReportDetailSheet(currentIndex: currentIndex)
        }
    }
    
    func showReportDetailSheet(isPost:Bool = false, currentIndex:IndexPath) {
        let controller = ReportDetailController.instantiate(fromAppStoryboard: .TabBar)
        controller.isPost = ReportType.Post
        controller.delegate = self
        controller.feedObj = dataSource?.item(at: currentIndex) as? FeedData
        openBottomSheet(controller, sheetSize: [.fullScreen], animated: false)
    }
}

// MARK: - DismissReportDetailSheetDelegate -
extension ReelViewController: DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        reelViewModel.successMsg(message)
    }
}
