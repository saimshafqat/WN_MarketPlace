//
//  HttpMethods.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 30/05/2023.
//

import UIKit

enum HTTPMethod: String {
    case get
    case put
    case post
    case delete
    var type: String {
        rawValue
    }
}
