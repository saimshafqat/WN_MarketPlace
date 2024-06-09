//
//  MPProfileAboutMeTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileAboutMeTableViewCell: UITableViewCell {
    static let identifier = "MPProfileAboutMeTableViewCell"

    @IBOutlet weak var aboutMeHeadingLabel: UILabel!
    @IBOutlet weak var houseIconImageView: UIImageView!
    @IBOutlet weak var livesInLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var responsiveLabel: UILabel!
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var joinedLabel: UILabel!
    
    @IBOutlet weak var joinedView: UIView!
    @IBOutlet weak var liveInView: UIView!
    @IBOutlet weak var responseView: UIView!
    
    var joinAtText = "Joined Worldnoor in"
    override func awakeFromNib() {
        super.awakeFromNib()
        showState()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(model:ListingUser?) {
        let aboutMe = model?.aboutMe ?? ""
        let responsive = model?.responsive ?? ""
        let joinAt = model?.createdAt ?? 0
        livesInLabel.text = aboutMe
        responsiveLabel.text = responsive
        joinedLabel.text = "\(joinAtText) \(joinAt)"
        
//        if aboutMe.isEmpty {
//            liveInView.isHidden = true
//        }
//        
//        if responsive.isEmpty {
//            responseView.isHidden = true
//        }
//        if joinAt == 0 {
//            joinedView.isHidden = true
//        }
    }
    
    func showState(){
        liveInView.isHidden = false
        responseView.isHidden = false
        joinedView.isHidden = false
    }
}
