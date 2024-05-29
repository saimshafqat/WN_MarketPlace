//
//  APIResponseTimer.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 15/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class APIResponseTimer {
    
    // MARK: - Properties -
    private let startTime: DispatchTime
    
    // MARK: - Initialization -
    public init(startTime: DispatchTime) {
        self.startTime = startTime
    }
    
    // MARK: - Public Methods -
    public func calculateElapsedTime() -> String {
        let endTime = DispatchTime.now()
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let responseTime = Double(nanoTime) / 1_000_000 // Convert to milliseconds
        let minutes = Int(responseTime) / 60000 // 60,000 milliseconds in a minute
        let seconds = (Int(responseTime) % 60000) / 1000 // Convert remainder to seconds
        let milliseconds = Int(responseTime) % 1000 // Remainder in milliseconds
        let formattedResponseTime = String(format: "%d m : %d s : %d ms", minutes, seconds, milliseconds)
        return formattedResponseTime
    }
}
