//
//  NotificationPagerController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class NotificationPagerController: HQPagerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuView.btn1.setTitle("Notifications".localized(), for: .normal)
        self.menuView.btn1.setTitle("Notifications".localized(), for: .selected)
        self.menuView.btn2.setTitle("Friend Requests".localized(), for: .normal)
        let notif =  AppStoryboard.Notification.instance.instantiateViewController(withIdentifier:"NotificationViewController") as! NotificationViewController
        let friendRequest = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier:"FriendNotificationVC") as! FriendNotificationVC
        self.viewControllers = [notif, friendRequest]
        self.menuView.layoutIfNeeded()
        self.title = "Notifications".localized()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
