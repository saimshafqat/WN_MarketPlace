//
//  SessionConfig.swift
//  WorldNoor
//
//  Created by Asher Azeem on 25/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class SessionConfig {
        
    func enableConfig() -> URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        return session
    }

}
