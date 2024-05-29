//
//  ExtensionURLComponent.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 31/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

// handling duplicating query items
extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
