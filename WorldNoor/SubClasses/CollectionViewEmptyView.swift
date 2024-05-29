//
//  CollectionViewEmptyView.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 29/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class CollectionEmptyView: UICollectionView {
    
    private lazy var emptyStateMessage: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.sizeToFit()
        return messageLabel
    }()
    
    public func showEmptyState(with message: String) {
        emptyStateMessage.text = message
        addSubview(emptyStateMessage)
        emptyStateMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyStateMessage.topAnchor.constraint(equalTo: topAnchor, constant: self.frame.size.height / 3.5).isActive = true
        emptyStateMessage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    public func hideEmptyState() {
        emptyStateMessage.removeFromSuperview()
    }
}

class TableEmptyView: UITableView {
    private lazy var emptyStateMessage: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.sizeToFit()
        return messageLabel
    }()
    
    public func showEmptyState(with message: String) {
        emptyStateMessage.text = message
        addSubview(emptyStateMessage)
        emptyStateMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyStateMessage.topAnchor.constraint(equalTo: topAnchor, constant: self.frame.size.height / 3.5).isActive = true
        emptyStateMessage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    public func hideEmptyState() {
        emptyStateMessage.removeFromSuperview()
    }
}
