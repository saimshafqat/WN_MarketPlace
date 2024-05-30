//
//  MPProductListingViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 08/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import Combine

class MPProductListingViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    var viewModel = MPProductListingViewModel()
    private var isAPICall = false
    private var isRefresh: Bool = false
    var selectedSortItem: RadioButtonItem?

//    var refresher:UIRefreshControl!
    
//    lazy var loadMoreHandler: LoadMoreHandler = {
//        let loadMoreHandler = LoadMoreHandler(scrollView: collectionView!)
//        return loadMoreHandler
//    }()
    
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: collectionView!)
        return refreshControlHandler
    }()
    private var bag = Set<AnyCancellable>()


    // MARK: - Properties -
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        self.collectionView?.register(UINib(nibName: MPProductListHeaderView.headerName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MPProductListHeaderView.headerName)
        self.collectionView?.register(UINib(nibName: MPProductSearchListHeaderView.headerName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MPProductSearchListHeaderView.headerName)
        setupRefreshListner()
        viewModel.searchText.isEmpty == true ? fetchProductListCategorieBase() : fetchProductListSearchBase(viewModel.searchText)
        self.searchBar.text = viewModel.searchText
        
    }
    
    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
//                loadMoreHandler.resetPage()
                self.isAPICall = false
                self.isRefresh = true
                viewModel.pullToRefresh()
            }.store(in: &bag)
    }

//    func setupRefreshListner() {
//        self.refresher = UIRefreshControl()
//        self.collectionView!.alwaysBounceVertical = true
//        self.refresher.tintColor = UIColor.lightGray
//        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
//        self.collectionView!.addSubview(refresher)
//    }

    @objc func loadData() {
        self.collectionView!.refreshControl?.beginRefreshing()

//        self.collectionView!.refreshControl?.beginRefreshing()
        viewModel.pullToRefresh()
    }
    
    func stopRefresher() {
//       self.collectionView!.refreshControl?.endRefreshing()
//        self.refresher.removeFromSuperview()
     }

    func fetchProductListCategorieBase() {
        if NetworkReachabilityManager()!.isReachable {
            viewModel.selectedApi = .category_items
            viewModel.fetchProductListOnCategorieSelection()
        }else {
            SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
        }
    }
    
    func fetchProductListSearchBase(_ text: String) {
        if NetworkReachabilityManager()!.isReachable {
            viewModel.selectedApi = .search_products
            viewModel.fetchProductListOnSearchResult(text)
        }else {
            SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
        }
    }
    deinit {
        print("MPProductListingViewController deinit")
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UISearchBarDelegate -
extension MPProductListingViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let controller = MPGlobalSearchViewController.instantiate(fromAppStoryboard: .Marketplace)
        let navController = UINavigationController(rootViewController: controller)
        controller.delegate = self
        presentFullVC(navController)
    }
}

extension MPProductListingViewController: ProductListDelegate {
    func isProductAvalaibleOrNot(_ avalaible: Bool) {
        if avalaible {
            self.refreshControlHandler.endRefreshing()
            self.collectionView?.reloadData()
        }
    }
}

extension MPProductListingViewController: SearchResultDelgate {
    func searchResult(_ text: String) {
//        viewModel.selectedApi = .search_products
//        fetchProductListSearchBase(text)
        let controller = MPProductListingViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.viewModel.selectedApi = .search_products
        controller.viewModel.searchText = text
        navigationController?.pushViewController(controller, animated: true)

    }
}




