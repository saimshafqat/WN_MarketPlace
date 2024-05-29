//
//  EditProfileSubCategoryEventCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class EditProfileSubCategoryEventCell: UITableViewCell {

    @IBOutlet weak var subCategoryNameLabel: UILabel?

    // MARK: - Configure View -
    func configureView(item: Any, indexPath: IndexPath) {
        if let obj = item as? LifeEventSubCategoryModel {
            subCategoryNameLabel?.text = obj.name
        }
    }
}
