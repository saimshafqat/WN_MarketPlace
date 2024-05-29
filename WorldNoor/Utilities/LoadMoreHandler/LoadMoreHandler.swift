//
//  LoadMoreHandler.swift
//  WorldNoor
//
//  Created by Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Combine

class LoadMoreHandler {
    
    private weak var scrollView: UIScrollView?
    var loadMorePublisher = PassthroughSubject<Int, Never>()
    
    private lazy var loadMoreThreshold: CGFloat = 100.0
    var isLoading = false
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var currentPage = 1
    private var cancellables: Set<AnyCancellable> = []
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        setupLoadMoreObserving()
//        setupActivityIndicator()
    }
    
    private func setupLoadMoreObserving() {
        guard let scrollView = scrollView else { return }
        
        Publishers.CombineLatest3(
            scrollView.publisher(for: \.contentOffset),
            scrollView.publisher(for: \.contentSize),
            scrollView.publisher(for: \.frame)
        )
        .sink { [weak self] (contentOffset, contentSize, frame) in
            guard let self = self, !self.isLoading else { return }
            
            let offsetY = contentOffset.y
            let contentHeight = contentSize.height
            let visibleHeight = frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
            
            if offsetY > contentHeight - visibleHeight + self.loadMoreThreshold {
                if self.canLoadMore() {
                    self.loadMorePublisher.send(self.currentPage)
                }
            }
        }
        .store(in: &cancellables)
    }
        
    func canLoadMore() -> Bool {
        return !isLoading
    }
    
    // Method to be called after successfully loading data
    func dataLoadedSuccessfully() {
        isLoading = false
        currentPage += 1
    }
    
    // Method to reset the state (for refresh, etc.)
    func resetPage() {
        isLoading = false
        currentPage = 1
    }
}
