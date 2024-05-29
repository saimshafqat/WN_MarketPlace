//
//  MPProductDetailHeaderView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 07/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(MPProductDetailHeaderView)
class MPProductDetailHeaderView: SSBaseCollectionReusableView {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    // MARK: - Methods -
    func configureView(obj: AnyObject?, parentObj: AnyObject? ,indexPath: IndexPath) {
        if let itemSection = obj as? SectionInfo {
            headingLabel.text = itemSection.sectionIdentifier as? String
        }
    }
}
