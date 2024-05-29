//
//  ColorExt.swift
//  WorldNoor
//
//  Created by Raza najam on 9/6/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let darkGreenCust = UIColor(red: 3/255, green: 155/255, blue: 97/255, alpha: 1.0)
    static let progressSliderColor = UIColor(red:131/255, green:177/255, blue:249/255, alpha: 1)
    static let feedBgColor = UIColor(red:224/255, green:224/255, blue:224/255, alpha: 1).cgColor
    static let tabSelectionBG = UIColor(red:25/255, green:103/255, blue:216/255, alpha: 1)
    static let progressBG = UIColor.white
    static let progressInnerBG = UIColor(red:90/255, green:100/255, blue:174/255, alpha: 1)
    static let defaultOuterColor = UIColor.rgb(56, 25, 49)
    static let defaultInnerColor: UIColor = .rgb(234, 46, 111)
    static let defaultPulseFillColor = UIColor.rgb(86, 30, 63)
    static let defaultLightGray = UIColor.rgb(239, 239, 239)
    static let themeBlueColor = UIColor.rgb(21, 78, 207)
    static let themeBlueChatToolBarColor = UIColor.rgb(58, 125, 161)

    static let chatThumbColor = UIColor.rgb(147, 177, 244)
    static let playerBgGray = UIColor.rgb(234, 234, 234)
    static let chatSenderCell = UIColor.rgb(110, 127, 220)
    static let chatReceiverCell = UIColor.rgb(239, 239, 250)
    static let chatSenderCellText = UIColor.white
    static let chatReceiverCellText = UIColor.rgb(71, 78, 115)
    static let pagerColor = UIColor.rgb(20, 40, 40)
    static let SettingBtnBgColor = UIColor.rgb(230, 230, 230)
    static let progressColor = UIColor(red:90/255, green:100/255, blue:174/255, alpha: 1)
    static let progressTrackColor = UIColor(red: 231.0/255.0, green: 242.0/255.0, blue: 237.0/255.0, alpha: 0.6)
    static let vLightGrayColor = UIColor(red: 235.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 0.6)


    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    
    static let frozenColor = UIColor.rgb(241, 247, 255)
    static let primaryColor = UIColor.rgb(18, 127, 165)
    static let textFieldBorderColor = UIColor.rgb(227, 227, 227)
    static let sectionSeparatorColor = UIColor.rgb(240, 240, 240)
}
