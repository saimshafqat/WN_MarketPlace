//
//  RelationshipDropdownTextField.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 13/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//


import UIKit

class RelationshipDropdownTextField: DropDownBase {
    
    // MARK: - Properties -
    override func updateDropDown() -> DropDown {
        return RelationshipDropDown()
    }
}
