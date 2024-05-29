//
//  APIError.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 28/05/2023.
//

import UIKit

enum APIError: Error {
    case unknown
    case unreachable
    case failedRequest
    case invalidResponse
    case unAuthorized
    case notFound
    case errorMessage(String)
}
