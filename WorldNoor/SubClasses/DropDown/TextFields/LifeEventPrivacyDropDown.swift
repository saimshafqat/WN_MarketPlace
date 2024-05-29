//
//  LifeEventPrivacyDropDown.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class LifeEventPrivacyDropDown: DropDownBase {

    // MARK: - Properties -
    override func updateCornerRadius() -> CGFloat {
        return 12.0
    }

    override func updateDropDown() -> DropDown {
        return PrivacyDropDown()
    }
}
