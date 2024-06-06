//
//  MPProfileViewController.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import Combine

class MPProfileViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
//            searchBar.delegate = self
        }
    }
    var viewModel = MPProfileViewModel()
    private var isAPICall = false
    private var isRefresh: Bool = false
    var selectedSortItem: RadioButtonItem?

//    var refresher:UIRefreshControl!
    
//    lazy var loadMoreHandler: LoadMoreHandler = {
//        let loadMoreHandler = LoadMoreHandler(scrollView: collectionView!)
//        return loadMoreHandler
//    }()
    
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: tableView!)
        return refreshControlHandler
    }()
    private var bag = Set<AnyCancellable>()


    // MARK: - Properties -
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.createCellList()
        self.tableView.register(UINib(nibName: String(describing: MPProfileSettingsInfoTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileSettingsInfoTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileCoverPhotoTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileCoverPhotoTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileShareButtonTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileShareButtonTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileAboutMeTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileAboutMeTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileSellerRatingTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileSellerRatingTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileYourStrengthsTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileYourStrengthsTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileAccessYourRatingsTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileAccessYourRatingsTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileListingHeaderTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileListingHeaderTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileListingTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileListingTableViewCell.identifier)
        self.tableView.register(UINib(nibName: String(describing: MPProfileListingNotFoundTableViewCell.self), bundle: nil), forCellReuseIdentifier: MPProfileListingNotFoundTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
//        setupRefreshListner()
//        viewModel.searchText.isEmpty == true ? fetchProductListCategorieBase() : fetchProductListSearchBase(viewModel.searchText)
//        self.searchBar.text = viewModel.searchText
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
//                loadMoreHandler.resetPage()
                self.isAPICall = false
                self.isRefresh = true
                viewModel.resetToFreshState()
                self.tableView.reloadData()
                viewModel.pullToRefresh()
            }.store(in: &bag)
    }


    @objc func loadData() {
        self.tableView!.refreshControl?.beginRefreshing()
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
            viewModel.resetToFreshState()
            viewModel.fetchProductListOnCategorieSelection()
        }else {
            SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
        }
    }
    
    func fetchProductListSearchBase(_ text: String) {
        if NetworkReachabilityManager()!.isReachable {
            viewModel.selectedApi = .search_products
            viewModel.resetToFreshState()
            viewModel.fetchProductListOnSearchResult(text)
        }else {
            SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
        }
    }
    deinit {
        print("MPProfileViewController deinit")
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UISearchBarDelegate -
extension MPProfileViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let controller = MPGlobalSearchViewController.instantiate(fromAppStoryboard: .Marketplace)
        let navController = UINavigationController(rootViewController: controller)
        controller.delegate = self
        presentFullVC(navController)
    }
}

extension MPProfileViewController: ProductListDelegate {
    func isProductAvalaibleOrNot(_ avalaible: Bool, newIndexes: [IndexPath]) {
        if avalaible {
            self.refreshControlHandler.endRefreshing()
//            self.collectionView?.reloadData()
            
            if newIndexes.count > 0 {
                self.tableView?.performBatchUpdates({
                    tableView?.insertRows(at: newIndexes, with: .automatic)
    //                self.collectionView?.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    if self.viewModel.getNumberOfRowsInSections() == 0 {
                        self.tableView?.setEmptyMessage("No products found".localized())
                    } else {
                        self.tableView?.restore()
                    }
                })
            } else {
                self.tableView?.reloadData()
                
                if self.viewModel.getNumberOfRowsInSections() == 0 {
                    self.tableView?.setEmptyMessage("No products found".localized())
                } else {
                    self.tableView?.restore()
                }
            }
        }
    }
}

extension MPProfileViewController: SearchResultDelgate {
    func searchResult(_ text: String) {
//        viewModel.selectedApi = .search_products
//        fetchProductListSearchBase(text)
        let controller = MPProfileViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.viewModel.selectedApi = .search_products
        controller.viewModel.searchText = text
        navigationController?.pushViewController(controller, animated: true)

    }
}




