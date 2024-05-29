//
//  EditProfileLifeEventCategoryLayout.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

final class EditProfileLifeEventCategoryLayout : LayoutBaseHelper {
    
    func createLayout() -> UICollectionViewLayout {
        let section = desireCellDivision(with: .estimated(120), cellCount: 3)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}
