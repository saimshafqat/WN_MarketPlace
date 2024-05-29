//
//  NotificationContainer.swift
//  WorldNoor
//
//  Created by Omnia Samy on 04/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class Container {
    
    class Notification {
        
        class func getNotificationCenterScreen() -> NotificationCenterViewController {
            let view = NotificationCenterViewController(viewModel: NotificationCenterViewModel())
            return view
        }
        
        class func getFriendsSuggestionsScreen() -> FriendsSuggestionsViewController {
            let view = FriendsSuggestionsViewController(viewModel: FriendsSuggestionsViewModel())
            return view
        }
        
        class func getFriendsBirthdayScreen() -> FriendsBirthdayViewController {
            let view = FriendsBirthdayViewController(viewModel: FriendsBirthdayViewModel())
            return view
        }
        
        class func getNotificationSettingsScreen() -> NotificationSettingsViewController {
            let view = NotificationSettingsViewController(viewModel: NotificationSettingsViewModel())
            return view
        }
        
        class func getNotificationSettingDetailsScreen(setting: NotificationSettingModel) -> NotificationSettingDetailsViewController {
            let view = NotificationSettingDetailsViewController(viewModel: NotificationSettingDetailsViewModel(notificationSettings: setting))
            return view
        }
    }
}
