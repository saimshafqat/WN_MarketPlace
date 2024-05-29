//
//  GroupSearchCollectionCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

@objc(GroupSearchCollectionCell)
class GroupSearchCollectionCell: SSBaseCollectionCell {
    
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
            let privacyStatus = !obj.privacy ? "Public" : "Private"
            let members = (obj.totalMember == "0" || obj.totalMember == "1") ? obj.totalMember + " " + "member" : obj.totalMember + " " + "members"
            addressLabel.text = privacyStatus + " " + "ᐧ" + " " + members
        }
    }
}
