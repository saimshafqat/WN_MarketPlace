//
//  AppNotificationTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 08/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class AppNotificationTableViewCell: UITableViewCell {

    @IBOutlet private weak var appNotificationBackgroundView: UIView!
    @IBOutlet private weak var appNotificationImageView: UIImageView!
    @IBOutlet private weak var appNotificationTitleLabel: UILabel!
    @IBOutlet private weak var appNotificationMessageLabel: UILabel!

    private var appNotification: AppsNotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(appNotification: AppsNotificationModel) {
        
        self.appNotification = appNotification

        if appNotification.app.lowercased().range(of: "kalamtime") != nil  {
            self.appNotificationImageView.image = UIImage.init(named: "KalamTimeFeed.png")!
        }else  if appNotification.app.lowercased().range(of: "mizdah") != nil  {
            self.appNotificationImageView.image = UIImage.init(named: "MizdahFeed.png")!
        }else  if appNotification.app.lowercased().range(of: "werfie") != nil  {
            self.appNotificationImageView.image = UIImage.init(named: "WerfieFeed.png")!
        }else  if appNotification.app.lowercased().range(of: "seezitt") != nil  {
            self.appNotificationImageView.image = UIImage.init(named: "SeezittFeed.png")!
        }
        
        
        appNotificationTitleLabel.text = appNotification.title
    }
}
