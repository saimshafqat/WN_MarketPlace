//
//  NotificationCenter + Delegates.swift
//  WorldNoor
//
//  Created by Omnia Samy on 25/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

extension NotificationCenterViewController: NotificationCenterDelegate {
    
    func moreTapped(notification: NotificationModel) {
        
        let popUpController = NotificationPopUpViewController()
        
        popUpController.notification = notification
        popUpController.delegate = self
        
        let sheetController = SheetViewController(controller: popUpController,
                                                  sizes: [.fixed(300), .fullScreen])
        
        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        sheetController.extendBackgroundBehindHandle = true
        sheetController.topCornersRadius = 20
        self.present(sheetController, animated: false, completion: nil)
    }
}

extension NotificationCenterViewController: NotificationOptionDelegate {
    
    func removeNotificationTapped(notification: NotificationModel) {
        
        self.viewModel?.newNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.earlierNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.unreadNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        
        tableView.reloadData()
        
        self.viewModel?.removeNotification(notificationID: notification.notificationID,
                                           completion: { [weak self] (msg, success) in
            guard let self = self else { return }
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func turnOffNotificationTapped(notification: NotificationModel) {
        // remove notification from list
        self.viewModel?.newNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.earlierNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.unreadNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        
        tableView.reloadData()
        
        self.viewModel?.turnOffNotification(notificationType: notification.type,
                                            completion: { [weak self] (msg, success) in
            guard let self = self else { return }
            if success {
                
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}

extension NotificationCenterViewController: FriendSuggestionsDelegate {
    
    func addFriendTapped(friendSuggestion: SuggestedFriendModel) {
        
        self.viewModel?.addFriend(friendSuggestion: friendSuggestion,
                                  completion: { [weak self] (msg, success) in
            guard let self = self else { return }
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func cancelFriendRequestTapped(friendSuggestion: SuggestedFriendModel) {
        
        self.viewModel?.cancelFriendRequest(friendSuggestion: friendSuggestion,
                                            completion: {[weak self] (msg, success) in
            guard let self = self else { return }
            if success {
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func removeFriendTapped(friendSuggestion: SuggestedFriendModel) {
        
        self.viewModel?.removeFriendSuggestion(friendSuggestion: friendSuggestion,
                                               completion: {[weak self] (msg, success) in
            guard let self = self else { return }
            if !success {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    func seeAllSuggestionsTapped() {
        let vc = Container.Notification.getFriendsSuggestionsScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationCenterViewController: NotificationRelationShipDelegate {
    
    func relationShipAction(notification: NotificationModel, relationshipAction: String) {
        
        // remove notification from list
        self.viewModel?.newNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.earlierNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        self.viewModel?.unreadNotificationList.removeAll(where: { $0.notificationID == notification.notificationID })
        
        tableView.reloadData()
        
        self.viewModel?.relationShipAction(notification: notification,
                                           relationshipAction: relationshipAction,
                                           completion: { (msg, success) in
            if !success {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}
