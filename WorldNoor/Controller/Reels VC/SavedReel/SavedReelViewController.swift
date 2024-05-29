//
//  SavedReelViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 01/05/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine
import SDWebImage

class SavedReelViewController: BaseViewController {
    
    // MARK: - Lazy Properties -
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: collectionView!)
        return refreshControlHandler
    }()
    
    lazy var loadMoreHandler: LoadMoreHandler = {
        let loadMoreHandler = LoadMoreHandler(scrollView: collectionView!)
        loadMoreHandler.currentPage = 1
        return loadMoreHandler
    }()
    
    lazy var defaultGroupSearchEmptyView: MyNetworkUpdateView? = {
        let emptyView = MyNetworkUpdateView.customInit()
        emptyView?.setupView(text: "You don't have any saved Reels")
        emptyView?.emptyText?.textColor = .darkGray
        emptyView?.hideEmptyImage()
        return emptyView
    }()
    
    // MARK: - Properties -
    var watchArray: [FeedData] = [FeedData]()
    private var bag = Set<AnyCancellable>()
    private var apiService = APITarget()
    private var isAPICall = false
    private var isRefresh: Bool = false
    private var viewHelper = SavedReelViewHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved items".localized()
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
        collectionView?.contentInsetAdjustmentBehavior = .never
        configureView()
        setupRefreshListner()
        setupLoadMoreListner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if dataSource?.emptyView != nil {
            dataSource?.emptyView.frame = emptyViewFrameCenter()
        }
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
    
    
    override func initilizeDataSource() -> SSBaseDataSource? {
        let ds = SSArrayDataSource(items: [])
        ds?.emptyView = defaultGroupSearchEmptyView
        return ds
    }
    
    override func configureView() {
        dataSource?.cellClass = SavedReelCollectionCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(cell, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
            (cell as? SavedReelCollectionCell)?.savedReelDelegate = self
        }
        dataSource?.collectionView = collectionView
        dataSource?.rowAnimation = .none
    }
    
    // MARK: - IBActions -
    @IBAction func onClickReel(_ sender: UIButton) {
        
    }
    
    func emptyViewFrameCenter() -> CGRect {
        let frame =  CGRect(x: 0, y: 0, width: collectionView?.frame.width ?? 0.0, height: collectionView?.frame.height ?? 0.0)
        return frame
    }
    
    // it will show empty view
    func emptyViewUpdate() {
        if Int(self.dataSource?.numberOfItems() ?? 0) == 0 {
            self.dataSource?.emptyView = self.defaultGroupSearchEmptyView
        } else {
            if self.dataSource?.emptyView != nil {
                self.dataSource?.emptyView = nil
            }
        }
    }
    
    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                loadMoreHandler.resetPage()
                self.isAPICall = false
                self.isRefresh = true
                getSavedReelRequest()
            }.store(in: &bag)
    }
    
    func setupLoadMoreListner() {
        loadMoreHandler.loadMorePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.loadMoreData(for: page)
            }
            .store(in: &bag)
    }
    
    private func loadMoreData(for page: Int) {
        guard loadMoreHandler.canLoadMore() else { return }
        loadMoreHandler.isLoading = true
        LogClass.debugLog("Loading data for page \(page)")
        getSavedReelRequest()
    }
    
    func stopRefresh() {
        refreshControlHandler.endRefreshing()
    }
    
    func getSavedReelRequest() {
        guard !isAPICall else { return }
        isAPICall = true
        let parameters = ["page": String(loadMoreHandler.currentPage)]
        if watchArray.count == 0 {
            Loader.startLoading()
        }
        apiService.newFeedVideosRequest(endPoint: .getSavedReels(parameters))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Finished")
                case .failure(let error):
                    if self.watchArray.count == 0 {
                        Loader.stopLoading()
                    }
SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: {[weak self] response in
                guard let self else { return }
                if self.watchArray.count == 0 {
                    Loader.stopLoading()
                }
                if isRefresh {
                    stopRefresh()
                    isRefresh.toggle()
                }
                if self.loadMoreHandler.currentPage == 1 {
                    self.watchArray = []
                    (self.dataSource as? SSArrayDataSource)?.removeAllItems()
                }
                checkPreload(response.data ?? [])
                for (_ , resObj) in (response.data ?? []).enumerated() {
                    isAPICall = false
                    watchArray.append(resObj)
                }
                (dataSource as? SSArrayDataSource)?.updateItems(self.watchArray)
                if response.data?.count ?? 0 > 0 {
                    loadMoreHandler.dataLoadedSuccessfully()
                } else {
                    isAPICall = false
                    _ = !loadMoreHandler.canLoadMore()
                }
                emptyViewUpdate()
            })
            .store(in: &bag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
        controller.items = self.watchArray
        controller.currentIndex = indexPath.item
        controller.isFromSavedReel = true
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
        updateVisibilityUnSaved(at: indexPath)
        
    }
    
    func updateVisibilityUnSaved(at indexPath: IndexPath)  {
        dataSource?.collectionView.indexPathsForVisibleItems.forEach({ index in
            let cell = (dataSource as? SSArrayDataSource)?.collectionView.cellForItem(at: index) as? SavedReelCollectionCell
            if indexPath.item == index.item {
                cell?.unSavedBtnVisibility(isHide: false)
            } else {
                cell?.unSavedBtnVisibility(isHide: true)
            }
        })
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func checkPreload(_ feedData: [FeedData]) {
        VideoPreLoadUtility.enable(at: feedData)
    }
    
    func unSavedServiceRequest(at indexPath: IndexPath, sender: LoadingButton?) {
        sender?.startLoading()
        if let feedData = (dataSource as? SSArrayDataSource)?.item(at: indexPath) as? FeedData {
            let postId = String(feedData.postID ?? 0)
            let fileId = String(feedData.post?.first?.fileID ?? 0)
            let params = ["type": "reels", "post_id": postId, "file_id": fileId]
            apiService.savedUnsavedRequest(endPoint: .savedUnsave(params))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        sender?.stopLoading()
                        LogClass.debugLog("Finished")
                    case .failure(let error):
    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                    }
                }, receiveValue: {[weak self] response in
                    guard let self else { return }
                    UIView.performWithoutAnimation {
                        self.watchArray = self.watchArray.filter({$0.postID != feedData.postID})
                        (self.dataSource as? SSArrayDataSource)?.removeItem(at: UInt(indexPath.item))
                        self.emptyViewUpdate()
                    }
                })
                .store(in: &bag)
        }
    }
}

// MARK: - SavedReelDelegate
extension SavedReelViewController: SavedReelDelegate {
    
    func unSavedTapped(at indexPath: IndexPath, sender: LoadingButton?) {
        unSavedServiceRequest(at: indexPath, sender: sender)
    }
    
    func dotTapped(at indexPath: IndexPath, sender: LoadingButton?) {
        let controller = SavedReelMoreViewController.instantiate(fromAppStoryboard: .Reel)
        controller.indexPath = indexPath
        controller.feedData = dataSource?.item(at: indexPath) as? FeedData
        controller.loadingButton = sender
        controller.savedReelMoreDelegate = self
        openBottomSheet(controller, sheetSize: [.fixed(200)], animated: false)
    }
}

// MARK: - SavedReelMoreDelegate
extension SavedReelViewController: SavedReelMoreDelegate {
    
    func unSavedTapped(at indexPath: IndexPath, feedData: FeedData, sender: LoadingButton?) {
        unSavedServiceRequest(at: indexPath, sender: sender)
    }
    
    func copyLinkTapped(at indexPath: IndexPath, feedData: FeedData) {
        if let fileID = feedData.post?.first?.fileID {
            let urlString = "https://worldnoor.com/reel/" + String(fileID)
            UIPasteboard.general.string = urlString
            SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: "Copied link successfully.")
        }
    }
}
