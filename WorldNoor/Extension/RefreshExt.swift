//
//  RefreshExt.swift
//  WorldNoor
//
//  Created by Raza najam on 11/30/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
    }
}
