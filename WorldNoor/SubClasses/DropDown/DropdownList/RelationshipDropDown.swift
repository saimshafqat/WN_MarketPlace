//
//  RelationshipDropDown.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

public class RelationshipDropDown: DropDown {
    public override func updateDropDownCell(cell: DropDownCell, at index: Int) {
        if let cellConfiguration = cellConfiguration {
            let result = cellConfiguration(index, dataSource[index]) as? RelationshipStatus
            cell.optionLabel.text = result?.status
        } else {
            cell.optionLabel.text = (dataSource[index] as? RelationshipStatus)?.status
        }
    }
}
