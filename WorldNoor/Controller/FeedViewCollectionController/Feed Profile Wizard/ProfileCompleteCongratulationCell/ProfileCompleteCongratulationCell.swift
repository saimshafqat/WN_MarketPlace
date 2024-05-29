//
//  ProfileCompleteCongratulationCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 23/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProfileCompleteCongratulationCell: UICollectionViewCell {


    weak var delegate: ProfileWizardDelegate?
    
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
}
