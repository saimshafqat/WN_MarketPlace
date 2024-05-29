//
//  NotificationCenterTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 28/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NotificationCenterTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var notificationBackgroundView: UIView!
    @IBOutlet private weak var notificationImageView: UIImageView!
    @IBOutlet private weak var notificationIconImageView: UIImageView!
    @IBOutlet private weak var notificationContentLabel: UILabel!
    @IBOutlet private weak var notificationDateLabel: UILabel!
    
    private weak var delegate: NotificationCenterDelegate?
    private var notification: NotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(notification: NotificationModel, delegate: NotificationCenterDelegate) {
        
        self.notification = notification
        self.delegate = delegate
        
        // bind data
        if Int(notification.isRead) == 0 { // not read
            notificationBackgroundView.backgroundColor = .notificationUnReadColor
        } else {
            notificationBackgroundView.backgroundColor = .white
        }
        
        let userImage = notification.sender.profileImageThumbnail
        DispatchQueue.main.async {
            self.notificationImageView.loadImageWithPH(urlMain: userImage)
        }
        
        notificationDateLabel.text = notification.notificationFormattedDate
        makeNotificationBody()
        
        // add icons depend on types
        notificationIconImageView.image = UIImage(named: "")
        addNotificationIcon()
    }
    
    @IBAction func moreTapped(_ sender: UIButton) {
        guard let notification = self.notification else { return }
        delegate?.moreTapped(notification: notification)
    }
    
    private func makeNotificationBody() {
        
        let userName = (self.notification?.sender.firstName ?? "") + " " + (self.notification?.sender.lastName ?? "")
        
        let userNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.black]
        
        let notificationText = (self.notification?.text ?? "")
        let strNumber: NSString = notificationText as NSString
        let range = (strNumber).range(of: userName)
        let attribute = NSMutableAttributedString.init(string: notificationText)
        
        attribute.addAttributes(userNameAttributes, range: range)
        notificationContentLabel.attributedText = attribute
    }
    
    private func addNotificationIcon() {
        
        guard let type = NotificationTypes(rawValue: self.notification?.type ?? "") else { return }
        switch type {
            
        case .groupJoinRequest, .groupUserJoined, .groupPostCreated, .groupUserInvited,
                .groupUserJoinedReceiver, .userAddGroupModerator:
            
            notificationIconImageView.image = UIImage(named: "group")
            
        case .pageUserLiked, .pageUserInvited, .addedInPageRole :
            notificationIconImageView.image = UIImage(named: "page")
            
        case .newBirthdayNOTIFICATION:
            notificationIconImageView.image = UIImage(named: "birthday")
            
        case .postProcessedSuccessfully, .postSharedSuccessfully, .postLinkSuccessfully, .postImageSuccessfully:
            notificationIconImageView.image = UIImage(named: "post")
         
        case .newReelNOTIFICATION:
            notificationIconImageView.image = UIImage(named: "reel")
            
        case .newCommentNOTIFICATION:
            notificationIconImageView.image = UIImage(named: "comment_notification")
       
            // show reaction icon
            //like,sad,happy,thanks,love,laugh,cry,angry,excited, smile
            
        case .newLikeNOTIFICATION, .reelReactionNotification, .storyReactionNotification:

            guard let reaction = notification?.reaction else { return }
            if reaction == "like" {
                notificationIconImageView.image = UIImage(named: "like_notificaton")
            } else {
                notificationIconImageView.image = UIImage(named: reaction)
            }
          
        case .userProfileUpdated:
            LogClass.debugLog("dont show icon for this type")
            
        case .memoriesSharedSuccessfully:
            notificationIconImageView.image = UIImage(named: "memory")
            
        case .newStoryNOTIFICATION:
            notificationIconImageView.image = UIImage(named: "story")
            
        case .newFriendRequest, .friendRequestAccepted:
            LogClass.debugLog("for settings only")
            
        case .newRelationshipRequest, .newFamilyMemberRequest:
            LogClass.debugLog("relationship notification is different cell")
        }
    }
}
