//
//  ConfigureableCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 16/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

// generic Configureable cell
@objc(ConfigableCollectionCell)

public class ConfigableCollectionCell: SSBaseCollectionCell {
    
    func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        // override me
    }
}
