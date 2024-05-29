//
//  ExtensionNotificationName.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let reactionCountUpdated = Notification.Name("reactions_count_updated")
    static let SavedPost = Notification.Name("SavedPost")
    static let landscape = Notification.Name("LandscapeTap")
    static let postDeleted = Notification.Name(rawValue: "post_deleted")
    static let updateNewsFeedOnReactionChange = Notification.Name(rawValue: "updateNewsFeedOnReactionChange")
    static let removeNewsFeedReactionObserver = Notification.Name(rawValue: "removeNewsFeedReactionObserver")
    static let notificationRecieved = Notification.Name(rawValue: "notification")
    static let enterBackground = UIApplication.didEnterBackgroundNotification
}
