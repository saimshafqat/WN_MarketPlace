//
//  ExtensionURLRequest.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 31/05/2023.
//

import Foundation

extension URLRequest {
    mutating func addHeader(_ headers: Headers) {
        headers.forEach { header, value in
            addValue(value, forHTTPHeaderField: header)
        }
    }
}
