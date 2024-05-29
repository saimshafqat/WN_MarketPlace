//
//  RefreshControlHandler.swift
//  WorldNoor
//
//  Created by Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

class RefreshControlHandler {
    
    // MARK: - Properties -
    private weak var scrollView: UIScrollView?
    var refreshPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Lazy Properties -
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor().hexStringToUIColor(hex: "#127FA5")
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()
    
    // MARK: - Init -
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        setupRefreshControl()
    }
    
    // MARK: - Methods -
    private func setupRefreshControl() {
        guard let scrollView else { return }
        scrollView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        SoundManager.share.playSound()
        refreshPublisher.send()
    }
    
    func beginRefreshing() {
        refreshControl.beginRefreshing()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}
