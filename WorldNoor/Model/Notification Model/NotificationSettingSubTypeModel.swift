//
//  NotificationSettingSubTypeModel.swift
//  WorldNoor
//
//  Created by Omnia Samy on 19/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class NotificationSettingSubTypeModel : ResponseModel {
    
    var type = ""
    var status = ""
    
    var localizedType = ""
    
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        super.init()
        
        self.type = self.ReturnValueCheck(value: dictionary["type"] as Any)
        self.status = self.ReturnValueCheck(value: dictionary["status"] as Any)
        
        self.localizedType = self.type
        guard let type = NotificationTypes(rawValue: self.type) else { return }
        
        switch type {

        case .groupJoinRequest:
            self.localizedType = "Group Join request".localized()
        case .groupUserJoined:
            self.localizedType = "Group user join".localized()
        case .groupPostCreated:
            self.localizedType = "Post created on group".localized()
        case .groupUserInvited:
            self.localizedType = "Group user Invited".localized()
        case .groupUserJoinedReceiver:
            self.localizedType = "Receiving users request to join group".localized()
        case .userAddGroupModerator:
            self.localizedType = "User added as a group moderator".localized()
        case .pageUserLiked:
            self.localizedType = "Pages liked by user".localized()
        case .pageUserInvited:
            self.localizedType = "Pages user invited".localized()
        case .addedInPageRole:
            self.localizedType = "Add a user in a page role".localized()
        case .newBirthdayNOTIFICATION:
            self.localizedType = "Users birthdays".localized()
        case .postProcessedSuccessfully:
            self.localizedType = "Sharing post successfully".localized()
        case .postSharedSuccessfully:
            self.localizedType = "Shared posts successfully".localized()
        case .postLinkSuccessfully:
            self.localizedType = "Shared links".localized()
        case.postImageSuccessfully:
            self.localizedType = "Shared images".localized()
        case .newReelNOTIFICATION:
            self.localizedType = "New Reels".localized()
        case .newCommentNOTIFICATION:
            self.localizedType = "New comments".localized()
        case .newLikeNOTIFICATION:
            self.localizedType = "Posts and comments reactions".localized()
        case .reelReactionNotification:
            self.localizedType = "Reels reactions".localized()
        case .storyReactionNotification:
            self.localizedType = "Stories Reactions".localized()
        case .userProfileUpdated:
            self.localizedType = "Users profile updates".localized()
        case .memoriesSharedSuccessfully:
            self.localizedType = "Memories".localized()
        case .newStoryNOTIFICATION:
            self.localizedType = "New Stories".localized()
            
        case .newFriendRequest:
            self.localizedType = "New friends Request".localized()
        case .friendRequestAccepted:
            self.localizedType = "Accepted Friends Request".localized()
            
        case .newRelationshipRequest:
            self.localizedType = "".localized()
            
        case .newFamilyMemberRequest:
            self.localizedType = "".localized()
        }
    }
}
