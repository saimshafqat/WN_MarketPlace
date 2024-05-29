//
//  Notification Types.swift
//  WorldNoor
//
//  Created by Omnia Samy on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

enum NotificationTypes: String {
    
    // -----------group-------show group icon navigate to group
    case groupJoinRequest = "group-join_request"
    case groupUserJoined = "group-user_joined"
    case groupPostCreated = "group-post_created"
    case groupUserInvited = "group-user_invited"
    case groupUserJoinedReceiver = "group-user_joined_receiver"
    case userAddGroupModerator = "user_add_group_moderator"
    
    // -----------page--------show page icon navigate to page
    case pageUserLiked = "page-user_liked"
    case pageUserInvited = "page-user_invited"
    case addedInPageRole = "added_in_page_role"
        
    // ----------birthday-------show birthday icon navigate to birthday screen
    case newBirthdayNOTIFICATION = "new_birthday_NOTIFICATION"
  
    // ----------post-----------show post icon navigate to post details
    case postProcessedSuccessfully = "post-processed_successfully"
    case postSharedSuccessfully = "post-shared_successfully"
    case postLinkSuccessfully = "post-link_successfully"
    case postImageSuccessfully = "post-image_successfully"
    
    // -----------user profile---------dont show icon and naviagte user profile
    case userProfileUpdated = "user_profile-updated"
    
    // ----------post--------show reaction icon and naviaget to post details
    case newLikeNOTIFICATION = "new_like_NOTIFICATION"
    
    // ----------post-----------show comment icon navigate to post details
    case newCommentNOTIFICATION = "new_comment_NOTIFICATION"
    
    // ---------memories--------- show and navigate to memories
    case memoriesSharedSuccessfully = "memories-shared_successfully"
    
    //----------reels types-------show reaction icon and naigate to reel
    case reelReactionNotification = "reel_reaction_notification"
    case newReelNOTIFICATION = "new_reel_NOTIFICATION"
    
    //----------story types-------show reaction icon and naigate to
    case storyReactionNotification = "story_reaction_notification"
    case newStoryNOTIFICATION = "new_story_NOTIFICATION"
    
    //--------RelationShip Types ---------------
    case newRelationshipRequest = "new_relationship_request"
    case newFamilyMemberRequest = "new_family_member_request"
    
    // for settings only
    // contact
    case newFriendRequest = "new_friend_request"
    case friendRequestAccepted = "friend_request_accepted"
}
