//
//  GlobalSearchViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 18/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

class GlobalSearchViewController: UIViewController {
    
    lazy var searchResultController: SearchResultViewController? = {
        let resultController = SearchResultViewController.instantiate(fromAppStoryboard: .EditProfile)
        resultController.searchResultDelegate = self
        resultController.keyboardScrollCompletion = {
            self.dismissSearch()
        }
        return resultController
    }()
    
    lazy var searchController: UISearchController = {
        let sController = UISearchController(searchResultsController: searchResultController)
        sController.hidesNavigationBarDuringPresentation = true
        sController.obscuresBackgroundDuringPresentation = false
        sController.searchBar.searchBarStyle = .minimal
        sController.searchBar.autocorrectionType = .no
        sController.searchBar.sizeToFit()
        sController.searchBar.autocorrectionType = .no
        sController.searchBar.spellCheckingType = .no
        sController.searchBar.placeholder = "Search..."
        sController.delegate = self
        sController.searchBar.delegate = self
        return sController
    }()
    
    // MARK: - Properties
    lazy var dataSource: SSArrayDataSource? = {
        let ds = SSArrayDataSource(items: [])
        return ds
    }()
    
    // MARK: - Lazy Properties -
    lazy var refreshControlHandler: RefreshControlHandler = {
        let refreshControlHandler = RefreshControlHandler(scrollView: tableView!)
        return refreshControlHandler
    }()

    // MARK: - Lazy Properties -
    lazy var defaultGroupSearchEmptyView: MyNetworkUpdateView? = {
        let emptyView = MyNetworkUpdateView.customInit()
        emptyView?.setupView(text: "No groups found")
        emptyView?.emptyText?.textColor = .darkGray
        emptyView?.hideEmptyImage()
        return emptyView
    }()
    
    var query: String?
    var globalSearchVM = GlobalSearchViewModel()
    let recentSearchUtility = RecentSearchRequestUtility.shared
    private var bag = Set<AnyCancellable>()

    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        emptyGroupView()
        configureView()
        addObserver()
        setupRefreshListner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if dataSource?.emptyView != nil {
            dataSource?.emptyView.frame = emptyViewFrameCenter()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecentSearch()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    // MARK: - Methods -
    
    func emptyViewFrameCenter() -> CGRect {
        let frame =  CGRect(x: 0, y: 0, width: tableView?.frame.width ?? 0.0, height: tableView?.frame.height ?? 0.0)
        return frame
    }

    func setupRefreshListner() {
        refreshControlHandler.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                recentSearchUtility.recentUserCallRequest()
                self.emptyGroupView()
            }.store(in: &bag)
    }
    
    // it will show empty view
    func emptyViewUpdate() {
        if Int(self.dataSource?.numberOfItems() ?? 0) == 0 {
            self.dataSource?.emptyView = self.defaultGroupSearchEmptyView
        }
    }

    func getRecentSearch() {
        // Check if cached response is available
        if let cachedResponse = recentSearchUtility.getRecentSearchResponseFromCache() {
            // Use the cached response
            LogClass.debugLog("Cached recent search response: \(cachedResponse)")
            refreshControlHandler.endRefreshing()
            self.emptyGroupView()
            if Int(dataSource?.numberOfItems() ?? 0) > 0 {
                dataSource?.removeAllItems()
            }
            dataSource?.appendItems(cachedResponse.data)
        }
    }
    
    // it will show empty view
    func emptyGroupView() {
        let items = Int(self.dataSource?.numberOfItems() ?? 0)
        if items == 0 {
            if dataSource?.emptyView != nil {
                dataSource?.emptyView = nil
            }
            defaultGroupSearchEmptyView?.setupView(text: "No search found")
            dataSource?.emptyView = defaultGroupSearchEmptyView
        }
    }

    func configureView() {
        dataSource?.cellClass = RecentSearchCell.self
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseTableCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseTableCell)?.layoutIfNeeded()
        }
        dataSource?.rowAnimation = .none
        dataSource?.tableView = tableView
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        callSearchRequest()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // searchResultController?.emptyGroupView()
        navigationController?.popViewController(animated: false)
    }
    
    func dismissSearch() {
        DispatchQueue.main.async {
            self.searchController.searchBar.resignFirstResponder()
        }
    }
    
    func callSearchRequest() {
        //  update the filtered array based on the search text
        let searchText = searchController.searchBar.text
        // strip out all the leading and trailing spaces
        let query = searchText?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if query?.count ?? 0 > 0 {
            if self.query != query || searchResultController?.dataSource?.numberOfItems() == 0 {
                searchResultController?.resetData()
                self.query = query
                searchResultController?.initialSearchRequest(with: query ?? .emptyString)
                DispatchQueue.main.async {
                    self.searchController.searchBar.resignFirstResponder()
                }
                
            }
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .recentSearchData, object: nil)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        getRecentSearch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
}

// MARK: - UITableViewDelegate
extension GlobalSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource?.item(at: indexPath) as? RecentSearchData
        searchController.searchBar.text = item?.searchQuery
        callSearchRequest()
    }
}

extension GlobalSearchViewController: SearchResultDelegate {
    func seeAllTapped(at section: SectionInfo, indexPath: IndexPath?, with query: String) {
        LogClass.debugLog(section)
        let sectionName = section.sectionIdentifier as? String ?? .emptyString
        switch sectionName {
        case SectionIdentifier.PeopleSearch.rawValue :
            let controller = SearchMoreUsersVC.instantiate(fromAppStoryboard: .Kids)
            controller.searchString = query
            controller.screenTitle = "People".localized()
            navigationController?.pushViewController(controller, animated: true)
        case SectionIdentifier.PostSearch.rawValue :
            let controller = SearchPostResultDetailController.instantiate(fromAppStoryboard: .More)
            controller.searchPost = query
            navigationController?.pushViewController(controller, animated: true)
        default:
            let controller = SearchMorePageVC.instantiate(fromAppStoryboard: .Kids)
            controller.isPage = (sectionName == SectionIdentifier.PageSearch.rawValue)
            controller.searchString = query
            controller.screenTitle = (sectionName == SectionIdentifier.PageSearch.rawValue) ? "Pages".localized() : "Groups".localized()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func sectionItemNavigation(with dataSource: SSSectionedDataSource?, indexPath: IndexPath) {
        let identifier = dataSource?.section(at: indexPath.section).sectionIdentifier as? String
        switch identifier {
        case SectionIdentifier.PeopleSearch.rawValue:
            let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            let item = dataSource?.item(at: indexPath) as? SearchUserModel
            controller.otherUserID = item?.user_id ?? .emptyString
            controller.otherUserisFriend = item?.is_my_friend ?? .emptyString
            controller.otherUserSearchObj = item
            controller.isNavPushAllow = true
            navigationController?.pushViewController(controller, animated: true)
        case SectionIdentifier.PageSearch.rawValue:
            let controller = NewPageDetailVC.instantiate(fromAppStoryboard: .Kids)
            controller.groupObj = dataSource?.item(at: indexPath) as? GroupValue
            navigationController?.pushViewController(controller, animated: true)
        case SectionIdentifier.GroupSearch.rawValue:
            let controller = GroupPostController1.instantiate(fromAppStoryboard: .Kids)
            controller.groupObj = dataSource?.item(at: indexPath) as? GroupValue
            navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
    
    // navigate to directly on chat screen
    func connectToMessage(at indexPath: IndexPath, sender: UIButton, searchUser: SearchUserModel?) {
        if let searchUser {
            let controller = ChatViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            controller.conversatonObj = globalSearchVM.setDBChatObj(with: searchUser)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func moveToPostDetail(postObj: FeedData) {
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        feedController.feedObj = postObj
        feedController.feedArray = [postObj]
        feedController.indexPath = IndexPath(row: 0, section: 0)
        feedController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(feedController, animated: true)
    }
    
    func moveToProfileDetai(postObj: FeedData) {
        let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        if let authorId = postObj.authorID {
            let userID = String(authorId)
            if Int(userID) != SharedManager.shared.getUserID() {
                controller.otherUserID = userID
                controller.otherUserisFriend = "1"
            }
        }
        controller.isNavPushAllow = true
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveToHashTag(with value: String) {
        let tagSection = HashTagVC.instantiate(fromAppStoryboard: .Shared)
        tagSection.Hashtags = value
        navigationController?.pushViewController(tagSection, animated: true)
    }
}

// MARK: - UISearchBarDelegate -
extension GlobalSearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // first responder
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // editing
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}

// MARK: - UISearchResultsUpdating -
extension GlobalSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: - UISearchControllerDelegate -
extension GlobalSearchViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.searchTextField.becomeFirstResponder()
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        
    }
}
