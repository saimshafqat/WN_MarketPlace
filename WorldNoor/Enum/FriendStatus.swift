//
//  FriendStatus.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

enum FriendStatus {
    case friendOrMyPost
    case pending
    case defaultStatus

    init(friendStatusString: String) {
        switch friendStatusString {
        case "friend_or_my_post": self = .friendOrMyPost
        case "pending": self = .pending
        default: self = .defaultStatus
        }
    }
}

extension FriendStatus {
    var localizedText: String {
        switch self {
        case .friendOrMyPost: return "Send Message".localized()
        case .pending: return "Cancel Request".localized()
        case .defaultStatus: return "Connect".localized()
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .friendOrMyPost: return UIColor(red: 41/255, green: 47/255, blue: 75/255, alpha: 1.0)
        case .pending: return UIColor.systemRed
        case .defaultStatus: return UIColor(red: 253/255, green: 136/255, blue: 36/255, alpha: 1.0)
        }
    }
}
