//
//  NotificationSettingsViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

protocol NotificationSettingsViewModelProtocol: AnyObject {
    
    func getNotificationSettingsList(completion: @escaping BlockWithMessageAndBool)
    func turnAllNotificationSettings(notificationTurnStatus: Int,
                                     notificationType: String,
                                     completion: @escaping BlockWithMessageAndBool)
    
    var notificationSettingsList: [NotificationSettingModel] { set get }
    var notificationAllTypes: NotificationSettingSubTypeModel { set get }
}

class NotificationSettingsViewModel: NotificationSettingsViewModelProtocol {
    
    var notificationSettingsList: [NotificationSettingModel] = []
    var notificationAllTypes: NotificationSettingSubTypeModel = NotificationSettingSubTypeModel()
    
    init() { }
    
    func getNotificationSettingsList(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/settings",
                          "token": SharedManager.shared.userToken(),
                          "device" : "ios"]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            switch response {
                
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    
                } else if let newRes = res as? [String: Any] {
                    
                    self.notificationSettingsList = []
                    if let settings = newRes["headers"] as? [[String : Any]] {
                        for indexNotification in settings {
                            self.notificationSettingsList.append(NotificationSettingModel.init(fromDictionary: indexNotification))
                        }
                    }
                    
                    if let generalSwitch = newRes["allNotifications"] as? [String : Any] {
                        self.notificationAllTypes = NotificationSettingSubTypeModel.init(fromDictionary: generalSwitch)
                    }
                    
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    func turnAllNotificationSettings(notificationTurnStatus: Int,
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
