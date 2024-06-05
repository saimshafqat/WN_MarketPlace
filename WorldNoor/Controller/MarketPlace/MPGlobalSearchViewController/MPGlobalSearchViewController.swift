//
//  MPGlobalSearchViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 10/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol SearchResultDelgate: AnyObject {
    func searchResult(_ text: String)
}

class MPGlobalSearchViewController: ContainerBaseController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    weak var delegate: SearchResultDelgate?
    // MARK: - Lazy Properties -
    // 1- For you
    private lazy var saveSearchController: MPSavedSearchViewController = {
        let saveSearchController = MPSavedSearchViewController.instantiate(fromAppStoryboard: .Marketplace)
        return saveSearchController
    }()
    
    // 2- Categories
    private lazy var categoryListController: MPCategoryListViewController = {
        let categoryListController = MPCategoryListViewController.instantiate(fromAppStoryboard: .Marketplace)
        categoryListController.isFromGlobalSearch = true
        categoryListController.isFromMPDashboardSearch = self.isFromMPDashboardSearch
        categoryListController.mpCategoryListDelegate = self
        return categoryListController
    }()
    // 3- Search Reuslt
    private lazy var searchResultController: MPGlobalSearchResultViewController = {
        let searchResultController = MPGlobalSearchResultViewController.instantiate(fromAppStoryboard: .Marketplace)
        return searchResultController
    }()
    
    // MARK: - Properties -
    var oldSegmentState: Int = 0
    var isFromMPDashboardSearch: Bool = false
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        initializeViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        DispatchQueue.main.async {
            self.searchBar.searchTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // It will initilize child view
    func initializeViewControllers() {
        allViewControllers = [categoryListController, saveSearchController, searchResultController]
        cycle(from: currentChildController, to: allViewControllers[0])
//        changeSegmentControlView(to: 0)
    }
}

// MARK: - UISearchBarDelegate -
extension MPGlobalSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        animateSegmentVisibility()
    }
    
    func animateSegmentVisibility() {
        let searchTextCount = searchBar.text?.count ?? 0
        let isHidden = searchTextCount > 0
        if isHidden {
            oldSegmentState = changeSegment?.selectedSegmentIndex ?? 0
        }
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.changeSegment?.isHidden = isHidden
            self.changeSegmentControlView(to: (isHidden) ? 2 : self.oldSegmentState)
        }
        // Start the animation
//        animator.startAnimation()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true) {[weak self] in
            self?.delegate?.searchResult(searchBar.text ?? "")
        }
    }
}

// MARK: - MPCategoryListDelegate -
extension MPGlobalSearchViewController: MPCategoryListDelegate {
    func startScrolling() {
        DispatchQueue.main.async {
            self.searchBar.searchTextField.resignFirstResponder()
        }
    }
}
