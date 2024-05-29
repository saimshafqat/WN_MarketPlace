//
//  SchoolTypeDropDown.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class SchoolTypeDropDown: DropDownBase {

    override func updateCornerRadius() -> CGFloat {
        return 12.0
    }
    
    // MARK: - Properties -
    override func updateDropDown() -> DropDown {
        return PrivacyDropDown()
    }
}
