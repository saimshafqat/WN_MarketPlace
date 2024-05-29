//
//  PaginatedViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 22/05/2023.


import UIKit

class PaginatedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: CollectionEmptyView?
    
    // MARK: - Lazy Properties
    var refreshControl: UIRefreshControl?
    
    // MARK: - Properties -
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPullToRefresh()
    }
    
    // MARK: - Methods
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: UIRefreshControl.Event.valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc func refreshData(_ refreshControl: UIRefreshControl) {
        SoundManager.share.playSound()
        // override me
    }
    
    func refreshCompleted() {
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
    }
    
    func shouldSetupRefresh() -> Bool {
        return true
    }
}
