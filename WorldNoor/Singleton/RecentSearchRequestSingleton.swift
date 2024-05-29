//
//  RecentSearchRequestSingleton.swift
//  WorldNoor
//
//  Created by Asher Azeem on 30/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import Combine

class CachedRecentSearchResponse: NSObject, Codable {
    
    let response: RecentSearchResponse
    
    init(response: RecentSearchResponse) {
        self.response = response
    }
    
}

class RecentSearchRequestUtility {
    
    private var apiService: APIService? = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    static let shared = RecentSearchRequestUtility()
    
    // NSCache for storing responses
    private let cache = NSCache<NSString, CachedRecentSearchResponse>()
    
    // File path for caching
    private let cacheFilePath: URL
    
    private init() {
        // Initialize cache file path
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheFilePath = cacheDirectory.appendingPathComponent("recentSearchResponseCache")
        LogClass.debugLog("Recent Search URL ==> \(self.cacheFilePath)")
        // Load cached data from disk during initialization
        if let cachedData = try? Data(contentsOf: cacheFilePath),
           let cachedResponse = try? JSONDecoder().decode(CachedRecentSearchResponse.self, from: cachedData) {
            cache.setObject(cachedResponse, forKey: "recentSearchResponse" as NSString)
        }
    }
    
    func getRecentSearchResponseFromCache() -> RecentSearchResponse? {
        // Check if response is cached
        if let cachedResponse = cache.object(forKey: "recentSearchResponse" as NSString)?.response {
            return cachedResponse
        }
        
        // If not cached, check if cached data exists on disk
        if let cachedData = try? Data(contentsOf: cacheFilePath),
           let cachedResponse = try? JSONDecoder().decode(CachedRecentSearchResponse.self, from: cachedData).response {
            // Cache the response in memory
            cache.setObject(CachedRecentSearchResponse(response: cachedResponse), forKey: "recentSearchResponse" as NSString)
            return cachedResponse
        }
        return nil
    }
    
    func recentUserCallRequest() {
        let params = ["token": SharedManager.shared.userToken()]
        apiService?.recentSearchRequest(endPoint: .recentSearch(params))
            .sink(receiveCompletion: { completion in
                // Handle completion
                switch completion {
                case .finished:
                    LogClass.debugLog("Recent search finished")
                case .failure(let errorType):
                    LogClass.debugLog("Recent search error \(errorType)")
                }
            }, receiveValue: { response in
                // Cache the response in memory
                let cachedResponse = CachedRecentSearchResponse(response: response)
                self.cache.setObject(cachedResponse, forKey: "recentSearchResponse" as NSString)
                
                // Save cached response to disk
                if let jsonData = try? JSONEncoder().encode(cachedResponse) {
                    try? jsonData.write(to: self.cacheFilePath)
                }
                NotificationCenter.default.post(name: .recentSearchData, object: response)
            })
            .store(in: &subscription)
    }
    
    func clearFromCache() {
        // Remove from cache
        cache.removeObject(forKey: "recentSearchResponse")
        // Remove from disk
        do {
            try FileManager.default.removeItem(at: self.cacheFilePath)
        } catch let error {
            LogClass.debugLog(error.localizedDescription)
        }
    }
}



