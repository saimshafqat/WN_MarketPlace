//
//  GoogleSiginManager.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/07/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import GoogleSignIn
import Combine

class GoogleSignInManager {
    
    // MARK: - Properties -
    
    // MARK: - Methods -
    
    /// 1 - Sign In
    public static func signIn(controller: UIViewController?, successCompletion: @escaping (GIDSignInResult?) -> Void, errorCompletion: @escaping (Error) -> Void) {
        guard let controller else {
            return
        }
        let additionalScope: [String] = [
            "https://www.googleapis.com/auth/contacts",
            "https://www.googleapis.com/auth/contacts.other.readonly",
            "https://www.googleapis.com/auth/contacts.readonly"
        ]
         
        GIDSignIn.sharedInstance.signIn(withPresenting: controller, hint: nil, additionalScopes: additionalScope) { signInResult, error in
            if let error = error {
                errorCompletion(error)
            } else if signInResult?.user != nil {
                successCompletion(signInResult)
            }
        }
    }
    
    /// 2- Sign Out
    public static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    /// 3- Restore Previous SignIn
    public static func restorePreviousSignIn() {
        let config = GIDConfiguration(clientID: "753663186569-p33rf0orjjm1v9bv4ek0da8294nosbnv.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                LogClass.debugLog(error.localizedDescription)
            } else if user != nil {
                LogClass.debugLog(user?.profile?.name ?? .emptyString)
            } else {
                // user signout
            }
        }
    }
    
    /// 4- Handle URL
    public static func handle(url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}
