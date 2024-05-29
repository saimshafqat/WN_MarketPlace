//
//  MPForYouViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import Combine

class MPForYouViewController: UIViewController {
    
    // MARK: - Properties -
    var viewHelper = MarketPlaceForYouViewHelper()
    var categoryListUser: MarketPlaceForYouUser? = nil
    var productList: [MarketPlaceForYouProduct] = []
    
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: collectionView!)
        return refreshControlHandler
    }()
    
    lazy var loadMoreHandler: LoadMoreHandler = {
        let loadMoreHandler = LoadMoreHandler(scrollView: collectionView!)
        return loadMoreHandler
    }()
    
    lazy var dataSource: SSSectionedDataSource? = {
        let ds = SSSectionedDataSource(sections: [])
        return ds
    }()
    
    private var bag = Set<AnyCancellable>()
    private var isAPICall = false
    private var isRefresh: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupRefreshListner()
        setupLoadMoreListner()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupCollectionView() {
        collectionView?.register(header: MarkerPlaceForYouHeaderView.self)
        collectionView?.register(foorter: MarketPlaceCategoryListFooterView.self)
        collectionView?.delegate = self
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
    }
    
    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                loadMoreHandler.resetPage()
                self.isAPICall = false
                self.isRefresh = true
                callRequestForSellingItem()
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
        callRequestForSellingItem()
    }
    
    func stopRefresh() {
        refreshControlHandler.endRefreshing()
    }
    
    func callRequestForSellingItem() {
        guard !isAPICall else { return }
        isAPICall = true

        let params = ["categoryPage": loadMoreHandler.currentPage, "productsPerCategory": 20]
        
        MPRequestManager.shared.request(endpoint: "sellingItems", method: .post, params: params) { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        // Use JSONDecoder to decode the data into your model
                        if self.isRefresh {
                            self.stopRefresh()
                            self.isRefresh.toggle()
                        }
                        let decoder = JSONDecoder()
                        let categoryResult = try decoder.decode(MarketPlaceForYouDataResponse.self, from: jsonData)
                        // Now you have your Swift model
                        LogClass.debugLog(categoryResult)
                        if self.loadMoreHandler.currentPage == 1 {
                            self.categoryListUser = categoryResult.data.returnResp.user
                            self.productList = []
                            self.dataSource?.removeAllSections()
                            
                            if categoryResult.data.returnResp.user.id > 0 {
                                SharedManager.shared.mpUserObj = categoryResult.data.returnResp.user
                            }
                        }
                        self.dataSource?.collectionView.performBatchUpdates({
                            for index in categoryResult.data.returnResp.products {
                                self.isAPICall = false
                                self.productList.append(index)
                                self.createSection(index.items, title: index.category_name, type: index.category_name)
                            }
                        })
                        if categoryResult.data.returnResp.products.count > 0 {
                            self.loadMoreHandler.dataLoadedSuccessfully()
                        } else {
                            self.isAPICall = true
                            _ = !(self.loadMoreHandler.canLoadMore())
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else {
                    print("Failed to convert JSON string to Data.")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
    
    func configureView() {
        dataSource?.cellClass = MarketPlaceForYouCollectionCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(self.categoryListUser, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
        }
        dataSource?.collectionSupplementaryCreationBlock = { kind, parentView, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return MarkerPlaceForYouHeaderView.self.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            } else {
                return MarketPlaceCategoryListFooterView.supplementaryView(for: parentView, kind: kind, indexPath: indexPath)
            }
        }
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
            let section = self.dataSource?.section(at: indexPath?.section ?? 0) as? SSSection
            (view as? MarkerPlaceForYouHeaderView)?.configureView(obj: section, parentObj: self.categoryListUser as? AnyObject, indexPath: indexPath ?? IndexPath())
        }
        
        dataSource?.rowAnimation = .none
        dataSource?.collectionView = collectionView
    }
    
    // will help to create section
    func createSection(_ items: [Any], title: String?, type: String?) {
        let section = SSSection(items: items, header: title ?? "", footer: "", identifier: type ?? "")
        dataSource?.appendSection(section)
    }
}

extension MPForYouViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MPProductDetailViewController.instantiate(fromAppStoryboard: .Marketplace)
        let item = dataSource?.item(at: indexPath) as? MarketPlaceForYouItem
        controller.marketProduct = item
        controller.mpProductDetailDelegate = self
        showTransition(to: controller, withAnimationType: .fade)
    }
}

extension MPForYouViewController: MPProductDetailDelegate {
    func updateSaved(product: MarketPlaceForYouItem?) {
        // need to update status alert item
    }
}
