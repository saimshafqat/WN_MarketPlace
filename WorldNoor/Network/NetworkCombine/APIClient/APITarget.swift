//
//  APITarget.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 30/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Foundation
import Combine

class APITarget: APIClient, APIService {
    
    func savedPost(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func GroupFeedRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    
    func getTranslation(endPoint: APIEndPoints) -> AnyPublisher<LanguageTranslateModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func sendFriendReuqest(endPoint: APIEndPoints) -> AnyPublisher<SendFriendRequestModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func cancelFriendReuqest(endPoint: APIEndPoints) -> AnyPublisher<CancelFriendRequestModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func postReactionRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func checkEmailRequest(endPoint: APIEndPoints) -> AnyPublisher<PhoneNoValidationResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func registerNewUserRequest(endPoint: APIEndPoints) -> AnyPublisher<UserRegistrationResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func fcmTokenStoreRequest(endPoint: APIEndPoints) -> AnyPublisher<FCMStoreResponseModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func relationStatusListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func relationStatusSaveRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func relationStatusUpdateRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func deleteRelationStautsRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func familyRelationStatusListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func savefamilyRelationStatusRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func updatefamilyRelationStatusRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func deleteFamilyRelationStausRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func suggestedFriendListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func getUserFriendsRequest(endPoint: APIEndPoints) -> AnyPublisher<UserFriendResponseModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func deleteWebsiteRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func lifeEventCategoriesRequest(endPoint: APIEndPoints) -> AnyPublisher<LifeEventCategoryResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func getCurrenciesRequest(endPoint: APIEndPoints) -> AnyPublisher<CurrencyListResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func updateCurrencyRequest(endPoint: APIEndPoints) -> AnyPublisher<UpdateCurrencyResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    
    func getCategoryLikedPagesRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func deleteLifeEventRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func getSingleLifeEvent(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func createConversationRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func peopleNearByRequest(endPoint: APIEndPoints) -> AnyPublisher<NearBySearchResponseModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func categoryDeleteRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError> {
        return request(endPoint: endPoint)
    }
    func leaveGroupMemberRequest(endPoint: APIEndPoints) -> AnyPublisher<LeaveGroupResponseModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func recentSearchRequest(endPoint: APIEndPoints) -> AnyPublisher<RecentSearchResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func newFeedVideosRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError> {
        return request(endPoint: endPoint)
    }
    
    func updateUserLocationRequest(endPoint: APIEndPoints) -> AnyPublisher<LocationUpdateResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
    func savedUnsavedRequest(endPoint: APIEndPoints) -> AnyPublisher<SavedUnsavedResponse, APIError> {
        return request(endPoint: endPoint)
    }
    
}

