//
//  PageSearchCollectionCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(PageSearchCollectionCell)
class PageSearchCollectionCell: SSBaseCollectionCell {
    
    @IBOutlet weak var searchImageView: UIImageView?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? GroupValue {
            searchImageView?.loadImage(urlMain: obj.groupImage)
            headingLabel.text = obj.groupName
            descriptionLabel.isHidden = obj.groupDesc.isEmpty
            descriptionLabel.text = obj.groupDesc
            let pageCategory = obj.categories.first
            let currentReview = obj.totalReviews == "0" ? .emptyString : obj.totalReviews == "1" ? "(\(obj.totalReviews) review)" : "(\(obj.totalReviews) reviews)"
            let currentRatingReview = obj.totalReviews == "0" ? .emptyString : "ᐧ" + " " + obj.reviewRating
            let members = (obj.totalFollow == "0" || obj.totalFollow == "1") ? obj.totalFollow + " " + "follower".localized() : obj.totalFollow + " " + "followers".localized()
            addressLabel.text = (pageCategory ?? .emptyString) + " " + currentRatingReview + currentReview + " " + "ᐧ" + " " + members
        }
    }
    
}
