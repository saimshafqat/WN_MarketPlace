//
//  APIEndPoints.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 16/05/2023.
//

import UIKit

enum APIEndPoints {
    
    // MARK: - Cases
    case savedPost(ParamKeywords)
    case searchPost(ParamKeywords)
    case getTranslationText(ParamKeywords, Int)
    case checkEmail(ParamKeywords)
    case memories(ParamKeywords)
    case feedView(ParamKeywords)
    case profileFeedView(ParamKeywords)
    case newsFeedVideos(ParamKeywords)
    case getReels(ParamKeywords)
    case getSavedReels(ParamKeywords)
    case sendFriendRequest(ParamKeywords)
    case cancelFriendRequest(ParamKeywords)
    case postReaction(ParamKeywords)
    case registerNewUser(ParamKeywords)
    case getImages(ParamKeywords)
    case fcmTokenStore(ParamKeywords)
    case relationStatusList(ParamKeywords)
    case relationStatusSave(ParamKeywords)
    case deleteRelationStauts(ParamKeywords)
    case familyRelationStatusList(ParamKeywords)
    case savefamilyRelationStatus(ParamKeywords)
    case deleteFamilyRelationStaus(ParamKeywords)
    case getSuggestedFriends(ParamKeywords)
    case getUserFriend(ParamKeywords)
    case familyRelationshipStatusUpdate(ParamKeywords)
    case relationshipStatusUpdate(ParamKeywords)
    case profileWebsiteSave(ParamKeywords)
    case profileWebsiteEdit(ParamKeywords)
    case profileWebsiteDelete(ParamKeywords)
    case lifeEventCategory(ParamKeywords)
    case getCurrencyList(ParamKeywords)
    case currencyUpdate(ParamKeywords)
    case getCatergoryLikedPages(ParamKeywords)
    case deleteLifeEvent(ParamKeywords)
    case getSingleLifeEvent(ParamKeywords)
    case createConversation(ParamKeywords)
    case peopleNearByRequest(ParamKeywords)
    case categoryDeleteRequest(ParamKeywords)
    case hiddenFeedPost(ParamKeywords)
    case groupMemberLeave(ParamKeywords)
    case groupFeedAPI(ParamKeywords)
    case recentSearch(ParamKeywords)
    case pageFeedAPI(ParamKeywords)
    case updateUserLocation(ParamKeywords)
    case savedUnsave(ParamKeywords)
    
    // MARK: - Properties
    public var url: URL? {
        var components = URLComponents()
        components.scheme = Const.NetworkKey.https
        components.host = Environment.Production.env
        components.path = route + path
        if params.count > 0 {
            components.setQueryItems(with: params)
        }
        return components.url
    }
    
    var request: URLRequest {
        LogClass.debugLog("Complete URL ==> \(url!)")
        var request = URLRequest(url: url!)
        LogClass.debugLog("Header Keys ==> \(TokenHeader.header)")
        request.addHeader(TokenHeader.header)
        request.httpMethod = httpMethod.type
        return request
    }
    
    // MARK: -
    var route: String {
        return Const.NetworkKey.route
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .savedPost, .memories, .searchPost, .getTranslationText, .getReels, .newsFeedVideos, .feedView, .profileFeedView, .relationStatusList, .familyRelationStatusList, .getUserFriend, .lifeEventCategory, .getCurrencyList, .getCatergoryLikedPages, .getSingleLifeEvent, .peopleNearByRequest, .hiddenFeedPost, .groupFeedAPI, .recentSearch, .pageFeedAPI, .getSavedReels:
            return .get
        case .checkEmail, .sendFriendRequest, .cancelFriendRequest, .postReaction, .registerNewUser, .getImages, .fcmTokenStore, .relationStatusSave, .deleteRelationStauts, .savefamilyRelationStatus, .deleteFamilyRelationStaus, .getSuggestedFriends, .familyRelationshipStatusUpdate, .relationshipStatusUpdate, .profileWebsiteSave, .profileWebsiteEdit, .profileWebsiteDelete, .currencyUpdate, .deleteLifeEvent, .createConversation, .categoryDeleteRequest, .groupMemberLeave, .updateUserLocation, .savedUnsave:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .savedPost:
            return Const.NetworkKey.savedNewFeed
        case .groupFeedAPI:
            return Const.NetworkKey.groupFeedAPI
        case .pageFeedAPI:
            return Const.NetworkKey.pageFeedAPI
        case .memories:
            return Const.NetworkKey.kMemory
        case .feedView:
            return Const.NetworkKey.kFeedView
        case .profileFeedView:
            return Const.NetworkKey.kProfileFeedView
        case .searchPost:
            return Const.NetworkKey.searchPost
        case .getTranslationText(_, let postId):
            return Const.NetworkKey.postTranslation + "\(postId)"
        case .checkEmail:
            return Const.NetworkKey.checkEmail
        case .newsFeedVideos:
            return Const.NetworkKey.newFeedVideos
        case .sendFriendRequest:
            return Const.NetworkKey.sendFriendRequest
        case .cancelFriendRequest:
            return Const.NetworkKey.cancelFriendRequest
        case .postReaction:
            return Const.NetworkKey.postReaction
        case .registerNewUser:
            return Const.NetworkKey.registerNewUser
        case .getImages:
            return Const.NetworkKey.images
        case .fcmTokenStore:
            return Const.NetworkKey.fcmTokenStore
        case .relationStatusList:
            return Const.NetworkKey.relationStatusList
        case .relationStatusSave:
            return Const.NetworkKey.relationStatusSave
        case .deleteRelationStauts:
            return Const.NetworkKey.deleteRelationStauts
        case .familyRelationStatusList:
            return Const.NetworkKey.familyRelationStatusList
        case .savefamilyRelationStatus:
            return Const.NetworkKey.savefamilyRelationStatus
        case .deleteFamilyRelationStaus:
            return Const.NetworkKey.deleteFamilyRelationStaus
        case .getSuggestedFriends:
            return Const.NetworkKey.getSuggestedFriends
        case .getUserFriend:
            return Const.NetworkKey.getUserFriend
        case .familyRelationshipStatusUpdate:
            return Const.NetworkKey.familyRelationshipStatusUpdate
        case .relationshipStatusUpdate:
            return Const.NetworkKey.relationshipStatusUpdate
        case .profileWebsiteEdit:
            return Const.NetworkKey.profileWebsiteEdit
        case .profileWebsiteDelete:
            return Const.NetworkKey.profileWebsiteDelete
        case .profileWebsiteSave:
            return Const.NetworkKey.profileWebsiteSave
        case .lifeEventCategory:
            return Const.NetworkKey.lifeEventCategories
        case .getCurrencyList:
            return Const.NetworkKey.getCurrencyList
        case .currencyUpdate:
            return Const.NetworkKey.currencyUpdate
        case .getCatergoryLikedPages:
            return Const.NetworkKey.getCatergoryLikedPages
        case .deleteLifeEvent:
            return Const.NetworkKey.deleteLifeEvent
        case .getSingleLifeEvent:
            return Const.NetworkKey.getSingleLifeEvent
        case .createConversation:
            return Const.NetworkKey.createConversation
        case .peopleNearByRequest:
            return Const.NetworkKey.searchPeopleNearBy
        case .categoryDeleteRequest:
            return Const.NetworkKey.pageVisibilityRequest
        case .hiddenFeedPost:
            return Const.NetworkKey.hiddenNewsFeed
        case .groupMemberLeave:
            return Const.NetworkKey.groupMemberLeave
        case .recentSearch:
            return Const.NetworkKey.recentSearch
        case .updateUserLocation:
            return Const.NetworkKey.updateUserLocation
        case .getReels:
            return Const.NetworkKey.getReels
        case .getSavedReels:
            return Const.NetworkKey.getSavedReels
        case .savedUnsave:
            return Const.NetworkKey.savedUnsaved
        }
    }
    
    public var params: ParamKeywords {
        var parameters: ParamKeywords = [:]
        switch self {
        case .savedPost(let keyword),
                .getTranslationText(let keyword, _),
                .memories(let keyword),
                .feedView(let keyword),
                .profileFeedView(let keyword),
                .checkEmail(let keyword),
                .newsFeedVideos(let keyword),
                .sendFriendRequest(let keyword),
                .cancelFriendRequest(let keyword),
                .postReaction(let keyword),
                .registerNewUser(let keyword),
                .getImages(let keyword),
                .fcmTokenStore(let keyword),
                .relationStatusList(let keyword),
                .relationStatusSave(let keyword),
                .deleteRelationStauts(let keyword),
                .familyRelationStatusList(let keyword),
                .savefamilyRelationStatus(let keyword),
                .deleteFamilyRelationStaus(let keyword),
                .getSuggestedFriends(let keyword),
                .getUserFriend(let keyword),
                .relationshipStatusUpdate(let keyword),
                .familyRelationshipStatusUpdate(let keyword),
                .profileWebsiteSave(let keyword),
                .profileWebsiteEdit(let keyword),
                .profileWebsiteDelete(let keyword),
                .lifeEventCategory(let keyword),
                .currencyUpdate(let keyword),
                .getCurrencyList(let keyword),
                .getCatergoryLikedPages(let keyword),
                .deleteLifeEvent(let keyword),
                .getSingleLifeEvent(let keyword),
                .createConversation(let keyword),
                .peopleNearByRequest(let keyword),
                .categoryDeleteRequest(let keyword),
                .hiddenFeedPost(let keyword),
                .groupFeedAPI(let keyword),
                .groupMemberLeave(let keyword),
                .searchPost(let keyword),
                .recentSearch(let keyword),
                .pageFeedAPI(let keyword),
                .updateUserLocation(let keyword),
                .getReels(let keyword),
                .getSavedReels(let keyword),
                .savedUnsave(let keyword)
            :
            parameters = keyword
        }
        return parameters
    }
}
