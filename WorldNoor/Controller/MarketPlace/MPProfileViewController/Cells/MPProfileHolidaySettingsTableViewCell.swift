//
//  MPProfileSettingsInfoTableViewCell.swift
//  WorldNoor
//
//  Created by Imran Baloch on 06/06/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProfileHolidaySettingsTableViewCell: UITableViewCell {
    static let identifier = "MPProfileHolidaySettingsTableViewCell"
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var turnOffDescriptionLbl: UILabel!
    @IBOutlet weak var turnOffBtn: UIButton!
    @IBOutlet weak var disabledInforContainerView: UIView!
    @IBOutlet weak var infoWithIconContainerView: UIView!
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var onHolidayDescription = "This seller has turned on holiday mode and currently won't accept any orders or receive messages."
    var turnOffHolidayModeDescription = "Turn off holiday mode to let people know that you're available"
    
    var descriptiontext2 = "Your Worldnoor profile privacy setttings controlls what people, including Marketplace user, can see on yourWorldnoor profile. Go to Settings"
    var subString = "Go to Settings"
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLbl.text = onHolidayDescription
        turnOffDescriptionLbl.text = turnOffHolidayModeDescription
        resetCell()
//        descriptionLbl.attributedText = descriptiontext.coloredAndClickableAttributedString(substringToColor: subString)
        
        
    }
    
    func resetCell(){
        infoWithIconContainerView.isHidden = true
        disabledInforContainerView.isHidden = true
        turnOffBtn.isHidden = true
    }

    func configrureCell(model: UserSettings?){
       // resetCell()
//        if model?.sellerMode == 1 {
//            turnOffDescriptionLbl.text = turnOffHolidayModeDescription
//        } else {
//            turnOffDescriptionLbl.isHidden = true
//        }
//        
//        if model?.vactionMode == 1 {
//            descriptionLbl.text = onHolidayDescription
//        } else {
//            infoWithIconContainerView.isHidden = false
//            turnOffBtn.isHidden = false
//            imgViewIcon.isHidden = false
//        }
//        if holidayOn == true {
//            descriptionLbl.text = onHolidayDescription
//        } else {
            infoWithIconContainerView.isHidden = false
            turnOffBtn.isHidden = false
//        }
    }
    
}
