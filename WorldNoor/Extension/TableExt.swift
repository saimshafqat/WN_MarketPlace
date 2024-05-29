//
//  TableExt.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        header.frame.size.height = header.frame.size.height
        self.tableHeaderView = header
        
    }
    
    func layoutTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = headerView.bounds.size.width
        let temporaryWidthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)

        headerView.addConstraint(temporaryWidthConstraint)

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame

        frame.size.height = height
        headerView.frame = frame

        self.tableHeaderView = headerView

        headerView.removeConstraint(temporaryWidthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        messageLabel.dynamicBodyRegular17()
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    func restore() {
        self.backgroundView = nil
    }
    
    func registerCustomCells(_ identifiers: [String]) {
        for identifier in identifiers {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
}

extension UITableView {
    
    // 7- handle top space of section
    func sectionTopSpace() {
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = .leastNormalMagnitude
        } else {
            tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: .leastNonzeroMagnitude))
        }
    }
}
