//
//  NotificationCenter+Navigation.swift
//  WorldNoor
//
//  Created by Omnia Samy on 28/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

extension NotificationCenterViewController {
    
    // depend on notification type
    func handleNotificationNavigation(notification: NotificationModel) {
        
        guard let type = NotificationTypes(rawValue: notification.type) else { return }
        switch type {
            
            // show group icon and open group details
        case .groupJoinRequest, .groupUserJoined, .groupPostCreated, .groupUserInvited,
                .groupUserJoinedReceiver, .userAddGroupModerator:
            self.openGroupDetails(notification: notification)
            
            // show page icon and navigate to page
        case .pageUserLiked, .pageUserInvited, .addedInPageRole :
            self.openPageDetails(notification: notification)
            
            // show birthday icon and navigate to birthday screen
        case .newBirthdayNOTIFICATION:
            self.openBirthdayScreen(notification: notification)
            
            // show post icon and navigate to post details screen
        case .postProcessedSuccessfully, .postSharedSuccessfully, .postLinkSuccessfully, .postImageSuccessfully:
            self.openPostDetailsScreen(notification: notification)
            
            // show reaction icon and naviaget to post details
        case .newLikeNOTIFICATION:
            self.openPostDetailsScreen(notification: notification)
            
        case .userProfileUpdated:
            self.openUserProfileScreen(notification: notification)
            
        case .newCommentNOTIFICATION:
            self.openPostDetailsScreen(notification: notification)
            
        case .memoriesSharedSuccessfully:
            self.openMemorieScreen(notification: notification)
            
        case .reelReactionNotification, .newReelNOTIFICATION:
            self.openReelsScreen(notification: notification)
            
        case .storyReactionNotification, .newStoryNOTIFICATION:
            self.openStoryScreen(notification: notification)
            
        case .newFriendRequest, .friendRequestAccepted:
            LogClass.debugLog("for settings only")
            
        case .newRelationshipRequest, .newFamilyMemberRequest:
            LogClass.debugLog("in case of relationship no action on cell")
        }
    }
    
    private func openGroupDetails(notification: NotificationModel) {
        // open group
        if notification.dataID.isEmpty {
            return
        }
//        let groupViewC = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewGroupDetailVC") as! NewGroupDetailVC
        let groupViewC = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupPostController1") as! GroupPostController1
        let groupValue =  GroupValue()
        groupValue.groupID = notification.dataID
        groupViewC.groupObj = groupValue
        self.navigationController?.pushViewController(groupViewC, animated: true)
    }
    
    private func openPageDetails(notification: NotificationModel) {
        // open page
        if notification.dataID.isEmpty {
            return
        }
        let pageViewC = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "PagePostController") as! PagePostController
        let groupValue =  GroupValue()
        groupValue.groupID = notification.dataID
        pageViewC.groupObj = groupValue
        self.navigationController?.pushViewController(pageViewC, animated: true)
    }
    
    private func openBirthdayScreen(notification: NotificationModel) {
        // open birthday screen
        let vc = Container.Notification.getFriendsBirthdayScreen()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openMemorieScreen(notification: NotificationModel) {
        let memoryVC = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "MemoryVC") as! MemoryVC
        self.navigationController?.pushViewController(memoryVC, animated: true)
    }
    
    private func openPostDetailsScreen(notification: NotificationModel) {
        // open post details
        if notification.dataID.isEmpty {
            return
        }
        
        let feedobj = FeedData(valueDict: [:])
        feedobj.postID = Int(notification.dataID)
        LogClass.debugLog("notification.dataID ===>")
        LogClass.debugLog(notification.dataID)
        LogClass.debugLog(feedobj.postID )
//        let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FeedNewDetailController") as! FeedNewDetailController
//        feedController.feedObj = feedobj
//        feedController.feedArray = [feedobj]
//        feedController.indexPath = IndexPath.init(row: 0, section: 0)
//        UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
//        UIApplication.topViewController()!.present(feedController, animated: true)
        
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        feedController.feedObj = feedobj
        feedController.feedArray = [feedobj]
//        UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
//        UIApplication.topViewController()!.present(feedController, animated: true)
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        UIApplication.topViewController()!.navigationController?.pushViewController(feedController, animated: true)
    }
    
    private func openUserProfileScreen(notification: NotificationModel) {
        // open user profile
        if notification.dataID.isEmpty {
            return
        }
        let profileVC = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let userID = notification.dataID
        if Int(userID) == SharedManager.shared.getUserID() {
        } else {
            profileVC.otherUserID = notification.dataID //userID // 161 wassem user id
            // profileVC.otherUserisFriend = "1"
            profileVC.isNavPushAllow = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    private func openReelsScreen(notification: NotificationModel) {
        // open reels
        if notification.dataID.isEmpty {
            return
        }
        
        if !isNavigateDataRequested {
            self.isNavigateDataRequested = true
        } else { return }
        
        viewModel?.getReelDetails(reelID: notification.dataID, completion: {[weak self] (msg, success) in
            guard let self = self else { return }
            self.isNavigateDataRequested = false
            if success {
                guard let reelData = self.viewModel?.reelData else { return }                
                let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
                controller.items = [reelData]
                controller.currentIndex = 0
                controller.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)

            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
    
    private func openStoryScreen(notification: NotificationModel) {
        // open story
        if notification.dataID.isEmpty {
            return
        }
        
        if !isNavigateDataRequested {
            self.isNavigateDataRequested = true
        } else { return }
        
        viewModel?.getStoryDetails(storyID: notification.dataID, completion: { [weak self] (msg, success) in
            
            guard let self = self else { return }
            self.isNavigateDataRequested = false
            if success {
                let storyPreviewScene = IGStoryPreviewController.init(stories: self.viewModel?.videoClipArray ?? [], handPickedStoryIndex: 0)
                storyPreviewScene.modalPresentationStyle = .fullScreen
                
                let navigationView = UINavigationController.init(rootViewController: storyPreviewScene)
                navigationView.navigationBar.isHidden = true
                self.present(navigationView, animated: true, completion: nil)
                
//                UIApplication.topViewController()!.navigationController?.pushViewController(storyPreviewScene, animated: true)
                
            } else {
                SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: msg ?? .emptyString)
            }
        })
    }
}
