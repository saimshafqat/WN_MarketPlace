//
//  InvitationPlatform.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 03/07/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

public enum InvitationPlatform {
    
    case sms
    case whatsapp
    case messanger
    case gmail
    case facebook
    case twitter
    
    //    var textShare = "https://www.worldnoor.com/login?signUpModal=1&referer="
   static var textShare: String {
        return "https://www.worldnoor.com/login?signUpModal=1".encodeURL
    }
    
    // will provide app url string to open app
    public var appInstalledURL: String {
        switch self {
        case .sms:
            return "sms:body=" + InvitationPlatform.textShare
        case .whatsapp:
            return "whatsapp://send?text=\(InvitationPlatform.textShare)"
        case .messanger:
            return "fb-messenger://share?link=\(InvitationPlatform.textShare)"
        case .gmail:
            return ""
        case .facebook:
            return InvitationPlatform.textShare
        case .twitter:
            let tweetText = ""
            return "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(InvitationPlatform.textShare)"
        }
    }
    
    // will provide browser url
    public var appStoreURL: String {
        switch self {
        case .sms:
            return ""
        case .whatsapp:
            return "https://web.whatsapp.com/"
        case .messanger:
            return "https://www.messenger.com/"
        case .gmail:
            return ""
        case .facebook:
            return "https://www.facebook.com/"
        case .twitter:
            return "https://twitter.com/i/flow/login?redirect_after_login=%2f"
        }
    }
        
    public static func openApp(of platform: InvitationPlatform) {
        let appURLStr = platform.appInstalledURL
        guard let url = URL(string: appURLStr) else {return}
        UIApplication.shared.open(url, options: [:]) { success in
            guard !success else  {return}
            // App not installed
            self.browseURLWithAlert(platform)
        }
    }
    
    static func browseURLWithAlert(_ platform: InvitationPlatform) {
        guard let url = URL(string: platform.appStoreURL) else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
