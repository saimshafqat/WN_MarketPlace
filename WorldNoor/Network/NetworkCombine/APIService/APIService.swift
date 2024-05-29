//
//  APIService.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 30/05/2023.
//

import UIKit
import Combine

protocol APIService {
    func savedPost(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    func getTranslation(endPoint: APIEndPoints) -> AnyPublisher<LanguageTranslateModel, APIError>
    func sendFriendReuqest(endPoint: APIEndPoints) -> AnyPublisher<SendFriendRequestModel, APIError>
    func cancelFriendReuqest(endPoint: APIEndPoints) -> AnyPublisher<CancelFriendRequestModel, APIError>
    func postReactionRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    func checkEmailRequest(endPoint: APIEndPoints) -> AnyPublisher<PhoneNoValidationResponse, APIError>
    func registerNewUserRequest(endPoint: APIEndPoints) -> AnyPublisher<UserRegistrationResponse, APIError>
    func fcmTokenStoreRequest(endPoint: APIEndPoints) -> AnyPublisher<FCMStoreResponseModel, APIError>
    func relationStatusListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func relationStatusSaveRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func relationStatusUpdateRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func deleteRelationStautsRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError>
    func familyRelationStatusListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func savefamilyRelationStatusRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func updatefamilyRelationStatusRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func deleteFamilyRelationStausRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError>
    func suggestedFriendListRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipStatusResponse, APIError>
    func getUserFriendsRequest(endPoint: APIEndPoints) -> AnyPublisher<UserFriendResponseModel, APIError>
    func deleteWebsiteRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError>
    func lifeEventCategoriesRequest(endPoint: APIEndPoints) -> AnyPublisher<LifeEventCategoryResponse, APIError>
    func getCurrenciesRequest(endPoint: APIEndPoints) -> AnyPublisher<CurrencyListResponse, APIError>
    func updateCurrencyRequest(endPoint: APIEndPoints) -> AnyPublisher<UpdateCurrencyResponse, APIError>
    func deleteLifeEventRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError>
    func getSingleLifeEvent(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    func getCategoryLikedPagesRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError>
    func createConversationRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError>
    func peopleNearByRequest(endPoint: APIEndPoints) -> AnyPublisher<NearBySearchResponseModel, APIError>
    func categoryDeleteRequest(endPoint: APIEndPoints) -> AnyPublisher<CategoryLikePagesResponse, APIError>
    func leaveGroupMemberRequest(endPoint: APIEndPoints) -> AnyPublisher<LeaveGroupResponseModel, APIError>
    func GroupFeedRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    // func deleteLifeEventRequest(endPoint: APIEndPoints) -> AnyPublisher<RelationshipDeleteResponse, APIError>
    // func getSingleLifeEvent(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    func recentSearchRequest(endPoint: APIEndPoints) -> AnyPublisher<RecentSearchResponse, APIError>
    func newFeedVideosRequest(endPoint: APIEndPoints) -> AnyPublisher<FeedModel, APIError>
    func updateUserLocationRequest(endPoint: APIEndPoints) -> AnyPublisher<LocationUpdateResponse, APIError>
}
