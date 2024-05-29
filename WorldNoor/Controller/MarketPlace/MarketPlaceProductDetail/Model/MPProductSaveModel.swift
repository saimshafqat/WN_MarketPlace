//
//  MPProductSaveModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 11/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit


struct MPProductSaveModel: Codable {
    let action: String
    let data: MPProductDataObject
}


struct MPProductDataObject: Codable {
    let item_id: String?
}
