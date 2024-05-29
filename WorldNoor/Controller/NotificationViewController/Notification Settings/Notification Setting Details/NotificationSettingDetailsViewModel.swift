//
//  NotificationSettingDetailsViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

protocol NotificationSettingDetailsViewModelProtocol: AnyObject {
    
    func turnOffNotification(notificationTurnStatus: Int,
                             notificationType: String,
                             completion: @escaping BlockWithMessageAndBool)
    
    var notificationSettings: NotificationSettingModel? { set get }
}

class NotificationSettingDetailsViewModel: NotificationSettingDetailsViewModelProtocol {
    
    var notificationSettings: NotificationSettingModel?
    
    init(notificationSettings: NotificationSettingModel) {
        self.notificationSettings = notificationSettings
    }
    
    func turnOffNotification(notificationTurnStatus: Int,
                             notificationType: String,
                             completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/mute-unmute",
                          "token": SharedManager.shared.userToken(),
                          "type": notificationType]
        RequestManager.fetchDataPost(Completion: { (response) in
            
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
}
