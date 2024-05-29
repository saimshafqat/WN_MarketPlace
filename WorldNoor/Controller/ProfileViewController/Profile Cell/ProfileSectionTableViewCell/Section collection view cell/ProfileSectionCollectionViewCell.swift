//
//  ProfileSectionCollectionViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 13/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ProfileSectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.labelRotateCell(viewMain: sectionTitleLabel)
    }

    func bind(sectionItem: ProfileSection, selectedTab: ProfileSection) {
        
        sectionTitleLabel.text = (sectionItem.rawValue).localized()
        if sectionItem == selectedTab {
            sectionTitleLabel.textColor = .systemBlue
        } else {
            sectionTitleLabel.textColor = .gray
        }
    }
}
