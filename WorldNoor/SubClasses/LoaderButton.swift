//
//  File.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class LoaderButton: UIButton {
    
    var indexPath: IndexPath?
    var customImage: UIImage?
    
    var activityIndicatorView: UIActivityIndicatorView?
    
    // MARK: -
    // MARK: - Button Activity Indicator
    
    /**********
     ********** start button Acticity. **********
     **********/
    
    func startLoading(_ indicatorStyle: UIActivityIndicatorView.Style = .medium,color: UIColor = .white) {
        activityIndicatorView = UIActivityIndicatorView(style: indicatorStyle)
        activityIndicatorView?.color = color
        activityIndicatorView?.frame = CGRect(x: (frame.size.width) - 28, y: ((frame.size.height) / 2) - 10, width: 20, height: 20)
        addSubview(activityIndicatorView!)
        alpha = 0.8
        isUserInteractionEnabled = false
        activityIndicatorView?.startAnimating()
    }
    
    /**********
     ********** stop Button Acticity. **********
     **********/
    
    
    func stopLoading() {
        alpha = 1
        isUserInteractionEnabled = true
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
    }
}
