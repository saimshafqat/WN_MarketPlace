//
//  CurrencyListResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 26/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

struct CurrencyListResponse: Codable {
    let action: String
    let meta: Meta
    let data: [Currency]
}

struct Currency: Codable {
    let id: Int
    let name: String
    let symbol: String
    var isSelected: Bool?
}
