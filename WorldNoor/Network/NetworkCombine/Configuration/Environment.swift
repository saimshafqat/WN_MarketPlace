//
//  Environment.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 28/05/2023.
//

import UIKit

// here we will set env
enum Environment {
    
    case Development
    case Staging
    case QA
    case Production
    
    var env: String {
        switch self {
        case .Development:
            return "testing.worldnoor.com"
        case .Staging:
            // http://devstage.worldnoor.com
            return "staging.worldnoor.com"
        case .QA:
            return "worldnoor.com"
        case .Production:
            return "worldnoor.com"
        }
    }
}

// https://marketplace.worldnoor.com


