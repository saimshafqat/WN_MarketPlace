//
//  NotificationNoDataView.swift
//  WorldNoor
//
//  Created by Omnia Samy on 08/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NotificationNoDataView: UIView {
    
    @IBOutlet private weak var noNotificationLabel: UILabel!
    
    let nibName = "NotificationNoDataView"
    private var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        
        contentView = self.loadViewFromNib(nibName: nibName)
        // use bounds not frame or it'll be offset
        contentView?.frame = self.bounds
        // Adding custom subview on top of our view
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(contentView)
        setLocalization()
    }
    
    func setLocalization() {
        noNotificationLabel.text = "No New Notifications".localized()
    }
}

extension UIView {
    
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
