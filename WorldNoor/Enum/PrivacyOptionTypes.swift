//
//  PrivacyOptionTypes.swift
//  WorldNoor
//
//  Created by Niks on 5/7/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

enum PrivacyOptionTypes: CaseIterable {
    
    case _public
    case _contacts
    case _onlyme
    case _everyone
    case _friendsoffriends
    
    var defaultValue: String {
        switch self {
        case ._public:
            return "Public".localized()
        case ._contacts:
            return "Contacts".localized()
        case ._onlyme:
            return "Only Me".localized()
        case ._everyone:
            return "Everyone".localized()
        case ._friendsoffriends:
            return "Friends of Friends".localized()
        }
    }
    
    var image: UIImage? {
        
        switch self {
       
        case ._public:
            return UIImage.privacyLogo1
        case ._contacts:
            return UIImage.privacyLogo2
        case ._onlyme:
            return UIImage.privacyLogo3
        case ._everyone:
            return UIImage.privacyLogo2
        case ._friendsoffriends:
            return UIImage.privacyLogo4
        }
    }
    
    var desc: String {
        
        switch self {
       
        case ._public:
            return "Anyone on or off Worldnoor"
        case ._contacts:
            return "Your contacts on Worldnoor"
        case ._onlyme:
            return "Only me"
        case ._everyone:
            return "Everyone on or off Worldnoor"
        case ._friendsoffriends:
            return "Friends of Friends on Worldnoor"
        }
    }
}

