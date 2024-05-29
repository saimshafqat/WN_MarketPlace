//
//  FriendsSuggestionsViewModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 08/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

protocol FriendsSuggestionsViewModelProtocol: AnyObject {
    func getFriendsSuggestionsList(completion: @escaping BlockWithMessageAndBool)
    func addFriend(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    func cancelFriendRequest(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    func removeFriendSuggestion(friendSuggestion: SuggestedFriendModel, completion: @escaping BlockWithMessageAndBool)
    var suggestedFriendList: [SuggestedFriendModel] { set get }
}

class FriendsSuggestionsViewModel: FriendsSuggestionsViewModelProtocol {
    
    var suggestedFriendList: [SuggestedFriendModel] = []
    
    init() { }
    
    func getFriendsSuggestionsList(completion: @escaping BlockWithMessageAndBool) {
        let parameters = ["action": "get-suggested-friends",
                          "token": SharedManager.shared.userToken(),
                          "device" : "ios"]
        
        RequestManager.fetchDataGet(Completion: { (response) in
            
            switch response {
                
            case .failure(let error):
                completion(Const.networkProblemMessage.localized(), false)
                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                    
                } else if let newRes = res as? [[String:Any]] {
                    
                    for indexNotification in newRes {
                        self.suggestedFriendList.append(SuggestedFriendModel.init(fromDictionary: indexNotification))
                    }
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
                } else if let _ = res as? [String: Any] {
                    
                    if let index = self.suggestedFriendList
                        .firstIndex(where: { $0.friendID == friendSuggestion.friendID }) {
                        self.suggestedFriendList[index].isFriendRequestSent = true
                    }
                    completion("sucess", true)
                } else if let newRes = res as? String {
                    completion(newRes, false)
                }
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
}
