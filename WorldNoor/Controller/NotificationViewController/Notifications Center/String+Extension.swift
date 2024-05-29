//
//  String+Extension.swift
//  WorldNoor
//
//  Created by Omnia Samy on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func width (font: UIFont, height: Double) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        return NSString(string: self).boundingRect( with: size,
                                                    options: .usesLineFragmentOrigin,
                                                    attributes: [.font: font], context: nil).size.width
    }
}

extension String {
    
    func convertDateToBirthdayFormate(formatteType: DateFormatteType) -> String {
        
        let dateString = self
        
        let dateFormatter = DateFormatter()  // "dob": "1999-01-01",
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myDate = dateFormatter.date(from: dateString) ?? Date()
        
        dateFormatter.dateFormat = formatteType.rawValue
        return dateFormatter.string(from: myDate)
    }
    
    func convertStringToDate() -> Date {
        
        let dateString = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //"2023-08-10 09:33:48"
        return dateFormatter.date(from: dateString) ?? Date()
    }
}

enum DateFormatteType: String {
    case dayMonthNumber = "EEEE, MMMM d"
    case monthNumber = "MMMM d"
}
// LLLL return month name
