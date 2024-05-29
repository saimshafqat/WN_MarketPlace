//
//  ProfileCompleteGenderCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 23/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProfileCompleteGenderCell: UICollectionViewCell {

    weak var delegate: ProfileWizardDelegate?
    
    var parentView : FeedViewCollectionModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func selectGenderTapped(_ sender: Any) {
        
        
        
        
        let genderController = GenderPopUP.instantiate(fromAppStoryboard: .Registeration)
        genderController.delegate = self
//        reportController.feedsDelegate = self
//        reportController.reportType = "Post"
//            strognSelf.openBottomSheet(reportController, sheetSize: [.fixed(350)])
        UIApplication.topViewController()!.openBottomSheet(genderController, sheetSize: [.fullScreen])
        
        
    }
    
    @IBAction func skipTapped(_ sender: Any) {    
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        
    }
    
}

extension ProfileCompleteGenderCell : ProfileWizardDelegate {
    func closeTapped(isSkipped: Bool) {
        self.delegate?.closeTapped(isSkipped: false)
    }
}
