//
//  ProfileFamilyRelationCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 16/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ProfileFamilyRelationCell: RelationBaseCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
