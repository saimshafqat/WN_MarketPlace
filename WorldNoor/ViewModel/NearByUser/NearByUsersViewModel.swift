//
//  NearByUsersViewModel.swift
//  WorldNoor
//
//  Created by Asher Azeem on 30/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Combine

class NearByUsersViewModel {
    
    // MARK: - Properties
    var locationHandler: LocationHandler?
    private var apiService = APITarget()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - Closure -
    var locationUpdatedCompletion: ((String, String) -> Void)? = nil
    var locationAuthorizationCompletion: (() -> Void)? = nil
    var sendFriendRequestSuccessCompletion: ((_ index: Int) -> Void)? = nil
    var cancelFriendRequestSuccessCompletion: ((_ index: Int) -> Void)? = nil
    
    // MARK: - Methods -
    func setupLocation() {
        locationHandler = LocationHandler()
        locationHandler?.delegate = self
        locationHandler?.checkLocationAuthorization()
    }
    
    func screenTitle()  -> String {
        "People Nearby".localized()
    }
    
    func cellInfos() -> [String] {
        return ["NearUserCell", "NearUserRangeCell"]
    }
    
    func showError() {
        Loader.stopLoading()
        apiService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: message)
            }.store(in: &subscription)
    }
    
    func sendFriendRequest(_ endPoint: APIEndPoints, sender : Int) {
        Loader.startLoading()
        apiService.sendFriendReuqest(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                case .failure(let error):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
                }
            }, receiveValue: { request in
                Loader.stopLoading()
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: request.meta.message ?? .emptyString)
                self.sendFriendRequestSuccessCompletion?(sender)
            })
            .store(in: &subscription)
    }
    
    func cancelFriendRequest(_ endPoint: APIEndPoints, sender : Int) {
        Loader.startLoading()
        apiService.cancelFriendReuqest(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                case .failure(let error):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
                }
            }, receiveValue: { request in
                Loader.stopLoading()
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: request.meta.message ?? .emptyString)
                self.cancelFriendRequestSuccessCompletion?(sender)
            })
            .store(in: &subscription)
    }
    
    func getUserRequest(_ endPoint: APIEndPoints, completion: @escaping (NearBySearchResponseModel) -> Void) {
        Loader.startLoading()
        apiService.peopleNearByRequest(endPoint: endPoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Loader.stopLoading()
                case .failure(let error):
                    Loader.stopLoading()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)
                }
            }, receiveValue: { request in
                Loader.stopLoading()
                completion(request)
            })
            .store(in: &subscription)
    }
    
    func createConversationRequest(nearUserModel: NearByUserModel, completion: @escaping (ChatViewController) -> Void) {
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let ObjUser = nearUserModel
        let memberID:[String] = ["\(ObjUser.userId)"]
        let parameters:NSDictionary = ["action": "conversation/create", "token":userToken, "serviceType":"Node", "conversation_type":"single", "member_ids": memberID]
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                Loader.stopLoading()
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    if res is NSDictionary {
                        let dict = res as! NSDictionary
                        let conversationID = dict["conversation_id"] as? String ?? .emptyString
                        let contactGroup = ChatViewController.instantiate(fromAppStoryboard: .PostStoryboard)
                        contactGroup.conversatonObj = self.createChatObject(user: ObjUser, conversationID: conversationID)
                        completion(contactGroup)
                    }
                }
            }
        }, param:parameters as! [String : Any])
    }
    
    func createChatObject(user: NearByUserModel, conversationID: String?) -> Chat {
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let objModel = Chat(context: moc)
        objModel.profile_image = user.profileImage
        objModel.member_id = "\(user.userId)"
        objModel.name = user.username
        objModel.latest_conversation_id = conversationID ?? .emptyString
        objModel.conversation_id = conversationID ?? .emptyString
        objModel.conversation_type = "single"
        return objModel
    }
    
    func profileData(obj: NearByUserModel) -> ProfileViewController {
        let newDict = [String : Any]()
        let userModel = SearchUserModel(fromDictionary: newDict)
        userModel.already_sent_friend_req = "\(obj.alreadySentFriendReq)"
        userModel.author_name = obj.authorName
        userModel.city = obj.city
        userModel.country_name = obj.country
        userModel.is_my_friend = "\(obj.isMyFriend)"
        userModel.profile_image = obj.profileImage
        userModel.state_name = ""
        userModel.user_id = "\(obj.userId)"
        userModel.username = obj.authorName
        userModel.conversation_id = ""
        let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        vcProfile.otherUserID = "\(obj.userId)"
        vcProfile.otherUserisFriend = "\(obj.isMyFriend)"
        vcProfile.otherUserSearchObj = userModel
        return vcProfile
    }
    
    func dismissKeyboard(searchBar: UISearchBar?) {
        DispatchQueue.main.async {
            searchBar?.resignFirstResponder()
        }
    }
}

extension NearByUsersViewModel: LocationHandlerDelegate {
    
    func locationUpdated(location: CLLocation) {
        let coordinate = location.coordinate
        let lattitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        locationUpdatedCompletion?(lattitude, longitude)
    }
    
    func locationAuthorizationStatusChanged() {
        locationAuthorizationCompletion?()
    }
}
