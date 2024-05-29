//
//  RelationShipNotificationTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 20/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class RelationShipNotificationTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var notificationBackgroundView: UIView!
    @IBOutlet private weak var notificationImageView: UIImageView!
    @IBOutlet private weak var notificationIconImageView: UIImageView!
    @IBOutlet private weak var notificationContentLabel: UILabel!
    
    private weak var delegate: NotificationRelationShipDelegate?
    private var notification: NotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func declineTapped(_ sender: UIButton) {
        guard let notification = self.notification else { return }
        delegate?.relationShipAction(notification: notification, relationshipAction: "decline")
    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        guard let notification = self.notification else { return }
        delegate?.relationShipAction(notification: notification, relationshipAction: "accept")
    }
    
    @IBAction func moreTapped(_ sender: UIButton) {
        guard let notification = self.notification else { return }
        delegate?.moreTapped(notification: notification)
    }
    
    func bind(notification: NotificationModel, delegate: NotificationRelationShipDelegate) {
        
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
        
        makeNotificationBody()
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
}
