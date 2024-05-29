//
//  FireConfiguration.swift
//  WorldNoor
//
//  Created by Raza najam on 5/18/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import Combine

class FireConfiguration: NSObject {
    
    static let shared = FireConfiguration()
    
    // MARK: - Properties -
    var isTokenUploaded = false
    var fcmToken: String = .emptyString
    var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - Methods -
    func callingFirebaseTokenService() {
        let sessionToken = SharedManager.shared.userToken()
        if sessionToken == "" || self.fcmToken == "" {
            return
        }
        let params: [String: String] = [
            "device_type": "ios",
            "fcm_token":self.fcmToken
        ]
        apiService.fcmTokenStoreRequest(endPoint: .fcmTokenStore(params))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully stored fcm token")
                case .failure(_):
                    LogClass.debugLog("Unable to store fcm token.")
                }
            }, receiveValue: { response in
                LogClass.debugLog("FCM Store Token Response ==> \(response)")
                self.isTokenUploaded = true
            })
            .store(in: &subscription)
    }
}
