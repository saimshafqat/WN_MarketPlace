//
//  UpdateCurrencyResponse.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 26/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

struct UpdateCurrencyResponse: Codable {
    let action: String
    let meta: Meta
    let data: CurrencyData
}

// Define a struct for the 'data' part of the JSON
struct CurrencyData: Codable {
    let id: Int
    let name: String
    let symbol: String
}
