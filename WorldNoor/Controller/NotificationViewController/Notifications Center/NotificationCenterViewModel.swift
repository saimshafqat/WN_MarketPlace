//
//  NotificationCenterViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 30/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

typealias BlockWithMessageAndBool = (String?, Bool) -> Void

protocol NotificationCenterViewModelProtocol: AnyObject {
    func getNotificationList(completion: @escaping BlockWithMessageAndBool)
    func markNotificationAsRead(notificationID: String, completion: @escaping BlockWithMessageAndBool)
    func markAllNotificationsAsRead(completion: @escaping BlockWithMessageAndBool)
    func removeNotification(notificationID: String, completion: @escaping BlockWithMessageAndBool)
    func turnOffNotification(notificationType: String, completion: @escaping BlockWithMessageAndBool)
    
    var newNotificationList: [NotificationModel] { set get }
    var earlierNotificationList: [NotificationModel] { set get }
    var suggestedFriendList: [SuggestedFriendModel] { set get }
    var sectionList: [SectionItem] { set get }
    
    // suggestion actions
    func addFriend(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    func cancelFriendRequest(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    func removeFriendSuggestion(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    
    // unread tab
    func getUnreadNotificationList(completion: @escaping BlockWithMessageAndBool)
    var unreadNotificationList: [NotificationModel] { set get }
    
    // apps tab
    func getAppsNotificationList(completion: @escaping BlockWithMessageAndBool)
    var appsNotificationList: [AppsNotificationModel] { set get }
    
    // get reel detais
    func getReelDetails(reelID: String, completion: @escaping BlockWithMessageAndBool)
    var reelData: FeedData? { set get }
    
    // get story details
    func getStoryDetails(storyID: String, completion: @escaping BlockWithMessageAndBool)
    var videoClipArray: [FeedVideoModel] { set get }
    
    // relationship notification
    func relationShipAction(notification: NotificationModel,
                            relationshipAction: String,
                            completion: @escaping BlockWithMessageAndBool)
    
    var currentTabType: TabsType { set get }
    var currentPage: Int { set get }
    var isNextPage: Bool { set get }
    
    // mark notifications list as read
    func markNotificationListRead(completion: @escaping BlockWithMessageAndBool)
}

class NotificationCenterViewModel: NotificationCenterViewModelProtocol {
    
    var currentTabType: TabsType = .All
    
    var newNotificationList: [NotificationModel] = []
    var earlierNotificationList: [NotificationModel] = []
    var suggestedFriendList: [SuggestedFriendModel] = []
    var sectionList: [SectionItem] = []
    
    var unreadNotificationList: [NotificationModel] = []
    var appsNotificationList: [AppsNotificationModel] = []
    
    var reelData: FeedData?
    var videoClipArray: [FeedVideoModel] = []
    
    var currentPage = 1
    var isNextPage = true
    
    init() { }
    
    func getNotificationList(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/get_all",
                          "token": SharedManager.shared.userToken(),
                          "device" : "ios",
                          "page": String(currentPage)]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            switch response {
                
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                LogClass.debugLog("res ===> 1122 33")
                LogClass.debugLog(res)
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    
                } else if let newRes = res as? [String: Any] {
                    
                    if let notificationCategories = newRes["notification_categories"] as? [String : Any] {
                        
                        if let newNotification = notificationCategories["new"] as? [[String : Any]] {
                            for indexNotification in newNotification {
                                self.newNotificationList.append(NotificationModel.init(fromDictionary: indexNotification))
                            }
                        }
                        
                        if let earlierNotification = notificationCategories["earlier"] as? [[String : Any]] {
                            for indexNotification in earlierNotification {
                                self.earlierNotificationList.append(NotificationModel.init(fromDictionary: indexNotification))
                            }
                            
                            if earlierNotification.count == 0 {
                                self.isNextPage = false
                            }
                        }
                    }
                    
                    if let suggestions = newRes["suggested_contacts"] as? [[String : Any]] {
                        for indexNotification in suggestions {
                            self.suggestedFriendList.append(SuggestedFriendModel.init(fromDictionary: indexNotification))
                        }
                        
                        if self.suggestedFriendList.count > 2 {
                            let array = [self.suggestedFriendList[0], self.suggestedFriendList[1]]
                            self.suggestedFriendList = array
                        }
                    }
                    
                    self.createData()
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    func getUnreadNotificationList(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/get-all-unread",
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
                    
                    if let unreaNotification = newRes["other_notifications"] as? [[String : Any]] {
                        for indexNotification in unreaNotification {
                            self.unreadNotificationList.append(NotificationModel.init(fromDictionary: indexNotification))
                        }
                    }
                    self.createData()
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    func getAppsNotificationList(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "Posh-notifications",
                          "token": SharedManager.shared.userToken(),
                          "device" : "ios",
                          "serviceType": "Node"]  //, "page": String(currentPage) not support pagination yet
        
        
        RequestManager.fetchDataPost(Completion: { (response) in
            self.appsNotificationList.removeAll()
            switch response {
                
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                LogClass.debugLog("res ===> 1122")
                LogClass.debugLog(res)
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    completion(Const.networkProblemMessage.localized(), false)
                } else if let newRes = res as? [[String: Any]] {
                    
                    for appNotification in newRes {
                        self.appsNotificationList.append(AppsNotificationModel.init(fromDictionary: appNotification))
                    }
                    self.createData()
                    completion("sucess", true)
                }else {
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    func addFriend(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "user/send_friend_request",
                          "token": SharedManager.shared.userToken(),
                          "user_id" : String(friendSuggestion.friendID)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    if let index = self.suggestedFriendList
                        .firstIndex(where: { $0.friendID == friendSuggestion.friendID }) {
                        self.suggestedFriendList[index].isFriendRequestSent = true
                    }
                    completion("sucess", true)
                }
                
                completion("sucess", true)
                
            }
        }, param: parameters)
    }
    
    func cancelFriendRequest(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "user/cancel_friend_request",
                          "token": SharedManager.shared.userToken(),
                          "user_id": String(friendSuggestion.friendID)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    
                    if let index = self.suggestedFriendList
                        .firstIndex(where: { $0.friendID == friendSuggestion.friendID }) {
                        self.suggestedFriendList[index].isFriendRequestSent = false
                    }
                    completion("sucess", true)
                }
                
                completion("sucess", true)
                
            }
        }, param: parameters)
    }
    
    func removeFriendSuggestion(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/remove-suggestion",
                          "token": SharedManager.shared.userToken(),
                          "remove_id": String(friendSuggestion.friendID)]
        
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
    
    // this api for reset notification counter
    func markNotificationListRead(completion: @escaping BlockWithMessageAndBool) {
        
        let parameters = ["action": "notifications/mark-seen",
                          "token": SharedManager.shared.userToken()]
        
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
    
    func markNotificationAsRead(notificationID: String, completion: @escaping BlockWithMessageAndBool) {
        let parameters = ["action": "notifications/mark-read",
                          "token": SharedManager.shared.userToken(),
                          "notification_id": notificationID]
        
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
    
    func markAllNotificationsAsRead(completion: @escaping BlockWithMessageAndBool) {
        let parameters = ["action": "notifications/mark-all-read",
                          "token": SharedManager.shared.userToken()]
        
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
    
    func removeNotification(notificationID: String, completion: @escaping BlockWithMessageAndBool) {
        let parameters = ["action": "notifications/delete-notification",
                          "token": SharedManager.shared.userToken(),
                          "notification_id": notificationID]
        
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
    
    func turnOffNotification(notificationType: String, completion: @escaping BlockWithMessageAndBool) {
        let parameters = ["action": "notifications/mute-unmute",
                          "token": SharedManager.shared.userToken(),
                          "status": "0",
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
    
    func getReelDetails(reelID: String, completion: @escaping BlockWithMessageAndBool) {
        
        Loader.startLoading()
        let parameters = ["action": "reel",
                          "token": SharedManager.shared.userToken(),
                          "reel_id": reelID]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    
                } else if let newRes = res as? [String: Any] {
                    
                    if let reel = newRes["post"] as? [String : Any] {
                        self.reelData = FeedData(valueDictMain: reel)
                    }
                    completion("sucess", true)
                }
            }
        }, param: parameters)
    }
    
    func getStoryDetails(storyID: String, completion: @escaping BlockWithMessageAndBool) {
        Loader.startLoading()
        let parameters = ["action": "story",
                          "token": SharedManager.shared.userToken(),
                          "story_id": storyID]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                let dict = res as? [String : Any]
                
                let feedVideoModel = FeedVideoModel.init(dict: dict ?? [:], status: "")
                FeedCallBManager.shared.videoClipArray = [feedVideoModel]
                self.videoClipArray = [feedVideoModel]
                if SharedManager.shared.createStory != nil {
                    self.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
                    FeedCallBManager.shared.videoClipArray.insert(SharedManager.shared.createStory!, at: 0)
                    SharedManager.shared.createStory = nil
                }
                
                completion("sucess", true)
            }
        }, param: parameters)
    }
    
    func relationShipAction(notification: NotificationModel,
                            relationshipAction: String,
                            completion: @escaping BlockWithMessageAndBool) {
        
        var parameters = ["action": "relationship_request_action",
                          "token": SharedManager.shared.userToken(),
                          "partnership_id": notification.dataID,
                          "relationship_action": relationshipAction,
                          "type": notification.type]
        
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

extension NotificationCenterViewModel {
    
    private func createData() {
        
        self.sectionList = []
        
        switch self.currentTabType {
        case .All:
            if self.newNotificationList.count != 0  {
                let newSection = SectionItem(title: "New".localized(), haveItems: true, type: .new)
                sectionList.append(newSection)
            }
            
            if self.suggestedFriendList.count != 0 {
                let suggestionsSection = SectionItem(title: "People You May Know".localized(),
                                                     haveItems: suggestedFriendList.count != 0 ? true : false,
                                                     type: .friendSuggestions)
                sectionList.append(suggestionsSection)
            }
            
            if earlierNotificationList.count != 0 {
                let earlierSection = SectionItem(title: "Earlier".localized(), haveItems: true, type: .earlier)
                sectionList.append(earlierSection)
            }
            
        case .unRead:
            if self.unreadNotificationList.count != 0 {
                let unreadSection = SectionItem(title: nil, haveItems: true, type: .unread)
                sectionList.append(unreadSection)
            }
            
        case .apps:
            if self.appsNotificationList.count != 0 {
                let appsSection = SectionItem(title: nil, haveItems: true, type: .apps)
                sectionList.append(appsSection)
            }
        }
    }
}

struct SectionItem {
    var title: String?
    var haveItems: Bool?
    var type: NotificationListSectionTypes?
}

enum NotificationListSectionTypes {
    case new
    case friendSuggestions
    case earlier
    case unread // for unread tab
    case apps // for apps tab
}

enum TabsType {
    case All
    case unRead
    case apps
}
