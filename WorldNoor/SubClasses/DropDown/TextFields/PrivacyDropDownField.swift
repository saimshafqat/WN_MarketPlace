//
//  PrivacyDropDownField.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class PrivacyDropDownField: DropDownBase {

    // MARK: - Properties -
    override func updateDropDown() -> DropDown {
        return PrivacyDropDown()
    }
}
