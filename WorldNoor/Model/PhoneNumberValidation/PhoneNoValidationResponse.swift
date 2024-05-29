//
//  ViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

// MARK: - PhoneNumberValidationResponse
struct PhoneNoValidationResponse: Codable {
    let meta: Meta
    let action: String
    let data: PhoneNoValidationData
}

// Define the DataItem struct for the 'data' array
struct PhoneNoValidationData: Codable {
    
}
