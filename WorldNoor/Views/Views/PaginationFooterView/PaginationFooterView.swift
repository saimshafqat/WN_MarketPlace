//
//  PaginationFooterView.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 29/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

@objc(PaginationFooterView)
class PaginationFooterView: SSBaseCollectionReusableView {
    class func customInit() -> PaginationFooterView? {
        return .loadNib()
    }

    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView? {
        didSet{
            activityIndicatorView?.hidesWhenStopped = true
        }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView?.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView?.stopAnimating()
        }
    }
}

extension UIView {
    public class func loadNib<T: UIView>() -> T? {
        let bundleLoad = Bundle.main.loadNibNamed(String(describing: T.self), owner: self)?.first as? T
        return bundleLoad
    }
}
