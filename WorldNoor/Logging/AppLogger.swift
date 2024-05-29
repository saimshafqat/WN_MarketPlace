//
//  AppLogger.swift
//  WorldNoor
//
//  Created by Asher Azeem on 15/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import OSLog

// Define an enum for different log tags
enum LogTag {
    case error
    case warning
    case success
    case debug
    case network
    case simOnly
    
    // Provide a label for each log tag
    var label: String {
        switch self {
        case .error   : return "[APP ERROR 🔴]"
        case .warning : return "[APP WARNING 🟠]"
        case .success : return "[APP SUCCESS 🟢]"
        case .debug   : return "[APP DEBUG 🔵]"
        case .network : return "[APP NETWORK 🌍]"
        case .simOnly : return "[APP SIMULATOR ONLY 🤖]"
        }
    }
}

// Define a struct for logging
struct AppLogger {
    static func log(tag: LogTag = .debug, _ items: Any...,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    separator: String = " ") {
        
        #if DEBUG
        // Check if iOS version is 14.0 or later
        if #available(iOS 14.0, *) {
            // Extract short file name from file path
            let shortFileName = URL(string: file)?.lastPathComponent ?? "---"
            
            // Join the items into a single string
            let output = items.map {
                if let itm = $0 as? CustomStringConvertible {
                    return "\(itm.description)"
                } else {
                    return "\($0)"
                }
            }.joined(separator: separator)
            
            // Construct the log message with tag, output, and category
            var msg = "\(tag.label) "
            let category = "\(shortFileName) - \(function) - line \(line)"
            if !output.isEmpty { msg += "\n\(output)" }
            
            // Initialize logger with subsystem and category
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)
            
            // Log message based on tag
            switch tag {
            case .error   : logger.error("\(msg)")
            case .warning : logger.warning("\(msg)")
            case .success : logger.info("\(msg)")
            case .debug   : logger.debug("\(msg)")
            case .network : logger.info("\(msg)")
            case .simOnly : logger.info("\(msg)")
            }
        } else {
            // Logging is not supported on iOS versions prior to 14.0
            print("Logging is supported only on iOS 14.0 or later.")
        }
        #endif
    }
}


// MARK: - Example
// AppLogger.log(tag: .debug, "This is a debug message")
// AppLogger.log(tag: .error, "An error occurred!")
