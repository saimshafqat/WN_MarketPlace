//
//  PrivacyDropDown.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

public class PrivacyDropDown: DropDown {
    public override func updateDropDownCell(cell: DropDownCell, at index: Int) {
        if let cellConfiguration = cellConfiguration {
            let result = cellConfiguration(index, dataSource[index]) as? String
            cell.optionLabel.text = result
        } else {
            cell.optionLabel.text = (dataSource[index]) as? String
        }
    }
}
